#!/bin/bash

# run abricate, this version on the plasmid_*fasta files generated by mob_recon 
# hoping this can be used to determine if the plasmid found indeed contain ARG.
# 2024.0804

#SBATCH --job-name=NA_WSL
#SBATCH --account=scs                 ###alt: --account=fc_graham
#SBATCH --partition=savio4_htc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=56             ## parallel
#SBATCH --time=71:00:00

#### https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/running-your-jobs/gnu-parallel/


date
hostname

module purge

#module load abricate/1.0.1  # see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate   ## 1.0.1 still newest on github on 2023.07

export abricate='/home/tin/tin-git-Ctin/abricate/abricate.SIF'

#module load gnu-parallel
#touch ~/.parallel/will-cite


CurrentDir=$( pwd )
#Thread=56 ## n0063.savio4
#Thread=32 ## n0082.savio3
Thread=4   ## weasel


#cd /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences_par3
cd /mnt/c/tin/dataCache/shrimp_ec23/MOB_recon_OUT



# run_abricate () {
    App="abricate"
    AbricateDB_list="vfdb resfinder ecoli_vf"

    echo '==== running abricate  ===='      | tee -a MARKER_${App}_begin.txt
    date                                    | tee -a MARKER_${App}_begin.txt

    cp /dev/null ${App}.cmd.lst
    echo "# $App commmand for gnu parallel"

    for AbricateDB in $AbricateDB_list; do
        #for FILE in *fasta; do
        for FILE in *.MOBre/plasmid_*.fasta ; do   # 105 of these
        #for FILE in AA*.MOBre/plasmid_*.fasta ; do   # 2 file test, worked ok
        #for FILE in AA_CKDN230030154-1A_HGKHYDSX7_L2.fasta;  do  # 1 time reprocess missed seq
            #Filename=$( basename -s .fasta -a $FILE )  # no dir name, which i need for plasmid source tracking
            #echo echo $Filename # dbg ++
            #echo "abricate --db $AbricateDB ${Filename}.fasta/assembly.fasta > ${Filename}_Abricate_${AbricateDB}.tsv" >> ${App}.cmd.lst
            $abricate --db $AbricateDB $FILE 
        done > ${App}_${AbricateDB}_combined_raw.tsv
		# header file was pre-created manually
		# oops, forgot to uncomment this, should have worked.  
        # (cat abricate_header.tsv && cat ${App}_${AbricateDB}_combined_raw.tsv | grep -v '^#FILE' ) >  ${App}_${AbricateDB}_combined.tsv 
    done



    #parallel -j 8 -a ${App}.cmd.lst
    #parallel -j $(( $Thread/2 )) -a ${App}.cmd.lst

    # output manually to Abricate_OUT/


    echo $? | tee -a MARKER_${App}_end.txt
    uptime  | tee -a MARKER_${App}_end.txt
    date    | tee -a MARKER_${App}_end.txt


# }  #end run_abricate



skip_for_plasmid_version_run_abricate_summarize () {

    # cuz output manually to Abricate_OUT/
	[[ -d Abricate_OUT ]] || mkdir Abricate_OUT
	mv *Abricate*.tsv Abricate_OUT
    cd Abricate_OUT

    for AbricateDB in $AbricateDB_list; do
        abricate --summary *_Abricate_${AbricateDB}.tsv  > Abricate_${AbricateDB}_summary.csv
        head -1 *_Abricate_${AbricateDB}.tsv | grep -v '^==' | head -1 > Abricate_${AbricateDB}_combined.csv
        cat     *_Abricate_${AbricateDB}.tsv | grep -v "COVERAGE_MAP" >> Abricate_${AbricateDB}_combined.csv
    done

    cd ..

}

create_combined_file_without_header () {

	# step in abricate run with cat could have worked, but forgot to uncomment 
	# thus doing this here, 
	# actually ran this manually

	# header file was pre-created manually
    for AbricateDB in $AbricateDB_list; do
        (cat abricate_header.tsv && cat ${App}_${AbricateDB}_combined_raw.tsv | grep -v '^#FILE' ) >  ${App}_${AbricateDB}_combined.tsv 
    done

	# result files in weasel: /mnt/c/tin/dataCache/shrimp_ec23/MOB_recon_OUT

}

cd $CurrentDir
