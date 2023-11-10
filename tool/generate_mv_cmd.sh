#!/bin/bash

# silly script to take an input text file of finemames
# and move them all into a directory indicated in ${NewDirectoryName}

# filenames are saved in list1.tsv
# 1 file name entry per line

# example run
# bash ./generate_mv_cmd.sh > TMP_CMD.sh
# bash TMP_CMD.sh

NewDirectoryName=preCovid

test -d $NewDirectoryName || mkdir $NewDirectoryName
cat list1.tsv | awk  -v Dir=$NewDirectoryName '{print "mv " $1 " " Dir }'
