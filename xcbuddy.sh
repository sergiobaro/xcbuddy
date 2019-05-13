#!/bin/bash

# FUNCTIONS

find_current_xcode_app_name () {
  current_xcode_app_path=$(xcode-select -p | tr "/" " ")
  for path in $current_xcode_app_path; do
    if [[ $path == *"Xcode"* ]]; then
      xcode_app_name=$path
    fi
  done

  echo $xcode_app_name
}

find_xcode_workspace_or_project () {
  for file in *.xcworkspace; do
    if [[ -d $file ]]; then
      echo "$file"
      return
    fi
  done
  for file in *.xcodeproj; do
    if [[ -d $file ]]; then
      echo "$file"
      return
    fi
  done
}

# MAIN

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
  echo "-o: Open workspace or project in current directory with default Xcode version"
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
  if [ -z $2 ]; then
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
  if [ -z $2 ]; then
    xcode_app_name=$(find_current_xcode_app_name)
  else 
    xcode_version=$2
    xcode_app_name="Xcode_$xcode_version.app"
  fi
  
  if [ -z $3 ]; then
    project=$(find_xcode_workspace_or_project)
  else
    project=$3
  fi

  if [ -z $project ]; then
    echo "Project file not found"
    exit 1
  fi
  
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
