import os
import json
import glob
import shutil
import argparse
from rdflib import Graph, Namespace, RDF, RDFS, OWL
from jinja2 import Template

# Namespaces
SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")

def extract_ontology_info(file_path):
    g = Graph()
    g.parse(file_path, format="turtle")

    for s in g.subjects(RDF.type, OWL.Ontology):
        title = g.value(subject=s, predicate=RDFS.label)
        abstract = g.value(subject=s, predicate=SKOS.definition)
        version = g.value(subject=s, predicate=OWL.versionInfo)

        return {
            "title": str(title) if title else "",
            "abstract": str(abstract) if abstract else "",
            "version": str(version) if version else "",
            "ontology": os.path.basename(file_path)
        }
    return None

def load_template(template_path):
    try:
        with open(template_path, "r", encoding="utf-8") as f:
            return Template(f.read())
    except Exception as e:
        raise RuntimeError(f"Error reading template file '{template_path}': {e}")

def write_bblock_json(output_dir, info, template):
    os.makedirs(output_dir, exist_ok=True)
    json_content = template.render(**info)
    json_path = os.path.join(output_dir, "bblock.json")
    with open(json_path, "w", encoding="utf-8") as f:
        f.write(json_content)

def copy_source_file(source_path, output_dir):
    try:
        shutil.copy2(source_path, output_dir)
    except Exception as e:
        print(f"Warning: Failed to copy {source_path} to {output_dir}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Generate OGC Building blocks from TTL Ontologies.")
    parser.add_argument("glob_pattern", help="Glob pattern to find TTL files (e.g., 'data/*.ttl')")
    parser.add_argument("--outdir", default="_sources", help="Base output directory (default: _sources)")
    parser.add_argument("--template", default="bblock-template.json", help="Path to Jinja2 JSON template (default: bblock-template.json)")
    args = parser.parse_args()

    try:
        template = load_template(args.template)
    except RuntimeError as e:
        print(e)
        return

    ttl_files = glob.glob(args.glob_pattern)
    if not ttl_files:
        print("No TTL files found.")
        return

    for file_path in ttl_files:
        info = extract_ontology_info(file_path)
        if info:
            base_name = os.path.splitext(os.path.basename(file_path))[0]
            target_dir = os.path.join(args.outdir, base_name)
            write_bblock_json(target_dir, info, template)
            copy_source_file(file_path, target_dir)
            print(f"Created: {os.path.join(target_dir, 'bblock.json')} and copied TTL file.")
        else:
            print(f"Warning: No owl:Ontology found in {file_path}")

if __name__ == "__main__":
    main()
