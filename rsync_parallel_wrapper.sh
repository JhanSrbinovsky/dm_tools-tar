#!/bin/bash
# This script assumes that the rsync_parallel.sh script is in the same directory as this wrapper.

copydir=/scratch/p66/cm2704/archive
destination=/g/data/p73/archive/

exps=(
PI-02
PI-1pct-04
)

scriptloc=`dirname $0`
for exp in ${exps[@]}; do
  echo "parallel rsync: $copydir/$exp to $destination"
  qsub -v "wrapdir=$copydir/$exp, wrapdest=$destination" $scriptloc/rsync_parallel.sh
  #break
done
exit
