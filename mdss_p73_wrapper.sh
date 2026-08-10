#!/bin/bash

exps=(
HI-aer-01
SSP-245-aer-01
)

for exp in ${exps[@]}; do
  ./mdss_push.sh $exp
  #./mdss_pull.sh $exp
  #break
done
exit
