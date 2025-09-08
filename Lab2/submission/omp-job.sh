#!/bin/bash
## Slurm job script for Lab 2: mm-omp.cpp

#SBATCH --job-name=lab2-ex11-e0694444
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=xs-4114
#SBATCH --mem=1gb
#SBATCH --time=00:03:00
#SBATCH --output=logs/%j_lab2_ex11-e0694444.slurmlog
#SBATCH --error=logs/%j_error_lab2_ex11-e0694444.slurmlog
#SBATCH --mail-type=NONE

set -euo pipefail
set -x
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# ---- args: <matrix_size> <num_threads>
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <matrix_size> <num_threads>"
  exit 1
fi

mkdir -p logs

events="cycles,instructions,duration_time,\
fp_arith_inst_retired.scalar_single"

echo "Running job: $SLURM_JOB_NAME on $(hostname)"
echo "Started: $(date)"
echo "Args: size=$1 threads=$2"

echo "Compiling..."
srun g++ -fopenmp -o mm-omp mm-omp.cpp

echo "Running perf stat..."
export OMP_NUM_THREADS="$2"
perf_out="logs/${SLURM_JOB_ID:-$$}_perf.csv"
tmp="logs/${SLURM_JOB_ID:-$$}_perf.tmp"

# If output file doesn't exist, we add a CSV header once
if [ ! -f "$perf_out" ]; then 
    echo "value,unit,event,percent_running,raw,metric,metric_unit,metric_name" > "$perf_out"
fi

# CSV-style perf output; 10 repeats for mean±stddev in the last lines
perf stat --no-big-num -x, -r 10 -e "$events" \
    -o "$tmp" --append -- \
    ./mm-omp "${1}" "${2}" 

grep -Ev '^(#|$)' "$tmp" >> "$perf_out"

echo "perf CSV saved to: $perf_out"
echo "Finished: $(date)"

