#!/bin/bash
#PBS -P p66
#PBS -q normal
#PBS -l ncpus=1,walltime=48:00:00,mem=8Gb,wd
#PBS -j oe
#PBS -N scratch_purge_summary

#proj=p66

rm -f scratch_purge_files.txt

if [ ! -f scratch_purge_files.txt ]; then
  #nci-file-expiry list-warnings --project $proj > scratch_purge_files.txt
  nci-file-expiry list-warnings > scratch_purge_files.txt
fi

echo -e "Your datasets that are vulnerable to purging: \n"

arch_paths=( history/atm history/atm/netCDF history/ocn history/ice 
  restart/atm restart/ocn restart/ice restart/cpl )

IFS=' '
vuln_dirs=( )
vuln_sims=( )
while read -r line; do
  read -a arr <<< $line
  vuln_file=${arr[4]}
  vuln_dir=`dirname $vuln_file`
  #echo orig_file: $vuln_file
  #echo orig_dir: $vuln_dir
  if [[ $vuln_file == PATH ]]; then continue ; fi
  if [[ $vuln_dir == */.git/* ]]; then continue ; fi
  arch=false
  for arch_path in ${arch_paths[@]}; do
    if [[ $vuln_dir == *$arch_path ]]; then 
    arch=true
      vuln_arch=${vuln_dir/$arch_path/}
      if [[ ! " ${vuln_sims[*]} " =~ " ${vuln_arch} " ]]; then
        vuln_sims+=( $vuln_arch )
        #echo arch: $vuln_arch
      fi
    fi
  done
  if $arch; then continue ; fi
  cylc=false
  if [[ $vuln_dir == */cylc-run/u-*/ ]]; then
    cylc=true
    vuln_cylc=${vuln_dir%%cylc-run/u-*/}
    if [[ ! " ${vuln_sims[*]} " =~ " ${vuln_cylc} " ]]; then
      vuln_sims+=( $vuln_cylc )
      #echo cylc: $vuln_cylc
    fi
  fi
  if $cylc; then continue ; fi
  if [[ ! " ${vuln_dirs[*]} " =~ " ${vuln_dir} " ]]; then
    vuln_dirs+=( $vuln_dir )
    #echo dir: $vuln_dir
  fi
done < scratch_purge_files.txt
 
echo -e "\n vulnerable simulation data: \n"
for vuln_sim in ${vuln_sims[@]}; do
  echo $vuln_sim
done

echo -e "\n other vulnerable directories: \n"
for vuln_dir in ${vuln_dirs[@]}; do
  echo $vuln_dir
done

