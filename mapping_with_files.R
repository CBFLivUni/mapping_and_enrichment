# Function to Download a file.
bdown=function(url, file){
  library('RCurl')
  f = CFILE(file, mode="wb")
  a = curlPerform(url = url, writedata = f@ref, noprogress=FALSE)
  close(f)
  return(a)
}


# Function to download the latest mapping data files from the UniProt website.
download_files <- function() {
  if (!file.exists('idmapping.dat.gz')) {
    ret = bdown('ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz', 'idmapping.dat.gz')
  }
  
  if (!file.exists('idmapping_selected.tab.gz')) {
    ret = bdown('https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz', 'idmapping_selected.tab.gz')
  }
  
}

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