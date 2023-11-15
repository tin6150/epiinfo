#!/bin/bash

# use unicycler to assemble the sequence.


#SBATCH --job-name=Tilden_par_assemble
#SBATCH --account=scs                 ###alt: --account=fc_graham
#SBATCH --partition=savio4_htc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=56             ## parallel
#SBATCH --time=71:00:00

#### https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

# unicycler | prokka | abricate
# fastqc?

module purge
module load gcc python java clang cmake     samtools blast bowtie2
module load unicycler/0.5.0

module load gnu-parallel
touch ~/.parallel/will-cite


cd /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL
[[ -d assembled-sequences_par3 ]] || mkdir assembled-sequences_par3


## below is the original script Gaby ran, check that string1 is still evaluating correctly 

cp /dev/null ./task.lst

for i in *_1.fq.gz
do
    string1="${i%_1.fq.gz}"
    echo $string1 >> task.lst

	#echo running: unicycler -1 ${string1}_1.fq.gz -2 ${string1}_2.fq.gz -o /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences/${string1}.fasta --min_fasta_length 500


done

parallel -j 14 -a task.lst  unicycler -1 {}_1.fq.gz -2 {}_2.fq.gz -o ./assembled-sequences_par3/{}.fasta --min_fasta_length 500

