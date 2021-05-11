#!/usr/bin/env nextflow
/*
========================================================================================
                         nf-core/maxquant
========================================================================================
 nf-core/maxquant Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/nicni16/nfcore-maxquant
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

def json_schema = "$projectDir/nextflow_schema.json"
if (params.help) {
    def command = 'nextflow run main.nf --raws "path/to/raws" --sdrf "path/to/*.tsv" --fasta "path/to/*.fasta" --experiment_design "SPECIFYFOLDER/exp_design.txt" -profile docker'
    log.info Schema.params_help(workflow, params, json_schema, command)
    exit 0
}
////////////////////////////////////////////////////
/* --          PARAMETER CHECKS                -- */
////////////////////////////////////////////////////

if (params.validate_params) {
    NfcoreSchema.validateParameters(params, json_schema, log)
}

// Check that conda channels are set-up correctly
if (params.enable_conda) {
    Checks.check_conda_channels(log)
}

// Check AWS batch settings
Checks.aws_batch(workflow, params)

// Check the hostnames against configured profiles
Checks.hostname(workflow, params, log)

// Check genome key exists if provided
Checks.genome_exists(params, log)

////////////////////////////////////////////////////
/* --         PRINT PARAMETER SUMMARY          -- */
////////////////////////////////////////////////////

def summary_params = Schema.params_summary_map(workflow, params, json_schema)
log.info Schema.params_summary_log(workflow, params, json_schema)





////////////////////////////////////////////////////
/* --          CONFIG FILES                    -- */
////////////////////////////////////////////////////

// Stage config files
ch_output_docs = file("$projectDir/docs/output.md", checkIfExists: true)
ch_output_docs_images = file("$projectDir/docs/images/", checkIfExists: true)



// Local: subworkflows
include { COMBINED      }   from './subworkflows/local/com_max'         addParams( summary_params: summary_params )
include { COMBINED_test  }   from './subworkflows/local/testcase.nf'    addParams( summary_params: summary_params )


////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////
def multiqc_report = []

workflow {
    if (workflow.profile.contains('test') ){
        COMBINED_test ()
    }
    else {    
        COMBINED ()
        }


    
    

}