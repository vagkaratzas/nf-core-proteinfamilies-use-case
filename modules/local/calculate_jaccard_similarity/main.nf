process CALCULATE_JACCARD_SIMILARITY {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/eb/eb3700531c7ec639f59f084ab64c05e881d654dcf829db163539f2f0b095e09d/data' :
        'community.wave.seqera.io/library/biopython:1.84--3318633dad0031e7' }"

    input:
    path aln_folder
    path original_folder
    val similarity_threshold

    output:
    path "jaccard_similarities.csv", emit: edgelist
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    calculate_jaccard_similarity.py \\
        --use_case_dir ${aln_folder} \\
        --original_base_dir ${original_folder} \\
        --output_file jaccard_similarities.csv \\
        --similarity_threshold ${similarity_threshold}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
    END_VERSIONS
    """
}
