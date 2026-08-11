# Data Management tools for large datasets on NCI's Gadi HPC system

### `tar-n-split.sh`
This script is for tarring up large datasets (>~ 200 TB) into manageable chunks, usually for transferring to tape (CSIRO or MDSS). Contains instructions at end of file for untarring data.  
The wrapper, **`tar-n-split_wrapper.sh`**, is useful if you have multiple datasets/simulations to tar and transfer to tape.  
It is highly recommended to archive ACCESS model output first using https://git.nci.org.au/cm2704/ACCESS-Archiver.

Commands for untarring these files is provided at the end of the script.  
Credit to Tilo Ziehn, CSIRO.

Edit the file and input the required paths into the variables:  
*archdir="path/to/pre-existing/files"*  
*tardir="path/in/which/to/save/tars"*

Usage:  
```
$ qsub tar-n-split.sh
```
OR  
```
$ ./tar-n-split_wrapper.sh 
```
Notes:jxs599:: edit tar-n-split_wrapper.sh - specify experiment directory to tar. i.e. set $p73exp
            :: edit tar-n-split.sh         - specify jobname to display that IDs experiment














---
### `rsync_parallel.sh`
This script is for copying large datasets/simulations (>~ 1 TB) from one location to another on NCI in a fast and scalable way, using gnuparallel. Increase the number of CPUs (#PBS -l ncpus=**10**) to scale up for a faster transfer.  
The wrapper, **`rsync_parallel_wrapper.sh`**, is useful if you have multiple datasets/simulations to transfer simultaneously.  

Edit the file and input the required paths into the variables:  
*tocopy="path/to/pre-existing/files"*  
*destination="path/in/which/to/copy/files"*

Usage:  
```
$ qsub rsync_parallel.sh
```
OR  
```
$ ./rsync_parallel_wrapper.sh 
```

---
### `scratch_purge_checking.sh`
This is a wrapper for NCI's `nci-file-expiry` tool to scan /scratch for datasets that are vulnerable to purging (https://opus.nci.org.au/pages/viewpage.action?pageId=145883145).  
The tool itself provides a list of individual files, while the wrapper will synthesise this into a list of vulnerable datasets and directories.

Usage:
```
$ qsub scratch_purge_checking.sh
```

---
### NCI-CSIRO data transfers
There are two tools in this respository for large data transfers between NCI (currently Gadi) and CSIRO systems (currently Petrichor).  
The two scripts are **`nci-csiro-pull_hispeed.sh`** (for NCI-to-CSIRO transfers), and **`nci-csiro-push_hispeed.sh`** (for CSIRO-to-NCI transfers).  

NOTE: These scripts \*must\* be run from the CSIRO HPC system, and are designed specifically for large tar files that are intended for long-term tape storage on CSIRO's Datastore. 

Edit the file and input the required paths (and your NCI ident) into the variables:  
*ncidir="path/to/directory/on/NCI"*  
*csirodir="path/to/directory/on/CSIRO/HPC"*

Usage:  
```
$ sbatch nci-csiro-pull_hispeed.sh
```
OR
```
$ sbatch nci-csiro-push_hispeed.sh
```

---
### NCI's MDSS data transfers
There are two tools in this respository for the transfer of UM model output to and from NCI's MDSS tape system.  
The two scripts are **`mdss_p73_push.sh`** (for NCI-to-MDSS transfers), and **`mdss_p73_pull.sh`** (for MDSS-to-NCI transfers).   
The wrapper, **`mdss_p73_wrapper.sh`**, is useful if you have multiple datasets/simulations to transfer simultaneously.  

NOTE: These scripts are specifically designed for the management of the [ACCESS model output archive on p73](https://confluence.csiro.au/display/ACCESS/ACCESS+Model+Output+Archive+%28p73%29+Wiki), however the basic principles can be adapted for general use.

Credit to Thomas Moore and Ondrej Hlinka at CSIRO. See: https://github.com/Thomas-Moore-Creative/CSIRO-NCI-data-best-practice/blob/master/Solution_Archive_DCFP_NCI_ALCG_data_to_CSIRO_tape.md 


Edit the file and input the required info into the variables:  
*maindir="path/to/directory/on/p73/with/experiments/for/transfer"*  
*umstreams=( a list of UM streams to transfer to MDSS. must be in a Bash-style list )*  
*exp="local-exp-name"*

Usage:
```
$ ./mdss_p73_push.sh
```
OR
```
$ ./mdss_p73_pull.sh
```
OR
```
$ ./mdss_p73_wrapper.sh
```


# dm_tools-tar
