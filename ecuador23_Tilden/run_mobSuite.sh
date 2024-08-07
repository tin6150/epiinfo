#!/bin/bash

# use mob-typer (one of the tool in MOB-suite)  to determine ARG in plasmid vs chromosome
# https://github.com/phac-nml/mob-suite?tab=readme-ov-file#mge-detection

# run as: 
#   bash -x ./run_mobSuite.sh 2>&1 | tee run_mobSuite.TEE_OUT
# currently in weasle only, as couldn't get mod_init to run (as prep) to create DB in container.
# see OneNote for install instruction

# mob_type takes ~1 min per fasta (bacteria)
# 55 fasta file, took 54 min on weasle with --threads 4
# got 55 report.txt
# but only 53 mge_report.txt

# mob_recon took 70 min for 55 bacteria fasta file, ~1.3 min / seq file

# mob_recon 
# actually run mob_type and generate mobtyper_results.txt report (tsv). 
# here is where there is mge.report.txt   ... combine all these... fasta filename is one of the col, so easy.


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
#for i in AA*.fasta
do
    string1="${i%.fasta}"  # this case basename $i .fasta has same result
    #echo ${string1}
	#/home/tin/.local/bin/mob_typer -i ${string1}.fasta  --out_file  ${string1}.MOBty.report.tsv  --num_threads 4 
	# echo running MOB-recon: /home/tin/.local/bin/mob_recon -i ${string1}.fasta  --outdir  ${string1}.MOBre/ --unicycler_contigs --num_threads 4 
	# /home/tin/.local/bin/mob_recon -i ${string1}.fasta  --outdir  ${string1}.MOBre/ --unicycler_contigs --num_threads 4 
	# more precise method with optional db for E.coli/Klepsiella 
	# https://github.com/phac-nml/mob-suite?tab=readme-ov-file#using-mob-recon-to-reconstruct-plasmids-from-draft-assemblies
	echo now running as /home/tin/.local/bin/mob_recon -i ${string1}.fasta  --outdir  ${string1}.MOBre2/ --unicycler_contigs -g 2019-11-NCBI-Enterobacteriacea-Chromosomes.fasta --num_threads 5 
	/home/tin/.local/bin/mob_recon -i ${string1}.fasta  --outdir  ${string1}.MOBre2/ --unicycler_contigs -g 2019-11-NCBI-Enterobacteriacea-Chromosomes.fasta --num_threads 5 
	# mge_report were all empty.
	echo "----"
done

# there was a --multi option!  But RTFM, some nuances!
# do not include multiple unrelated plasmids in the file without specifying --multi as they will be treated as a single plasmid.
# Multiple independant plasmids
#  mob_typer --multi --infile assembly.fasta --out_file sample_mobtyper_results.txt


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


cd -

# manually move result out to separate dir, should work with
# mv  *MOBty*txt  MOBty_OUT/ 

# combining results for mob_typer ::
# *.MOBty.mge_report.txt  have 0 lines, cuz no end of file marker?  all 220 bytes, just header info, no results.  ignore for now.

# *.MOBty.report.txt  have exactly 2 lines, header + output.
#    check predicted_mobility col for MGE?
# head -1 AA*.MOBty.report.txt >  combined.MOBty.report.tsv  # get 1 header line
# tail --quiet -n 1 *.MOBty.report.txt >>  combined.MOBty.report.tsv

# ~~~

# combining result for mob_recon
# mv *MOBre/ MOB_recon_OUT/
# ls *MOBre/mobtyper_results.txt | wc # 36
# ls *MOBre/mge.report.txt | wc       # 50
# ls *MOBre/chromosome.fasta | wc     # 55
# ls *MOBre/plasmid_* | wc            # 105  ## some are named with "_novel_HASH"

# mv *MOBre2/ MOB_recon_OUT_2/  # result quite different this time with the -g flag...

# test procedure using 1 sample
# head -1 Z_CKDN230030153-1A_HGKHYDSX7_L2.MOBre/mge.report.txt >   MOB_recon_combined.mge.report.tsv

# actual report
# grep -h -v ^sample_id *MOBre/mge.report.txt | grep -v ^sample_id >> MOB_recon_combined.mge.report.tsv
# these file don't have end of file char, could not use cat.  thx for -h in grep.  hopefully it is no longer a problem this way
# cp -pi MOB_recon_combined.mge.report.tsv  ~/tin-git-Ctin/epiinfo/ecuador23_Tilden/result
