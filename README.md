# xctools

Scripts to handle Xcode from the command line

## Installation

```bash
$ make install
```

## xcbuddy

Script to open projects with a specific Xcode version. In order for this to work the Xcode app has to be named like this `Xcode_12.2.app` and then you can do `xcbuddy -o 12.2`.

```
  -h : Prints help
  -v : Prints current xcbuddy version
  -p : Prints current Xcode path
  -s [xcode_version] : Switches command line tools
  -o [xcode_version] [project_file] : Opens project with the specified Xcode version
  -o : Opens workspace or project in current directory with default Xcode version
  -l : Shows Xcode installed versions
  -u : Updates dependencies and generates the project file if needed
  -x [xcode_version] [project_file] : Updates and then opens
  -c : Shows Xcode cache size ('DerivedData' & 'iOS DeviceSupport')
  -r : Removes Xcode default derived data folder
```

## xcsim

Script to open simulators.

```
  -h : Prints help
  -l : Shows available simulators
  -u [url] : Open url in current simulator
  -s [file.png] : Takes screenshot from current simulator
  -r [file.mov] : Records video from current simulator
  -p [json] [bundle] : Sends a push to the current simulator
  -c : Deletes unavailable simulators
  -o [name] : Opens a simulator
```

https://nshipster.com/simctl/

## xcprof

Script to handle installed provisioning profiles.

```
  -h : Prints help
  -l : Shows installed profiles
  -o : Opens profiles folder
```