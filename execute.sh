#!/bin/sh
#SBATCH --chdir /scratch/almuelle
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 1G
rm pi.out
touch pi.out
echo STARTING AT$(date) >> pi.out
cd A1
make pi
make pi_pthreads
echo "openMP" >> ../pi.out
./pi 1 10000000000 >> ../pi.out
./pi 4 10000000000 >> ../pi.out
./pi 8 10000000000 >> ../pi.out
echo "pthreads" >> ../pi.out
./pi_pthreads 1 10000000000 >> ../pi.out
./pi_pthreads 4 10000000000 >> ../pi.out
./pi_pthreads 8 10000000000 >> ../pi.out
cd ..
cat pi.out
echo FINISHED AT $(date) >> pi.out
