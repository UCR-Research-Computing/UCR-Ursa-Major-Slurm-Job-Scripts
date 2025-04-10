#!/bin/bash -l

#SBATCH -c 4 
#SBATCH -p compute 


project="blast"
ran=$(echo $RANDOM)

filename=$project"_"$ran

echo $filename

scratchdir=$HOME/$filename

mkdir -p $scratchdir

cp ./cluster-data/* $scratchdir/.

module load blast-2.13

cd $scratchdir
time makeblastdb -in mouse.1.protein.faa -dbtype prot
time makeblastdb -in zebrafish.1.protein.faa -dbtype prot

time blastp -query zebrafish.1.protein.faa -db mouse.1.protein.faa -num_threads 4 -out zebrafish.x.mouse
#blastp -query zebrafish.top.faa -db mouse.1.protein.faa -num_threads 4 -out zebrafish.x.mouse

tar -zcvf zebrafish-job-output.tar.gz zebrafish.x.mouse
cp zebrafish-job-output.tar.gz $HOME/$filename-zebrafish-job-output.tar.gz
