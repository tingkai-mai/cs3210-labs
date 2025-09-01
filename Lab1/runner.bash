#!/usr/bin/env bash
set -euo pipefail
LC_ALL=C                    
events="duration_time,cycles,instructions,LLC-loads,LLC-load-misses"  

sizes=($(seq 0 1000 50000))
algs=("bubble" "quick")

echo "algo,n,time_s,throughput,ipc,llc_miss_pct,instructions,cycles,LLC_loads,LLC_misses" > results.csv

for algo in "${algs[@]}"; do
  echo "===> Running algorithm ${algo}"
  for n in "${sizes[@]}"; do
    echo "=> Running for size ${n}"

    # build
    if [[ $algo == "quick" ]]; then
      g++ -O2 -g -fno-omit-frame-pointer -std=c++17 -DUSE_QUICK -DARR_N=$n asdf.cpp -o prog
    else
      g++ -O2 -g -fno-omit-frame-pointer -std=c++17 -DARR_N=$n asdf.cpp -o prog
    fi

    # measure (average 9 repeats) and save raw perf output
    perf stat -x , -r 9 -e "$events" -- ./prog 1>/dev/null 2> perf.tmp

    # parse one tidy row
    awk -F, -v n=$n -v algo=$algo '
    /duration_time,/ {
          T = $1; unit = $2;          # value + unit
          if (unit == "ns") T /= 1e9; # seconds
          else if (unit == "ms") T /= 1e3;
          # if unit=="seconds" or empty, T already seconds
      }
      /instructions,/        {I=$1}
      /cycles,/              {C=$1}
      /LLC-loads,/           {L=$1}
      /LLC-load-misses,/     {LM=$1}
      END{
        ipc=(C>0?I/C:0);
        llc=(L>0?LM/L:0);
        thr=(T>0?n/T:0);
        printf "%s,%d,%.6f,%.2f,%.3f,%.3f,%.0f,%.0f,%.0f,%.0f\n",
               algo,n,T,thr,ipc,llc*100.0,I,C,L,LM;
      }' perf.tmp >> results.csv
  done
done

