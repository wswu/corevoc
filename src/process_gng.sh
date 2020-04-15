folder=/export/fs03/a08/wwu/res/google-ngrams/unigrams

mkdir -p google-ngrams

for letter in {a..z}
do
    echo $letter
    julia gng-accumulate.jl $folder/googlebooks-eng-all-1gram-20120701-$letter google-ngrams/$letter
done

cat google-ngrams-old/googlebooks* > google-ngrams/counts.txt
sort -k2 -n -r google-ngrams/counts.txt > google-ngrams/counts.sorted
head google-ngrams/counts.sorted -n 100000 > google-ngrams/counts.100000
julia gng-clean.jl google-ngrams/counts.100000 > google-ngrams/gng.clean