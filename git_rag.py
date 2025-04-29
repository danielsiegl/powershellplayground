#!/usr/bin/env python3
# git_rag.py  ─── Build + query a Git-history RAG index
import argparse, json, os, pathlib, re, sys, textwrap, pickle
from typing import Iterator, List, Dict

import numpy as np
import faiss                          # type: ignore
from tqdm import tqdm                 # progress bars
from openai import OpenAI
import keyring

# ---------- CONFIG -----------------------------------------------------------
EMBED_MODEL = "text-embedding-3-small"      # 1 536-dim
CHAT_MODEL  = "gpt-4o-mini"
INDEX_FILE  = "git.faiss"

print("Starting OpenAI API client...")
apiKey=keyring.get_password("https://github.com/danielsiegl/powershellplayground","API_TOKEN")
client = OpenAI(api_key=apiKey)


# ---------- STEP 1 : read NUL-terminated stream ------------------------------
def stream_commits(path: str) -> Iterator[Dict]:
    raw = pathlib.Path(path).read_bytes()
    for block in raw.split(b"\0"):
        if not block.strip():
            continue
        header, body = block.split(b"\n", 1)
        commit = json.loads(header)
        commit["payload"] = body.decode("utf-8", errors="replace")
        yield commit

# ---------- STEP 2 : chunk on diff hunks -------------------------------------
hunk_re = re.compile(r"^@@.*?@@", flags=re.M)
def chunk_commit(commit: Dict, max_len: int = 4_000) -> Iterator[Dict]:
    parts = hunk_re.split(commit["payload"])
    for i, txt in enumerate(parts):
        txt = txt.strip()
        if not txt:
            continue
        yield {
            "id": f"{commit['commit']}_{i}",
            "commit": commit["commit"],
            "metadata": {
                "author": commit["author"]["name"],
                "date":   commit["date"],
                "subject": commit["subject"],
            },
            "text": txt[:max_len],
        }

# ---------- STEP 3 : embed & STEP 4 : store ----------------------------------
def build_index(repo_stream: str, index_out: str = INDEX_FILE):
    print("📜  Parsing Git stream …")
    docs: List[Dict] = []
    for commit in stream_commits(repo_stream):
        docs.extend(chunk_commit(commit))

    print(f"🔢  Embedding {len(docs):,} chunks …")
    vectors = []
    batch = []
    ids    = []
    for doc in tqdm(docs):
        batch.append(doc["text"])
        ids.append(doc["id"])
        if len(batch) == 1000:
            vectors.extend(client.embeddings.create(
                input=batch, model=EMBED_MODEL).data)
            batch, ids = [], []
    if batch:
        vectors.extend(client.embeddings.create(
            input=batch, model=EMBED_MODEL).data)

    vecs = np.vstack([v.embedding for v in vectors]).astype("float32")
    faiss.normalize_L2(vecs)
    index = faiss.IndexFlatIP(vecs.shape[1])
    index.add(vecs)

    print("💾  Saving index …")
    pickle.dump((index, docs), open(index_out, "wb"))
    print(f"✅  Done. Index saved to {index_out}")

# ---------- QUERY ------------------------------------------------------------
def ask(question: str, k: int = 4, index_path: str = INDEX_FILE):
    if not pathlib.Path(index_path).exists():
        sys.exit("❌  Index not found. Run --build first.")
    index, docs = pickle.load(open(index_path, "rb"))

    qvec = client.embeddings.create(
        input=[question], model=EMBED_MODEL).data[0].embedding
    qvec = np.asarray(qvec, dtype="float32")[None, :]
    faiss.normalize_L2(qvec)
    D, I = index.search(qvec, k)

    context = "\n\n---\n\n".join(
        f"{docs[i]['metadata']['subject']} "
        f"({docs[i]['metadata']['date']})\n{docs[i]['text']}"
        for i in I[0])

    prompt = textwrap.dedent(f"""
        You are an expert code-history assistant. Use the git diff context to answer.
        {context}

        Question: {question}
    """)

    reply = client.chat.completions.create(
        model=CHAT_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2)
    print("\n🗨️  " + reply.choices[0].message.content.strip())

# ---------- CLI --------------------------------------------------------------
if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="Build and query a Git-history RAG index")
    ap.add_argument("--build", metavar="repo.ndjsonz",
                    help="parse & embed the Git stream")
    ap.add_argument("--question", "-q", help="ask a question")
    ap.add_argument("--topk", type=int, default=4, help="how many chunks to use")
    args = ap.parse_args()

    if args.build:
        build_index(args.build)
    if args.question:
        ask(args.question, k=args.topk)
    if not (args.build or args.question):
        ap.print_help()
