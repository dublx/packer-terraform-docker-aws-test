#!/bin/bash
set -euo pipefail

if [ -f builds/build ]; then
	echo "$0: Found build file in $(pwd)/builds/build. Exiting."
	exit 1
fi

TIME=$(date +%k%M)
DAY=`/bin/date +%Y%m%d`
BUILD="${DAY}_${TIME}"
PACKERBUILDLOG="builds/${BUILD}/packer.build.log"
echo "Executing build ${BUILD}"
echo "Packer Build Log file: ${PACKERBUILDLOG}"
PACKERTMPL="packer_docker.json"
AMIFILE="builds/${BUILD}/packer.ami"
AMINAME="Ubuntu_14.04-Docker-${BUILD}"

[[ ! -d builds/${BUILD}/ ]] && mkdir builds/${BUILD}

# create new AMI using Packer and save the id to file ${AMIFILE}
PACKERCMD="packer build -var ""ami_name=${AMINAME}"" -var aws_access_key=${AWS_ACCESS_KEY} -var ""aws_secret_key=${AWS_SECRET_KEY}"" ${PACKERTMPL}"
$PACKERCMD 2>&1 | tee ${PACKERBUILDLOG}
tail -2 ${PACKERBUILDLOG} | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }' > ${AMIFILE}

# validate packer worked and we created ${AMIFILE}
if [ -f ${AMIFILE} ]; then
	echo "$0: Created AMI: $(cat ${AMIFILE}) and saved to $(pwd)/${AMIFILE}"
	echo "${BUILD}" > builds/build
	exit 0
else
	echo "$0: Failed to create AMI file at: $(pwd)/${AMIFILE}"
fi
exit 1