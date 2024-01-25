#!/bin/bash

## epiinfo run mlst for TJ Ecuador data
## based on guatemala_amr/helper_script/run_guat_mlst.sh

## be careful with the path each of the function cd into  !!

DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/TJ/ALL/assembled-sequences_par4/Fasta4Prokka
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it

CurrentDir=$( pwd )
Thread=32 ## sav4

######################################################################


setup () {

	module load gnu-parallel
	# https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

	# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
	# foo-{}  or $foo-{}   will     prefix correctly,
	# foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!

	module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	
}

######################################################################
# prep-step
# shuffle fasta files
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it
######################################################################

setup_fasta4prokka() {

	cd $DataDir
	# cd /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/TJ/ALL/assembled-sequences_par4/Fasta4Prokka
	cd ..
	pwd
	for FILE in $( ls -d S*CKDN*fasta ) ; do cp -p  $FILE/assembly.fasta   Fasta4Prokka/$FILE ; done
	cd -

}

######################################################################
# step 2
# run_mlst
######################################################################

# this generate SeqType number...  (rely on the .fasta file renaming process in run_guat_prokka.sh run_prep4prokka, but don't otherwise need the output of prokka or roary)


run_mlst () {

	#cd  ~/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	App="mlst"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

# conda install -c conda-forge -c bioconda -c defaults mlst
# mlst {input}.fasta > $out.txt
# potentially mlst *.fasta > mlst.txt

	[[ -d MLST_OUT ]] || mkdir MLST_OUT

	# first trial by hand 
	#mlst A9_CKDN220053879-1A_HK7KTDSX5_L2.fasta >  MLST_OUT/mlst.A9.txt 
	# reran the whole thing to include A30  2023.0708

	# https://github.com/tseemann/mlst
	# header:
	#echo "Filename \tPubMLST_scheme_name \tST \tAllele_IDs" > MLST_OUT/col_header.tsv
	#echo "FILE	SCHEME	ST	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7	Allele_ID_8	Allele_ID_9	Allele_ID_10	Allele_ID_11	Allele_ID_12" > MLST_OUT/col_header.tsv
	#echo "Filename	PubMLST_scheme_name	SeqType	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7	Allele_ID_8	Allele_ID_9	Allele_ID_10	Allele_ID_11	Allele_ID_12" > MLST_OUT/col_header.tsv # changed colname to mostly match --legacy output static header
	# maybe mlst only analyze 7 allels only anyway.
	echo "Filename	PubMLST_scheme_name	SeqType	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7" > MLST_OUT/col_header.tsv # changed colname to mostly match --legacy output static header
	#echo "FILE \tSCHEME \tST \tAllele_IDs" > MLST_OUT/col_header.tsv   # get actual \t into file :-/
	mlst *.fasta >  MLST_OUT/mlst.all.raw.tsv
	cat  MLST_OUT/col_header.tsv MLST_OUT/mlst.all.raw.tsv >  MLST_OUT/mlst.all.tsv
	# mlst 2.x auto detect and choose scheme with the best score
	# thus header is variable
	# harder to parse, also may give diff ST that corresponds to diff scheme 


	#mlst --scheme ecoli *.fasta >  MLST_OUT/mlst.EC.all.txt 
	# --legacy is easier to parse output, allele always in the same col pos, and won't get non ecoli scheme (score could be low or untypable)
	# but sample isolate may not be ecoli, good to let mlst detect and determine organism
	# header will be included, since it is static for a given scheme, eg below for SCHME=ecoli
	# FILE    SCHEME  ST      adk     fumC    gyrB    icd     mdh     purA    recA
	#x mlst --legacy --scheme ecoli *.fasta >  MLST_OUT/mlst.EC.all.tsv  #-- isolate may not always be ecoli!
	# for this prj, if not ecoli scheme, probably prefer it to be untyped.

	
	# mlst --scheme
	# https://github.com/tseemann/mlst#tweaking-the-output

	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt

} # end run_mlst()


######################################################################


main () {
	setup
	cd $DataDir
	echo "Hello World! Running ... mlst for Guatemala AMR"
	setup_fasta4prokka
 	run_mlst
	cd $CurrentDir
}


main	


