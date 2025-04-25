process CALCULATE_SEQUENCE_STATS {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/eb/eb3700531c7ec639f59f084ab64c05e881d654dcf829db163539f2f0b095e09d/data' :
        'community.wave.seqera.io/library/biopython:1.84--3318633dad0031e7' }"

    input:
    path alignments
    path db_fasta
    path decoys
    val type

    output:
    path "${type}_decoy_counts.txt"     , emit: decoy_count
    path "${type}_original_counts.txt"  , emit: original_count
    path "${type}_summary.txt"          , emit: summary
    path "${type}_unknown_sequences.txt", emit: unknown
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    calculate_sequence_stats.py \\
        --original_fasta ${db_fasta} \\
        --decoy_fasta ${decoys} \\
        --alignment_folder ${alignments} \\
        --alignment_type ${type}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
    END_VERSIONS
    """
}
