// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SDRF {
    tag "$meta.id"
    label 'process_medium'
    
}