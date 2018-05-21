# prepPSX

A script to prepare runnable BIN/CUE packages from common compressed PSX ROM archive formats.


## Features
* Supports .7z & .rar archives. Additionally, performs recursive .7z extraction on .rar archives.
* Converts .ecm > .bin format.
* Full handling of multibin/multitrack formats > single .bin
* Full handling of .ape track audio formats > single .bin
* Cleaning & renaming:
    * Creates directories for each rom. Removes all files except .bin & .cue file in the final package.
    * Strips the track info (e.g "Track 01.bin") & disc part number (e.g. "SLES-12345") from the name.
    * Leaves region info.


## Requirements
1. ecm *(sudo apt-get install ecm)*
2. monkeys-audio *(sudo apt-get monekys-audio)*
3. binmerge *(https://github.com/putnam/binmerge/blob/master/binmerge)*


## Installation
1. Download binmerge script & install ecm/monkeys-audio linux packages.
2. Update "BINMERGE=" path in script to point to your binmerge script file.


## Usage
**Usage:**
```
prepPSX.sh /path/to/romarchives /path/to/cuefiles
```

This will create 3 folders in the path of the rom archive directory: `completed`, `missingcue`, & `multibinfail`

- Successful rom extractions/conversions will be moved to `completed`.
- If there is an error finding the corresponding cue file for the rom .bin (either not in the rom archive itself or not found in the /path/to/cues directory), then the rom extraction will be moved to `missingcue`.
- If there is an error for whatever reason with the binmerge script (throws a bad return value), then the rom extraction will be moved to `multibinfail`.


<br />
***This script is for educational purposes only. The author is not responsible for its use. Please only use for games that you legally own.***
