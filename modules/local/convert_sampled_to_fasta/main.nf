process CONVERT_SAMPLED_TO_FASTA {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.4.3' :
        'biocontainers/pandas:1.4.3' }"

    input:
    path sampled_metadata
    path hamap
    path ncbifam
    path panther
    path pfam

    output:
    path "sampled_fasta", emit: log
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    convert_sampled_to_fasta.py \\
        --metadata_file ${sampled_metadata} \\
        --hamap ${hamap} \\
        --ncbifam ${ncbifam} \\
        --panther ${panther} \\
        --pfam ${pfam}

    mkdir sampled_fasta 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        pandas: \$(python -c "import importlib.metadata; print(importlib.metadata.version('pandas'))")
    END_VERSIONS
    """
}
