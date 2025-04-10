#!/bin/bash
#SBATCH -N 2                       # Request 2 compute Nodes
#SBATCH --ntasks-per-node 30       # Request 30 tasks (MPI ranks) on each node (Total 60)
#SBATCH --job-name=gmx_tempdir      # Job name
#SBATCH --partition=compute         # --- CHANGE THIS to your cluster's partition ---
#SBATCH --time=01:00:00             # --- ADJUST time limit as needed ---
#SBATCH --output=gmx_slurm_%j.log   # Main SLURM output log file (in submission dir)

# --- Configuration ---
# Fixed location for the input files (taken from your previous 'cp' command)
INPUT_DIR="/opt/apps/gromacs/water-cut1.0_GMX50_bare/1536"

# Define the unique temporary working directory for this job run
# $SLURM_JOB_ID is unique for each job
WORKDIR="gmx_run_${SLURM_JOB_ID}"

# --- Environment Setup ---
echo "Job starting on $(date)"
echo "SLURM Job ID: $SLURM_JOB_ID"
echo "Submission directory: $SLURM_SUBMIT_DIR"
echo "Reading input files from: $INPUT_DIR"
echo "Creating temporary working directory: ${SLURM_SUBMIT_DIR}/${WORKDIR}"

# Set up Spack environment (adjust path if needed for your cluster)
source /opt/apps/spack/share/spack/setup-env.sh

# --- Load Modules (Using the combination from your script) ---
echo "Loading modules..."
module purge # Start fresh
module use /sw/spack/share/spack/lmod/linux-rocky8-x86_64/intel-oneapi-mpi/2021.9.0-ypu6zoo/gcc/13.1.0/
module use /sw/spack/share/spack/lmod/linux-rocky8-x86_64/gcc/13.1.0/
module use /sw/spack/share/spack/lmod/linux-rocky8-x86_64/Core/
module load gromacs # Assumes this loads the correct GROMACS + MPI
echo "Modules loaded."
which gmx_mpi # Verify executable path

# --- Create and Enter Temporary Directory ---
# Create the directory relative to the submission directory
mkdir -p "${SLURM_SUBMIT_DIR}/${WORKDIR}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to create temporary directory ${SLURM_SUBMIT_DIR}/${WORKDIR}"
  exit 1
fi
echo "Created temporary directory: ${SLURM_SUBMIT_DIR}/${WORKDIR}"

# Change into the temporary directory
# Note: Removed the 'cd $SLURM_SUBMIT_DIR' from your original script as we now cd here.
cd "${SLURM_SUBMIT_DIR}/${WORKDIR}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to change into temporary directory ${SLURM_SUBMIT_DIR}/${WORKDIR}"
  exit 1
fi
echo "Changed working directory to: $(pwd)"

# --- GROMACS Steps (executed inside temporary directory) ---

# 1. Run grompp (serially)
#    Reads inputs from INPUT_DIR using full paths.
#    Writes output 'input.tpr' to the current temporary directory.
echo "Running grompp..."
gmx_mpi grompp -f "${INPUT_DIR}/pme.mdp" \
               -c "${INPUT_DIR}/conf.gro" \
               -p "${INPUT_DIR}/topol.top" \
               -o input.tpr \
               -maxwarn 2 # Assuming maxwarn is still desired, otherwise remove

# Check if grompp succeeded
if [ $? -ne 0 ]; then
  echo "ERROR: Grompp failed, exiting."
  echo "Temporary directory ${WORKDIR} will be left for inspection in ${SLURM_SUBMIT_DIR}."
  # Exiting while inside the directory is okay here.
  exit 1
fi
echo "grompp finished successfully, created input.tpr in $(pwd)"

# 2. Prepare hostfile for mpirun (ensures correct node usage by mpirun)
#    Create this inside the temporary directory.
echo "Creating hostfile..."
scontrol show hostnames ${SLURM_JOB_NODELIST} > hostfile
if [ ! -f hostfile ]; then
    echo "ERROR: Failed to create hostfile."
    exit 1
fi

# 3. Run mdrun (in parallel using mpirun)
#    Reads 'input.tpr' from the current (temp) directory.
#    Uses the hostfile created in the current (temp) directory.
#    Writes output files (md logs, trajectories, etc.) to the current (temp) directory.
echo "Running mdrun on $SLURM_NTASKS tasks using mpirun..."
mpirun -n $SLURM_NTASKS -hostfile hostfile -ppn $SLURM_NTASKS_PER_NODE gmx_mpi mdrun \
    -notunepme -dlb yes -v -resethway -noconfout -nsteps 4000 -s input.tpr

# Check if mdrun succeeded
MD_RUN_STATUS=$? # Store exit status

if [ $MD_RUN_STATUS -ne 0 ]; then
  echo "ERROR: mdrun step failed with status $MD_RUN_STATUS. Check GROMACS output files in $(pwd)"
  echo "Temporary directory ${WORKDIR} will be left for inspection in ${SLURM_SUBMIT_DIR}."
  # Exiting while inside the directory is okay here.
  exit 1
fi

echo "mdrun finished successfully."

# --- Cleanup (only runs if mdrun was successful) ---
echo "Simulation successful. Cleaning up temporary directory..."
# Go back UP to the original submission directory BEFORE removing the temp one
cd "${SLURM_SUBMIT_DIR}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to change back to submission directory. Manual cleanup of ${WORKDIR} may be required."
  # mdrun succeeded, but cleanup failed. Exit with non-zero to indicate script issue.
  exit 1
fi

# Remove the temporary directory and all its contents
rm -rf "${WORKDIR}"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to remove temporary directory ${WORKDIR}. Manual cleanup may be required."
  exit 1
fi
echo "Temporary directory ${WORKDIR} removed."

echo "Job finished successfully on $(date)"
# --- End of Script ---
