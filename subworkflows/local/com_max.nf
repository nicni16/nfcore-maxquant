/*
================================================================================
                                 Combination of processes
================================================================================
*/


params.collected_options = [:]
include { GET_SOFTWARE_VERSIONS }         from '../../modules/software/getsoftwareversions/main'   addParams(options: [publish_files : ['csv':'']])
include { SDRFPIPELINES }                 from '../../modules/software/sdrfpipelines/main'         addParams(options: params.collected_options)
include { MAXQUANT }                      from '../../modules/software/maxquant/main'              addParams(options: params.collected_options)
include { NORMALIZERDE }                  from '../../modules/software/normalizerde/main'          addParams(options: params.collected_options)
workflow COMBINED {
    ch_software_versions = Channel.empty()

    input_sdrf = channel.fromPath(params.sdrf)
    input_fasta = channel.fromPath(params.fasta)
    input_raw = channel.fromPath(params.raws)
    input_exp_design = channel.fromPath(params.experiment_design)
    SDRFPIPELINES (input_sdrf, input_fasta)
    ch_software_versions = ch_software_versions.mix(SDRFPIPELINES.out.version.first().ifEmpty(null))
    MAXQUANT (SDRFPIPELINES.out.xml, input_raw.collect(), input_fasta)
    ch_software_versions = ch_software_versions.mix(MAXQUANT.out.version.first().ifEmpty(null))
    NORMALIZERDE (input_sdrf, SDRFPIPELINES.out.tsv, MAXQUANT.out.txt, input_exp_design)
    ch_software_versions = ch_software_versions.mix(NORMALIZERDE.out.version.first().ifEmpty(null))
    GET_SOFTWARE_VERSIONS (
        ch_software_versions.map { it }.collect()
    )
    

}