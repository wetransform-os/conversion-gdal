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
else
  # strip file protocol (for Argo conversions)
  source_loc="${source_loc#file:}"
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
    source_loc="${DATA_DIR}/source-zip"
  fi

  echo "New source is ${source_loc}"
fi

# create target directory
target_dir=${cmdarg_cfg['target-dir']}
if [ -z "$target_dir" ]; then
  target_dir="${DATA_DIR}/target"
fi
mkdir -p $target_dir || true

# build ogr2ogr command
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
else
  # Extract driverShortName
  driverShortName=$(ogrinfo -json $source_loc | jq -r '.driverShortName')
  echo "Driver Short Name: $driverShortName"
  # Check if driverShortName is GML and source_srs is not set
  if [ "$driverShortName" == "GML" ]; then
    echo "GML driver detected and no source SRS provided, setting FORCE_SRS_DETECTION=YES"
    convert_cmd="$convert_cmd -oo FORCE_SRS_DETECTION=YES"
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

custom_args=${cmdarg_cfg['args']}

if [ -n "$custom_args" ]; then
  # add custom arguments
  convert_cmd="$convert_cmd $custom_args"
elif [ "$target_format" == "GML" ]; then
  # special options for GML target format
  convert_cmd="$convert_cmd -dsco FORMAT=GML3.2 -dsco SRSNAME_FORMAT=OGC_URL -dsco PREFIX=hc -dsco TARGET_NAMESPACE=http://wetransform.to/hale-connect/converter/gml"
elif [ "$target_format" == "GPKG" ]; then
  # special options for GPKG target format

  # -forceNullable: allow creation w/o GML IDs when converted from GML
  # not added as a general option because for instance not supported by all drivers (e.g. GMLAS driver)
  convert_cmd="$convert_cmd -forceNullable"
fi

# run
echo "Executing conversion..."
echo "Command: $convert_cmd"
eval $convert_cmd
rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Conversion failed"; exit $rc; else echo "Conversion successful"; fi
