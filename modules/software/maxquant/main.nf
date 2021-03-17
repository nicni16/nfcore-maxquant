// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process MAXQUANT {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::maxquant=1.6.10.43" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "quay.io/biocontainers/maxquant:1.6.10.43--0"
    }

    input:
        path mqparameters
        file rawfile 
	    file fastafile 
         

    output:
        file "combined/txt/proteinGroups.txt"	


    script:
    """ 
    sed -i "s|PLACEHOLDER|\$PWD/|g" "${mqparameters}"
    mkdir temp
    maxquant ${mqparameters}
    cp -R "\$PWD/combined/txt" "${params.outdir}"
    """
}