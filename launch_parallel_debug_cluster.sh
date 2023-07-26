#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l select=1:ncpus=8:mem=64gb
#PBS -j oe

# Cluster Environment Setup
cd $PBS_O_WORKDIR

module load anaconda3/personal
source activate incomp_sac

# Copy over the whole dir
cp -r $PBS_O_WORKDIR/Incompact3d_Flaps $TMPDIR/
cp -r $PBS_O_WORKDIR/rl-training $TMPDIR/

# cd $TMPDIR/Incompact3d_Flaps
# make clean
# make

cd $TMPDIR/rl-training
echo $description
cat params.json
JOB_ID_SPLIT=${PBS_JOBID%.*}
mkdir $HOME/jobs/$JOB_ID_SPLIT
echo $description > $HOME/jobs/$JOB_ID_SPLIT/job_description.txt

date
ray start --head --port=6379 --temp-dir=/rds/general/user/pm519/ephemeral --num-gpus=0
python3 launch_parallel_td3.py -n 4 --logdir=$HOME/jobs/$JOB_ID_SPLIT/logs --savedir=$HOME/jobs/$JOB_ID_SPLIT/saver_data
cp -r ../* $HOME/jobs/$JOB_ID_SPLIT

# date
# python3 single_runner.py --savedir=$HOME/jobs/$JOB_ID_SPLIT/saver_data
# cp -r test_run $HOME/jobs/$JOB_ID_SPLIT/rl-training/

ray stop
exit 0
