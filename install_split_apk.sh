#!/bin/bash

# Save initial working directory
initial_wd=$(pwd)

# Location for installation /data/local/tmp
install_dir="/data/local/tmp"
temp_path=""

full_path=$(realpath "$0")
dir_path=$(dirname "$full_path")

# Change to script directrory
cd "$dir_path"

# Copy apks to install_dir, if they are not already there
if [[ "$dir_path" != "$install_dir"* ]] ; then
  random=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)
  temp_path="$install_dir/tmp.$random"
  mkdir "$temp_path"
  cp *.apk "$temp_path/"
  cd "$temp_path"
fi

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

# Go back to the initial working directory
cd "$initial_wd"

# Clean up
if [[ "$temp_path" != "" ]] ; then
  rm -r "$temp_path"
fi 
