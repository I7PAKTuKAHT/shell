#!/bin/bash

#   Name: audit_bkp.sh
#   Description: Archiving all ABAP Security audit log files from ABAP dialog instance by month and delete
#   Author: Boris Gyulumyants
#   email: bgyulumyants@tsconsulting.com
#   Version: 0.1
#   Date: 13.11.2019
#
#   How to use: You can run script manualy by <sid>adm
#   You can schedule script once a day by adding it to the crontab
#   0 23 */1 * * <sid>adm /<path to script>/audit_bkp.sh > /<path to script>/audit_bkp.log 2>&1

#   Set retention days for security audit logs

delete_mode=1
retention_days="+60"

#   Set file parts
preffix="audit_"
suffix=""


#   Set current year
year=$(date +"%Y")
local_time=$(date +"%d.%m.%Y %H:%M")

source $HOME/.sapsrc.sh


ArchiveLogs() {
    for ((j=2000; j<=$year; j++)); do
        for ((i=1; i<=12; i++)); do
            if [ $i -lt 10 ];
            then
                find ./ -type f \( -iname "${preffix}${j}${suffix}0${i}*" ! \( -iname "*.zip" -or -iname "*.tar.gz" \) \) | xargs -r zip -uv ${preffix}${j}${suffix}0${i}.zip
            else
                find ./ -type f \( -iname "${preffix}${j}${suffix}${i}*" ! \( -iname "*.zip" -or -iname "*.tar.gz" \) \) | xargs -r  zip -uv ${preffix}${j}${suffix}${i}.zip
            fi
        done
    done
}


DeleteLogs() {
    # For the test purpose this code only prints files needs to be removed. To productive run uncomment string
    find ./ -type f \( -iname "${preffix}*" ! \( -iname "*.zip" -or -iname "*.tar.gz" \) \) -mtime $retention_days -print
    #find ./ -type f \( -iname "${preffix}*" ! \( -iname "*.zip" -or -iname "*.tar.gz" \) \) -mtime $retention_days -delete
}


echo $local_time
if [ $delete_mode -eq 1 ];
then
    echo "Script run in delete mode"
else
    echo "Script run in archive mode"
fi

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
            if [ $? -eq 0 ]; then
                echo "Archiving logs from: $(pwd)"
                ArchiveLogs
                if [ $delete_mode -eq 1 ]; then
                    echo "Deleting logs older than $retention_days days from:"
                    echo "$(pwd)"
                    DeleteLogs
                fi
            fi
        elif [ $rc2 -eq 0 ]; then
            cd /usr/sap/$SAPSYSTEMNAME/D[0-9][0-9]/log
            if [ $? -eq 0 ]; then
                echo "Archiving logs from: $(pwd)"
                ArchiveLogs
                if [ $delete_mode -eq 1 ]; then
                    echo "Deleting logs older than $retention_days days from:"
                    echo "$(pwd)"
                    DeleteLogs
                fi
            fi
        fi
    done
fi

