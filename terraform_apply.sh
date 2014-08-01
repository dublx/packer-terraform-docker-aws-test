#!/bin/bash
set -euo pipefail

BUILD=$(cat builds/build)
if [ ! -f builds/build ]; then
	echo "$0: Not found $(pwd)/builds/build. Exiting."
	exit 1
fi

TFPLAN="builds/${BUILD}/terraform.plan"
if [ ! -f ${TFPLAN} ]; then
	echo "$0: Not found $(pwd)/${TFPLAN}. Exiting."
	exit 1
fi

TFAPPLYLOG="builds/${BUILD}/terraform.apply.log"
echo "terraform apply log file: ${TFAPPLYLOG}"

TFSTATE="builds/${BUILD}/terraform.tfstate"
TFSTATEBKUP="builds/${BUILD}/terraform.tfstate.bak"
TFVARS="terraform.tfvars"
AMIFILE="builds/${BUILD}/packer.ami"
AMI=$(cat ${AMIFILE})
terraform apply -state=${TFSTATE} -state-out=${TFSTATE} -backup=${TFSTATEBKUP} -var-file ${TFVARS} -var "ami=${AMI}" 2>&1 | tee ${TFAPPLYLOG}

TFAPPLYOUTPUT="builds/${BUILD}/terraform.output"
terraform show -state=${TFSTATE} 

if [ $? != 0 ]; then
	echo "$0: terraform apply failed. See log: ${TFAPPLYLOG}. Exiting."
else
	mkdir -p builds/${BUILD}/
	mv builds/build builds/${BUILD}/build_${BUILD}
fi


exit 1