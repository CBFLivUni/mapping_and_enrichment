# Change the two following entries to point to paths on your system for filtered mapping files.
idmapping_file_path = 'c:/Users/Simon Perkins/go/bin/mappings_9796_20220620185409.txt'
idmapping_selected_file_path = 'c:/Users/Simon Perkins/go/bin/mappings_selected_9796_20220620185409.txt'

# DEPRECATED: This function accepts a list of accessions and filters idmapping.data.gz (in the working directory).
filterIdData <- function(species_all_accessions) {
  download_files()
  
  incon = gzcon(file('idmapping.dat.gz', open = 'rb'))
  #incon = file(f, open = 'rb')
  line = readLines(incon, 1)
  species_data = data.frame(accession = c(), type = c(), id = c())
  while(length(line) == 1) {
    elements = strsplit(line, '\t')[[1]]
    if (elements[1] %in% species_all_accessions) {
      species_data = rbind(species_data, data.frame(accession = elements[1], type = elements[2], id = elements[3]))
    }
    
    line = readLines(incon, 1)
  }
  
  close(incon)
  write.csv(species_data, file ='idmapping_filtered.csv')
}

map_using_uniprot_files <- function(input_id = 'UniProtKB-AC', input_values, output_id) {
  input_values = as.character(input_values)
  if (output_id %in% uniprot_selected_term_types) {
    species_mapping_data = read_delim(idmapping_selected_file_path, delim = "\t", escape_double = FALSE, col_names = uniprot_selected_term_types, trim_ws = T)
    data_terms = tibble(input_ids = input_values) %>% left_join(species_mapping_data, by = c('input_ids' = input_id)) %>% select(input_ids, output_id)
    data_terms = data_terms %>% filter(if_all(output_id, \(x)!is.na(x)))
    data_terms = data_terms %>% separate_rows(output_id, sep = "; ")
  } else {
    species_mapping_data = read_delim(idmapping_file_path, delim = "\t", escape_double = FALSE, col_names = c('accession', 'id_type', 'id'), trim_ws = T)
    # If the input ID type is not UP accession, we need to map back to it.
    if (input_id != 'UniProtKB-AC') {
      input_values = species_mapping_data %>% filter(id_type == input_id) %>% filter(sapply(id, function(id_){id_ %in% input_values})) %>% select(accession) %>% pull()
    }
    
    data_terms = tibble(input_ids = input_values) %>% left_join(filter(species_mapping_data, id_type == output_id), by = c('input_ids' = 'accession')) %>% select(-id_type) %>% rename_with(\(x) output_id, matches('^id$'))
  }
  
  data_terms %>% filter(if_all(output_id, \(x)!is.na(x)))
}