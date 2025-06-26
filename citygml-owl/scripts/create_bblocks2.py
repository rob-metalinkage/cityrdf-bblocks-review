import os
import json
import glob
import shutil
import argparse
import fnmatch
import yaml
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
        imports = list(g.objects(subject=s, predicate=OWL.imports))

        return {
            "uri": str(s),
            "title": str(title) if title else "",
            "abstract": str(abstract) if abstract else "",
            "version": str(version) if version else "",
            "ontology": os.path.basename(file_path),
            "imports": [str(i) for i in imports]
        }
    return None

def load_template(template_path):
    try:
        with open(template_path, "r", encoding="utf-8") as f:
            return Template(f.read())
    except Exception as e:
        raise RuntimeError(f"Error reading template file '{template_path}': {e}")

def load_config(config_path):
    if os.path.exists(config_path):
        with open(config_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    return {}

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

def build_ontology_index(file_paths):
    index = {}
    for file_path in file_paths:
        g = Graph()
        g.parse(file_path, format="turtle")
        for s in g.subjects(RDF.type, OWL.Ontology):
            index[str(s)] = os.path.basename(file_path)
    return index

def remove_extension(filename):
    return os.path.splitext(filename)[0]

def apply_excludes(files, exclude_patterns):
    if not exclude_patterns:
        return files
    excluded = set()
    for pattern in exclude_patterns:
        excluded.update(set(fnmatch.filter([os.path.basename(f) for f in files], pattern)))
    return [f for f in files if os.path.basename(f) not in excluded]

def main():
    parser = argparse.ArgumentParser(description="Generate bblock.json files from TTL Ontologies.")
    parser.add_argument("glob_pattern", help="Glob pattern to find TTL files (e.g., 'data/*.ttl')")
    parser.add_argument("--outdir", default="_sources", help="Base output directory (default: _sources)")
    parser.add_argument("--template", default="bblock-template.json", help="Path to Jinja2 JSON template (default: bblock-template.json)")
    parser.add_argument("--config", default="bblocks-config.yaml", help="Path to YAML config file with identifier-prefix (default: bblocks-config.yaml)")
    parser.add_argument("--exclude", nargs="*", default=[], help="List of glob patterns to exclude (e.g., '*-test.ttl')")
    args = parser.parse_args()

    config = load_config(args.config)
    raw_prefix = config.get("identifier-prefix", "")
    prefix = raw_prefix.rstrip(".") + "." if raw_prefix else ""

    try:
        template = load_template(args.template)
    except RuntimeError as e:
        print(e)
        return

    # Collect and filter TTL files
    all_ttl_files = glob.glob(args.glob_pattern)
    if not all_ttl_files:
        print("No TTL files found.")
        return

    ttl_files = apply_excludes(all_ttl_files, args.exclude)
    if not ttl_files:
        print("No TTL files left after exclusions.")
        return

    # Build index only from included files
    ontology_index = build_ontology_index(ttl_files)

    for file_path in ttl_files:
        info = extract_ontology_info(file_path)
        if info:
            # Match only imports that are in the index (i.e., not excluded)
            depends_on = []
            for uri in info.get("imports", []):
                if uri in ontology_index:
                    imported_filename = remove_extension(ontology_index[uri])
                    depends_on.append(f"{prefix}{imported_filename}")

            info["dependsOn"] = depends_on

            # Clean internal fields
            del info["uri"]
            del info["imports"]

            base_name = remove_extension(os.path.basename(file_path))
            target_dir = os.path.join(args.outdir, base_name)
            write_bblock_json(target_dir, info, template)
            copy_source_file(file_path, target_dir)
            print(f"Created: {os.path.join(target_dir, 'bblock.json')} with dependsOn: {depends_on}")
        else:
            print(f"Warning: No owl:Ontology found in {file_path}")

if __name__ == "__main__":
    main()
