#!/bin/bash
#SBATCH --job-name=prisa_prokka_3
#SBATCH --account=fc_PINAME
#SBATCH --partition=savio4_htc
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --time=72:00:00

## for parallel -j 56 .... needed to use --ntasks=1 --cpus-per-task=56  (savio4 nodes with 56 cores)



## epiinfo run prokka
## but new wisdom is to run bakta instead - https://github.com/oschwengers/bakta

## adapted from run_kpg_prokka.sh

## early attempt to create script that can process fasta data 
## that can be fitted as a job script
## pipeline 1 proposed by Niko
## prooka | roary | snp-sites | raxml

## be careful with the path each of the function cd into  !!

#### have repeatedly modified this to run various pieces,
#### mostly cuz need gff in certain filename format.  (strict taxa name in (phylip) limited to 10 chars)



#xx DataDir=~/gs/klebsiella/KPC_Klebsiella_Outbreak/Fastq_files_from_APHL/assembled-seq-comb/
DataDir=/global/scratch/users/tin/guatemala_amr/assembled-sequences_sn

CurrentDir=$( pwd )
Thread=56 ## n0059.savio4  # RAxML use all core, single instance
#Thread=16 ## n0059.savio4  (roary detect core count, parallel doesn't know that, this prevent super overloading)  done < 10 min, max load 82.91
# snp-sites not multi-threaded

######################################################################

setup () {

	module load gnu-parallel
	# https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/


	echo "will cite" | parallel --citation # to prevent it from stopping process
	# https://www.gnu.org/software/parallel/parallel_tutorial.html#transferring-environment-variables-and-functions
	# env_parallel will allow variables to be passed as env vars , otherwise 
	# source $( which env_parallel.bash )

	# better use parallel --env ... but need SERVER name...
	# export SERVER=localhost

	# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
	# foo-{}  or $foo-{}   will     prefix correctly,
	# foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!
}


######################################################################
# step PRE-1 ie prep step before running prooka
# mostly shuffle/rename files to feed prooka
######################################################################
run_prep4prokka () {
	# list of commands
	# probably run them manually rather than in script, at least for now
	# very case specific
	# could make prokka read unicycle output of name.fasta/assembly.fasta
	# but then output filename would be all the same
	# thus making a copy for prooka to use.
	# could be link, but cp is easier to undo if there is mistake :P
	cd /global/home/users/tin/gs/guatemala_amr/assembled-sequences_sn
	mkdir Fasta4Prokka
	#for FILE in $( ls -d A30*CKDN*fasta ) ; do cp -p  $FILE/assembly.fasta   Fasta4Prokka/$FILE ; done   # 1 time reprocess for A30
	for FILE in $( ls -d A*CKDN*fasta ) ; do cp -p  $FILE/assembly.fasta   Fasta4Prokka/$FILE ; done
	cd -

	## A26_CKDN220053896-1A_HK7KTDSX5_L1.fasta/assembly.fasta - no such file... ok, can ignore, L2 is what's in the finale_isolate_list
	## A26_CKDN220053896-1A_HK7H7DSX5_L2.fasta   has assembly.fasta
	##                         ^^
	## A30 only got fasta file so can run mlst.  rest of this script (prokka, roary, etc) not ran for A30 yet.
}

######################################################################
# step 1
######################################################################


# before running this prokka step for KPC data 
# had to shuffle files output by unicycle, since i had 2 dirs for paired vs unpaired
# and didn't like the NUM.fasta/assembly.fasta file name struc

# cd ~/gs/klebsiella/KPC_Klebsiella_Outbreak/Fastq_files_from_APHL/assembled-seq/302.fasta
# mkdir ../TMP/assembled-seq-unpaired
# for FILE in $( ls -d assembled-seq/*fasta assembled-seq-unpaired/*fasta ) ; do cp -p  $FILE/assembly.fasta   ../TMP/$FILE; done


## ++ maybe not finding match for filename... ++

run_prokka () {
	echo '==== running prokka via gnu parallel ====' 		| tee -a MARKER.prokka.begin.txt
	date | tee -a MARKER.prokka.begin.txt

	[[ -d PROKKA ]] || mkdir PROKKA 

	#XX OrgList="dog chicken cow goose guinea pig quail rabbit sheep"  ## animal   = 371 ## rerun to gen 9chars taxaname
	OrgList="EC" # ecoli KPC ...
	for ORG in $OrgList; do

		#cd $ORG
		cd Fasta4Prokka

		export $ORG
		basename -s .fasta -a *.fasta > prokka.task.lst
		#parallel ... may want to reduce $Thread... or have prokka only use 1 core rather than detecting cores again
		parallel -j $Thread -a prokka.task.lst \
		singularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/prokka/1.14.5/prokka.sif prokka --outdir PROKKA  --prefix $ORG-{}               --compliant --force {}.fasta
		## >> best of $ORG-{}.gff produced by prokka is 9 chars in basename, paup nexus file has 10 chars limit, and put a tab char as a separator
		#XXsingularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/prokka/1.14.5/prokka.sif prokka --outdir PROKKA_9CHAR  --prefix $ORG-{} --centre _pilon --compliant --force {}.fasta
		#singularity exec /global/scratch/users/tin/cacheDir/prokka.sif prokka --outdir PROKKA  --prefix $ORG-{} --centre _pilon --compliant --force {}.fasta
		# dont use $ORG_{}, that wont parse correctly

		# --force will use existing output_3 folder if it already exist
		# --center _labName can be used to remove strings in fasta header containing the center/lab name (make name sorter for downstream display benefit)

		# mv PROKKA ..
		cd ..
	done
	echo $? | tee -a MARKER.prokka.end.txt
	uptime  | tee -a MARKER.prokka.end.txt
	date    | tee -a MARKER.prokka.end.txt

}


######################################################################
# step 1b
######################################################################

rename_gff() {
	echo see renameGff.Rmd, which rename all gff to 9 chars filename  so that paup can create .nex file with 10 chars name 
	# cuz step 2 roary take those filenames and placed in single phy file

	echo "see naming3.sh generated by groupGff.Rmd for naming with host org"
	cd /global/home/users/tin/gs/guatemala_amr/assembled-sequences_sn/Fasta4Prokka/PROKKA
	naming3.sh
	mkdir ../PROKKA_3
	mv nc*gff cc*gff ../PROKKA_3
}


######################################################################
# step 2
# roary, convert series of gff to single phy 
# good to have gff files to have exactly 9 chars... so rename before running this
######################################################################

run_roary () {
	#cd anim66/PROKKA/
	#cd ggqrs9/PROKKA_9CHAR
	#cd animal/PROKKA         # 2022.1230 renam3.sh fixed gff to 9CHAR
	cd Fasta4Prokka
	#cd ./PROKKA         #  gff to 9CHAR
	cd ./PROKKA_3        #  gff with nc or cc for host org prefix (still 9 char filename)

	echo "==== running roary ====" | tee -a MARKER.roary.begin.txt

	date >> MARKER.roary.begin.txt
	#singularity exec /global/scratch/users/tin/cacheDir/phylotool.sif roary -e -mafft -p 56 *.gff
	singularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/phylotool/u20.04/phylotool.sif roary -e -n -mafft -p $Thread *.gff
	# -p 28 is thread, don't seems too parallel
	# -e        create a multiFASTA alignment of core genes using PRANK
    # -n        fast core gene alignment with MAFFT, use with -e   
	# -g 6000 # allow for more clusters, 60000 needed?

	## see https://github.com/sanger-pathogens/Roary/issues/349
	## E.coli tends to be very plastic, and has a small core genome. Roary is designed to work with things that are genetically close. Also draft genomes tend to produce a lot of small hypothetical genes. You might want to filter those out


	echo $? 	>> MARKER.roary.end.txt
	uptime  	>> MARKER.roary.end.txt
	date 		>> MARKER.roary.end.txt


	cd ..
	cd ..
}



######################################################################

run_snp-sites () {
	cd Fasta4Prokka
    #cd ./PROKKA         # same dir as roary above
    cd ./PROKKA_3         # same dir as roary above


	echo "==== running snp-sites ====" 		| tee -a MARKER.snp-sites.begin.txt


	date | tee -a MARKER.snp-sites.begin.txt
	#// snp-sites -p  -o ccggprqs.phy core_gene_alignment.aln

	#### taxa name length issue here
	#### if roary had .gff with 10 chars for file basename
	#### snp-sites generate .phy that still have a tab after the taxa name, before seq
	#### think this might create a first char as tab for paup toNexus cmd and may fail for mb (worked in paup)
	#### and if .gff name dont have - in it, then taxa name in .nex wont have quotes around them, but quotes are problem for MrBayes, not Paup

	#// singularity exec /global/scratch/users/tin/cacheDir/phylotool.sif \
	singularity exec  /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/phylotool/u20.04/phylotool.sif \
	  snp-sites -p  -o ECgua_9ch.phy   core_gene_alignment.aln
	  #snp-sites -p  -o ECkpc_9ch.phy   core_gene_alignment.aln
	  #snp-sites -p  -o animal_9char.phy   core_gene_alignment.aln
	echo $? 	| tee -a  MARKER.snp-sites.end.txt
	uptime  	| tee -a  MARKER.snp-sites.end.txt
	date 		| tee -a  MARKER.snp-sites.end.txt


	cd ..
	cd ..
}


######################################################################

run_raxml () {
	echo "==== running raxml ====" 	| tee -a MARKER.raxml.begin.txt
	date 							| tee -a MARKER.raxml.begin.txt

	cd Fasta4Prokka
	#cd ./PROKKA/
	cd ./PROKKA_3/
	# need to set number of threads for raxml ... -T 28

	singularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/phylotool/u20.04/phylotool.sif \
    raxmlHPC-PTHREADS-AVX  -s ECgua_9ch.phy        -n ECgua_raxml.tre      -m GTRCAT -f a -x 123 -N autoMRE -p 456  -T $Thread
    #raxmlHPC-PTHREADS-AVX  -s ECkpc_9ch.phy        -n ECkpc_raxml.tre      -m GTRCAT -f a -x 123 -N autoMRE -p 456  -T $Thread
    #raxmlHPC-PTHREADS-AVX  -s animal.phy           -n animal.tre           -m GTRCAT -f a -x 123 -N autoMRE -p 456  -T $Thread
	echo $? | tee -a  MARKER.raxml.end.txt
	uptime  | tee -a  MARKER.raxml.end.txt
	date    | tee -a  MARKER.raxml.end.txt



	cd ../
	cd ../
}


######################################################################
# paup need a nexus file, see devNotes.paup.md on construction

run_paup () {

        #/clusterfs/vector/home/groups/software/sl-7.x86_64/modules/paup/4.0a/paup --version
        module load paup/4.0a

		# cd /global/scratch/users/tin/klebsiella/KPC_Klebsiella_Outbreak/Fastq_files_from_APHL/assembled-seq-comb/PROKKA
		# paup
        # paup> toNexus / format=PHYLIP fromFile=ECkpc_9ch.phy  toFile=ECkpc_9ch.nex interleaved=yes
		# https://docs.google.com/presentation/d/1fcrbiF69tg3pQUzLrh5D5ud-NfluSI-NxGCZDo-WUyc/edit#slide=id.g1a2141510d7_0_18
		# vi .nex to add commands for tree generation
		# paup ECkpc_9ch.nex

		echo '
  cd /global/home/users/tin/gs/klebsiella/KPC_Klebsiella_Outbreak/Fastq_files_from_APHL/assembled-seq-comb/PROKKA/PAUP_run2
  # n58sav4 M5_s1 bottom

  log file=ECkpc_trees_P2.LOG;
  set autoclose=yes warnreset=no increase=auto;
  set crit=likelihood;
  lset nthread=8;

  execute ECkpc_9ch.nex

  nj;
  lset nst=2 tratio=est basefreq=est rates=gamma shape=est;
  lscores 1;
  lset tratio=prev basefreq=prev shape=prev;
  hs start=1;
[! start 11:13 2023.0402, take just 1 min, it is a small tree! ]

  savetrees file=ECkpc_paup_RUN2_1.tre replace=yes;


  lset tratio=est basefreq=est shape=est;
  lscores 1;
[! start 11:18 2023.0402, taking a long time too! ]

  lset tratio=prev basefreq=prev shape=prev;
  hs start=1;
  savetrees file=ECkpc_paup_RUN2_2.tre replace=yes;

		'
	echo '
	# GTR+G ML under PAUP3
	# after producing tree 3_1
	# as otherwise it would be same as run 2

	lset nst=6 tratio=est basefreq=est rates=gamma shape=est;
	lset tratio=est basefreq=est shape=est;

  	lscores 1;
	[! Unexpected matrix diagonalization failure. ]

	# trying from scratch as PAUP_run4

		'
}
######################################################################


# adapted from run_prisa_pipeline4_beast1.sh
run_beast () {
	echo argggg... have to generate a xml file using that gui... tbd	

}
######################################################################


run_tbd () {
	singularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/phylotool/u20.04/phylotool.sif run_gubbins
	#tbd /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/phylotool/u20.04/run_gubbins
	singularity exec /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/snippy/4.6.0/snippy.sif /usr/local/bin/snippy 
	/clusterfs/vector/home/groups/software/sl-7.x86_64/modules/snippy/4.6.0/snippy
	# /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/beast/2.6.4/beast
	# /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/beast/2.6.4/beast2.6.4-beagle.sif --beagle_Info #??

}

######################################################################


main () {
	setup
	cd $DataDir
	#run_prokka		# apr 17 ran this for guat data , albeing can't find MARKER*txt file, but whatever
	#rename_gff		# probably should rename before rest of steps.
	run_roary		# 9 chars gff filename as input.   start 2023.0507
	run_snp-sites 
	run_raxml
	#run_paup
	cd $CurrentDir
}


main	


