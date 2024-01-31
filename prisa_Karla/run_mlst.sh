#!/bin/bash

## epiinfo run mlst for Karla on PRISA kids seq
## based on guatemala_amr/helper_script/run_guat_mlst.sh

## be careful with the path each of the function cd into  !!

##DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences_par3/Fasta4Prokka
DataDir=/global/scratch/users/tin/fc_graham/PRISA_scarletbliss/raw_reads/
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it

CurrentDir=$( pwd )

######################################################################


setup () {

	module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate

}


######################################################################
# step 
# run_mlst
######################################################################

# this generate SeqType number...  (rely on the .fasta file renaming process in run_guat_prokka.sh run_prep4prokka, but don't otherwise need the output of prokka or roary)


run_mlst () {

	#cd  ~/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	App="mlst"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

	[[ -d MLST_OUT ]] || mkdir MLST_OUT


	# https://github.com/tseemann/mlst
	# header:
	echo "Filename	PubMLST_scheme_name	SeqType	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7" > MLST_OUT/col_header.tsv # changed colname to mostly match --legacy output static header
	mlst *.fasta >  MLST_OUT/mlst.all.raw.tsv
	cat  MLST_OUT/col_header.tsv MLST_OUT/mlst.all.raw.tsv >  MLST_OUT/mlst.all.tsv
	# mlst 2.x auto detect and choose scheme with the best score
	# thus header is variable
	# harder to parse, also may give diff ST that corresponds to diff scheme 

	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt

} # end run_mlst()


######################################################################


main () {
	setup
	cd $DataDir
	echo "Hello World! Running ... mlst "
 	run_mlst
	cd $CurrentDir
}


main	


