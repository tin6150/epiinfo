# got email from ncbi/genbank that files have error.
# see gdoc https://docs.google.com/document/d/1gxJgz1fDlrKINKYSuc9735PtMe94fAH9zTfoV26hGIQ/edit?tab=t.0
# anyway, using 
# seqkit cli tool to bulk edit fasta file
# resubmitted, but adding [organism=Escherichia coli] isn't cutting it.  NCBI still complain of errors.  this is during the (re)submission stage.
# strange, clicking continue again, 2nd time it seems to have accepted it.  
# or maybe it just kept it in the same error state and moved on in the submission page?

# m02 had brew install seqkit

cd  ~/dataCache/ChristopherLeBoaWGSdata_irrigation_exposure_2026_AI-5395/Sequence_LeBoa_AI-5395/AI-5395_results/AI-5395_assembly/
#for FILE in `ls AI-5395_1_1*assembly.fasta`; do
for FILE in `ls AI-5395_*assembly.fasta`; do
	#echo seqkit replace -p $ -r ' [organism=Escherichia coli]' $FILE redir ../AI-5395_assembly_editHeader/$FILE
	#seqkit replace -p $ -r ' [organism=Escherichia coli]' $FILE > ../AI-5395_assembly_editHeader/$FILE
	#seqkit replace -p $ -r ' [organism=Escherichia coli]' --seq-width 0  "$FILE" > "../AI-5395_assembly_editHeader/$FILE"
	#seqkit replace -p '$' -r ' [organism=Escherichia coli]' "$FILE" | seqkit seq -w 0 > ../AI-5395_assembly_editHeader/"$FILE"
	wc "$FILE"  ../AI-5395_assembly_editHeader/"$FILE"
done


# --seq-width 0 will not break DNA lines into shorter ones (which is the format the angstrong .fasta came in)


