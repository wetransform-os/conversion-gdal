#!/bin/bash

source ./cmdarg.sh

CMDARG_ERROR_BEHAVIOR=exit

cmdarg_info "header" "Helper script for ogr2ogr file conversion"
cmdarg_info "author" "Simon Templer <simon@wetransform.to>"
cmdarg_info "copyright" "(C) 2016 wetransform GmbH"
cmdarg 'i:' 'source' 'Source file location (http/https URL or local file path)'
cmdarg 'n?' 'source-name' 'If input is a URL, provide a name for the downloaded file, if the format detection relies on the file extension'
cmdarg 'd?' 'target-dir' 'Target directory where to put files'
cmdarg 'o:' 'target-name' 'The main target file name (file name only)'
cmdarg 'f:' 'target-format' 'OGR target format'
cmdarg 's?' 'source-srs' 'Override source SRS'
cmdarg 't?' 'target-srs' 'Provide target SRS to convert to'
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
  curl $source_loc > "${DATA_DIR}/source/${source_file}"
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
  # use extracted content as new source
  source_loc="${DATA_DIR}/source-zip"
fi

# create target directory
target_dir=${cmdarg_cfg['target-dir']}
if [ -z "$target_dir" ]; then
  target_dir="${DATA_DIR}/target"
fi
mkdir -p $target_dir || true

# build ogr2ogr comman
convert_cmd="time ogr2ogr"

source_srs=${cmdarg_cfg['source-srs']}
target_srs=${cmdarg_cfg['target-srs']}

if [ -n "$source_srs" ]; then
  # source srs is provided
  # add as parameter
  convert_cmd="$convert_cmd -s_srs \"$source_srs\""
  if [ -z "$target_srs" ]; then
    # no target srs, but if s_srs is provided, t_srs must be as well
    target_srs=$source_srs
  fi
fi
if [ -n "$target_srs" ]; then
  # target srs is provided
  # add as parameter
  convert_cmd="$convert_cmd -t_srs \"$target_srs\""
fi

target_loc="$target_dir/${cmdarg_cfg['target-name']}"
target_format=${cmdarg_cfg['target-format']}
convert_cmd="$convert_cmd -f \"$target_format\" \"$target_loc\" \"$source_loc\""

# run
echo "Executing conversion..."
eval $convert_cmd
rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Conversion failed"; exit $rc; else echo "Conversion successful"; fi
