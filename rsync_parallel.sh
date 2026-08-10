#!/bin/bash
#PBS -P p66
#PBS -q normal
#PBS -l ncpus=10,walltime=12:00:00,mem=8Gb,wd
#PBS -l storage=scratch/p66+gdata/p66+scratch/p73+gdata/p73
#PBS -j oe
#PBS -N rs_par

module load parallel

tocopy=/scratch/p66/cm2704/archive/PI-C-01
destination=/g/data/p73/archive/non-CMIP

if [ ! -z $wrapdir ]; then
  tocopy=$wrapdir
  destination=$wrapdest
fi

newgrp=p73

JOBID=${PBS_JOBID}
NCPUS=${PBS_NCPUS}

mkdir -p $destination/file_lists/${JOBID}
rm -f $destination/file_lists/${JOBID}/*
rsync -av --ignore-existing --dry-run $tocopy $destination > $destination/file_lists/${JOBID}/list.main
#exit
num=$( cat $destination/file_lists/${JOBID}/list.main | wc -l )
numspl=$(( $num / ${NCPUS} + 1 ))
echo $numspl
split -l $numspl $destination/file_lists/${JOBID}/list.main $destination/file_lists/${JOBID}/list.
rm $destination/file_lists/${JOBID}/list.main
#exit

ls $destination/file_lists/${JOBID}/list.* | \
  parallel --group -v -j $NCPUS rsync -av --no-dirs --chown=:${newgrp} --files-from={} $tocopy/.././ $destination
#  parallel --lb -v -j $NCPUS rsync -av --files-from={} $tocopy/./ $destination

exit
