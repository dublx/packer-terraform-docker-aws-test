#!/bin/bash
set -euo pipefail


NEW=false
BUILD=false
PACKERBUILD=false
TFPLAN=false
TFAPPLY=false
for var in "$@"
do
  if [[ $var == --build* ]]; then
    BUILD=$(echo $var | cut -d= -f 2)
    echo "Working on build ${BUILD}"
    cp builds/build builds/${BUILD}/build_${BUILD}
  fi
  if [ "$var" = "--new" ]; then
	rm builds/build || true
  fi
  if [ "$var" = "--packer-build" ]; then
    PACKERBUILD=true
  fi
  if [ "$var" = "--tf-plan" ]; then
    TFPLAN=true
  fi
  if [ "$var" = "--tf-apply" ]; then
    TFAPPLY=true
  fi
done


if [ ${PACKERBUILD} = true ]; then
	./packer_build.sh
fi

if [ ${TFPLAN} = true ]; then
	./terraform_plan.sh
fi

if [ ${TFAPPLY} = true ]; then
	./terraform_apply.sh
fi
