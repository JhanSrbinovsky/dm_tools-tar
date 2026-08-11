#!/bin/bash
# This script assumes: 
#     that the tar-n-split.sh script is in the same directory as this wrapper.
#     we are archiving production runs (as per experiment) from p73 (@ $p73archive below)

### user input req^d ###
p73exp=esm-flat10-zec
### END user input   ###

#production archive is here 
p73archive=/g/data/p73/archive/CMIP7/ACCESS-ESM1-6/production/

# experiment to archive
exp=$p73archive/$p73exp

#qsub the job
qsub -v "wrapdir=$exp" tar-n-split.sh

exit

