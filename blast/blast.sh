#!/bin/bash -l

#SBATCH -c 4 
#SBATCH -p compute 

#create random
project="blast"
ran=$(echo $RANDOM)
dirname=$project"_"$ran

#make scratch directory
scratchdir=$HOME/$dirname
mkdir -p $scratchdir

#copy input files to scratch directory
cp ./cluster-data/* $scratchdir/.

#load the blast environment module
module load blast-2.13

cd $scratchdir
time makeblastdb -in mouse.1.protein.faa -dbtype prot
time makeblastdb -in zebrafish.1.protein.faa -dbtype prot

time blastp -query zebrafish.1.protein.faa -db mouse.1.protein.faa -num_threads 4 -out zebrafish.x.mouse
#blastp -query zebrafish.top.faa -db mouse.1.protein.faa -num_threads 4 -out zebrafish.x.mouse

tar -zcvf zebrafish-job-output.tar.gz zebrafish.x.mouse
cp zebrafish-job-output.tar.gz $HOME/$filename-zebrafish-job-output.tar.gz