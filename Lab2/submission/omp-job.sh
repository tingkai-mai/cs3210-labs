#!/bin/bash

## This is a Slurm job script for Lab 2: mm-omp.cpp

#SBATCH --job-name=lab2-ex11-e0694444
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=xs-4114
#SBATCH --mem=1gb
#SBATCH --time=00:03:00
#SBATCH --output=logs/%j_lab2_ex11-e0694444.slurmlog
#SBATCH --error=logs/%j_error_lab2_ex11-e0694444.slurmlog
#SBATCH --mail-type=NONE

# Check that two arguments were passed (matrix size and number of openmp threads)
#if [ ! "$#" -eq 2 ]
#then
#  echo "Expecting 2 arguments (<matrix size> <num threads>), got $#"
#  exit 1
#fi

events="cycles,instructions,duration_time,\
fp_arith_inst_retired.scalar_double,\
fp_arith_inst_retired.128b_packed_double,\
fp_arith_inst_retired.256b_packed_double,\
fp_arith_inst_retired.512b_packed_double,\
fp_arith_inst_retired.scalar_single,\
fp_arith_inst_retired.128b_packed_single,\
fp_arith_inst_retired.256b_packed_single,\
fp_arith_inst_retired.512b_packed_single"

if [ ! "$#" -eq 2 ]
then
  echo "Expecting 2 arguments (<matrix size> <num threads>), got $#"
  exit 1
fi

echo "Running job: $SLURM_JOB_NAME!"
echo "We are running on $(hostname)"
echo "Job started at $(date)"
echo "Arguments to your executable: $@"

echo "Compiling..."
srun g++ -fopenmp -o mm-omp mm-omp.cpp

echo "Running perf stat..."

# Run 10 times
perf stat -x , -r 10 -e "$events" -- ./mm-omp $@ 1>/dev/null 2>perf.tmp

echo "Job ended at $(date)"
