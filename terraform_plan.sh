#!/bin/bash
set -euo pipefail

if [ ! -f builds/build ]; then
	echo "$0: Not found $(pwd)/builds/build"
	exit 1
else

	BUILD=$(cat builds/build)
	TFAPPLYLOG="builds/${BUILD}/terraform.apply.log"
	TFPLANLOG="builds/${BUILD}/terraform.plan.log"
	TFPLAN="builds/${BUILD}/terraform.plan"
	TFVARS="terraform.tfvars"
	AMIFILE="builds/${BUILD}/packer.ami"

	echo "terraform plan log file: ${TFPLANLOG}"

	if [ -f ${AMIFILE} ]; then
		AMI=$(cat ${AMIFILE})
		echo "$0: Read AMI=$AMI"

		TFSTATE="builds/${BUILD}/terraform.tfstate"
		if [ -f ${TFSTATE} ]; then
			echo "Found existing state file: ${TFSTATE}"
			TFSTATE="-state=${TFSTATE}"
		else
			TFSTATE=""
		fi
		terraform plan ${TFSTATE} -out ${TFPLAN} -var-file ${TFVARS} -var "ami=${AMI}" 2>&1 | tee ${TFPLANLOG}

		if [ ! -f ${TFPLAN} ]; then
			echo "$0: terraform plan failed. See $(pwd)${TFPLANLOG}"
			exit 1
		else
			exit 0
		fi
	else
		echo "$0: AMI file not found. Expected file at $(pwd)/builds/${AMIFILE}"
	fi
	exit 1
fi