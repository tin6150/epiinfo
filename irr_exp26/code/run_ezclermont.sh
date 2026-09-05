#!/bin/bash

## epiinfo pathotype determination using ezClermont 

# run ezclermont - tool to extract phylogroup A, B1, B2, C, D...

# run this script as:
# sbatch run_ezclermont.sh 
# or 
# bash run_ezclermont.sh | tee run_ezclermont.TEE.OUT 



#SBATCH --job-name=LeBoa_pathotype
###SBATCH --account=scs
#SBATCH --account=fc_graham
####SBATCH --partition=savio4_htc
#SBATCH --partition=savio3
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#####SBATCH --cpus-per-task=56             ## parallel  savio4
#SBATCH --cpus-per-task=1             ## 32 parallel  savio3, but not needed for ezclermont
#SBATCH --time=71:00:00

## be careful with the path each of the function cd into  !!

#DataDir=/global/scratch/users/tin/guatemala_amr/assembled-sequences_sn
DataDir=/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly


CurrentDir=$( pwd )
#Thread=56 ## n0027.savio4 
#Thread=32 ## .savio3
Thread=1   ## good enough for ezclermont till module load works.

######################################################################


setup () {

	#module load bio/abricate/1.0.1  # EL8
	module load bio/ezclemont/1.0.0  # EL8     ## files in /global/software/vector/sl-7.x86_64/modfiles/ezclermont but module/lmod not finding it, need "rehash" of sort?
	module load parallel/20220522   # EL8

	#module load gnu-parallel
	touch ~/.parallel/will-cite
	# https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

	# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
	# foo-{}  or $foo-{}   will     prefix correctly,
	# foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!

	#module load ezclermont/0.7.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	#module load ezclermont/1.0.0	# 2026 May - docker://quay.io/biocontainers/ezclermont:1.0.0--pyhdfd78af_0
	
}

version () {
	echo "------VERSION_INFO-------"
	hostname; date; uptime;
	echo "version via full singularity invokation"
	singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/1.0.0/ezclermont1.0.0.sif /usr/local/bin/ezclermont --version
	echo "-------------"
	singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/1.0.0/ezclermont1.0.0.sif /usr/local/bin/ezclermont -h
	echo "-------------"
	echo "-------------"
	echo "version via module setup"
	which ezclermont 
	ezclermont --version
	echo "-------------"
	ezclermont -h
	echo "-------------"
	echo "-------------"
	echo "---- gnu parallel info ---------"
	parallel --version
	parallel -h
	echo "------VERSION_INFO--END-----"
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
# singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/1.0.0/ezclermont1.0.0.sif /usr/local/bin/ezclermont $*
# ezclermont 

# tbd actual run ... 2026.0905

	# single fasta, quite verbose output
	# $App A30_CKDN220053900-1A_HK7HVDSX5_L1.fasta | tee $App.OUT
	#~~$App A30_CKDN220053900-1A_HK7HVDSX5_L1.fasta | tee $App.OUT

	# example parallel run from github
	# ls ./folder/with/assemblies/*.fa | parallel "ezclermont {} 1>> results.txt  2>> results.log"

	cp /dev/null ${App}.input.lst
	echo "# input for $App with gnu parallel"
	#ls A30*.fasta > ${App}.input.lst 
	# eg filename for LeBoa irr_exp26 dataset AI-5395_72_74_assembly.fasta
	ls AI-5395*.fasta > ${App}.input.lst 
	# module load isn't working for 1.0.0
	#cat ${App}.input.lst | parallel "ezclermont {} 1>> ezclermont.results.tsv  2>> ezclermont.results.log"
	# using full singularity cli, format dont work well with parallel, need more debug.  
	#xx cat ${App}.input.lst | parallel "singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/1.0.0/ezclermont1.0.0.sif /usr/local/bin/ezclermont {} 1>> ezclermont.results.tsv  2>> ezclermont.results.log"

	# ezclearmont completes very quickly, no need for parallel, just run directly
	for SeqFile in `ls AI-5395*.fasta`; do
		singularity  exec /global/software/vector/sl-7.x86_64/modules/ezclermont/1.0.0/ezclermont1.0.0.sif /usr/local/bin/ezclermont $SeqFile  1>> ezclermont.results.tsv  2>> ezclermont.results.log
	done
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
	hostname; uptime; date;
	setup
	version
	cd $DataDir
	#run_unicycler	##  | tee run_unicycler.TeeOUT		# this tee out is not really useful, tangled output
	echo "==== "
	echo "==== "
	echo "==== hola mundo! ezclermont for irr_exp26 starting"
	echo "==== "
	echo "==== "
	run_ezclermont
	echo $?
	echo "==== done ezclermont for irr_exp26"
	cd $CurrentDir
	hostname; uptime; date;
}


main	


