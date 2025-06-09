process INVESTIGATE_MATCHED_ORIGINALS {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/eb/eb3700531c7ec639f59f084ab64c05e881d654dcf829db163539f2f0b095e09d/data' :
        'community.wave.seqera.io/library/biopython:1.84--3318633dad0031e7' }"

    input:
    path sampled_fasta
    path clustering
    path metadata
    path generated_fasta

    output:
    path "metadata.csv"    , emit: metadat
    path "all_clusters.txt", emit: clusters
    path "all_matches.txt" , emit: matches
    path "versions.yml"    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    investigate_matched_originals.py \\
        --db_folder ${sampled_fasta} \\
        --cluster_file ${clustering} \\
        --metadata ${metadata} \\
        --generated_fasta ${generated_fasta} \\
        --output metadata.csv \\
        --cluster_log all_clusters.txt \\
        --match_log all_matches.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
    END_VERSIONS
    """
}
