package pkg

import (
	"bytes"
	"compress/gzip"
	"io"
	"log"
	"os"
	"strings"
)

type void struct{}

var member void

func StringInSlice(a string, list []string) bool {
	for _, b := range list {
		if b == a {
			return true
		}
	}
	return false
}

func StringInSet(a string, set map[string]void) bool {
	_, exists := set[a]
	return exists
}

func SliceToSet(list []string) map[string]void {
	set := map[string]void{}
	for i := 0; i < len(list); i++ {
		set[list[i]] = member
	}

	return set
}

func OpenFileOrGzFile(file string) (io.ReadCloser, error) {
	f, err := os.Open(file)
	if err != nil {
		log.Fatal(err)
	}

	if strings.HasSuffix(file, "gz") {
		gzr, err := gzip.NewReader(f)
		return gzr, err
	}

	return f, err
}

func GetLineCount(file string) int {
	f, err := OpenFileOrGzFile(file)
	defer f.Close()
	if err != nil {
		log.Fatal(err)
	}

	lineCount, err := lineCounter(f)
	if err != nil {
		log.Fatal(err)
	}

	return lineCount
}

func lineCounter(r io.Reader) (int, error) {
	buf := make([]byte, 32*1024)
	count := 0
	lineSep := []byte{'\n'}

	for {
		c, err := r.Read(buf)
		count += bytes.Count(buf[:c], lineSep)

		switch {
		case err == io.EOF:
			return count, nil

		case err != nil:
			return count, err
		}
	}
}

func Ifelse(condition bool, this string, that string) string {
	if condition {
		return this
	} else {
		return that
	}
}
