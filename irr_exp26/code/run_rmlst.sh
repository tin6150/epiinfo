#!/bin/bash

## epiinfo run rmlst rMLST ribosomal MLST 

## be careful with the path each of the function cd into  !!

#DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/TJ/ALL/assembled-sequences_par4/Fasta4Prokka
#DataDir=/global/home/users/tin/gs/dataCache/_Doug_Gabrielle_WGS_Data/Summer_2025_WGS_Sequences/AI-1608_results/AI-1608_assembly/Borbon_summer_25_Gabrielle
# Irr_Exp26: 
DataDir=/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly


# some dataset need preSetup to manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it

CurrentDir=$( pwd )

######################################################################


setup () {

	#module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	#module load bio/mlst/2.19.0	# EL8
	echo "" # no-op

}


######################################################################
# step 2
# run_rmlst
######################################################################

# this generate SeqType number...  (rely on the .fasta file renaming process in run_guat_prokka.sh run_prep4prokka, but don't otherwise need the output of prokka or roary)


run_rmlst () {

	#cd  ~/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	App="rmlst"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

	[[ -d rMLST_OUT ]] || mkdir rMLST_OUT

	# Irr_Exp26: 
	# dataDir /global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly
	# eg filename: AI-5395_10_10_assembly.fasta  AI-5395_24_24_assembly.fasta 
	# run rMLST on fasta to be sure isolate is E.coli, filter them out if not.  subsequent run with mlst will use force ecoli scheme.
	# cmd from
	#  cat nonEcoliPerMlst.tsv | awk -F. '{print "/global/home/users/tin/gs/opt/rmlst/rmlst.py --file " $1 ".fasta | tee " $1 ".rMlst.txt " }' > run_rmlst.sh


for SEQ_FILE in `ls AI*.fasta`; do
	FILE_STEM=$(basename -s .fasta $SEQ_FILE)
	/global/home/users/tin/gs/opt/rmlst/rmlst.py --file $SEQ_FILE | tee ${FILE_STEM}.rMlst.txt
	sleep 10   # it is web service, don't want to be too agressive
	# rmlst.py is from https://pubmlst.org/species-id/species-identification-via-api#python
done


	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt


	mv AI*.rMlst.txt  rMLST_OUT
} # end run_rmlst()


######################################################################


main () {
	setup
	cd $DataDir
	echo "Hello World! Running ... rmlst "
	#xxx setup_fasta4prokka
 	run_rmlst
	cd $CurrentDir
}


main	


