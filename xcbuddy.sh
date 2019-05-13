#!/bin/bash

operation=$1

if [ -z $operation ]; then
  operation="-h"
fi

# Display help
# usage: xcbuddy -h
if [ $operation = "-h" ]; then
  echo "usage:"
  echo "-h : Prints help"
  echo "-p : Prints current Xcode path"
  echo "-s [xcode_version] : Change command line tools"
  echo "-o [xcode_version] [project_file]: Open project with the specified Xcode version"
  echo "-d : Shows Xcode installed versions"
  echo "-m : Display available simulators"

  exit 0
fi

# Print command line tools current path
# usage: xcbuddy -p
if [ $operation = "-p" ]; then
  xcode-select -p
  exit 0
fi

# Change command line tools
# usage: xcbuddy -s [version]
if [ $operation = "-s" ]; then
  if [[ -z $2 ]]; then
    echo "Missing Xcode version"
    exit 1
  fi

  xcode_version=$2
  xcode_path="/Applications/Xcode_$xcode_version.app/Contents/Developer"
  echo "Switch to: $xcode_path"
  sudo xcode-select -s $xcode_path
  exit 0
fi

# Open Xcode project with an specific version
# usage: xcbuddy -o [version] [project]
if [ $operation = "-o" ]; then
  xcode_version=$2
  xcode_app_name="Xcode_$xcode_version.app"
  project=$3
  open -a $xcode_app_name $project
  exit 0
fi

# Show Xcode installed versions
# usage: xcbuddy -d
if [ $operation = "-d" ]; then
  ls /Applications | grep "Xcode"
  exit 0
fi

# Display simulators
# usage: xcbuddy -m
if [ $operation = "-m" ]; then
  xcrun simctl list devices available
  exit 0
fi