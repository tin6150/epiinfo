#!/bin/bash

# run abricate, after completing unicycler.  need fasta as input
# unicycler | abricate

#SBATCH --job-name=Tilden_abricate
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

module load abricate/1.0.1  # see ~/CF_BK/sw/smf.rst, this from quay, not phylotool/abricate   ## 1.0.1 still newest on github on 2023.07


module load gnu-parallel
touch ~/.parallel/will-cite


CurrentDir=$( pwd )
Thread=56 ## n0063.savio4
#Thread=32 ## n0082.savio3


cd /global/scratch/users/tin/fc_graham/ecuador_2023_TJ/Sequences/Tilden/ALL/assembled-sequences_par3


# run_abricate () {
    App="abricate"
    AbricateDB_list="vfdb resfinder ecoli_vf"

    echo '==== running abricate  ===='      | tee -a MARKER_${App}_begin.txt
    date                                    | tee -a MARKER_${App}_begin.txt

    cp /dev/null ${App}.cmd.lst
    echo "# $App commmand for gnu parallel"

    for AbricateDB in $AbricateDB_list; do
        for FILE in *fasta; do
        #for FILE in AA_CKDN230030154-1A_HGKHYDSX7_L2.fasta;  do  # 1 time reprocess missed seq
            Filename=$( basename -s .fasta -a $FILE )
            #echo echo $Filename # dbg ++
            echo "abricate --db $AbricateDB ${Filename}.fasta/assembly.fasta > ${Filename}_Abricate_${AbricateDB}.tsv" >> ${App}.cmd.lst
        done
    done

    #parallel -j 8 -a ${App}.cmd.lst
    parallel -j $(( $Thread/2 )) -a ${App}.cmd.lst

    # output manually to Abricate_OUT/


    echo $? | tee -a MARKER_${App}_end.txt
    uptime  | tee -a MARKER_${App}_end.txt
    date    | tee -a MARKER_${App}_end.txt


# }  #end run_abricate



# run_abricate_summarize () {

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

#}


cd $CurrentDir
