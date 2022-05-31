library(memoise)
library(stringr)

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

readDatRecord <- function(record_lines) {
  record = list()
  record$go = list()
  record$gn = list()
  record$de = list()
  record$cc = list()
  for (record_line in record_lines) {
    line_type = substring(record_line, 1, 2)
    line_data = substring(record_line, 6)
    if (line_type == 'ID') {
      record$id = strsplit(line_data, ' ')[[1]][1]
      names(record$id) = NULL
    } else if (line_type == 'AC') {
      record$ac = sapply(strsplit(line_data, ';')[[1]], trim)
      names(record$ac) = NULL
    } else if (line_type == 'GN') {
      gn_records = sapply(strsplit(line_data, ';')[[1]], trim)
      for (gn_record in gn_records) {
        if (grepl('=', gn_record)) {
          gn_record_split = strsplit(gn_record, '=')[[1]]
          record$gn[gn_record_split[1]] = gn_record_split[2]
        } else {
          record$gn = append(record$gn, list(gn_record))
        }
      }
    } else if (line_type == 'DR') {
      line_data_split = sapply(strsplit(line_data, ';')[[1]], trim)
      names(line_data_split) = NULL
      if (line_data_split[1] == 'GO') {
        record$go = append(record$go, list(list(term = line_data_split[2], description = line_data_split[3], extra = line_data_split[4])))
      }
    } else if (line_type == 'DE') {
      record$de = append(record$de, line_data)
    } else if (line_type == 'CC') {
      record$cc = append(record$cc, line_data)
    }
  }
  
  record
}

readDatFile <- function(f) {
  if (str_detect(f, 'gz')) {
    incon = gzfile(f, open = 'rb')
  } else {
    incon = file(f, open = 'rb')
  }
  
  line = readLines(incon, 1)
  record_lines = c()
  records = list()
  while(length(line) == 1) {
    if (startsWith(line, '//')) {
      record = readDatRecord(record_lines)
      records = append(records, list(record))
      record_lines = c()
    } else {
      record_lines = append(record_lines, line)
    }
    
    line = readLines(incon, 1)
  }
  
  close(incon)
  records
}

readDatFile_memoised <- memoise(readDatFile, cache = cache_filesystem('.'))
