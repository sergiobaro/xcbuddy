#!/bin/bash

# GLOBAL
version="0.4"

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
  echo "Usage:"
  echo "  -h : Prints help"
  echo "  -v : Prints current xcbuddy version"

  echo " Xcode:"
  echo "  -p : Prints current Xcode path"
  echo "  -s [xcode_version] : Switches command line tools"
  echo "  -o [xcode_version] [project_file] : Opens project with the specified Xcode version"
  echo "  -o : Opens workspace or project in current directory with default Xcode version"
  echo "  -l : Shows Xcode installed versions"
  echo "  -u : Updates dependencies and generates the project file if needed"
  echo "  -x : Updates and then opens"

  echo " Simulator:"
  echo "  sim l: Shows available simulators"
  echo "  sim o [url]: Open url in current simulator"
  echo "  sim s [file.png]: Takes screenshot from current simulator"
  echo "  sim r [file.mov]: Records video from current simulator"

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
fi

# Update and open
# usage: xcbuddy -x
if [ $operation = "-x" ]; then
  xcbuddy -u
  xcbuddy -o
fi


## SIMULATORS

# Display simulators
# usage: xcbuddy sim list
if [ $operation = "sim" ]; then
  command=$2
  if [ -z $command ]; then 
    command="l"
  fi

  # List simulators
  if [ $command = "l" ]; then
    xcrun simctl list devices available
    exit 0
  fi

  # Open url
  if [ $command = "o" ]; then
    url=$3
    if [ -z $url ]; then
      echo "Missing url parameter"
      echo "Usage: xcbuddy sim o [url]"
      exit 1
    fi
    if [[ ! $url = "https://"* ]] && [[ ! $url = "http://"* ]]; then
      url="https://$url"
    fi
    echo "xcrun simctl openurl booted $url"
    xcrun simctl openurl booted $url
    exit 0
  fi

  # Take screenshot
  if [ $command = "s" ]; then
    file=$3
    if [ -z $file ]; then 
      file="screenshot.png"
    fi
    xcrun simctl io booted screenshot $file
    if [ $? -eq 0 ]; then
      open $file
    fi
    exit 0
  fi

  # Record video
  if [ $command = "r" ]; then
    file=$3
    if [ -z $file ]; then
      file="video.mov"
    fi
    echo "Recording... press ^C to finish"
    # `h264` gives better frame rate than `hevc`
    xcrun simctl io booted recordVideo --codec=h264 --force $file
    if [ $? -eq 0 ]; then
      open $file
    fi
    exit 0
  fi

fi