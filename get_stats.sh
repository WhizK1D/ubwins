#!/bin/bash

# AUTHOR: Abhyudaya Mourya

# DESCRIPTION:
# This script works on a simple logic and assumes that provided input file
# is a txt file exported from Wireshark with appropriate radio tap headers

# INPUT/OUTPUT:
# The script takes in 1 argument viz. the plain text packet file generated from
# Wireshark export feature.
# The script generates 2 output files:
# 1. output_packet_stats.txt
# 2. output_amsdu_stats.txt

# The reason the 2 data are separated is because the communication information
# is included in the "radio information" block of the packets but the
# "A-MSDU" subframe data is a separate block, hence they are dumped in a separate file

INPUT_FILE=$1

# Generates metadata of parsing done from the output files
generate_metadata()
{
    subframe_count=`cat output_amsdu_stats.txt | grep "A-MSDU Subframe" | wc -l`
    echo -e "\n\nTotal sub-frames processed: $subframe_count"

    radio_header_count=`cat output_packet_stats.txt | grep "radio information" | wc -l`
    echo -e "\n\nTotal packets processed: $radio_header_count"
}

# Generates the A-MSDU stats output file
generate_amsdu_stats()
{
    OUTPUT_FILE="output_amsdu_stats.txt"
    if [ -f "$OUTPUT_FILE" ]; then
        echo "Removing old A-MSDU stats..."
        rm $OUTPUT_FILE
    fi

    touch $OUTPUT_FILE

    echo "Parsing for A-MSDU stats..."
    cat $INPUT_FILE | grep "A-MSDU Subframe" -A 3 > output_amsdu_stats.txt
}

# Generates general packet stats output file
generate_packet_stat()
{
    OUTPUT_FILE="output_packet_stats.txt"
    if [ -f "$OUTPUT_FILE" ]; then
        echo "Removing old packet stats..."
        rm $OUTPUT_FILE
    fi

    touch $OUTPUT_FILE

    echo "Parsing for general packet information..."
    cat $INPUT_FILE | grep "radio information" -A 13 > $OUTPUT_FILE
}

echo "--- Running packet parsing ---"
echo "Checking if input file exists"

if [ ! -f $INPUT_FILE ]; then
    echo "Input file does not exist! Invalid argument!"
    exit -1
fi

echo "Input file found, beginning processing..."

generate_amsdu_stats
generate_packet_stat
generate_metadata
