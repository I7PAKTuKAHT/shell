#!/bin/bash

#   Name: Audit_bkp.sh
#   Description: Archiving all ABAP Security audit log files from ABAP dialog instance
#   Author: Boris Gyulumyants
#   email: bgyulumyants@tsconsulting.com
#   Version: 0.1
#   Date: 13.11.2019
#
#   How to use: You can run script manualy bu <sid>adm
#   You can schedule script once a day by adding it to the crontab 
#   * * */1 * * <sid>adm /<path to script>/audit_bkp.sh > /<path to script>/audit_bkp.log 2>&1

source $HOME/.sapsrc.sh

month=$(date +"%m")
year=$(date +"%Y")

ArchiveLogs() {
    for ((j=2000; j<=$year; j++)); do
        for ((i=1; i<=$month; i++)); do
            if [ $i -lt 10 ];
            then
                find ./ -type f \( -iname "audit_${j}0${i}*" ! -iname "*.zip" \) | xargs -r zip -uv audit_${j}0${i}.zip
            else
                find ./ -type f \( -iname "audit_${j}${i}*" ! -iname "*.zip" \) | xargs -r  zip -uv audit_${j}${i}.zip
            fi
        done
    done
}


ls -d /usr/sap/$SAPSYSTEMNAME/[D]*[0-9][0-9] >/dev/null 2>&1
if [ $? -eq 0 ]; then
    INSTANCEDIR_LIST=$(ls -d /usr/sap/$SAPSYSTEMNAME/[D]*[0-9][0-9])
    INSTANCEDIR_CI="/usr/sap/$SAPSYSTEMNAME/DVEBM"
    INSTANCEDIR_DI="/usr/sap/$SAPSYSTEMNAME/D"

    for d in $INSTANCEDIR_LIST; do
        echo $d | grep $(echo $INSTANCEDIR_CI) >/dev/null
        rc1=$?
        echo $d | grep $(echo $INSTANCEDIR_DI) >/dev/null
        rc2=$?
        if [ $rc1 -eq 0 ]; then
            cd /usr/sap/$SAPSYSTEMNAME/DVEBM*[0-9][0-9]/log
            ArchiveLogs
        elif [ $rc2 -eq 0 ]; then
            cd /usr/sap/$SAPSYSTEMNAME/D[0-9][0-9]/log
            ArchiveLogs
        fi
    done
fi