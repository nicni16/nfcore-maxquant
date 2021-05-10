// Import generic module functions
include { saveFiles } from './functions'


params.options = [:]


/*
 * Parse software version numbers
 */
process GET_SOFTWARE_VERSIONS {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'pipeline_info', publish_id:'') }

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/python:3.8.3"
    } else {
        container "lnkn/nfcore-maxquant:latest"
    }

    cache false

    input:
    path versions
    
    output:
    path "software_versions.csv"     , emit: csv
    path 'software_versions_mqc.yaml', emit: yaml

    script:
    """
    echo $workflow.manifest.version > pipeline.version.txt
    echo $workflow.nextflow.version > nextflow.version.txt
    scrape_software_versions.py &> software_versions_mqc.yaml
    """
}