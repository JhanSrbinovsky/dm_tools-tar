#!/bin/bash
#PBS -P p66
#PBS -q normal
#PBS -l ncpus=1,walltime=24:00:00,mem=8Gb,wd
#PBS -l storage=scratch/p73+gdata/p73
#PBS -j oe
#PBS -N esm-r1

cd $PBS_O_WORKDIR

tardir=tars
tarname=`basename $wrapdir`

if [[ ! -f $tardir/$tarname.tar.part-* ]]; then
  echo "creating tar files: $tardir/$tarname.tar.part-*"
  tar -C `dirname $wrapdir` -cvf - $tarname \
    | split -d -b 200GB - "$tardir/$tarname.tar.part-"
  echo "tars created successfully"
else
  echo "$tardir/$tarname.tar.part-* already exists, exiting"
  exit
fi

exit

# TO UNTAR:
# cat ${tarname}.tar.part-* | tar -xvf -
