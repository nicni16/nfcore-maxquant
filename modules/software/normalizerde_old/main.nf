// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process NORMALYZERDE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::bioconductor-normalyzerde==1.8.0" : null) // Conda package
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bioconductor-normalyzerde:1.8.0--r40_0" //Singularity Image
    } else {
        container "quay.io/biocontainers/bioconductor-normalyzerde:1.8.0--r40_0"  // Docker Image
    }

    input:
        path sdrf_file
        path exp_file
        path protein_file 
        file exp_file2 

    output:
	    file "Normalyzer/Normalyzer_stats.tsv" 
	    file "Normalyzer/${params.normalyzerMethod}-normalized.txt"

    script:
    """
     cp "${exp_file}" exp_file.tsv
     cp "${exp_file2}" exp_file2.tsv 
     cp "${protein_file}" protein_file.txt
     Rscript $baseDir/runNormalyzer.R --comps="${params.comparisons}" --method="${params.normalyzerMethod}"
     cp -R Normalyzer "${params.outdir}"
    """ 
}