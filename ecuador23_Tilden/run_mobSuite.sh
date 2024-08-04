#!/bin/bash

# use mob-typer (one of the tool in MOB-suite)  to determine ARG in plasmid vs chromosome
# https://github.com/phac-nml/mob-suite?tab=readme-ov-file#mge-detection

# run as: ./run_mobSuite.sh
# currently in weasle only, as couldn't get mod_init to run (as prep) to create DB in container.
# see OneNote for install instruction


#SBATCH --job-name=TBD
#SBATCH --account=scs                 ###alt: --account=fc_graham
#SBATCH --partition=savio4_htc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8           ## unicycler does not seems to use that many cpu, def -t=8  
#SBATCH --time=12:00:00				## unicycler for 1 fq.gz seq of E.coli is about 1.5 hours with 8 threads on sav4
###SBATCH --time=71:00:00

#### https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/


echo "random stuff might be useful for posterity.  pre run"
date
hostname
uname -a
uptime
echo "================"


#module purge
#module load gcc python java clang cmake     samtools #blast bowtie2  these not in el8 atm
#module load bio/unicycler/0.5.0		# el8 placed in /global/software/rocky-8.x86_64/modfiles/apps/bio/


echo "================"

#DataDir=/global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL
DataDir=/mnt/c/tin/dataCache/shrimp_ec23/
cd $DataDir



#for i in *_1.fq.gz


# this script doesn't make the output dir in -o "assembled-sequences", unicycler mkdir it I suppose...

# this has 55 files, but only used 44 seq.  oh well.
for i in *.fasta
do
    string1="${i%.fasta}"  # this case basename $i .fasta has same result
    #echo ${string1}
	echo running: /home/tin/.local/bin/mob_typer -i ${string1}.fasta  --out_file  ${string1}.MOBty.report.txt --mge_report_file ${string1}.MOBty.mge_report.txt --num_threads 4 
	/home/tin/.local/bin/mob_typer -i ${string1}.fasta  --out_file  ${string1}.MOBty.report.txt --mge_report_file ${string1}.MOBty.mge_report.txt --num_threads 4 
	echo "----"
done

echo $?

echo "random stuff might be useful for posterity.  post run"
date
hostname
uname -a
uptime
echo "================"

echo "ls dont work cuz not in cwd, trying these things"

#scontrol show job "$SLURM_JOB_ID" 
echo ""
#scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}'
echo ""

#echo "cmd from https://stackoverflow.com/questions/56962129/how-to-get-original-location-of-script-used-for-slurm-job"
#echo ""
#if [ -n "${SLURM_JOB_ID:-}" ] ; then
#THEPATH=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
#else
#THEPATH=$(realpath "$0")
#fi

#echo $THEPATH  # eg /global/scratch/users/tin/tin-gh/epiinfo/ecuador23_Tilden/assemble_paired.sh
#echo "ls..."
#THEPATH_NoScriptName=$( dirname $THEPATH )
#ls -l $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out 
##cp -p $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out   ${DataDir}/assembled-sequences/  && mv $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out ~/TMP/   # essentially delete if successful cp
#echo "ls...2"
#ls -l $THEPATH_NoScriptName/slurm-${SLURM_JOB_ID}.out   ${DataDir}/assembled-sequences/  ~/TMP/ 


#ls -l slurm-${SLURM_JOB_ID}.out 
#echo try to mv slurm-${SLURM_JOB_ID}.out to the output dir --or cp if moving across fs is a problem...



# manually move result out to separate dir, should work with
# mv  *MOBty*txt  MOBty_OUT/ 
