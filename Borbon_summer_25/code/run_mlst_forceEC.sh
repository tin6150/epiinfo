#!/bin/bash

## epiinfo run mlst for G Borbon_summer_25
## based on mission2022/guatemala/helper_script/run_guat_mlst.sh  # now cuz forcing EC in mlst run
#### 2026.0411 version, force specie to EC, will will rMLST to filter out non EC

## be careful with the path each of the function cd into  !!

#DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/TJ/ALL/assembled-sequences_par4/Fasta4Prokka
DataDir=/global/home/users/tin/gs/dataCache/_Doug_Gabrielle_WGS_Data/Summer_2025_WGS_Sequences/AI-1608_results/AI-1608_assembly/Borbon_summer_25_Gabrielle
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it

CurrentDir=$( pwd )

######################################################################


setup () {

	#module load mlst/2.19.0	# see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate
	module load bio/mlst/2.19.0	# EL8

}

######################################################################
# prep-step
# shuffle fasta files
# manually shuffle files into Fasta4Prokka/ subdir, as upstream process created fasta dir with many gfa files in it
######################################################################

xxx_setup_fasta4prokka() {

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

	[[ -d MLST_OUT_forceEC ]] || mkdir MLST_OUT_forceEC


	# https://github.com/tseemann/mlst
	# header:
	#// echo "Filename	PubMLST_scheme_name	SeqType	Allele_ID_1	Allele_ID_2	Allele_ID_3	Allele_ID_4	Allele_ID_5	Allele_ID_6	Allele_ID_7" > MLST_OUT/col_header.tsv # changed colname to mostly match --legacy output static header
	#echo "FILE    SCHEME  ST      adk     fumC    gyrB    icd     mdh     purA    recA" > MLST_OUT_forceEC/col_header.tsv # fix TBD
	#// mlst *.fasta >  MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv
	# mlst 2.x auto detect and choose scheme with the best score
	# thus header is variable
	# harder to parse, also may give diff ST that corresponds to diff scheme 

	printf "FILE\tSCHEME\tST\tadk\tfumC\tgyrB\ticd\tmdh\tpurA\trecA" > MLST_OUT_forceEC/col_header.tsv # legacy forced ecoli scheme header
	#cat  MLST_OUT_forceEC/col_header.tsv MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv >  MLST_OUT_forceEC/mlst.all.forceEC.tsv
	# seems like legacy will output the header, no need to manually add it
	cat  MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv >  MLST_OUT_forceEC/mlst.all.forceEC.tsv

	mlst --legacy --scheme ecoli *.fasta >  MLST_OUT_forceEC/mlst.all.forceEC.raw.tsv

	echo $? | tee -a MARKER_${App}_end.txt
	uptime  | tee -a MARKER_${App}_end.txt
	date    | tee -a MARKER_${App}_end.txt

} # end run_mlst()


######################################################################


main () {
	setup
	cd $DataDir
	echo "Hello World! Running ... mlst "
	#xxx setup_fasta4prokka
 	run_mlst
	cd $CurrentDir
}


main	


