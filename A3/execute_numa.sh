#!/bin/sh
#SBATCH --chdir /scratch/bonnaude
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 36
#SBATCH --mem 10G

cd /home/bonnaude/cs-307-mularch/A3
make numa
echo "compiled"

echo "** INTERLEAVED **"
numactl --interleave=all ./numa

echo "** LOCAL ALLOC **"
numactl --localalloc ./numa

echo "** PREFFERED / REMOTE **"
numactl --preferred=0 --cpunodebind=1 ./numa

