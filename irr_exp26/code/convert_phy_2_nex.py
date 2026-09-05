#!/global/software/rocky-8.x86_64/python-3.11.6/python-3.11.6/python/3.11.6-gcc/bin/python3

# module load python/3.11.6-gcc-11.4.0  # EL8, used by bofhbot

# convert .phy (eg Phylip alignment) to .nex (Nexus), needed by Mr.Bayes


input_path   = "/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly/PROKKA_gff/ECirr_exp.phy"
output_path  = "/global/home/users/tin/gs/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026/AI-5395_results/AI-5395_assembly/PROKKA_gff/ECirr_exp.nex"

import io
import sys
from Bio import AlignIO
from Bio.Nexus import Nexus


#------- 
# Mr.Bayes quirk: throw parsing error with single quote 
# so 'cg-GCA_018769385.1_PDT001063311.1_genomic' becomes a problem
# maybe strict phylip was better after all
# try 
# mrbayes=True
#------- 

# Version by Claude Sonet 5, better than Gemini stuff, this worked.
# no single quote around taxa name which Mr.Bayes choke
# (but not limited to 10 chars, at least the .nex file has the long filename, just replaced .- with _) 
# await Mr.Bayes output to verify it works ok.

## updated: pad short taxaname to 10 chars exactly


MIN_NAME_LEN = 10  # pad taxon names shorter than this up to exactly this length

# 1. Read the phylip alignment (relaxed format handles long taxon names like
#    cg-GCA_033666085.1_PDT001728921.1_genomic without truncation)
alignment = AlignIO.read(input_path, "phylip-relaxed")

# 2. Sanitize taxon names: replace '.' and '-' with '_'
for rec in alignment:
    rec.id = rec.id.replace(".", "_").replace("-", "_")
    rec.name = rec.id
    rec.description = ""

# 2b. Pad short taxon names to exactly MIN_NAME_LEN characters using
#     trailing underscores (spaces would break unquoted NEXUS parsing)
for rec in alignment:
    if len(rec.id) < MIN_NAME_LEN:
        padded = rec.id.ljust(MIN_NAME_LEN, "_")
        rec.id = padded
        rec.name = padded

# 3. Sanity check: make sure sanitizing/padding didn't create duplicate names
names = [rec.id for rec in alignment]
if len(names) != len(set(names)):
    dupes = sorted({n for n in names if names.count(n) > 1})
    raise ValueError(f"Sanitizing/padding taxa names created duplicates: {dupes}")

# 4. Write NEXUS by hand so taxon names are NOT quoted (required for MrBayes)
ntax   = len(alignment)
nchar  = alignment.get_alignment_length()
width  = max(len(n) for n in names) + 2

with open(output_path, "w") as f:
    f.write("#NEXUS\n")
    f.write("BEGIN DATA;\n")
    f.write(f"  DIMENSIONS NTAX={ntax} NCHAR={nchar};\n")
    f.write("  FORMAT DATATYPE=DNA MISSING=? GAP=- INTERLEAVE=NO;\n")
    f.write("  MATRIX\n")
    for rec in alignment:
        f.write(f"  {rec.id.ljust(width)}{str(rec.seq)}\n")
    f.write("  ;\n")
    f.write("END;\n")

print(f"Wrote NEXUS alignment: {ntax} taxa, {nchar} characters -> {output_path}")

