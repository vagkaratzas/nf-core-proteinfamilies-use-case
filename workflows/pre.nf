include { EXTRACT_VALID_INTERPRO_IDS          } from '../modules/local/extract_valid_interpro_ids/main'
include { EXTRACT_CANDIDATE_INTERPRO_FAMILIES } from '../modules/local/extract_candidate_interpro_families/main'
include { EXTRACT_HAMAP_METADATA              } from '../modules/local/extract_hamap_metadata/main'
include { EXTRACT_NCBIFAM_METADATA            } from '../modules/local/extract_ncbifam_metadata/main'
include { EXTRACT_PANTHER_METADATA            } from '../modules/local/extract_panther_metadata/main'
include { EXTRACT_PFAM_METADATA               } from '../modules/local/extract_pfam_metadata/main'
include { FILTER_VALID_CANDIDATE_FAMILIES     } from '../modules/local/filter_valid_candidate_families/main'
include { SAMPLE_INTERPRO                     } from '../modules/local/sample_interpro/main'

workflow PRE {
    take:
    interpo_hierarchy_file
    id_mapping_file
    path_to_hamap
    path_to_ncbifam
    path_to_panther
    path_to_pfam
    min_membership
    num_per_db

    main:
    ch_hierarchy = Channel.fromPath(interpo_hierarchy_file, checkIfExists: true)
    EXTRACT_VALID_INTERPRO_IDS( ch_hierarchy )

    ch_mapping = Channel.fromPath(id_mapping_file, checkIfExists: true)
    EXTRACT_CANDIDATE_INTERPRO_FAMILIES( EXTRACT_VALID_INTERPRO_IDS.out.output, ch_mapping )

    ch_hamap = Channel.fromPath(path_to_hamap, checkIfExists: true)
    EXTRACT_HAMAP_METADATA( ch_hamap )

    ch_ncbifam = Channel.fromPath(path_to_ncbifam, checkIfExists: true)
    EXTRACT_NCBIFAM_METADATA( ch_ncbifam )

    ch_panther = Channel.fromPath(path_to_panther, checkIfExists: true)
    EXTRACT_PANTHER_METADATA( ch_panther )

    ch_pfam = Channel.fromPath(path_to_pfam, checkIfExists: true)
    EXTRACT_PFAM_METADATA( ch_pfam )

    FILTER_VALID_CANDIDATE_FAMILIES( EXTRACT_CANDIDATE_INTERPRO_FAMILIES.out.metadata, \
        EXTRACT_HAMAP_METADATA.out.metadata, EXTRACT_NCBIFAM_METADATA.out.metadata, \
        EXTRACT_PANTHER_METADATA.out.metadata, EXTRACT_PFAM_METADATA.out.metadata
    )

    SAMPLE_INTERPRO( FILTER_VALID_CANDIDATE_FAMILIES.out.metadata, ch_hierarchy, \
        min_membership, num_per_db
    )
}
