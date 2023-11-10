#!/bin/bash

#SBATCH --job-name=mlst_eg
#SBATCH --account=scs   #fc_graham
#SBATCH --partition=savio2_htc
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=05:30:00




cd /global/home/users/tin/gs/demo/PRISA_demo/raw_reads



# run mlst
# ie utilize output from unicycler
# essentially, run:
# mlst {input}.fasta > $out.txt
# https://github.com/tseemann/mlst

# run this script as:
# local machine: 
# bash run_mlst.sh | tee run_guat_mlst.OUT.TXT
# or cluster 
# sbatch run_mlst.sh


######################################################################


setup () {
	module purge

	[[ -d ~/.parallel ]] || mkdir ~/.parallel 
	touch ~/.parallel/will-cite
	module load gnu-parallel
	# https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

	# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
	# foo-{}  or $foo-{}   will     prefix correctly,
	# foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!

	module load mlst/2.19.0	
	
}

######################################################################
# step 2
# run_mlst
######################################################################

# this generate SeqType number...  (rely on the .fasta file renaming process in run_guat_prokka.sh run_prep4prokka, but don't otherwise need the output of prokka or roary)


run_mlst () {

	# expect  .fasta as files, (see run_guat_prokka.sh run_prep4prokka)


	[[-d MLST_OUT ]] || mkdir MLST_OUT

	# https://github.com/tseemann/mlst
	# header:
	#echo "Filename \tPubMLST_scheme_name \tST \tAllele_IDs" > MLST_OUT/col_header.tsv
	echo "FILE \tSCHEME \tST \tAllele_IDs" > MLST_OUT/col_header.tsv   # changed colname to mostly match --legacy output static header
	# mlst *.fasta >  MLST_OUT/mlst.all.tsv
	# mlst 2.x auto detect and choose scheme with the best score
	# thus header is variable
	# harder to parse, also may give diff ST that corresponds to diff scheme 


	#mlst --scheme ecoli *.fasta >  MLST_OUT/mlst.EC.all.txt 
	# --legacy is easier to parse output, allele always in the same col pos, and won't get non ecoli scheme (score could be low or untypable)
	# header will be included, since it is static for a given scheme, eg below for SCHME=ecoli
	# FILE    SCHEME  ST      adk     fumC    gyrB    icd     mdh     purA    recA
	mlst --legacy --scheme ecoli *.fasta >  MLST_OUT/mlst.EC.all.tsv
	# for this prj, if not ecoli scheme, probably prefer it to be untyped.

	
} # end run_mlst()


######################################################################


main () {
	setup
	run_mlst
}


main	


