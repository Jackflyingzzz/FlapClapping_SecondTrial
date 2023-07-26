#!/bin/bash
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=32:mem=64gb
#PBS -j oe

# Cluster Environment Setup
ncpus=32
hostname -i
cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate sb3

# Copy over the whole dir
cp -r $PBS_O_WORKDIR/Incompact3d_Flaps $TMPDIR/
cp -r $PBS_O_WORKDIR/rl-training $TMPDIR/

cd $TMPDIR/Incompact3d_Flaps
make clean
make

cd $TMPDIR/rl-training
echo $description
cat params.json
JOB_ID_SPLIT=${PBS_JOBID%.*}
mkdir $HOME/jobs/$JOB_ID_SPLIT
echo $description > $HOME/jobs/$JOB_ID_SPLIT/job_description.txt

date
wandb login

timeout 47.5h python3 sb3_wandb_sweep.py -n $ncpus --sweep-id=$sweep_id

cp -r ../* $HOME/jobs/$JOB_ID_SPLIT

exit 0
