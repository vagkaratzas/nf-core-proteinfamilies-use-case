#!/usr/bin/env python3

import argparse
import csv
from pathlib import Path
from Bio import SeqIO

def parse_args():
    parser = argparse.ArgumentParser(description="Count decoy sequences in MSAs and output stats.")
    parser.add_argument("--msa_folder", required=True, help="Folder containing MSA files (FASTA format).")
    parser.add_argument("--decoy_fasta", required=True, help="FASTA file containing decoy sequences.")
    parser.add_argument("--output_csv", required=True, help="Output CSV filename.")
    return parser.parse_args()

def read_decoy_ids(decoy_fasta):
    decoy_ids = set()
    for record in SeqIO.parse(decoy_fasta, "fasta"):
        decoy_ids.add(record.id)
    return decoy_ids

def process_msa_file(msa_path, decoy_ids):
    total_sequences = 0
    decoy_sequences = 0
    for record in SeqIO.parse(msa_path, "fasta"):
        total_sequences += 1
        cleaned_name = record.id.split("/", 1)[0]
        if cleaned_name in decoy_ids:
            decoy_sequences += 1
    percentage = (decoy_sequences / total_sequences * 100) if total_sequences > 0 else 0
    return {
        "family": msa_path.stem,
        "decoy_count": decoy_sequences,
        "total_sequences": total_sequences,
        "decoy_percentage": percentage
    }

def main():
    args = parse_args()
    msa_folder = Path(args.msa_folder)
    decoy_ids = read_decoy_ids(args.decoy_fasta)

    results = []
    for msa_file in msa_folder.glob("*"):
        if msa_file.is_file():
            stats = process_msa_file(msa_file, decoy_ids)
            results.append(stats)

    # Sort by descending decoy percentage
    results.sort(key=lambda x: x["decoy_percentage"], reverse=True)

    # Write output CSV
    with open(args.output_csv, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=["family", "decoy_count", "total_sequences", "decoy_percentage"])
        writer.writeheader()
        for row in results:
            writer.writerow(row)

if __name__ == "__main__":
    main()
