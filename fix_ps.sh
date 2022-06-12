#!/bin/bash

cd /psx/PLAYSTATION

FLIST=$(find . -name \*.bin -type f | grep -v _ns)

for file in $FLIST
do
    SERIAL=$(strings ${file} | grep "^BOOT.*=.*S.US" | sed -e 's/.*\(S.US\).\([0-9][0-9][0-9]\).\([0-9][0-9]\).*/\1-\2\3/' | tail -1)
    if [ -z "${SERIAL}" ]; then
	SERIAL=$(strings ${file} | grep S.US-[0-9][0-9][0-9][0-9][0-9] | sed -e 's/.*\(S.US-[0-9][0-9][0-9][0-9][0-9]\).*/\1/' | tail -1)
    fi
    if [ ! -z "${SERIAL}" ]; then
	echo $file is $SERIAL
	REALNAME=$(grep "rom.*${SERIAL}" ~/Sony\ -\ PlayStation.dat | head -1 | sed -e 's/.*name "\(.*\)" size.*/\1/')
	CRC=$(grep "rom.*${SERIAL}" ~/Sony\ -\ PlayStation.dat | head -1 | sed -e 's/.*crc \(.*\) md5.*/\1/')
	NAME=$(grep -B3 "rom.*${SERIAL}" ~/Sony\ -\ PlayStation.dat | head -1 | grep description | awk '{$1=""; print $0}' | sed -e 's/^ //')
	DIRNAME=$(dirname $file)
	if [ ! -z "${REALNAME}" ]; then
	    #FIXNAME=$(printf '%q' "${REALNAME}")
	    if [ ! -f ${DIRNAME}/"$REALNAME" ]; then
		echo ln -s $(basename $file) ${DIRNAME}/"$REALNAME"
		ln -s $(basename $file) ${DIRNAME}/"$REALNAME"
	    fi
	    touch ${DIRNAME}/${SERIAL}
	    echo ${CRC} > ${DIRNAME}/crc32
	    echo ${NAME} > ${DIRNAME}/name
	    echo ${SERIAL} > ${DIRNAME}/serial
	else
	    echo $file bad realname UNKNOWN
	fi
    else
	echo $file UNKNOWN
    fi
done
