#!/bin/bash

set -e # exit when a command fails

# GLOBAL
provisioning_profiles_folder="$HOME/Library/MobileDevice/Provisioning Profiles"

# ARGS
operation=$1
if [ -z $operation ]; then 
  operation="-h"
fi

# Display help
# usage: xcsim -h
if [ $operation = "-h" ]; then
  echo ""
  echo "  -h : Prints help"
  echo "  -l : Shows installed profiles"
  echo "  -o : Opens profiles folder"
  echo ""

  exit 0
fi

# List profiles
if [ $operation = "-l" ]; then
  for profile in "$provisioning_profiles_folder"/*.{mobileprovision,provisionprofile}; do
    filename=${profile##*/}
    echo -n "$filename: "
    security cms -D -i "$profile" > temp.plist # decrypt the profile
    profileName=`/usr/libexec/PlistBuddy -c "print :Name" temp.plist`
    echo "=> '$profileName'"
  done
  rm temp.plist
  exit 0
fi

# Open profiles folder
if [ $operation = "-o" ]; then
  open "$provisioning_profiles_folder"
fi
