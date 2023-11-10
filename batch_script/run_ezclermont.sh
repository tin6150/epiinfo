#!/bin/bash

## epiinfo Guatemala AMR ExPEC e.coli practicum project 2023 summer

# run ezclermont - tool to extract phylogroup A, B1, B2, C, D...

# run this script as:
# bash run_guat_ezclermont.sh | tee run_guat_ezclermont.TEE.OUT 


## script adapted from abricate, not edited below yet   ~~~~~~

## be careful with the path each of the function cd into  !!

#DataDir=/global/scratch/users/tin/guatemala_amr/assembled-sequences_sn
DataDir=/global/scratch/users/tin/guatemala_amr/assembled-sequences_sn/Fasta4Prokka

CurrentDir=$( pwd )
Thread=56 ## n0063.savio4

######################################################################


setup () {

	module load gnu-parallel
	# https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

	# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
	# foo-{}  or $foo-{}   will     prefix correctly,
	# foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!

	#module load unicycler/0.5.0
	#source ~tin/.bashrc_conda
	#conda activate epi
	#module load abricate/1.0.1	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	#module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	module load ezclermont/0.7.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	
}

######################################################################
# step 2
# run_ezclemont
######################################################################

# https://github.com/nickp60/EzClermont

run_ezclermont () {

	#cd  ~/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	App="ezclermont"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

# singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/0.7.0/ezclermont.sif /usr/local/bin/ezclermont $*
# ezclermont 

# tbd actual run ...

	# single fasta, quite verbose output
	# $App A30_CKDN220053900-1A_HK7HVDSX5_L1.fasta | tee $App.OUT
	$App A30_CKDN220053900-1A_HK7HVDSX5_L1.fasta | tee $App.OUT

	# example parallel run from github
	# ls ./folder/with/assemblies/*.fa | parallel "ezclermont {} 1>> results.txt  2>> results.log"

	cp /dev/null ${App}.input.lst
	echo "# input for $App with gnu parallel"
	#ls A30*.fasta > ${App}.input.lst 
	ls A*.fasta > ${App}.input.lst 
	cat ${App}.input.lst | parallel "ezclermont {} 1>> ezclermont.results.tsv  2>> ezclermont.results.log"
	# so not too picky about num of threads...  1>> ...  2>>  syntax works in bash or a gnu parallel parsed thing?
	# .tsv is short and sweet output, fasta vs phylogroup
	# .log is the long verbose output

	#[[-d MLST_OUT ]] || mkdir MLST_OUT

	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt

} # end run_mlst()


######################################################################


main () {
	setup
	cd $DataDir
	#run_unicycler	##  | tee run_unicycler.TeeOUT		# this tee out is not really useful, tangled output
	echo "hola mundo! ezclermont for Guatemala AMR"
	run_ezclermont
	cd $CurrentDir
}


main	


