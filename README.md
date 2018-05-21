# prepPSX

A script to prepare runnable BIN/CUE packages from various common compressed PSX ROM archive formats.

Fully tested to be working on PS3 running CFW using multiMAN.


## Features
* Supports .7z & .rar archives. Additionally, performs recursive .7z extraction on .rar archives.
* Converts .ecm > .bin format.
* Full handling of multibin/multitrack formats > single .bin file.
* Full handling of .ape track audio formats > single .bin file.
* Cleaning & renaming:
    * Creates directories for each rom. Removes all files except .bin & .cue files in the final package.
    * Strips the track info (e.g "Track 01.bin") & disc part number (e.g. "SLES-12345") from the name.
    * Leaves region info in the name.


## Requirements
1. p7zip *(sudo apt-get install p7zip-full)*
2. unrar *(sudo apt-get install unrar-free)*
3. ecm *(sudo apt-get install ecm)*
4. monkeys-audio *(sudo apt-get monekys-audio)*
5. binmerge *(https://github.com/putnam/binmerge/blob/master/binmerge)*


## Installation
1. Download binmerge script & install all required linux packages.
2. Update "BINMERGE=" path in script to point to the location of your binmerge script file.


## Usage
**Usage:**
```
prepPSX.sh /path/to/romarchives /path/to/cuefiles
```

This will create 3 folders in the path of the rom archive directory: `completed`, `missingcue`, & `multibinfail`.

- `completed` : Successful rom extractions/conversions will be moved here.
- `missingcue` : Rom extractions will be moved here if there is an error finding the corresponding .cue file for the rom (either not in the rom archive itself or not found in the /path/to/cues directory).
- `multibinfail` : Rom extractions will be moved here if there is an error with the binmerge script (throws a bad return value).

<br />
***This script is for educational purposes only. The author is not responsible for its use. Please use only for games that you legally own.***
