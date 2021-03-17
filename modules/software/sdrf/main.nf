// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SDRF {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::sdrf-pipelines=0.0.12" : null) // Conda package
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
            container "https://depot.galaxyproject.org/singularity/sdrf-pipelines:0.0.12--py_0" //Singularity Image
    } else {
        container "quay.io/biocontainers/sdrf-pipelines:0.0.12--py_0" // Docker image
    }
    
    input: 
        path sdrf_file 
        path fasta_file

    output:
        file "mqpar.xml" 
        file "exp_design.tsv"

    script: 
    """
    parse_sdrf convert-maxquant -s "${sdrf_file}" -f "PLACEHOLDER${fasta_file}" -m ${params.match} -r PLACEHOLDER -pef ${params.peptidefdr} -prf ${params.proteinfdr} -t PLACEHOLDERtemp -o2 exp_design.tsv -n ${task.cpus} 
    """
}