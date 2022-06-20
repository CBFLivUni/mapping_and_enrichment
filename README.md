# Mapping & Enrichment

Mapping and enrichment of uniprot accessions for "uncommonly"" used species.

## Mapping

1). You can use uniprot ID mapping files to map between various identifiers. You may use them to map accessions to orthologous accessions (i.e. probably human). You will first need to run the Go code/executable to filter the uniprot mapping files down to just those entriesd pertaining to your species of interest. There were R and then Python versions of this code but they were too slow.

### Go Console Application
You may build the GO console application from source or you just run it.
You provide the path to idmapping.dat(.gz) and idmapping_selected.tab(.gz), and an NCBI taxon ID or file of accessions for which you want mapping data.

### R/Python Scripts
There is a Python script and R code for filtering the mapping data but is is very slow. See 'filterIdData' in 'mapping_with_files.R' for the deprecated function, or 'create_custom_mapping_files.py' for a more full featured but still slow Python script.

After running the Go application or the R/Python scripts, you can use the mapping data however you like once you read it into R/Python. The enrichment section below goes into this.

If you are looking to map to orthologues then as mentioned above you can try out the db_ortho web service. I have my wrapper function in 'mapping_with_db_ortho.R'. To learn the different types of input ID types and output ID types, and species for which you can map to with your IDs, check out the db_ortho website.




## Enrichment
If the mappings are used to map IDs to a particular ontology, then enrichment analysis can be performed upon those ontology terms.


The 'make_heatmap_data_strict_with_charges' function uses the PSM data and spectra to score PSMs on their pY/sY fragment ion signal content.
There is a previous version that is less strict and a previous version that does not differentiate on charges.
You can use the 'low_e_value' flag to only take e-values less than 0.01, you can peak pick the spectra before further processing, and you can 
set the threshold for matching fragment ion peaks (in units of 1/Z).

    make_heatmap_data_strict_with_charges(low_e_value = T, peak_picking = T, peak_match_threshold = 0.05)
    
This function writes two RDS files, 'frag_numbers_01042022_strict_full_{peak_match_threshold}_with_charges.rds' and 'frag_numbers_01042022_strict_{peak_match_threshold}_with_charges.rds'. The second is used directly to draw the heatmap, the first is more detailed and contains the counts for individual PSMs - I used this for debugging.




 
