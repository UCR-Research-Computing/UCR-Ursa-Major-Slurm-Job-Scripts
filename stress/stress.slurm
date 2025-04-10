#!/bin/bash

# Define an array of CPU counts to test
#CPUS=(1 2 4 8)
CPUS=(1 2)


# Define an array of stress command lengths to test
LENGTHS=(10s 30s 1m 3m 5m 10m)

# Loop over the CPU counts and stress command lengths and create a Slurm script for each combination
for cpu in "${CPUS[@]}"
do
  for length in "${LENGTHS[@]}"
  do
    # Create a Slurm script for this combination
    cat <<EOF > "job_cpu${cpu}_length${length}.sh"
#!/bin/bash
#SBATCH --job-name=stress-test
#SBATCH --output=job_cpu${cpu}_length${length}.out

module load stress
stress -c ${cpu} -t ${length}
EOF

    # Submit the Slurm script
    sbatch -c ${cpu} "job_cpu${cpu}_length${length}.sh"
  done
done
