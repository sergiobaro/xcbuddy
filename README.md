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
  -p : Prints current Xcode path
  -s [xcode_version] : Switch command line tools
  -o [xcode_version] [project_file] : Open project with the specified Xcode version
  -o : Open workspace or project in current directory with default Xcode version
  -d : Shows Xcode installed versions
  -m : Display available simulators
  -x : Update (carthage & xcodegen) and open project with default settings
```
