process GET_SIZE_DISTRIBUTIONS {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.4.3' :
        'biocontainers/pandas:1.4.3' }"

    input:
    path metadata_file
    path similarity_file

    output:
    path "log.txt"     , emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    get_size_distributions.py \\
        --metadata_file ${metadata_file} \\
        --similarity_file ${similarity_file} \\
        --output_file size_distributions.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        pandas: \$(python -c "import importlib.metadata; print(importlib.metadata.version('pandas'))")
    END_VERSIONS
    """
}
