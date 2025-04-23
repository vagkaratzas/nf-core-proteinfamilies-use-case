#!/usr/bin/env python3

import argparse
import csv
import os
from pathlib import Path
from Bio import SeqIO, AlignIO
from Bio.SeqRecord import SeqRecord


def parse_args():
    parser = argparse.ArgumentParser(description="Process sampled metadata and resolve MSA file paths.")
    parser.add_argument("--metadata_file", help="Path to the sampled_metadata.tsv file")
    parser.add_argument("--hamap", required=True, help="Path to HAMAP alignment folder")
    parser.add_argument("--ncbifam", required=True, help="Path to NCBIfam alignment folder")
    parser.add_argument("--panther", required=True, help="Path to Panther alignment folder")
    parser.add_argument("--pfam", required=True, help="Path to Pfam alignment folder")
    parser.add_argument("--output_folder", required=True, help="Path to store converted FASTA files")
    return parser.parse_args()


def get_db_path(db, paths):
    return paths.get(db.lower())


def find_matching_file(folder: Path, dbkey: str):
    for file in folder.iterdir():
        if file.is_file() and file.name.split(".")[0] == dbkey:
            return file
    return None


def detect_format(file_path: Path) -> str:
    with open(file_path, 'r') as f:
        first_line = f.readline().strip()
        if first_line.startswith('>'):
            return 'fasta'
        elif first_line.startswith('# STOCKHOLM'):
            return 'stockholm'
        else:
            return 'unknown'


def clean_sequence(seq: str) -> str:
    return ''.join([aa for aa in seq if aa.isupper()])


def convert_to_fasta(input_file: Path, fmt: str, output_file: Path):
    records = []
    if fmt == 'fasta':
        for record in SeqIO.parse(input_file, "fasta"):
            clean_seq = clean_sequence(str(record.seq))
            records.append(SeqRecord(seq=clean_seq, id=record.id, description=""))
    elif fmt == 'stockholm':
        for record in AlignIO.read(input_file, "stockholm"):
            clean_seq = clean_sequence(str(record.seq))
            records.append(SeqRecord(seq=clean_seq, id=record.id, description=""))

    if records:
        output_file.parent.mkdir(parents=True, exist_ok=True)
        with open(output_file, 'w') as out_f:
            SeqIO.write(records, out_f, "fasta")


def main():
    args = parse_args()

    db_paths = {
        "hamap": Path(args.hamap),
        "ncbifam": Path(args.ncbifam),
        "panther": Path(args.panther),
        "pfam": Path(args.pfam),
    }

    output_base = Path(args.output_folder)

    with open(args.metadata_file, newline='') as tsvfile:
        reader = csv.DictReader(tsvfile, delimiter=",")
        for row in reader:
            db = row["db"].lower()
            dbkey = row["dbkey"]
            base_path = get_db_path(db, db_paths)

            if base_path is None:
                print(f"[SKIPPED] Unknown DB type '{db}' for IPR {row['interpro_id']}")
                continue

            matching_file = find_matching_file(base_path, dbkey)
            if not matching_file:
                print(f"[NOT FOUND] {dbkey} in {base_path}")
                continue

            fmt = detect_format(matching_file)
            if fmt == 'unknown':
                print(f"[SKIPPED] Unknown format for file {matching_file}")
                continue

            output_file = output_base / db / f"{dbkey}.fasta"
            try:
                convert_to_fasta(matching_file, fmt, output_file)
                print(f"[OK] Converted {dbkey} from {fmt.upper()} to {output_file}")
            except Exception as e:
                print(f"[ERROR] Failed to convert {matching_file}: {e}")


if __name__ == "__main__":
    main()
