// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options        = initOptions(params.options)
def VERSION ='0.0.12'

process SDRFPIPELINES {
    tag "$sdrf"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "bioconda::sdrf-pipelines=0.0.12" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/sdrf-pipelines:0.0.12--py_0"
    } else {
        container "lnkn/nfcore-maxquant:dev"
    }

    input:
        path sdrf_file 
        path fasta_file

    output:
        path "mqpar.xml"              , emit: xml
        path "exp_design.tsv"         , emit: tsv
        path "*.version.txt"          , emit: version
        path "Warning_message.txt"    , emit: warning

    script:
    def software = getSoftwareName(task.process)
    """
    parse_sdrf \\
    convert-maxquant \\
    -s "${sdrf_file}" \\
    -f "PLACEHOLDER${fasta_file}" \\
    -m ${params.match} \\
    -r PLACEHOLDER \\
    $options.args \\
    -pef ${params.peptidefdr} \\
    -prf ${params.proteinfdr} \\
    -t PLACEHOLDERtemp \\
    -o2 exp_design.tsv \\
    -n ${task.cpus} 
     
    echo $VERSION > ${software}.version.txt
    cat "\$PWD/.command.out" > Warning_message.txt
    """
}
