#!/bin/bash

set -e # exit when a command fails

# GLOBAL
version="0.6"
default_derived_data_folder=~/Library/Developer/Xcode/DerivedData
ios_device_support_folder=~/Library/Developer/Xcode/iOS\ DeviceSupport
provisioning_profiles_folder=~/Library/MobileDevice/Provisioning\ Profiles

# FUNCTIONS

# Find current selected Xcode file name
find_current_xcode_app_name () {
  current_xcode_app_path=$(xcode-select -p | tr "/" " ")
  for path in $current_xcode_app_path; do
    if [[ $path == *"Xcode"* ]]; then
      xcode_app_name=$path
    fi
  done

  echo $xcode_app_name
}

# Find in current directory a workspace or a project file
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
  if [ -f "Package.swift" ]; then
    echo "Package.swift"
  fi
}

# Resolve dependencies for: carthage, pods and swift package manager
resolve_dependencies () {
  if [ -f "Cartfile" ]; then
    carthage bootstrap --platform ios
  fi
  if [ -f "Podfile" ]; then
    pod install
  fi
  if [ -f "Package.swift" ]; then 
    swift package update
  fi
}

# Generate project file for: xcodegen and swift package manager
generate_project () {
  if [ -f "project.yml" ]; then
    xcodegen
  fi
  if [ -f "Package.swift" ]; then
    swift package generate-xcodeproj
  fi 
}

# MAIN

operation=$1

if [ -z $operation ]; then
  operation="-h"
fi

# Display help
# usage: xcbuddy -h
if [ $operation = "-h" ]; then
  echo ""
  echo "  -h : Prints help"
  echo "  -v : Prints current xcbuddy version"
  echo "  -p : Prints current Xcode path"
  echo "  -s [xcode_version] : Switches command line tools"
  echo "  -o [xcode_version] [project_file] : Opens project with the specified Xcode version"
  echo "  -o : Opens workspace or project in current directory with default Xcode version"
  echo "  -l : Shows Xcode installed versions"
  echo "  -u : Updates dependencies and generates the project file if needed"
  echo "  -x [xcode_version] [project_file] : Updates and then opens"
  echo "  -c : Shows Xcode cache size ('DerivedData' & 'iOS DeviceSupport')"
  echo "  -r : Removes Xcode default derived data folder"
  echo ""

  exit 0
fi

# Print current xcbuddy version
# usage: xcbuddy -v
if [ $operation = "-v" ]; then
  echo "$version"
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
    echo "Usage: xcbuddy -s [xcode_version]"
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
  xcode_app_name="Xcode.app"
  
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

  if [ -z "$project" ]; then
    echo "Project file not found"
    exit 1
  fi
  
  open -a $xcode_app_name "$project"

  exit 0
fi

# List Xcode installed versions
# usage: xcbuddy -l
if [ $operation = "-l" ]; then
  ls /Applications | grep "Xcode"
  exit 0
fi

# Update project
# usage: xcbuddy -u
if [ $operation = "-u" ]; then
  resolve_dependencies
  generate_project
  exit 0
fi

# Update and open
# usage: xcbuddy -x
if [ $operation = "-x" ]; then
  xcbuddy -u
  xcbuddy -o $2 $3
  exit 0
fi

# Shows Xcode cache
# usage: xcbuddy -c 
if [ $operation = "-c" ]; then
  du -hs "$default_derived_data_folder" || true
  find "$ios_device_support_folder" -maxdepth 1 -exec du -hs '{}' \;
  exit 0
fi

# Remove Xcode derived data folder
# usage: xcbuddy -r
if [ $operation = "-r" ]; then
  echo "Deleting ${default_derived_data_folder}/*"
  find $default_derived_data_folder -mindepth 1 -exec rm -rf '{}' \;
  exit 0
fi

echo "Operation '${operation}' not supported"
