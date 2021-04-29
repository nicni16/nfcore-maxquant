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
        container "lnkn/nfcore-maxquant:dev"
    }

    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/software/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    input:
        path mqparameters
        file rawfile 
	    file fastafile 
         

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
        path "combined/txt/proteinGroups.txt", emit: txt
        path "*.version.txt"       , emit: version


    script:
    def software = getSoftwareName(task.process)
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/software/homer/annotatepeaks/main.nf
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "$options.args" variable
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """ 
    sed -i "s|PLACEHOLDER|\$PWD/|g" "${mqparameters}"
    mkdir temp
    maxquant ${mqparameters}
    echo $VERSION > ${software}.version.txt
    cp -R "\$PWD/combined/txt" "${params.outdir}"
    echo $VERSION > ${software}.version.txt
    """
    //maxquant --version |& sed -e "s/MaxQuantCmd //gI" > ${software}.version.txt
    
}