package main

import (
	"cbf/mapping_filtering/pkg"
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func main() {
	var idmappingFilePath string
	var idmappingSelectedFilePath string
	var ncbiTaxon string
	var universeAccessionsFile string

	flag.StringVar(&idmappingFilePath, "mapping", "", "Specify input mapping file path.")
	flag.StringVar(&idmappingSelectedFilePath, "smapping", "", "Specify input selected mapping file path.")
	flag.StringVar(&ncbiTaxon, "taxon", "", "Specify species NCBI taxon ID. Overrides accessions if set.")
	flag.StringVar(&universeAccessionsFile, "accessions", "", "Specify accessions file, if not using NCBI taxon ID.")

	flag.Parse()

	if _, err := os.Stat(universeAccessionsFile); (ncbiTaxon == "") && errors.Is(err, os.ErrNotExist) {
		fmt.Println("NCBI taxon ID OR accessions file must be provided.")
		return
	}

	if _, err := os.Stat(idmappingFilePath); (idmappingFilePath == "") || errors.Is(err, os.ErrNotExist) {
		fmt.Println("ID mapping file path file must be provided.")
		return
	}

	if _, err := os.Stat(idmappingSelectedFilePath); (idmappingSelectedFilePath == "") || errors.Is(err, os.ErrNotExist) {
		fmt.Println("ID mapping selected file path file must be provided.")
		return
	}

	fmt.Println("Output will be made in the working directory.")

	var accessions = []string{}
	if ncbiTaxon != "" {
		totalLines := pkg.GetLineCount(idmappingSelectedFilePath)
		lineCount := 0
		prevPc := "BLAH"
		f, err := pkg.OpenFileOrGzFile(idmappingSelectedFilePath)
		if err != nil {
			log.Fatal(err)
		}

		cr := csv.NewReader(f)

		for {
			line, err := cr.Read()
			if err != nil {
				if err == io.EOF {
					break
				}

				log.Fatal(err)
			}

			lineCount++
			lineSplit := strings.Split(line[0], "\t")
			if lineSplit[12] == ncbiTaxon {
				accessions = append(accessions, lineSplit[0])
			}

			pc := fmt.Sprintf("%d%%", 100*lineCount/totalLines)
			if prevPc != pc {
				prevPc = pc
				fmt.Println("Getting list of species accessions: " + pc)
			}

		}
	} else {
		accessionReader, err := os.Open(universeAccessionsFile)
		if err != nil {
			log.Fatal(err)
		}

		accessions_, err := csv.NewReader(accessionReader).ReadAll()
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println(accessions_)
		accessions = append(accessions, "")

	}

	pkg.CreateMappingFilesFromAccessions(accessions, ncbiTaxon, idmappingFilePath, idmappingSelectedFilePath)
}
