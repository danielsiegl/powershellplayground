"""
Erzeugt eine 2-seitige A4-PDF-Karte des Peloponnes inkl. Athen & Delphi
aus OSM-Daten (Bounding Box 20.116,36.320,25.225).

Nötig: Python ≥3.9, pip install osmnx geopandas matplotlib shapely fiona
"""
import os
import matplotlib.pyplot as plt
import osmnx as ox
ox.settings.overpass_endpoint = "https://overpass.osm.ch/api/interpreter"
import geopandas as gpd
from matplotlib.backends.backend_pdf import PdfPages
from shapely.geometry import box
import time
import pandas as pd

# 1. Bounding-Box & Download in Chunks mit Retry-Loop
bbox = (36.320, 20.116, 38.827, 25.225)  # south, west, north, east
n_lat, w_lon, s_lat, e_lon = bbox
n_chunks = 15  # number of chunks per axis (finer grid for smaller requests)

lat_steps = [n_lat + (s_lat - n_lat) * i / n_chunks for i in range(n_chunks + 1)]
lon_steps = [w_lon + (e_lon - w_lon) * i / n_chunks for i in range(n_chunks + 1)]

all_edges = []
max_retries = 5
base_timeout = 60

for i in range(n_chunks):
    for j in range(n_chunks):
        chunk_bbox = (
            lat_steps[i], lon_steps[j], lat_steps[i+1], lon_steps[j+1]
        )
        for attempt in range(1, max_retries + 1):
            try:
                print(f"Lade Chunk {i+1},{j+1} … (Versuch {attempt}, Timeout {base_timeout}s)")
                G_chunk = ox.graph_from_bbox(*chunk_bbox, network_type="drive", timeout=base_timeout)
                edges_chunk = ox.graph_to_gdfs(G_chunk, nodes=False, edges=True)
                all_edges.append(edges_chunk)
                break
            except Exception as e:
                print(f"Fehler beim Laden Chunk {i+1},{j+1} (Versuch {attempt}): {e}")
                if attempt == max_retries:
                    raise
                base_timeout += 60
                time.sleep(5)

# 2. Umwandeln in GeoDataFrames (Mergen aller Chunks)
edges = gpd.GeoDataFrame(pd.concat(all_edges, ignore_index=True))

# 3. PDF-Setup: 2 A4-Seiten quer (landscape)
a4 = (11.69, 8.27)  # inch (ISO 216)
pdf_path = "peloponnese_map.pdf"
with PdfPages(pdf_path) as pdf:
    # Seite 1: Gesamtübersicht
    fig, ax = plt.subplots(figsize=a4)
    edges.plot(ax=ax, linewidth=0.2, color="black")
    ax.set_axis_off()
    ax.set_title("Peloponnes, Athen & Delphi – Übersicht", pad=12)
    pdf.savefig(fig, bbox_inches="tight")
    plt.close(fig)

    # Seite 2: Detailfenster (Peloponnes)
    # -> Fenster kleiner schneiden
    pelop_bbox = box(36.3, 21.8, 38.0, 24.2)
    pelop_edges = edges[edges.intersects(pelop_bbox)]
    fig, ax = plt.subplots(figsize=a4)
    pelop_edges.plot(ax=ax, linewidth=0.25, color="black")
    ax.set_xlim(pelop_bbox.bounds[0], pelop_bbox.bounds[2])
    ax.set_ylim(pelop_bbox.bounds[1], pelop_bbox.bounds[3])
    ax.set_axis_off()
    ax.set_title("Detail: Peloponnes", pad=12)
    pdf.savefig(fig, bbox_inches="tight")
    plt.close(fig)

print(f"✓ Fertig: {pdf_path}")
