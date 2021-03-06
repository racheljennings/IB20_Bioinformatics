
#run from within ref_sequences directory
#usage: bash finalScript.sh

#Copy contents of proteomes to ref_sequences
cp -R ../proteomes/* ../ref_sequences

#combines all hsp70 gene reference files into one fasta file
for num in {01..22}
do
cat hsp70gene_$num.fasta >> allhsp.txt
done

#combines all mcrA gene reference files into one fasta	file
for num in {01..18}
do
cat mcrAgene_$num.fasta >> allmcrA.txt
done

#run muscle to align all hsp70 reference files
../muscle -in allhsp.txt -out alignhsp70.afa

#run muscle to align all mcrA reference files   
../muscle -in allmcrA.txt -out alignmcrA.afa

#build hidden markov model for hsp70 references
hmmbuild hsp.HMM alignhsp70.afa

#build hidden markov model for mcrA references
hmmbuild mcrA.HMM alignmcrA.afa

mv hsp.HMM ../proteomes
mv mcrA.HMM ../proteomes
cd ../proteomes

#search	all 50 proteomes using hsp.HMM as search criteria
mkdir hspresults
for num in {01..50}
do
hmmsearch --tblout hspresults/hspsearchoutput_proteome$num.HMM hsp.HMM proteome_$num.fasta
done

#search all 50 proteomes using mcrA.HMM as search criteria
mkdir mcraresults
for num in {01..50}
do
hmmsearch --tblout mcraresults/mcrasearchoutput_proteome$num.HMM mcrA.HMM proteome_$num.fasta
done

#running from proteome directory with hspresults and mcra results being a subdirectory of current location, makes a table with all of the matches
echo "Proteome # ,  hsp Matches , mcrA Matches" >> table.txt
echo -n >> table.txt
for num in {01..50}
do
echo -e "$(echo "Proteome" $num) " , " $(grep ^"W" ./hspresults/hspsearchoutput_proteome$num.HMM | wc -l) " , " $(grep ^"W" ./mcraresults/mcrasearchoutput_proteome$num.HMM | wc -l)" >> table.txt
echo -n >> table.txt
done

#Sorts the best matches with the McrA gene
echo -e "Proteome # , hsp genes , mcrA genes" >> bestmatches.txt
cat table.txt | sort -n -k 6n | tail -n 16 | sort -n -k 4n | tail -n 15 >> bestmatches.txt
