#!/bin/bash

# fastqc here


#SBATCH --job-name=Tilden_par_assemble
#SBATCH --account=scs                 ###alt: --account=fc_graham
#SBATCH --partition=savio4_htc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=56             ## parallel
#SBATCH --time=71:00:00



module purge
module load fastqc/0.11.9   # load java

cd /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/TJ/ALL

[[ -d ./fastqc_output ]] || mkdir ./fastqc_output


date | tee -a fastqc_output/flag.start
fastqc  --noextract --threads 52 *.fq.gz -o ./fastqc_output

echo $? | tee -a fastqc_output/flag.end
date | tee -a fastqc_output/flag.end


