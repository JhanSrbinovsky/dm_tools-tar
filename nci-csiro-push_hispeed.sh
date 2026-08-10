#!/bin/bash
#SBATCH --ntasks=5
#SBATCH --mem=8Gb
#SBATCH --time=18:00:00
#SBATCH --job-name=rs_nci-push_hispeed
#SBATCH --partition=io
#SBATCH --output rs_nci-push_hispeed_%j.log

module load jemalloc
module load parallel
csiro_ident=$USER

########################################################

# This tool is designed to be used on CSIRO's internal HPC system
# Pushes data from CSIRO' tape system 'Datastore' to NCI's Gadi HPC

# NOT FOR USE ON NCI; CSIRO ONLY.

# This script is based on the best-practice work by Thomas Moore and Ondrej Hlinka at CSIRO. See:
# https://github.com/Thomas-Moore-Creative/CSIRO-NCI-data-best-practice/blob/master/Solution_Archive_DCFP_NCI_ALCG_data_to_CSIRO_tape.md 

########################################################
# USER DEFINED VARIABLES

# NCI user details
nci_ident=cm2704
ncidir=/scratch/p73/${nci_ident}/tars/

# CSIRO user details
csirodir=/datastore/${csiro_ident}/ACCESS/

#-------------------------------------------------------

gadi=${nci_ident}@gadi-dm.nci.org.au
logdir=$csirodir/logs_${SLURM_JOB_ID}

########################################################

echo "nci-csiro_push_hispeed"
echo "ntasks: ${SLURM_NTASKS}"
echo "job_id: ${SLURM_JOB_ID}"
echo "ncidir: ${ncidir}"
echo "csirodir: ${csirodir}"
echo "logdir: ${logdir}"
echo ""

function timeleft () {
  t_remain=$( squeue -h -j ${SLURM_JOB_ID} -O timeleft | xargs )
  echo "time remaining: $t_remain (${#t_remain})"
  if [ "${#t_remain}" -le 7 ]; then
    echo "<10hr remaining; exiting job"
    echo "true" > ${logdir}/resubmit.txt
    exit 1
  fi
}
export -f timeleft
mkdir -p $logdir
if [ ! -d "$logdir" ]; then
  echo "$logdir does not exist, and cannot be created; exiting"
  exit
fi
echo "false" > ${logdir}/resubmit.txt
resub=$( cat ${logdir}/resubmit.txt )
export csirodir
export logdir

filelist=$logdir/rs_filelist.txt
echo "reading filelist from csiro"
find ${csirodir} -type f -name "*.tar*" 2>/dev/null > $filelist
sed -i "s#${csirodir}##g" $filelist

echo "copying script to logdir"
script=$0
echo $script
cp $script $logdir

maincommand="echo {}; rsync -ravWR --log-file=\"${logdir}/rsync_nci-push_hispeed.log.$(date +%Y%m%d%H%m%S)\" -e \"ssh -T -c aes128-ctr\" \"${csirodir}\"/./{} \"${gadi}\":\"${ncidir}\" ; timeleft "

echo $maincommand

time cat ${filelist} | parallel -j ${SLURM_NTASKS} --halt soon,fail=1 "$maincommand"

resub=$( cat ${csirodir}/resubmit.txt )
if $resub; then
  echo "resubmitting script"
  sbatch ${logdir}/`basename $script`
fi

echo "completed; cleaning up"
mv rs_nci-push_hispeed_${SLURM_JOB_ID}.log $logdir
tar -uvf $csirodir/logs.tar $logdir
rm -r $logdir

exit
