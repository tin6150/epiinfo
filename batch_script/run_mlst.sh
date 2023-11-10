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

# mlst generate SeqType number...  

run_mlst () {

	# expect  .fasta as input files

	[[-d MLST_OUT ]] || mkdir MLST_OUT

	mlst --legacy --scheme ecoli *.fasta >  MLST_OUT/mlst.EC.all.tsv
	# for this prj, if not ecoli scheme, probably prefer it to be untyped.

	
} # end run_mlst()


######################################################################


main () {
	setup
	run_mlst
}


main	


