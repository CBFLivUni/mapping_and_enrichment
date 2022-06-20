import datetime
import pandas as pd
from mappings import write_filtered_file
from utils import get_line_count, open_file_or_gzfile

# Change the two following paths to reflect their locations on your system.
idmapping_file_path = 'c:/Users/Simon Perkins/Downloads/idmapping_02032022.dat.gz'
idmapping_selected_file_path = id_mapping_specific_file = 'c:/Users/Simon Perkins/Downloads/idmapping_selected.tab.gz'

# The script will create files in the working directory, i.e. the place from where you run the script.

# If you have a CSV (with 'accession' header) set the path here.
universe_accessions_file = 'c:/Users/Simon Perkins/Downloads/horse_accessions.csv'

# If you have an NCBI taxon ID, set it here. If set it overrides the accessions file above.
ncbi_taxon = '9796'


# The next function actually does all the work, and it is called at the end of this file.
def create_mapping_files():
    # Check if the NCBI ID is not blank. If not we'll use the ID to filter for species-specific accessions.
    if ncbi_taxon != '':
        # We need to get the accessions from the mapping file using the NCBI taxon ID.
        accessions = []
        # Get the total number of lines in this file so that we can shortly calculate a percentage to report to user.
        total_lines = get_line_count(idmapping_selected_file_path)
        line_count = 0
        # Some random garbage that the percentage string will never be equal to.
        prev_pc = "BLAH"
        with open_file_or_gzfile(idmapping_selected_file_path, 'rt') as f:
            for line in f:
                line_count += 1
                # Split the line by tabs.
                line_split = line.strip().split('\t')

                # If the 12th (0-index) entry if the NCBI taxon ID we were given, add the accession at position 0.
                # If the accession is not alphanumeric, add 'DOH' instead as something is wrong.
                if line_split[12] == ncbi_taxon:
                    accessions.append(line_split[0] if all(c.isalnum() for c in line_split[12]) else 'DOH')
                # If the NCBI taxon ID entry is similarly not alphanumeric, do nothing. Previously I had an idea to
                # split the text and try to match individual NCBI taxa IDs if there were multiple but that didn't go
                # anywhere.
                if not all(c.isalnum() for c in line_split[12]):
                    pass
                # Create the formatted percentage update.
                pc = "{0:.0%}".format(line_count / total_lines)
                # If the percentage update is not the same as before, print it to screen and set the 'before' value
                # to the current percentage update.
                if prev_pc != pc:
                    prev_pc = pc
                    print('\rGetting list of species accessions: ' + pc)
            # Print a new line character - can't remember specifically why?!
            print("\n")
    else:
        # If the NCBI taxon ID was blank, try to read the accessions from file using pandas.
        accessions = set(pd.read_csv(universe_accessions_file)['accession'].tolist())

    # Call the function to create the filtered mapping files with the list of accessions we got from the taxon ID or
    # from file.
    create_mapping_files_from_accessions(accessions, ncbi_taxon)


# Function to create the filtered mapping files given a list of accessions to filter with. The NCBI taxon ID is only
# used here to make the file name.
def create_mapping_files_from_accessions(accessions, ncbi_taxon_):
    # Create the name of the output mapping file using the NCBI taxon ID if given and a timestamp.
    outfile = 'mappings_' + (ncbi_taxon_ + '_' if ncbi_taxon_ != '' else '') + datetime.datetime.now().strftime(
        '%Y%m%d%H%M%S') + '.txt'
    # Create the filtered output file.
    write_filtered_file(idmapping_file_path, outfile, accessions)
    # Create the name of the output selected mapping file using the NCBI taxon ID if given and a timestamp.
    outfile = 'mappings_selected_' + (ncbi_taxon_ + '_' if ncbi_taxon_ != '' else '') + datetime.datetime.now().strftime(
        '%Y%m%d%H%M%S') + '.txt'
    # Create the filtered output file.
    write_filtered_file(idmapping_selected_file_path, outfile, accessions)


# To run this script, uncomment the below line. If there is no code below this line, then this script will do nothing!
create_mapping_files()
