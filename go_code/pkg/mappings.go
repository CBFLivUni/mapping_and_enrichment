package pkg

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
	"time"
)

func readAndFilterToWriter(mappingFile string, writer *bufio.Writer, accessions []string) {
	accessionsSet := SliceToSet(accessions)
	lineCount := 0
	prevPc := "BLAH"
	totalLines := GetLineCount(mappingFile)

	reader, err := OpenFileOrGzFile(mappingFile)
	if err != nil {
		log.Fatal(err)
	}

	br := bufio.NewReader(reader)
	for {
		line, err := br.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}

			log.Fatal(err)
		}

		lineCount++
		pc := fmt.Sprintf("%d%%", 100*lineCount/totalLines)
		if prevPc != pc {
			prevPc = pc
			fmt.Println("Filtering mapping of DAT file: " + pc + " of " + mappingFile)
		}
		lineSplit := strings.Split(line, "\t")
		accession := lineSplit[0]
		if StringInSet(accession, accessionsSet) {
			writer.WriteString(line + "\n")
		}
	}

	reader.Close()
}

func WriteFilteredFile(mappingFile string, outFile string, accessions []string) {
	writer, err := os.Create(outFile)
	if err != nil {
		log.Fatal(err)
	}

	defer writer.Close()
	bwriter := bufio.NewWriter(writer)
	readAndFilterToWriter(mappingFile, bwriter, accessions)
}

func CreateMappingFilesFromAccessions(accessions []string, ncbiTaxon string, idmappingFilePath string, idmappingSelectedFilePath string) {
	t := time.Now()
	timeFormatted := fmt.Sprintf(t.Format("20060102150405"))
	outfile := "mappings_" + Ifelse(ncbiTaxon != "", ncbiTaxon+"_", "") + timeFormatted + ".txt"
	WriteFilteredFile(idmappingFilePath, outfile, accessions)
	outfile = "mappings_selected_" + Ifelse(ncbiTaxon != "", ncbiTaxon+"_", "") + timeFormatted + ".txt"
	WriteFilteredFile(idmappingSelectedFilePath, outfile, accessions)
}
