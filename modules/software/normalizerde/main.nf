// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)
def VERSION = '1.8.0'

process NORMALIZERDE {
    tag "$norm"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }
    conda (params.enable_conda ? "bioconda::bioconductor-normalyzerde=1.8.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bioconductor-normalyzerde:1.8.0--r40hdfd78af_1"
    } else {
        container "wombatp/maxquant-pipeline:dev"
    }

    input:
        path sdrf_file
        path exp_file
        path protein_file 
        file exp_file2 

    output:
	    path "Normalyzer/Normalyzer_stats.tsv"                      , emit: tsv
	    path "Normalyzer/${params.normalyzerMethod}-normalized.txt" , emit: txt
        path "*.version.txt"                                        , emit: version

    script:
    def software = getSoftwareName(task.process)
        
    """
    cp "${exp_file}" exp_file.tsv
    cp "${exp_file2}" exp_file2.tsv 
    cp "${protein_file}" protein_file.txt
    Rscript $baseDir/runNormalyzer.R --comps="${params.comparisons}" --method="${params.normalyzerMethod}" "$options.args"
    cp -R Normalyzer "${params.outdir}"
    echo $VERSION > ${software}.version.txt

    """
}
