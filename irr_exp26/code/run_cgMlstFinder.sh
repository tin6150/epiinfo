#!/bin/bash


#### run cgMLSTFinder against many *fna files  - for irr_exp26

## ++ hopefully remember to change job name :D  >>>>
#SBATCH --job-name=cgF_irrExp26
###SBATCH --account=scs
#SBATCH --account=fc_graham
#SBATCH --partition=savio4_htc
###SBATCH --partition=savio3_htc   # only few savio3_htc, tends to be busy
####SBATCH --partition=savio3
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
###SBATCH --cpus-per-task=32             ## parallel  savio3
#SBATCH --cpus-per-task=24             ## parallel -j 12 ... doubling just in case.
#SBATCH --time=71:00:00
#SBATCH --mem=501G                  # Memory required per node ## savio4 has 512G,
####SBATCH --mem=352G                  # Memory required per node ## savio3_htc typically has 384, def 9GB per core


## ++ Search for entries change need for next Snp Cluster run


## version history

# 2026.1031
# adopted from usdastec/Env_EcO157/code/run_SnpClus_cgMlstFinder.sh



#### ------------------------ code below ----------------------------

## be careful with the path each of the function cd into  !!

# Irr_Exp26:
export DataDir=/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly


CurrentDir=$( pwd )
#Thread=56 ## n0060.savio4
Thread=24  ## Snp1a took a long time with gnu parallel -j 8, so changed to 12, esp as run on sav4
#Thread=16  ## savio3, load avg is low, ~1 per thread (gnu parallel -j 8 should be about right, considering RAM also)
#Thread=32 ## n0082.savio3
#Thread=8   ## bofh

# example run as:
# cd .../code

## sbatch run_cgMlstFinder.sh  #   mv slurm...out cgFind.slurm...out 
## OR: bash run_cgMlstFinder.sh | tee run_cgMlstFinder.TEE.OUT

######################################################################

######################################################################
# setup environment for running cgMLSTFinder
######################################################################

setup () {
  # only run module load on hpc, not local machine env
  if [[ -d /global/software/ ]]; then

        # EToKi was installed under my own pythong virtual env, using python3 from SMF
        module load python/3.11.6-gcc-11.4.0

        # EToKi cmd result in load avg = 1
        module load parallel/20220522  # el8
        # https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/

        # https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-output
        # foo-{}  or $foo-{}   will     prefix correctly,
        # foo_{}  nor $foo_{}  will NOT prefix as desired, $foo_ get dropped silently!

  fi	

  source ~tin/gs/venv_stec/bin/activate
  # ?needed?   iqtree installed there manually
  export PATH=$PATH:~tin/gs/venv_stec/bin

  # ~tin/gs/tin-gh/EToKi

}

######################################################################
# step 0
# pre_setup prep step
######################################################################

# run once only
pre_setup_cgMlstFinder_db () {
	# ref	https://github.com/genomicepidemiology/cgmlstfinder

	# Go to the directory where you want to store the cgmlst database
	#cd /path/to/some/dir
	cd ~tin/gs/tin-gh/	# or n0060.s4 /local/user/tin/tin-gh
	# Clone install script from git repository
	git clone https://bitbucket.org/genomicepidemiology/cgmlstfinder_db.git
	cd cgmlstfinder_db
	cgMLST_DB=$(pwd)
	# Install cgMLST database (look at https://bitbucket.org/genomicepidemiology/cgmlstfinder_db.git for more information)
	python3 INSTALL.py


	# 2 attempted install as of 2025-08-22
	# n0060 /local/user/tin/tin-gh/cgmlstfinder_db/       # had some time out error
	# /global/home/users/tin/gs/tin-gh/cgmlstfinder_db    # cancelled, rerun in future 

} # end fn


######################################################################
# Pre-setup option 2.  (run only once per server)
# use Singularity container that has the Enterobase cgST db
# this is what I used with the USDA EE1394 isolates
######################################################################

# dont usually need repeated run
setup_cgMlstFinder_container () {
	# echo "it is a docker thing... try with singularity"

	cd /global/home/users/tin/gs/singularity-repo
	singularity pull --name cgmlstfinder.sif  docker://ghcr.io/tin6150/cgmlstfinder:master
	cd -
	# docker pull ghcr.io/tin6150/cgmlstfinder:master


	echo \
	docker run --rm -it \
       -v $cgMLST_DB:/database \
       -v $(pwd):/workdir \
       cgmlstfinder -o [OUTPUT PATH] -s [SPECIE] -db [DATABASE PATH] -t [TEMPORARY FILE] [INPUT/S FASTQ]


	exit 007 
	# example run below, do not run in script
	singularity run --bind ~tin//gs/tin-gh/cgmlstfinder_db/:/database  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i GCA_*.fna -s ecoli -db ~/gs/tin-gh/cgmlstfinder_db/ -o cgMlstFinder_Out 

	singularity exec --bind ~tin//gs/tin-gh/cgmlstfinder_db/:/database  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  /bin/bash

	# install db and bind mount to singularity 

} # end fn 

######################################################################
# kinda like step 4
# Neighbour Joining tree
# tried to generate tree... didn't really work
# produced a matrix, but don't know what program would parse that to generate a tree.  2025.0918
# run, choose serial vs parallel version...  in main()
######################################################################
# takes a long time to run, didn't find it useful last time, no doing for Snp2..5..1a  2026.1011


# run this after cgmlstFinder finishes
# hoping that make_nj_tree.py
# is same as --neighbour option of multi-files input (serial run) form.
run_cgMlstFinder_mk_tree () {

	#make_nj_tree.py
	#cd  ~/gs/fc_graham/stec_usda_Env_EcO157/Fasta4Prokka_EE1394/cgMlstFinder_Out
	cd  ${DataDir}/Fasta4Prokka_EE1394/cgMlstFinder_Par_Out  # _Par or Serial, update addordingly

	# the serial version have all output files in the same dir.
	#singularity exec /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  make_nj_tree.py --NJ_path /usr/bin/phylip 
	cp -p ecoli_results.txt results.txt  # seems like make_nj_tree.py hard coded results.txt 
	singularity exec --env PYTHONPATH=/opt/python_venv/ /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif   /opt/python_venv/bin/python3 /opt/gitrepo/container/make_nj_tree.py --NJ_path /usr/bin/phylip # -o Nj_Out
	# finally running... 00:06  00:14 ended with:
	# Usage: /usr/bin/phylip <program>  \n Neighbor program failed.
	# maybe better a wrapper script inside the container that calls the necessary program after sourcing...
	#singularity exec  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif   /opt/python_venv/bin/python3 -m venv /opt/python_venv -- /opt/gitrepo/container/make_nj_tree.py --NJ_path /usr/bin/phylip 
	# with -- after venv path, complain RO FS :-/ 
	# xx --output_file treeName.nwk or .tre
	# -o OutDir ## have to mkdir ahead of time.
	# --input_file ecoli_results.txt ? # not .fasta i hope
	# ~tin/gs/tin-gh/cgmlstfinder/make_nj_tree.py  # it needs pip3 ete3 
	# overall, couldn't get make_nj_tree.py to work.

	## tried to use phylip directly
	## cp ecoli_results.txt infile
	## singularity shell ..../cgmlstfinder.sif
	## phylip neighbor
	## it is prompted menu, like paup.  but it didn't like that file format, numbers are inteter rather than float 0..1 ? 
	## wait till next meeting.  probably better off generate tree using cfsan (used by NCBI PDP) anyway.
}

# it use 1 cpu core, but need comma list of file to have output that has combined summary, 
# 75s * 1394 = 104550  = 29 hours!!
# it is ecoli_summary.txt which i can recreate from individual files by tail -1 */ecoli_summary.txt 
# ecoli_results.txt likely the same.   dont know how useful this is at the moment.
# the data.json file, i won't need
# memory usage peak per free, for what I have seen is 25 GB.   prev parallel run thought it was about 23 GB per process.


######################################################################
# step 2s
# run, choose serial vs parallel version...  in main()
######################################################################


run_cgMlstFinder_serial () {
        App=cgMlstFinder
        hostname | tee -a MARKER_${App}_start.txt
        uptime  | tee -a MARKER_${App}_start.txt
        date    | tee -a MARKER_${App}_start.txt

	export SINGULARITY_BIND='/global/scratch/users/tin/tin-gh/cgmlstfinder_db:/database'   # cant parse ~
	#export SINGULARITY_BIND='/local/user/tin/tin-gh/cgmlstfinder_db:/database'             # n0060s4 only
	# the above would be run instead of explicity setting  --bind 

	# caller has cd into the dir with input fna files.
	# eg cg /global/home/users/tin/gs/fc_graham/stec_usda_Env_EcO157/Fasta4Prokka_EE1394/Test_Enterobase
	[[ -d cgMlstFinder_Out ]] || mkdir cgMlstFinder_Out 

	# if the ~/gs/...db is there it might work without bind, since it is accessible from inside container.
	# singularity run  /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i GCA_018769385.1_PDT001063311.1_genomic.fna  -s ecoli -db ~/gs/tin-gh/cgmlstfinder_db/ -o cgMlstFinder_Out 
	# currently doing this (with the SINGULARITY_BIND env var defined):
	# /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i GCA_018769385.1_PDT001063311.1_genomic.fna  -s ecoli -db /database -o cgMlstFinder_Out 
	# run completed.  took 73 sec
	# List several filenames in a comma separeted manner without white spaces 
	CommaFileList=$(ls -1 *fna | xargs | sed 's/\ /,/g')
	#/global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i $CommaFileList  -s ecoli -db /database -o cgMlstFinder_Out   # 1st serial run from 8/23 , no tree

	#/global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -h
	#xx /global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i $CommaFileList  -s ecoli -db /database -o cgMlstFinder_Out --neighbor
	# run time complain cgMLST.py: error: unrecognized arguments: --neighbor
	/global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i $CommaFileList  -s ecoli -db /database -o cgMlstFinder_Out --nj_path /usr/bin/phylip
	# specifying --nj_path doesnt seems to change output.  
	# seems like going to need to generate the tree manually using make_nj_tree.py  
        echo $? | tee -a MARKER_${App}_end.txt
        hostname | tee -a MARKER_${App}_end.txt
        uptime  | tee -a MARKER_${App}_end.txt
        date    | tee -a MARKER_${App}_end.txt

} # end fn run_cgMlstFinder

######################################################################
# step 2p (part 1)
# run, choose serial vs parallel version...  in main()
# tool ~ 11 hours, parallel -j 8.  load avg seems about 8.  but disk io might have been a bottleneck
######################################################################

run_cgMlstFinder_parallel () {
        App=cgMlstFinderP
        echo $? | tee -a MARKER_${App}_start.txt
        uptime  | tee -a MARKER_${App}_start.txt
        free -h | tee -a MARKER_${App}_start.txt
        date    | tee -a MARKER_${App}_start.txt
        hostname | tee -a MARKER_${App}_start.txt

	export SINGULARITY_BIND='/global/scratch/users/tin/tin-gh/cgmlstfinder_db:/database'   # cant parse ~
	#export SINGULARITY_BIND='/local/user/tin/tin-gh/cgmlstfinder_db:/database'             # n0060s4 only
	# the above would be run instead of explicity setting  --bind 

	# caller has cd into the dir with input fna files.
	# eg cd /global/home/users/tin/gs/fc_graham/stec_usda_Env_EcO157/Fasta4Prokka_EE1394/Test_Enterobase
	#       /global/home/users/tin/gs/fc_graham/usda_EcO157_Snp1/Fasta4Prokka  # $DataDir
	[[ -d cgMlstFinder_Par_Out ]] || mkdir cgMlstFinder_Par_Out 

		# reset the cmd.lst for gnu parallel
		echo "" > ${App}.cmd.lst
	#for FILE in GCA_*fna ; do    # _EE1394 fasta seq file  should be fine for Snp1 
	for FILE in AI-5395*_assembly.fasta ; do    # _EE1394 fasta seq file  should be fine for Snp1 
		Filename=$( basename -s _assembly.fasta -a $FILE )
		echo "/global/home/users/tin/gs/singularity-repo/cgmlstfinder.sif  -i $FILE  -s ecoli -db /database -o cgMlstFinder_Par_Out/$Filename" >> ${App}.cmd.lst
		[[ -d cgMlstFinder_Par_Out/$Filename ]] || mkdir cgMlstFinder_Par_Out/$Filename
		# ls -ld cgMlstFinder_Par_Out/$Filename
	done

	echo "will cite" | parallel --citation # to prevent it from stopping process
        echo "past parallel --citation"
        touch ~/.parallel/will-cite
        #parallel -j 4 -a ${App}.cmd.lst  
        # parallel -j $(( $Thread/2 )) -a ${App}.cmd.lst
	# see 2 cores can get busy per input file.
	# 28 thread ran out of memory.   many files had no output for ecoli_summary.txt
	# doing 4 just to be very safe.  peak usage: 91 GB, so 23 GB per process at peak. (mostly around 35 GB, once saw at 51 GB).  7h24m
	# should be able do 8 threads ; 25*8=200 GB, n0060 has 251/8 = 31.3GB avail per process.  would take ~3h45m
        parallel -j 12 -a ${App}.cmd.lst    ## Thread adjust, savio3_htc def 9GB/task, 384G in system
	

        echo $? | tee -a MARKER_${App}_end.txt
        free -h | tee -a MARKER_${App}_end.txt
        uptime  | tee -a MARKER_${App}_end.txt
        date    | tee -a MARKER_${App}_end.txt
        echo "run_cgMlstFinder_parallel fn ending"    | tee -a MARKER_${App}_end.txt

		

} # end fn run_cgMlstFinder_parallel




######################################################################
# step 2p (part 2)
# run, only if used  parallel version (ie follow from Step 2p (part 1) above
######################################################################

run_cgMlstFinder_summarize () {
	# if used gnu Parallel, then cgMLSTFinder result is 1 file per directory
	# collect all the cgST number across dirs and concat into single file

	# cd /global/home/users/tin/gs/fc_graham/stec_usda_Env_EcO157/Fasta4Prokka_EE1394/cgMlstFinder_Par_Out
	#xx  cd ../cgMlstFinder_Par_Out_OOM

	cd cgMlstFinder_Par_Out
	echo "run_cgMlstFinder_summarize fn starting" | tee -a  _begin.flag
	date     | tee -a  _begin.flag
	uptime   | tee -a  _begin.flag
	hostname | tee -a  _begin.flag
	#head -1 GCA_031305995.3_PDT001876886.3/ecoli_summary.txt  > cgMlstFinderSummary.tsv   # EE1394 ## this step need to dig manually
	#head -1 GCA_052642315.1_PDT002921120.1/ecoli_summary.txt  > cgMlstFinderSummary_wFilename.tsv   # Snp1a update TBD++
	#head -1  GCA_000008865.2_*/ecoli_summary.txt               > cgMlstFinderSummary_wFilename.tsv   # Snp2  ## this step need to dig manually
	#cp -p ../../../usda_SnpAid/cgMlstFinderSummary_wFilename.header cgMlstFinderSummary_wFilename.tsv

	#vvv--- below, untested header line from std dir , coded for run_SnpCLus_cgMlstFinder.sh 2026.1011
	#???  cp -p /global/home/users/tin/gs/fc_graham/usda_SnpAid/cgMlstFinderSummary_wFilename.header cgMlstFinderSummary_wFilename.tsv
	#tail -q -n 1 GCA*/ecoli_summary.txt | sort >> cgMlstFinderSummary.tsv
	fgrep GCA_ GCA*/ecoli_summary.txt | sort >> cgMlstFinderSummary_wFilename.tsv
	wc -l  cgMlstFinderSummary*.tsv
	[[ -d ../../Result_SnpClus/ ]] || mkdir ../../Result_SnpClus/  # expect this to be contained under usda_Snp2, 1a, etc  so no name change
	cp -pi cgMlstFinderSummary*.tsv         ../../Result_SnpClus/  # 
	cd -

	date     | tee -a  _end.flag
	uptime   | tee -a  _end.flag
	hostname | tee -a  _end.flag
	echo "run_cgMlstFinder_summarize fn ending" | tee -a  _end.flag


} # end fn run_cgMlstFinder_summarize


################################################################====
#### main
################################################################====

main () {
	date     | tee -a  _begin.flag
	uptime   | tee -a  _begin.flag
	hostname | tee -a  _begin.flag
	CurrentDir=$( pwd )
	setup
	cd $DataDir
	#cd $DataDir/Test_Enterobase		# TMP !! <<<
	#date; hostname; uptime
	pwd
	echo "check pwd... expect to be in ..._SnpX/Fasta4Prokka... with many GCA_*fna files.  scancel (bash ctrl-C) to cancel otherwise... sleeping 60..."
	sleep 2
	#sleep 60

	#//run_cgMlstFinder_serial 		# 2nd run of complete 1394, after getting install db in ~gs, to double check result.
	# the serial version, ecoli_summary.tsv was identical to the parallel version
	# but the serial form, with cli input of all files, have an option to do --neighbour for tree generation
	# hopefully make_nj_tree.py can do the job afterward, which might be why there are so many other output files.
	run_cgMlstFinder_parallel
	#++run_cgMlstFinder_summarize # only if used run_cgMlstFinder_parallel   # ++ manual fix tbd, after above step complete ++
	# results (cp to .../metadata unless really big):
	# /global/scratch/users/tin/fc_graham/usda_Snp*/Result_SnpClus
	
	


        date     | tee -a  _end.flag
        uptime   | tee -a  _end.flag
        hostname | tee -a  _end.flag

	cd $CurrentDir
        echo "    egrep -i 'error|fatal|warn' slurm*out ;   "
		echo "##  cp -pi /global/scratch/users/tin/fc_graham/.../Result_ ../result/"
        echo "--------------------------------" 
        echo "// the end. download_dat.bash //"
	
}


main	


################################################################################


