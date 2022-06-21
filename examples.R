source('uniprot_dat_reading.R')
source('mapping_with_files.R')
source('mapping_with_db_ortho.R')

## Mapping using db ortho.
## First get the IDs you want to map from. In this case we get them from a species uniprot DAT file, for which we have a reader function.
data_with_accessions = readDatFile_memoised('c:/Users/Simon Perkins/Downloads/uniprot-proteome_UP000002281.txt')
from_ids = unique(unlist(sapply(data_with_accessions, function(datum){datum$ac})))
## Here we map our (in thin case horse) uniprot accessions to human gene symbols. With human gene symbols any online tool should work right away.
mapped_data = map_using_db_ortho(input_id = 'UniProt Accession', input_values = from_ids, input_taxon = '9796', output_taxon = '9606', output_id = 'Gene Symbol')
## Alternatively you could map straight to GO! And then you could follow some other code, like the enrichment code below.
mapped_data = map_using_db_ortho(input_id = 'UniProt Accession', input_values = from_ids, input_taxon = '9796', output_taxon = '9606', output_id = 'GO ID')
## Note: The ID type you map to may have multiple matches, so always check the data.

## Mapping using uniprot mapping files.
## It is very advantageous to have mapping files specific to your species/dataset of interest, otherwise steps could take a long time.
## For selected species, these are available here: https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/
## If you want to make these files, you can make them from idmapping.dat and idmapping_selected.dat, you just need to know the NCBI taxon ID, or the whole set of accessions for that species.
## There is R, Python and Go code for this.
## Here, we map our accessions to GO, and KEGG.
mapped_data = map_using_uniprot_files(input_id = 'UniProtKB-AC', input_values = from_ids, output_id = 'GO')
mapped_data = map_using_uniprot_files(input_id = 'UniProtKB-AC', input_values = from_ids, output_id = 'KEGG')


## Enrichment
## If you have done your mapping and now have some 'terms' that you would like to enrich for, then you can look at the following examples.
background_accessions = from_ids
background_terms = map_using_uniprot_files(input_id = 'UniProtKB-AC', input_values = background_accessions, output_id = 'GO') %>% select(GO) %>% pull()
foreground_accessions = sample(from_ids, length(from_ids) / 100)
foreground_terms = map_using_uniprot_files(input_id = 'UniProtKB-AC', input_values = foreground_accessions, output_id = 'GO') %>% select(GO) %>% pull()
enrichment = enrichment_funky(foreground_terms, background_terms)

