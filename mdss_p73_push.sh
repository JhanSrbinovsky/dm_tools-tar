#!/bin/bash
###################################################
#
# This tool (mdss_push) is designed to tar up certain output streams from
# ACCESS UM (atmos) data, and push them to MDSS. 
# An equivalent tool exists to pull from MDSS and untar automatically (mdss_pull)

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
mkdir -p $tardir
mkdir -p $logs
mkdir -p $tmp

# do the thing
cd $maindir
echo -e "\nexp: $exp"
# count up different .p[i,j,7,8] and loop
for pp in ${umstreams[@]}; do
  tasknm=${exp}.${pp}
  findpp=$( find $exp/history/atm/netCDF/ -type f -name "*.$pp*" -printf "%p\n" | sort )
  findppnum=$( echo "${findpp[@]}" | wc -l )
  if [[ $findppnum -gt 1 ]] || [ -f $tardir/$exp.$pp.tar ] ; then
    echo -e "${pp}: $findppnum files"
    mdss -P $mdss_proj mkdir -p ACCESS_archive/subdaily/$exp
    #write tar job
    cat << EOF > $tmp/${tasknm}_tar.sh
#!/bin/bash
#PBS -P p66
#PBS -q normal
#PBS -l storage=scratch/p66+gdata/p73+scratch/p73
#PBS -l ncpus=1,walltime=24:00:00,mem=8Gb,wd
#PBS -j oe
#PBS -o ${logs}/${tasknm}_tar.log
#PBS -N ${tasknm}_tar
echo "$exp $pp"
if [ ! -f $tardir/$exp.$pp.tar ]; then
  echo "tarring $maindir/$exp/history/atm/netCDF/*.$pp* -> $tardir/$exp.$pp.tar"
  tar -cvf $tardir/$exp.$pp.tar $maindir/$exp/history/atm/netCDF/*.$pp* \
    && echo "tar successful, deleting $pp files"; rm $maindir/$exp/history/atm/netCDF/*.$pp*
else
  echo "tar exists"
fi
echo "submitting mdss move job:"
netcp -M -P $mdss_proj -l other=mdss,storage=gdata/p73+scratch/p66,mem=2GB \
  -N ${tasknm}_mdss -d $logs -o ${tasknm}_mdss.log -e ${tasknm}_mdss.log \
  $tardir/$exp.$pp.tar ACCESS_archive/subdaily/$exp/
EOF
  ls $tmp/${tasknm}_tar.sh
  qsub $tmp/${tasknm}_tar.sh
  fi
done

exit
