#!/usr/bin/env python3

import argparse
import csv
import os
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Process sampled metadata and resolve MSA file paths.")
    parser.add_argument("--metadata_file", help="Path to the sampled_metadata.tsv file")
    parser.add_argument("--hamap", required=True, help="Path to HAMAP alignment folder")
    parser.add_argument("--ncbifam", required=True, help="Path to NCBIfam alignment folder")
    parser.add_argument("--panther", required=True, help="Path to Panther alignment folder")
    parser.add_argument("--pfam", required=True, help="Path to Pfam alignment folder")
    return parser.parse_args()


def get_db_path(db, paths):
    db = db.lower()
    if db == "hamap":
        return paths["hamap"]
    elif db == "ncbifam":
        return paths["ncbifam"]
    elif db == "panther":
        return paths["panther"]
    elif db == "pfam":
        return paths["pfam"]
    else:
        return None


def main():
    args = parse_args()

    db_paths = {
        "hamap": args.hamap,
        "ncbifam": args.ncbifam,
        "panther": args.panther,
        "pfam": args.pfam,
    }

    with open(args.metadata_file, newline='') as tsvfile:
        reader = csv.DictReader(tsvfile, delimiter=",")
        for row in reader:
            db = row["db"]
            dbkey = row["dbkey"]
            base_path = get_db_path(db, db_paths)

            if base_path is None:
                print(f"Unknown DB type '{db}' for IPR {row['interpro_id']}")
                continue

            file_path = Path(base_path) / f"{dbkey}.fasta"
            if file_path.exists():
                print(f"[FOUND] {file_path}")
            else:
                print(f"[NOT FOUND] {file_path}")

if __name__ == "__main__":
    main()
