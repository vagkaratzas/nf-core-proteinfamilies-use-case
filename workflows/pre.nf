include { EXTRACT_VALID_INTERPRO_IDS } from '../modules/local/extract_valid_interpro_ids/main'

workflow PRE {
    take:
    interpo_hierarchy_file
    id_mapping_file
    path_to_hamap
    path_to_ncbifam
    path_to_panther
    path_to_pfam

    main:
    ch_hierarchy = Channel.fromPath(interpo_hierarchy_file, checkIfExists: true)
    EXTRACT_VALID_INTERPRO_IDS(ch_hierarchy)
}
