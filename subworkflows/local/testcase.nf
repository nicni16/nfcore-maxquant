/*
================================================================================
                                 Combination of processes
================================================================================
*/

/*
* Read and setup the variables
*/ 
params.raws = params.raws ?: { log.error "No read data provided. Make sure you have used the '--raws' option."; exit 1 }()
params.sdrf = params.sdrf ?: {log.error "No read data provided. Make sure you have used the '--sdrf' option."; exit 1}()
params.outdir = params.outdir ?: { log.warn "No output directory provided. Will put the results into './results'"; return "./results" }()
params.fasta = params.fasta ?: { log.error "No fasta file provided. Make sure you have used the '--fasta' option."; exit 1}()


////////////////////////////////////////////////////
/* --  UPDATE MODULES OPTIONS BASED ON PARAMS  -- */
////////////////////////////////////////////////////
def modules = params.modules.clone()


params.collected_options = [:]

include {GET_SOFTWARE_VERSIONS}         from '../../modules/software/getsoftwareversions/main'     addParams(options: [publish_files : ['csv':'']])
include {SDRFPIPELINES}                 from '../../modules/software/sdrfpipelines/main'           addParams(options: params.collected_options)
include {MAXQUANT}                      from '../../modules/software/maxquant/main'                addParams(options: params.collected_options)

workflow COMBINED_test {
    ch_software_versions = Channel.empty()
     
        input_sdrf = channel.fromPath(params.sdrf)
        input_fasta = channel.fromPath(params.fasta)
        input_raw = channel.fromPath(params.raws)
        SDRFPIPELINES (input_sdrf, input_fasta)
        ch_software_versions = ch_software_versions.mix(SDRFPIPELINES.out.version.first().ifEmpty(null))
        MAXQUANT (SDRFPIPELINES.out.xml, input_raw.collect(), input_fasta)
        ch_software_versions = ch_software_versions.mix(MAXQUANT.out.version.first().ifEmpty(null))
        GET_SOFTWARE_VERSIONS (
            ch_software_versions.map { it }.collect()
        )
}