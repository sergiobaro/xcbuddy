#!/bin/bash

operation=$1

# Print command line tools current path
if [ -z $operation ] || [ $operation = "-p" ]; then
  xcode-select -p
  exit 0
fi

# Help
if [ $operation = "-h" ]; then
  echo "usage:"
  echo "-h : Prints help"
  echo "-p : Prints current Xcode path"
  echo "-s [xcode_version] : Change command line tools"
  echo "-o [xcode_version] [project_file]: Open project with the specified Xcode version"

  exit 0
fi

# Change command line tools
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
if [ $operation = "-o" ]; then
  if [[ -z $2 ]]; then
    xcode_app_name=`xcode-select -p`
    open -a $xcode_app_name
    exit 0
  fi

  xcode_version=$2
  xcode_app_name="Xcode_$xcode_version.app"
  project=$3
  open -a $xcode_app_name $project
  exit 0
fi