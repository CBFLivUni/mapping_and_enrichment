library(jsonlite)
library(glue)

# Please see https://biodbnet-abcc.ncifcrf.gov/db/dbOrtho.php for an idea of what the input_id and output_id could be.
# If you supply too many input values you may get a HTTP error - try splitting it up into multiple calls if that happens.
map_using_db_ortho <- function(input_id, input_values, input_taxon, output_taxon, output_id, output_format = 'row') {
  url_ = glue('https://biodbnet-abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.json?method=dbortho&input={input_id}&inputValues={paste(input_values, collapse=",",sep="")}&inputTaxon={input_taxon}&outputTaxon={output_taxon}&output={output_id}&format={output_format}')
  fromJSON(url(url_))
}
