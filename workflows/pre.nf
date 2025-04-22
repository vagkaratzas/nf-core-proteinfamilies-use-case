include { CHUNK_CLUSTERS } from '../modules/local/chunk_clusters.nf'

workflow PRE {
    take:
    interpo_hierarchy_file
    id_mapping_file
    path_to_hamap
    path_to_ncbifam
    path_to_panther
    path_to_pfam

    main:

}
