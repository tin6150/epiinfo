#!/bin/bash

## epiinfo run mlst for TJ Ecuador data

## this script generate cgMLST (to further profile whether two seq are duplicate)
## cgMLST Nike recoomends web site, https://cge.food.dtu.dk/services/cgMLSTFinder/
## here, try to use chewbbaca cli, said to generate cgMLST (and wgMLST).  
## https://chewbbaca.readthedocs.io/en/latest/user/getting_started/installation.html

## be careful with the path each of the function cd into  !!

DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences_par3/Fasta4Prokka
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it

CurrentDir=$( pwd )

######################################################################


setup () {

	#module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	# mlst was in /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mlst/2.19.0/mlst
	export PATH=$PATH:/clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mlst/2.19.0
	export PATH=$PATH:/global/software/rocky-8.x86_64/manual/modules/apps/bio/bioabricate/1.0.1/ 
	export PATH=$PATH:/global/scratch/users/tin/cacheDir  # SINGULARITY_CACHEDIR

}


######################################################################
# step XX
# run_chewbbaca to generate cgMLST
# ++ need download DB first ... TBD ++
######################################################################

# this generate SeqType number...  (rely on the .fasta file renaming process in run_guat_prokka.sh run_prep4prokka, but don't otherwise need the output of prokka or roary)


run_chewbbaca() {

	#cd  ~/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	App="chewbbaca"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

	[[ -d cgMLST_OUT ]] || mkdir cgMLST_OUT


	# https://github.com/tseemann/mlst
	# header:
	# echo "Filename	PubMLST_scheme_name	SeqType	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7" > MLST_OUT/col_header.tsv # changed colname to mostly match --legacy output static header

	### hmm... may need to get a db for cgMLST with chewbbaca... https://chewbbaca.readthedocs.io/en/latest/user/modules/ExtractCgMLST.html
	### stopping for now ++

	#mlst *.fasta >  MLST_OUT/mlst.all.raw.tsv
	#cat  MLST_OUT/col_header.tsv MLST_OUT/mlst.all.raw.tsv >  MLST_OUT/mlst.all.tsv
	# mlst 2.x auto detect and choose scheme with the best score
	# thus header is variable
	# harder to parse, also may give diff ST that corresponds to diff scheme 

	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt

} # end run_chewbbaca()


######################################################################


main () {
	setup
	cd $DataDir
	echo "Hello World! Running ... chewbbaca to generate cgMLST"
	#-- setup_fasta4prokka  # file shuffle done by run_MLST
 	run_chewbbaca
	cd $CurrentDir
}


main	


