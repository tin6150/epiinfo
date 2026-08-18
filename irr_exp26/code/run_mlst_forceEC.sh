#!/bin/bash

## epiinfo run mlst for Irrigation Exposure 2026 data
## based on G/Borbon 

#SBATCH --job-name=LeBoa_mlst
###SBATCH --account=scs
#SBATCH --account=fc_graham
####SBATCH --partition=savio4_htc
#SBATCH --partition=savio3
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32             ## parallel  savio3
#SBATCH --time=71:00:00


CurrentDir=$( pwd )

## be careful with the path each of the function cd into  !!

# Irr_Exp26:
DataDir=/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly



######################################################################


setup () {

	#module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	module load bio/mlst/2.19.0	# EL8

}


######################################################################
# step 
# run_mlst
######################################################################

# this generate SeqType number...  (input needed = .fasta file) 
# https://github.com/tseemann/mlst


run_mlst () {

	# cd to datadir done by calling fn
	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)

	App="mlst"
	echo "==== running $App  ===="  		| tee -a MARKER_${App}_begin.txt
	date 									| tee -a MARKER_${App}_begin.txt

	[[ -d MLST_OUT_forceEC ]] || mkdir MLST_OUT_forceEC


	printf "FILE\tSCHEME\tST\tadk\tfumC\tgyrB\ticd\tmdh\tpurA\trecA" > MLST_OUT_forceEC/col_header.tsv # legacy forced ecoli scheme header
	# seems like legacy will output the header, no need to manually add it
	cat  MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv >  MLST_OUT_forceEC/mlst.all.forceEC.tsv


	mlst --legacy --scheme ecoli *.fasta >  MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv  ## force E.coli, rely on rMLST to determine/filter out non E.coli

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


