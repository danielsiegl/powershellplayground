"""
Erzeugt eine 2-seitige A4-PDF-Karte des Peloponnes inkl. Athen & Delphi
aus OSM-Daten (Bounding Box 20.116,36.320,25.225).

Nötig: Python ≥3.9, pip install osmnx geopandas matplotlib shapely fiona
"""
import os
import matplotlib.pyplot as plt
import osmnx as ox
import networkx as nx
import subprocess
import shutil
from matplotlib.backends.backend_pdf import PdfPages
from shapely.geometry import box

# Ensure osmconvert is available, download if not
osmconvert_path = r"C:\Users\danie\Downloads\osmconvert64-0.8.8p.exe"
if not os.path.exists(osmconvert_path):
    raise FileNotFoundError(f"osmconvert not found at {osmconvert_path}. Please download it manually from https://wiki.openstreetmap.org/wiki/Osmconvert#Download.")

# Clip the PBF file to the bounding box using osmconvert
osm_pbf_path = r"C:\Users\danie\Downloads\greece-latest.osm.pbf"
osm_clip_path = os.path.join(os.getcwd(), "peloponnese.osm.pbf")
bbox_str = "20.116,36.320,25.225,38.827"
if not os.path.exists(osm_clip_path):
    print("Schneide PBF-Datei auf Bounding Box …")
    subprocess.run([
        osmconvert_path,
        osm_pbf_path,
        f"-b={bbox_str}",
        f"-o={osm_clip_path}"
    ], check=True)

# Convert to OSM XML for osmnx
osm_xml_path = os.path.join(os.getcwd(), "peloponnese.osm")
if not os.path.exists(osm_xml_path):
    print("Konvertiere PBF zu OSM XML …")
    subprocess.run([
        osmconvert_path,
        osm_clip_path,
        f"-o={osm_xml_path}"
    ], check=True)

print("Lade Graph aus OSM XML …")
G = ox.graph_from_xml(osm_xml_path)
print("Graph geladen. Wandle in GeoDataFrames um …")
edges = ox.graph_to_gdfs(G, nodes=False, edges=True)
print(f"{len(edges)} Kanten geladen.")

# 3. PDF-Setup: 2 A4-Seiten quer (landscape)
a4 = (11.69, 8.27)  # inch (ISO 216)
pdf_path = "peloponnese_map.pdf"
print("Erzeuge PDF …")
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
    print(f"{len(pelop_edges)} Kanten im Detailfenster.")
    fig, ax = plt.subplots(figsize=a4)
    pelop_edges.plot(ax=ax, linewidth=0.25, color="black")
    ax.set_xlim(pelop_bbox.bounds[0], pelop_bbox.bounds[2])
    ax.set_ylim(pelop_bbox.bounds[1], pelop_bbox.bounds[3])
    ax.set_axis_off()
    ax.set_title("Detail: Peloponnes", pad=12)
    pdf.savefig(fig, bbox_inches="tight")
    plt.close(fig)

print(f"✓ Fertig: {pdf_path}")
