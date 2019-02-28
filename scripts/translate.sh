#!/bin/bash

source ./cmdarg.sh

CMDARG_ERROR_BEHAVIOR=exit

cmdarg_info "header" "Helper script for conversion of images files using gdal_translate"
cmdarg_info "author" "Simon Templer <simon@wetransform.to>"
cmdarg_info "copyright" "(C) 2019 wetransform GmbH"
cmdarg 'i:' 'source' 'Source file location (http/https URL or local file path)'
cmdarg 'n?' 'source-name' 'If input is a URL, provide a name for the downloaded file, if the format detection relies on the file extension'
cmdarg 'd?' 'target-dir' 'Target directory where to put files'
cmdarg 'o:' 'target-name' 'The main target file name (file name only)'
cmdarg 'f?' 'target-format' 'GDAL target format'
cmdarg 'a?' 'args' 'Custom arguments'
cmdarg_parse "$@"

web_regex='^(https?)://.+$'
source_loc=${cmdarg_cfg['source']}

echo "Source file location: $source_loc"

if [[ $source_loc =~ $web_regex ]]
then
  # download locally
  source_file=${cmdarg_cfg['source-name']}
  if [ -z "$source_file" ]; then
    # as fallback use filename w/o extension
    source_file="sourcefile"
  fi
  mkdir "${DATA_DIR}/source" || true
  echo "Downloading file..."
  curl -L $source_loc > "${DATA_DIR}/source/${source_file}"
  rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Error downloading source file"; exit $rc; fi
  # use downloaded file as new source
  source_loc="${DATA_DIR}/source/${source_file}"
fi

# test if source exists
if [ ! -f $source_loc ]; then
  echo "ERROR: Source file could not be found"
  exit 1;
fi

# check file mime type
source_mime=$(file -b --mime-type $source_loc)
echo "Mime-type for source file: $source_mime"

# extract if ZIP file
if [ "$source_mime" == "application/zip" ]; then
  echo "Source file is a ZIP file - extracting..."
  mkdir "${DATA_DIR}/source-zip" || true
  unzip "$source_loc" -d "${DATA_DIR}/source-zip"

  # count extracted files
  archive_file_count=$(ls -1 "${DATA_DIR}/source-zip/" | wc -l)

  if [ $archive_file_count -eq 1 ]; then
    # single file -> use as new source
    extracted_file=$(ls -1 "${DATA_DIR}/source-zip/")
    source_loc="${DATA_DIR}/source-zip/$extracted_file"
  else
    # multiple files
    # use extracted folder as new source
    echo "ERROR: Multiple source files not supported"
    exit 1;
  fi

  echo "New source is ${source_loc}"
fi

# create target directory
target_dir=${cmdarg_cfg['target-dir']}
if [ -z "$target_dir" ]; then
  target_dir="${DATA_DIR}/target"
fi
mkdir -p $target_dir || true

# build gdal_translate comman
# see https://www.gdal.org/gdal_translate.html
convert_cmd="time gdal_translate"

custom_args=${cmdarg_cfg['args']}

if [ -n "$custom_args" ]; then
  # add custom arguments
  convert_cmd="$convert_cmd $custom_args"
fi

target_loc="$target_dir/${cmdarg_cfg['target-name']}"
target_format=${cmdarg_cfg['target-format']}
convert_cmd="$convert_cmd -of \"$target_format\" \"$source_loc\" \"$target_loc\""

# run
echo "Executing conversion..."
eval $convert_cmd
rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Conversion failed"; exit $rc; else echo "Conversion successful"; fi
