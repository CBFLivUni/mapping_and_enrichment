# Function to download a file.
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