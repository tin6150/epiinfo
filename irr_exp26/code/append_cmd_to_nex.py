#!/global/software/rocky-8.x86_64/python-3.11.6/python-3.11.6/python/3.11.6-gcc/bin/python3

# module load python/3.11.6-gcc-11.4.0  # EL8, used by bofhbot



# quick run with ngen 12k ... (def is 1M)

#output_path = "ee1352_py.nex"
#output_path = "/global/scratch/users/tin/fc_graham/stec_usda_Env_EcO157/Fasta4Prokka_EE1394/fasta4tree_cgSTee1352/PROKKA/ee1352_cmd3.nex"
output_path = "/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly/PROKKA_gff/ECirr_exp.nex"

# 1. Define your MrBayes command block
mrbayes_block = """
begin mrbayes;
    set autoclose=yes nowarn=yes;
    lset nst=6 rates=gamma;
    mcmcp savebrlens=yes ngen=12000 samplefreq=1000 printfreq=1000;

     mcmcp ngen=20000 nruns=1 nchains=1;
     mcmcp savebrlens=yes;
     mcmcp printfreq=1000 samplefreq=1000;
     mcmcp diagnfreq=2500 diagnstat=maxstddev;
     mcmcp filename=irr_mb_ngen12k;

    mcmc;
    sump;
    sumt;
end;
"""

#    mcmcp savebrlens=yes ngen=1000000 samplefreq=1000 printfreq=1000;

# the mcmcp above maybe throwing errors, took them out in the ...cmd3.nex file to get basic process running first ++

# oh, the inline cmd likely need ; at the end!  (which i didn't have in the previous setting)

#     mcmcp ngen=20000 nruns=1 nchains=1                  # ? ~ chain lenght = 20k nrun=1 took 10min
#     mcmcp savebrlens=yes
#     mcmcp printfreq=1000 samplefreq=1000
#     mcmcp diagnfreq=2500 diagnstat=maxstddev            # converge diag settings
#     mcmcp filename=MB_ee1352_uni20                      # filename prefix, _uni for uniform mcmc ??


# 2. Append the MrBayes commands to the existing Nexus file
with open(output_path, "a") as nex_file:
    nex_file.write(mrbayes_block)

print(f"Successfully appended the MrBayes command block to {output_path}.  hand edit the .nex file to adjust Mr.Bayes cmd...")



