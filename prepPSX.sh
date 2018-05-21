#!/bin/bash

if [ "$#" != "2" ]; then
  echo -e "Usage: ./prepPSX.sh <romdir> <cuedir>\n"
  exit 1
fi

BINMERGE="/path/to/binmerge"  # Path to binmerge script
WD="${1}"
CUES="${2}"

MULTIBIN="${WD}/multibinfail"; if [ ! -d "${MULTIBIN}" ]; then mkdir "${MULTIBIN}"; fi
MISSINGCUE="${WD}/missingcue"; if [ ! -d "${MISSINGCUE}" ]; then mkdir "${MISSINGCUE}"; fi
COMPLETED="${WD}/completed"; if [ ! -d "${COMPLETED}" ]; then mkdir "${COMPLETED}"; fi

IFS=$'\n'  # Set the Internal Field Separator to properly make arrays from external ls commands

# Helper function, not for folders
exists () { [[ -f $1 ]]; }

if ! exists "${WD}"/*.7z && ! exists "${WD}"/*.rar  ; then
  echo Error: No compressed ROM files found in directory. && exit 1
fi

# Uncompress ecm file to bin
extract_ecm () {
  if [ -f "${DIR}"/*.ecm ]; then
    ecmfile=$( find "${DIR}" -name "*.ecm")
    ECMNAME="${ecmfile##*/}"
    ECMNAME=$( sed -r 's/(.*\/)//;s/(\.(bin\.)?(ecm))//' <<< "${ecmfile}" )
    ecm-uncompress "${DIR}"/*.ecm "${DIR}/${ECMNAME}.bin"
    rm "${DIR}"/*.ecm
  fi
}

copy_cue () {
  if [[ ${cuefile} ]]; then
    CUENAME="${cuefile##*/}"
    cp "${cuefile}" "${DIR}" 2> /dev/null
  else
    mv "${DIR}" "${MISSINGCUE}"
    echo \""${NAME}"\" is missing CUE file or something went wrong!
    continue
  fi
}

# Find and copy cue file if missing
find_cue () { 
  if ! [[ $cuefile ]] && ! exists "${DIR}"/*.cue; then
    cuefile=$( find "${CUES}" -maxdepth 2 -name "${NAME_E}.cue")
    copy_cue
  # cue file exists in archive but hasn't been recorded
  elif ! [[ $cuefile ]] && exists "${DIR}"/*.cue; then
    cuefile=$( find "${DIR}" -maxdepth 2 -name "*.cue")
    copy_cue
  else
    cuefile=$( find "${DIR}" -maxdepth 2 -name "*.cue")
  fi
} 

# Decompress APE audio to bin files
convert_ape () { 
  if exists "${DIR}"/*.ape; then
    for a in "${DIR}"/*.ape; do
      mac "${a}" "${a%.ape}.bin" -d
      rm "${a}"
    done
  fi
}

binmerge () { 
  if [[ $( python3 "${BINMERGE}" "${DIR}/${CUENAME}" "${NAME_C}" 2> /dev/null ) ]]; then
    rm -rf "${DIR}"/*\(Track*\)*
  else
    mv "${DIR}/" "${MULTIBIN}"
    echo Merging bin files for \""${NAME}"\" failed!
    continue
  fi
}

# Combine roms with multiple bin files
multibin () {
  binfiles=("${DIR}"/*.bin)
  binfiles2=("${DIR%/*}"/*.bin)
  trackone=($(ls "${DIR}"/ | egrep 'Track.*(1|01)'))  # Array
  # if all the bin files exist, also Track 01..
  if [[ ${#binfiles[@]} -gt 1 ]] && exists "${DIR}/${trackone[*]}"; then
    binmerge
  # if "Track 01" file is one level deeper..
  elif [[ ${#binfiles[@]} -eq 1 ]] && exists "${DIR}/${trackone[*]}"; then
    if [ "${DIR%/*}" != "${WD}" ] && [[ ${#binfiles2[@]} -gt 1 ]]; then
      mv "${DIR}"/* "${DIR%/*}"
      DIR="${DIR%/*}" # We must be a level deeper, so move back one level
      binmerge
    fi
  fi
}

# Decompress 7z archives
extract_7 () {
  7z x -o"${DIR}" "${h}"; rm "${h}"
}

# Decompress rar archives
extract_r () {
  # extract
  unrar x "${h}"; rm "${h}"
  
  # handle any embedded 7z archives  
  if [ -f "${DIR}"/*.7z ]; then
    F=$( find "${DIR}" -name "*.7z")
    mkdir "${DIR}/${NAME}"; 7z e -o"${DIR}/${NAME}" "${F}"; rm "${F}"
    mv "${DIR}/${NAME}"/* "${DIR}/${NAME}"/..
  fi
}

# Cleanup
cleanup () {
  # Remove all crap except bins and cues
  if (exists "${DIR}/${NAME_C}"*.bin || exists "${DIR}/${trackone[0]}") && exists "${DIR}/${NAME_C}"*.cue; then
    for a in "${DIR}"/*; do
      PAT1="${NAME_R}.*\.bin"
      PAT2="${NAME_R}.*\.cue"
      a="${a##*/}"
      if [[ "${a}" =~ ${PAT1} ]] || [ "${a}" = "${trackone[0]}" ]; then
        mv "${DIR}/${a}" "${DIR}/${NAME_C}.bin" 2>/dev/null
      elif [[ "${a}" =~ ${PAT2} ]]; then
        mv "${DIR}/${a}" "${DIR}/${NAME_C}.cue" 2>/dev/null
      else
        rm -rf "${DIR}/${a}"
      fi
    done
  fi
  # Move to completed
  mv "$DIR" "$COMPLETED/$NAME_C"
}

# Start
for h in "${WD}"/*; do
  # Skip folders
  if [ -f "$h" ]; then
    DIR="${h%.*}"
    FILEEXT="${h##*.}"
    NAME="${DIR##*/}"
    NAME_C=$( sed -r 's/(\s*\(Track [0-9]{1,2}\).*)//;s/\s*\[.*?\]//' <<< "${NAME}" )         # Clean track info and part number
    NAME_R=$( sed -r 's/\s/\\s/g;s/\./\\./g;s/\(/\\(/g;s/\)/\\)/g' <<< "${NAME_C}" )          # Bash regex format
    NAME_E=$( sed -r 's/(\s*\(Track [0-9]{1,2}\))/\*/;s/\[/\\[/g;s/\]/\\]/g' <<< "${NAME}" )  # find command format, make sure to glob
   
    if [ "$FILEEXT" == "rar" ]; then
      extract_r
    elif [ "$FILEEXT" == "7z" ]; then
      extract_7
    else
      echo "Unknown file type: \"$h\" - \"$FILEEXT\""
    fi
    extract_ecm  
    find_cue
    convert_ape
    multibin
    cleanup
    unset cuefile
  fi
done
