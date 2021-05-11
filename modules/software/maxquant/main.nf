// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'
params.options = [:]
options        = initOptions(params.options)
def VERSION = '1.6.10.43'

process MAXQUANT {
    tag "$max"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }
    conda (params.enable_conda ? "bioconda::maxquant:1.6.10.43--0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/maxquant:1.6.10.43--0"
    } else {
        container "lnkn/nfcore-maxquant:latest"
    }
    input:
        path mqparameters
        file rawfile 
	    file fastafile 
    output:
        path "combined/txt/proteinGroups.txt"   , emit: txt
        path "*.version.txt"                    , emit: version
    script:
    def software = getSoftwareName(task.process)

    """ 
    sed -i "s|PLACEHOLDER|\$PWD/|g" "${mqparameters}"
    mkdir temp
    maxquant ${mqparameters}
    cp -R "\$PWD/combined/txt" "${params.outdir}"
    echo $VERSION > ${software}.version.txt
    """
    
}