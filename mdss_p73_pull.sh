#!/bin/bash
###################################################
#
# This tool (mdss_pull) is designed to pull certain output streams of
# ACCESS UM (atmos) data from MDSS and untar them.
# An equivalent tool exists to tar and push to MDSS (mdss_push).

# NOTE: These scripts are specifically designed for the management of the ACCESS model output archive on p73,
# however the basic principles can be adapted for general use.
# see https://confluence.csiro.au/display/ACCESS/ACCESS+Model+Output+Archive+%28p73%29+Wiki

# Author: Chloe Mackallah, CSIRO

###################################################
# USER DEFINED VARIABLES

maindir=/g/data/p73/archive/CMIP6/ACCESS-ESM1-5
umstreams=( p7 p8 pi pj )
exp=bj402  # can be read in via wrapper

#--------------------------------------------------
# Other variables
mdss_proj=p73    # project for MDSS
tardir=/scratch/p73/$USER/tars_p73    # directory for saving temporary files

###################################################

# check if wrapper is used, and overwrite exp
if [ ! -z $1 ]; then
  export exp=$1
fi
# set up
logs=$tardir/logs
tmp=$tardir/tmp
mkdir -p $logs
mkdir -p $tmp

# do the thing
cd $maindir
echo -e "exp: $exp"
massdir=ACCESS_archive/subdaily/$exp
# count up different .p[streams] and loop
for pp in ${umstreams[@]}; do
  echo $pp
  cat << EOF > $tmp/$exp.${pp}_pull.sh
#!/bin/bash
#PBS -P p66
#PBS -q copyq
#PBS -l storage=gdata/p73+scratch/p73
#PBS -l ncpus=1,walltime=10:00:00,mem=8Gb,wd
#PBS -j oe
#PBS -o ${tmp}/${exp}.${pp}.log
#PBS -N pull_subd_${exp}_${pp}
echo "$exp $pp"
mdss -P $mdss_proj get ACCESS_archive/subdaily/$exp/$exp.$pp.tar $maindir/$exp/history/atm/netCDF
tar -xvf $maindir/$exp/history/atm/netCDF/$exp.$pp.tar && rm $maindir/$exp/history/atm/netCDF/$exp.$pp.tar
EOF
  qsub $tmp/$exp.${pp}_pull.sh
done

