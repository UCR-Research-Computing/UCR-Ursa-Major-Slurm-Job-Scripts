#!/bin/bash -l

#SBATCH --mail-user=useremail@address.com
#SBATCH --mail-type=ALL
#SBATCH --job-name="R Example"

# The latest R is loaded by default
module load r
module load r-rjags
module load r-coda
module load r-lattice

# Use Rscript to run R script
Rscript myRscript.R
Rscript jags.R
