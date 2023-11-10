#!/bin/bash

#SBATCH --job-name=savio_demo_abricate
#SBATCH --account=scs   #fc_graham
#SBATCH --partition=savio2_htc
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=00:30:00

module purge
module load gnu-parallel
module load python
module load abricate/1.0.1

[[ -d ~/.parallel ]] || mkdir ~/.parallel 
touch ~/.parallel/will-cite


cd /global/home/users/tin/gs/demo/PRISA_demo/raw_reads

basename -s .fasta  -a *.fasta  > task.list

parallel -j 2 -a task.list  'abricate --db vfdb {}.fasta >  {}_vfdb.tsv'

abricate --summary *_vfdb.tsv  > vfdb_summary.tsv
