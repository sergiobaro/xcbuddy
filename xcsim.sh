#!/bin/bash

set -e # exit when a operation fails

# GLOBAL
version="0.5"

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
  echo "  -l : Shows available simulators"
  echo "  -u [url] : Open url in current simulator"
  echo "  -s [file.png] : Takes screenshot from current simulator"
  echo "  -r [file.mov] : Records video from current simulator"
  echo "  -p [json] [bundle] : Sends a push to the current simulator"
  echo "  -c : Deletes unavailable simulators"
  echo "  -o [UUID] : Opens a simulator"
  echo ""

  exit 0
fi

# List simulators
if [ $operation = "-l" ]; then
  xcrun simctl list devices available
  exit 0
fi

# Open url
if [ $operation = "-u" ]; then
  url=$2
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
if [ $operation = "-s" ]; then
  file=$2
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
if [ $operation = "-r" ]; then
  file=$2
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

# Send push
if [ $operation = "-p" ]; then
  xcrun simctl push booted $2 $3
  exit 0
fi

# Clean
if [ $operation = "-c" ]; then
  xcrun simctl delete unavailable
  exit 0
fi

# Open simulator

select_sim () {
  # iPhone 8 (1B6CC249-26AF-4987-8349-E53F87747E88) (Shutdown)
  local sim_regex="^([[:alnum:][:blank:]\(\)-]+) \(([A-Z0-9\-]+)\) \(([A-Za-z]+)\)"

  local sims=""
  while read -r line ; do
    if [[ $line =~ $sim_regex ]]; then
      sims+="$line"
      sims+=$'\n'
    fi
  done < <(xcrun simctl list devices)

  local oldIFS=$IFS
  IFS=$'\n'
  local choices=( $sims )
  IFS=$oldIFS

  PS3="Select:"
  select sim in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == $sim ]]; then
        if [[ $item =~ $sim_regex ]]; then
          local sim_name=${BASH_REMATCH[1]}
          local sim_id=${BASH_REMATCH[2]}
          # local sim_status=${BASH_REMATCH[3]}
          echo "$sim_id $sim_name"
        fi
        break 2
      fi
    done
  done
}

if [ $operation = "-o" ]; then
  sim_id=$2
  if [ -z "$sim_name" ]; then
    read sim_id sim_name < <(select_sim)
  fi
  echo "Opening... $sim_name"
  open -a Simulator --args -CurrentDeviceUDID "$sim_id"
  xcrun simctl boot "$sim_id"
  exit 0
fi

echo "Operation '${operation}' not supported"