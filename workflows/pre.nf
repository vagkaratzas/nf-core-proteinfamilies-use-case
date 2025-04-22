include { EXTRACT_VALID_INTERPRO_IDS          } from '../modules/local/extract_valid_interpro_ids/main'
include { EXTRACT_CANDIDATE_INTERPRO_FAMILIES } from '../modules/local/extract_candidate_interpro_families/main'

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

    ch_mapping = Channel.fromPath(id_mapping_file, checkIfExists: true)
    EXTRACT_CANDIDATE_INTERPRO_FAMILIES(EXTRACT_VALID_INTERPRO_IDS.out.output, ch_mapping)
}
