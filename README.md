# xcbuddy

Simple bash script to help managing different installed Xcode versions

## Installation

```bash
$ make install
```

## Usage

```
  -h : Prints help
  -v : Prints current xcbuddy version
 Xcode:
  -p : Prints current Xcode path
  -s [xcode_version] : Switches command line tools
  -o [xcode_version] [project_file] : Opens project with the specified Xcode version
  -o : Opens workspace or project in current directory with default Xcode version
  -l : Shows Xcode installed versions
  -u : Updates dependencies and generates the project file if needed
  -x : Updates and then opens
  -c : Shows Xcode cache size ('DerivedData' & 'iOS DeviceSupport')
  -r : Removes Xcode default derived data folder
 Simulator:
  sim l: Shows available simulators
  sim o [url]: Open url in current simulator
  sim s [file.png]: Takes screenshot from current simulator
  sim r [file.mov]: Records video from current simulator
  sim p [json] [bundle]: Sends a push to the current simulator
```
