#!/bin/bash

# get the total size of all apks in byte
total_apk_size_bytes=0
for filename in *.apk; do
    apk_size_bytes=$(stat -c %s $filename)
    let total_apk_size_bytes=$total_apk_size_bytes+$apk_size_bytes
done

echo "pm install-create total size $total_apk_size_bytes"

# Example output
# create_output="Success: created install session[1165024922]"
create_output=$(pm install-create -S $total_apk_size_bytes)
pm_session_id=$(echo $create_output |grep -E -o '[0-9]+')

echo "pm install-create session id $pm_session_id"

apk_index=0
for filename in *.apk; do
    apk_size_bytes=$(stat -c %s $filename)
    pm install-write -S $apk_size_bytes $pm_session_id $apk_index $filename
    let apk_index=$apk_index+1
done

pm install-commit $pm_session_id
