#!/bin/bash
## Slurm job script for Lab 2: mm-omp.cpp

#SBATCH --job-name=lab2-ex11-e0694444
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:30:00
#SBATCH --partition=xs-4114
#SBATCH --mem=1gb
#SBATCH --output=logs/ex11.slurmlog
#SBATCH --error=logs/ex11_err.slurmlog
#SBATCH --mail-type=NONE

set -euo pipefail
set -x
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# ---- args: <matrix_size> <num_threads>
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <matrix_size>"
  exit 1
fi

mkdir -p logs

events="cycles,instructions,duration_time,\
fp_arith_inst_retired.scalar_single"
columns="jobid,size,threads,value,unit,event,percent_running,raw,percent_enabled,metric,metric_unit,metric_name"

echo "Running job: $SLURM_JOB_NAME on $(hostname)"
echo "Started: $(date)"
echo "Args: size=$1"

echo "Compiling..."
srun g++ -fopenmp -o mm-omp-ex12 mm-omp-ex12.cpp

echo "Running perf stat..."
tmp="logs/${SLURM_JOB_ID:-$$}_ex12_perf.tmp"
MASTER_CSV="logs/${SLURM_JOB_ID:-$$}_perf.csv"
MAX_THREADS="${SLURM_CPUS_ON_NODE:-$(nproc)}" # Sensible number of threads - logical core count
#THREAD_LIST="$(seq 1 $(( MAX_THREADS + 10 )) )" # NOTE: We do 10 additional threads to see if performance falls off
THREAD_LIST="$(seq 1 30 )" # xs-4114 has 20 threads, i7-7700 has 8 threads, so we run 30

# Echo thread count info
echo "Current partition ${SLURM_JOB_PARTITION} has ${MAX_THREADS} threads." 

# If output file doesn't exist, we add a CSV header once
if [ ! -f "$MASTER_CSV" ]; then 
    echo "$columns" > "$MASTER_CSV"
fi

# CSV-style perf output; 5 repeats for mean±stddev in the last lines
for t in $THREAD_LIST; do
  export OMP_NUM_THREADS="$t"
  tmp="$(mktemp)"

  # perf → temp (CSV), your program runs with size=$1 and threads=$t
  perf stat --no-big-num -x, -r 5 -e "$events" \
    -o "$tmp" -- ./mm-omp-ex12 "$1" "$t"

  # append non-comment, non-empty lines; prefix with jobid & params
  awk -F, -v OFS=, -v jid="${SLURM_JOB_ID:-NA}" -v n="$1" -v thr="$t" '
    $0 !~ /^#/ && NF { print jid, n, thr, $0 }
  ' "$tmp" >> "$MASTER_CSV"

  rm -f "$tmp"
done

echo "perf CSV saved to: $MASTER_CSV"
echo "Finished: $(date)"

