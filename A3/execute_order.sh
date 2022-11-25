#!/bin/sh
#SBATCH --chdir /scratch/bonnaude
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 36
#SBATCH --mem 10G

cd /home/bonnaude/cs-307-mularch/A3
make order
echo "compiled"

echo "same socket"
numactl -C 0,1,2 ./order
echo "different socket"
numactl -C 0,1,18 ./order