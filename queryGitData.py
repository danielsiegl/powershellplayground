from openai import OpenAI
import time
import keyring

print("Starting OpenAI API client...")
apiKey=keyring.get_password("https://github.com/danielsiegl/powershellplayground","API_TOKEN")
client = OpenAI(api_key=apiKey)

# Upload the file
file_json = client.files.create(
    file=open("git_repo_data.json", "rb"),  # <— any .json file ≤ 512 MB
    purpose="assistants"
)

# Attach the file to an assistant that has the code_interpreter tool
assistant = client.beta.assistants.create(
    model="gpt-4o",
    tools=[{"type": "code_interpreter"}],
    instructions="Analyse the JSON and answer questions about it.",
    tool_resources={
        "code_interpreter": {"file_ids": [file_json.id]}
    }
)

assistant_id = assistant.id      # the Assistant created earlier

# Create (or reuse) a thread and seed it with the user’s question
thread = client.beta.threads.create(
    messages=[{
        "role": "user",
        "content": "How many commits were made in the last month?"
      
    }]
)

# Kick off a run of that assistant on the thread
run = client.beta.threads.runs.create(
    thread_id    = thread.id,
    assistant_id = assistant_id,
)

# Poll until the run finishes (or use create_and_poll / streaming helpers)
while run.status not in ("completed", "failed", "cancelled", "expired"):
    time.sleep(1)                              # ~1 s is fine for most use cases
    run = client.beta.threads.runs.retrieve(   # refresh status
        run_id   = run.id,
        thread_id= thread.id
    )

# Read the assistant’s reply
msgs = client.beta.threads.messages.list(thread_id=thread.id)
assistant_msg = next(m for m in msgs.data if m.role == "assistant")
print(assistant_msg.content[0].text.value)
