#!/usr/bin/env python3

import os
import glob
import argparse
from Bio import SeqIO
import itertools

def parse_args():
    parser = argparse.ArgumentParser(description="Calculate Jaccard similarity between use-case MSAs and original family FASTAs.")
    parser.add_argument("--use_case_dir", required=True, help="Folder containing use-case MSA files (.aln or .fasta).")
    parser.add_argument("--original_base_dir", required=True, help="Base folder containing original family FASTA files (organized by db_layer).")
    parser.add_argument("--output_file", required=True, help="Output TSV file for the similarity results.")
    parser.add_argument("--similarity_threshold", type=float, default=0.5, help="Similarity threshold to filter matches (default: 0.5).")
    return parser.parse_args()

def extract_protein_ids(fasta_path):
    """Extracts set of protein IDs (splitting on '/') from a FASTA file."""
    ids = set()
    with open(fasta_path) as handle:
        for record in SeqIO.parse(handle, "fasta"):
            base_id = record.id.split('/')[0]
            ids.add(base_id)
    return ids

def jaccard_similarity(set1, set2):
    """Computes the Jaccard similarity index."""
    intersection = set1 & set2
    union = set1 | set2
    return len(intersection) / len(union) if union else 0.0

def main():
    args = parse_args()

    use_case_dir = args.use_case_dir
    original_base_dir = args.original_base_dir
    output_file = args.output_file
    similarity_threshold = args.similarity_threshold

    db_layers = ["pfam", "panther", "ncbifam", "hamap"]
    
    # Build a list of all original family FASTA files
    original_files = []
    for db_layer in db_layers:
        folder = os.path.join(original_base_dir, db_layer)
        fasta_files = glob.glob(os.path.join(folder, "*.fasta"))
        for f in fasta_files:
            original_files.append((f, db_layer))  # Tuple of path + db_layer name

    with open(output_file, "w") as out_f:
        out_f.write("use_case_basename\toriginal_basename\tsimilarity_score\tuse_case_layer\tdb_layer\n")

        use_case_files = itertools.chain(
            glob.glob(os.path.join(use_case_dir, "*.aln")),
            glob.glob(os.path.join(use_case_dir, "*.fasta"))
        )

        counter = 0
        # Iterate over use-case FASTA files
        for use_case_fasta in use_case_files:
            counter += 1
            print(counter)
            use_case_basename = os.path.splitext(os.path.basename(use_case_fasta))[0]
            use_case_ids = extract_protein_ids(use_case_fasta)

            for original_fasta, db_layer in original_files:

                original_basename = os.path.splitext(os.path.basename(original_fasta))[0]
                original_ids = extract_protein_ids(original_fasta)

                similarity = jaccard_similarity(use_case_ids, original_ids)
                if similarity >= similarity_threshold and original_basename != use_case_basename:
                    out_f.write(f"{use_case_basename}\t{original_basename}\t{similarity:.3f}\tuse_case\t{db_layer}\n")

if __name__ == "__main__":
    main()
