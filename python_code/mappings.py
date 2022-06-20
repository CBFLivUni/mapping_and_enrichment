from utils import open_file_or_gzfile, get_line_count


# Function to write data filtered by accessions, to a specified writer.
# The obsolete 'line_limit' was useful in the past but no more.
def read_and_filter_to_writer(mapping_file, writer, accessions, line_limit=0):
    # Get the total number of lines in this file so that we can shortly calculate a percentage to report to user.
    total_lines = get_line_count(mapping_file)
    line_count = 0
    # Some random garbage that the percentage string will never be equal to.
    prev_pc = "BLAH"
    with open_file_or_gzfile(mapping_file, 'rt') as f:
        for line in f:
            # Break from loop if we've met the limit of lines.
            if (line_limit > 0) & (line_count > line_limit):
                break
            line_count += 1
            # Create the formatted percentage update.
            pc = "{0:.0%}".format(line_count / total_lines)
            # If the percentage update is not the same as before, print it to screen and set the 'before' value
            # to the current percentage update.
            if prev_pc != pc:
                prev_pc = pc
                # Include the name of the mapping file in the update text, as we may be printing to console about
                # multiple mapping files.
                print('\rFiltering mapping of DAT file: ' + pc + " of " + mapping_file)
                # Split the line by tabs.
            line_split = line.strip().split('\t')
            accession = line_split[0]
            # If the current accession is in our list of required accessions, write the whole line to the writer.
            if accession in accessions:
                writer.write(line)


# Create a filtered output mapping file, using the supplied accessions and mapping file.
def write_filtered_file(mapping_file, out_file, accessions):
    # Create a writer then pass it to the above function to do the filtering and printing.
    # The output file will be automatically closed correctly.
    with open(out_file, 'w') as writer:
        read_and_filter_to_writer(mapping_file, writer, accessions)
