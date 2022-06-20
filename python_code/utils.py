import binascii
import gzip
from functools import cache

# Handful of functions to aid file reading.


# Get the number of lines in a text file. File can be plain or gzipped.
# Function is cached so that line counts of huge files are not computer more than once.
@cache
def get_line_count(file):
    line_count = 0
    with open_file_or_gzfile(file, 'rt') as f:
        for line in f:
            line_count += 1
    return line_count


# Function to open a file for reading, either as a plain file or as a gzip file, according to the magic byte.
def open_file_or_gzfile(file, args):
    return gzip.open(file, args) if is_gz_file(file) else open(file, args)


# Function to test whether a file is gzipped or not, using the magic byte.
def is_gz_file(filepath):
    with open(filepath, 'rb') as test_f:
        return binascii.hexlify(test_f.read(2)) == b'1f8b'
