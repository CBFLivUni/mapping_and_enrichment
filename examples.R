source('mapping_with_files.R')
source('mapping_with_db_ortho.R')

## Mapping using db ortho.
## First get the IDs you want to map from. In this case we get them from a species uniprot DAT file, for which we have a reader function.
data_with_accessions = species_universe = readDatFile_memoised('c:/Users/Simon Perkins/Downloads/uniprot-proteome_UP000002281.fasta.gz')
from_ids = unique(unlist(sapply(data_with_accessions, function(datum){datum$ac})))
## Here we map our (in thin case horse) uniprot accessions to human gene symbols. With human gene symbols any online tool should work right away.
mapped_data = map_using_db_ortho(input_id = 'uniprotaccession', input_values = from_ids, input_taxon = '9796', output_taxon = '9606', output_id = 'genesymbol')
## Alternatively you could map straight to GO! And then you could follow some other code, like the enrichment code below.
mapped_data = map_using_db_ortho(input_id = 'uniprotaccession', input_values = from_ids, input_taxon = '9796', output_taxon = '9606', output_id = 'GO')


## Mapping using uniprot mapping files.
## It is very advantageous to have mapping files specific to your species/dataset of interest, otherwise steps could take a long time.
## For selected species, these are available here: https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/
## If you want to make these files, you can make them from idmapping.dat and idmapping_selected.dat, you just need to know the NCBI taxon ID, or the whole set of accessions for that species.
## There is R, Python and Go code for this.
## Here, we map our accession to GO.
mapped_data = map_using_uniprot_files(input_id = 'UniProtKB-AC', input_values = from_ids, output_id = 'GO')


## Enrichment
## If you have done your mapping and now have some 'terms' that you would like to enrich for, then you can look at the following examples.


enrichment_with_background_from_species_dat_file()
mapped_data