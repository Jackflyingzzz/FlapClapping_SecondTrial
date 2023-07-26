#!/bin/bash
#PBS -l walltime=24:00:00
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

mkdir $HOME/jobs/$JOB_ID_SPLIT/saver_data

date
wandb login
if [ -z "$restore" ]
then
	python3 launch_parallel_sb3.py -n $ncpus --logdir=$HOME/jobs/$JOB_ID_SPLIT/logs --savedir=$HOME/jobs/$JOB_ID_SPLIT/saver_data
else
	echo "Restoring from:"
	echo $restore
	python3 launch_parallel_sb3.py -n $ncpus --logdir=$HOME/jobs/$JOB_ID_SPLIT/logs --savedir=$HOME/jobs/$JOB_ID_SPLIT/saver_data --restore=$restore
fi
cp -r ../* $HOME/jobs/$JOB_ID_SPLIT

# date
# python3 single_runner.py --savedir=$HOME/jobs/$JOB_ID_SPLIT/saver_data
# cp -r test_run $HOME/jobs/$JOB_ID_SPLIT/rl-training/

exit 0
