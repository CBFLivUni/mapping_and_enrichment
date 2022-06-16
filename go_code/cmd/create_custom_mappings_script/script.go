package main

import (
	"awesomeProject/pkg"
	"encoding/csv"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"strings"
)

var idmappingFilePath = "/home/simon/data/idmapping.dat"
var idmappingSelectedFilePath = "/home/simon/data/idmapping_selected.tab"

//var ncbiTaxon = "9796"
var ncbiTaxon = ""
var universeAccessionsFile = "/home/simon/data/horse_accessions.txt"

func main() {
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
		accessions_bytes, err := ioutil.ReadFile(universeAccessionsFile)
		if err != nil {
			log.Fatal(err)
		}

		accessions_ := strings.Split(string(accessions_bytes), "\n")
		accessions = append(accessions, accessions_...)

	}

	pkg.CreateMappingFilesFromAccessions(accessions, ncbiTaxon, idmappingFilePath, idmappingSelectedFilePath)
}
