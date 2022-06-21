# Load packages.
library(memoise)
library(stringr)
library(readr)

source('uniprot_selected_term_types.R')
source('uniprot_dat_reading.R')

enrichment_funky <- function(foreground_terms, background_terms) {
  background = table(background_terms)
  foreground = table(foreground_terms)
  
  enrichment = sapply(names(background), function(term) {
    fg_counts = foreground[term]
    fg_counts = ifelse(is.na(fg_counts), 0, fg_counts)
    fg_size = length(foreground_terms)
    bg_counts = background[term]
    bg_size = length(background_terms)
    
    fs_test = fisher.test(
      matrix(c(
        # Proteins matching GO:XXXXXX in background. Proteins not matching GO... in background.
        bg_counts, bg_size-bg_counts,
        # Proteins matching GO:XXXXXX in foreground. Proteins not matching GO... in foreground.
        fg_counts, fg_size-fg_counts
      ), nrow = 2)
    )
    c(term = term, fg = paste(fg_counts, fg_size, sep = '/'), bg = paste(bg_counts, bg_size, sep = '/'), p.value = fs_test$p.value, fold_enrichment = (fg_counts/fg_size)/(bg_counts/bg_size))
  })
  
  enrichment = as.data.frame(t(enrichment))
  colnames(enrichment)[5] = 'fold_enrichment'
  enrichment$p.value.adjusted = p.adjust(enrichment$p.value, method='BH')
  enrichment
}



enrichment_with_background_from_species_dat_file <- function(foreground_accessions, species_specific_dat_file_path = 'uniprot-proteome_UP000002281.txt', enrichment_type = 'GO') {
  # Read in the species specific data file. Using memoise so not all calls to function will cause a reread, but will use a cached version.
  species_universe = readDatFile_memoised(species_specific_dat_file_path)
  
  # Get the unique protein accessions from the file.
  species_universe_accessions = unique(unlist(sapply(species_universe, function(species_universe_datum){species_universe_datum$ac})))
  
  # If enrichment type is GO, get the GO terms from the species specific file. If not get the terms from one of the two huge mapping files.
  if (enrichment_type == 'GO') {
    all_terms = sapply(species_universe, function(species_universe_record) {t(sapply(species_universe_record$go, unlist))})
    all_terms = all_terms[sapply(all_terms, ncol) == 3]
    all_terms = do.call(rbind, all_terms)
    all_terms = as_tibble(all_terms)
  } else {
    print('Enrichment type is not GO.')
    # If enrichment type is one of a select few we can use the smaller mapping file. If not we must use the bigger mapping file.
    if (enrichment_type %in% uniprot_selected_term_types) {
      species_mapping_data = read_table('idmapping_selected.tab.gz', col_names = uniprot_selected_term_types)
      all_terms = tibble(accession = species_universe_accessions) %>% left_join(species_mapping_data, by = c('accession' = 'UniProtKB-AC')) %>% select(enrichment_type)
    } else {
      if (!file.exists('idmapping_filtered.csv')) {
        filterIdData(species_universe_accessions)
      }
      
      species_mapping_data = read_csv('idmapping_filtered.csv') %>% filter(type == enrichment_type)
      all_terms = tibble(accession = species_universe_accessions) %>% left_join(species_mapping_data) %>% select(id) %>% rename(term = id)
    }
  }
  
  background = table(all_terms$term)
  
  if (enrichment_type == 'GO') {
    data_terms = do.call(rbind, lapply(foreground_accessions, function(accession) {
      correct_records = species_universe[sapply(species_universe, function(species_universe_record) {accession %in% species_universe_record$ac})]
      
      if (length(correct_records) > 1) {
        
        warning('More than one match to accession! Using only the first')
      }
      
      if (length(correct_records) == 0) {
        
        warning('Less than one match to accession! Are you using the correct strain?')
        correct_records = list(list())
      }
      
      correct_record = correct_records[[1]]
      records = correct_record$go
      
      if (is.null(records) | length(records) == 0) {
        return(data.frame(term = c(), description = c(), extra = c()))
      }
      
      return(data.frame(term = sapply(records, function(record) {record$term}), description = sapply(records, function(record) {record$description})))
    }))
  } else{
    if (enrichment_type %in% uniprot_selected_term_types) {
      species_mapping_data = read_table('idmapping_selected.tab.gz', col_names = uniprot_selected_term_types)
      data_terms = tibble(accession = foreground_accessions) %>% left_join(species_mapping_data, by = c('accession' = 'UniProtKB-AC')) %>% select(enrichment_type)
    } else {
      if (!file.exists('idmapping_filtered.csv')) {
        filterIdData(species_universe_accessions)
      }
      
      species_mapping_data = read_csv('idmapping_filtered.csv') %>% filter(type == enrichment_type)
      data_terms = tibble(accession = foreground_accessions) %>% left_join(species_mapping_data) %>% select(-accession, -type) %>% rename(term = id)
    }
  }
  
  foreground = table(data_terms$term)
  
  enrichment = enrichment_funky(data_terms$term, all_terms$term)
  enrichment$description = sapply(enrichment$term, function(term) {
    all_terms %>% filter(term == term) %>% slice_head(n=1) %>% select(description) %>% pull()
    #all_go_terms[all_go_terms$term == term,'description'][1]
  })
  
  enrichment
}









