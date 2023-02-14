# R

Here is a basic example on how you can submit R code to the cluster.

Make sure your `job_wrapper.sh` and `myRscript.R` files are in the same directory, and then submit your wrapper from that directory:

1. Make example directory

```bash
mkdir ~/R_example
cd ~/R_example
```

2. Download example scripts

```bash
wget https://raw.githubusercontent.com/UCR-Research-Computing/UCR-Ursa-Major-Slurm-Job-Scripts/master/R/myRscript.R
wget https://raw.githubusercontent.com/UCR-Research-Computing/UCR-Ursa-Major-Slurm-Job-Scripts/master/R/jags.R
wget https://raw.githubusercontent.com/UCR-Research-Computing/UCR-Ursa-Major-Slurm-Job-Scripts/master/R/job_wrapper.sh
```

3. Submit wrapper

```
sbatch job_wrapper.sh
```

