#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=6gb
#PBS -j oe

# Cluster Environment Setup
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
echo "Restoring from:"
echo $restore
python3 eval_sb3.py --algorithm=$algo --restore=$restore
date

cp -r ../* $HOME/jobs/$JOB_ID_SPLIT

cp -r test_run $HOME/jobs/$JOB_ID_SPLIT/rl-training/

exit 0
