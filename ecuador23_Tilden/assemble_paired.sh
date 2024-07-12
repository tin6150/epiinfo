#!/bin/bash

# use unicycler to assemble the sequence.

# run as: sbatch assemble_paired.sh


#SBATCH --job-name=Tilden_assemble
#SBATCH --account=scs                 ###alt: --account=fc_graham
#SBATCH --partition=savio4_htc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8           ## unicycler does not seems to use that many cpu, def -t=8  
#SBATCH --time=12:00:00				## unicycler for 1 fq.gz seq of E.coli is about 1.5 hours with 8 threads on sav4
###SBATCH --time=71:00:00

#### https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

# unicycler | abricate
# fastqc

date

module purge
module load gcc python java clang cmake     samtools blast bowtie2
module load unicycler/0.5.0



DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL
cd $DataDir


## below is the original script Gaby ran, check that string1 is still evaluating correctly 

#for i in *_1.fq.gz
# reprocess this one, somehow no assembled fasta file for this.  2024-0627
# using --mode bold --> crashed
# using --mode conservative --> crashed
# using -t 1 ...  and see if it can produce fasta output.  nope, still crash.
# if still crash, might try -t THREADS , lower it, def is 8.   # apparently prev job submitted with req of 6 cores only.


# this script doesn't make the output dir in -o "assembled-sequences", unicycler mkdir it I suppose...

for i in I_CKDN230030142-1A_HGKHYDSX7_L2_1.fq.gz
do
    string1="${i%_1.fq.gz}"
    #echo ${string1}
	echo running: unicycler -1 ${string1}_1.fq.gz -2 ${string1}_2.fq.gz -o /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences/${string1}.fasta --min_fasta_length 500 --mode normal -t 4  --mode bold
	unicycler -1 ${string1}_1.fq.gz -2 ${string1}_2.fq.gz -o /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences/${string1}.fasta --min_fasta_length 500 --mode normal -t 4  --mode bold

	#crashed# unicycler -1 ${string1}_1.fq.gz -2 ${string1}_2.fq.gz -o /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences/${string1}.fasta --min_fasta_length 500 --mode normal -t 1 
	echo "----"
done

echo $?

echo "random stuff might be useful for posterity"
date
hostname
uname -a
uptime


echo "ls dont work cuz not in cwd, trying these things"

scontrol show job "$SLURM_JOB_ID" 
echo ""
scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}'
echo ""

echo "cmd from https://stackoverflow.com/questions/56962129/how-to-get-original-location-of-script-used-for-slurm-job"
echo ""
if [ -n "${SLURM_JOB_ID:-}" ] ; then
THEPATH=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
else
THEPATH=$(realpath "$0")
fi

echo $THEPATH  # eg /global/scratch/users/tin/tin-gh/epiinfo/ecuador23_Tilden/assemble_paired.sh
echo "ls..."
THEPATH_NoScriptName=$( dirname $THEPATH )
ls -l $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out 
cp -p $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out   ${DataDir}/assembled-sequences/


#ls -l slurm-${SLURM_JOB_ID}.out 
#echo try to mv slurm-${SLURM_JOB_ID}.out to the output dir --or cp if moving across fs is a problem...
