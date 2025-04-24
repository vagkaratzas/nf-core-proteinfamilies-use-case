include { PRE  } from './workflows/pre'
// include { POST } from './workflows/post'

workflow NFCORE_PROTEINFAMILIES_USE_CASE {

    take:
    workflow_mode // channel: samplesheet read in from --input

    main:
    //
    // WORKFLOW: Run pre pipeline
    //
    if (workflow_mode == "pre") {
        PRE( params.interpo_hierarchy_file, params.id_mapping_file, \
            params.path_to_hamap, params.path_to_ncbifam, params.path_to_panther, params.path_to_pfam, \
            params.path_to_swissprot, params.min_membership, params.num_per_db
        )
    }
    //
    // WORKFLOW: Run post pipeline
    //
    // else if (workflow_mode == "post") {
    //     POST(params.non_redundant_msas)
    // }
}

workflow {

    main:
    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_PROTEINFAMILIES_USE_CASE (
        params.workflow_mode
    )

}
