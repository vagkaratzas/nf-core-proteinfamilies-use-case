include { CALCULATE_SEQUENCE_STATS       } from '../modules/local/calculate_sequence_stats/main'
include { CALCULATE_DB_SEQUENCE_COVERAGE } from '../modules/local/calculate_db_sequence_coverage/main'
include { ANALYZE_RECRUITED_DECOYS       } from '../modules/local/analyze_recruited_decoys/main'
include { CALCULATE_JACCARD_SIMILARITY   } from '../modules/local/calculate_jaccard_similarity/main'
include { CALCULATE_DB_FAMILY_COVERAGE   } from '../modules/local/calculate_db_family_coverage/main'
include { GET_SIZE_DISTRIBUTIONS         } from '../modules/local/get_size_distributions/main'

workflow POST {
    take:
    alignments
    db_fasta
    decoys
    sampled_metadata
    sampled_fasta_folder
    jaccard_similarity_threshold

    main:
    ch_aln      = Channel.fromPath(alignments, checkIfExists: true)
    ch_db_fasta = Channel.fromPath(db_fasta  , checkIfExists: true)
    ch_decoys   = Channel.fromPath(decoys    , checkIfExists: true)

    CALCULATE_SEQUENCE_STATS( ch_aln, ch_db_fasta, ch_decoys, 'aln' )

    ch_metadata     = Channel.fromPath(sampled_metadata, checkIfExists: true)
    ch_fasta_folder = Channel.fromPath(sampled_fasta_folder, checkIfExists: true)
    CALCULATE_DB_SEQUENCE_COVERAGE( ch_metadata, CALCULATE_SEQUENCE_STATS.out.original_count, ch_fasta_folder )

    ANALYZE_RECRUITED_DECOYS( ch_aln, ch_decoys )

    CALCULATE_JACCARD_SIMILARITY( ch_aln, ch_fasta_folder, jaccard_similarity_threshold )

    CALCULATE_DB_FAMILY_COVERAGE( CALCULATE_JACCARD_SIMILARITY.out.edgelist, ch_fasta_folder )

    GET_SIZE_DISTRIBUTIONS ( ch_metadata, CALCULATE_JACCARD_SIMILARITY.out.edgelist )
}
