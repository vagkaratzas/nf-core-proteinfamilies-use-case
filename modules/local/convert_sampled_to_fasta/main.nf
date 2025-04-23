process CONVERT_SAMPLED_TO_FASTA {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/eb/eb3700531c7ec639f59f084ab64c05e881d654dcf829db163539f2f0b095e09d/data' :
        'community.wave.seqera.io/library/biopython:1.84--3318633dad0031e7' }"

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
        --pfam ${pfam} \\
        --output_folder sampled_fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
    END_VERSIONS
    """
}
