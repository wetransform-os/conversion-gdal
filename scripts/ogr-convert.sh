#!/bin/bash

source ./cmdarg.sh

CMDARG_ERROR_BEHAVIOR=exit

cmdarg_info "header" "Helper script for ogr2ogr file conversion"
cmdarg_info "author" "Simon Templer <simon@wetransform.to>"
cmdarg_info "copyright" "(C) 2016 wetransform GmbH"
cmdarg 'i:' 'in' 'Source file location'
cmdarg 'n?' 'source-name' 'If input is a URL, provide a name for the downloaded file'
cmdarg 'o:' 'out' 'Path to target file'
cmdarg 'f:' 'target-format' 'OGR target format'
cmdarg 's?' 'source-srs' 'Override source SRS'
cmdarg 't?' 'target-srs' 'Provide target SRS to convert to'
cmdarg_parse "$@"

web_regex='^(https?)://.+$'
source_loc=${cmdarg_cfg['in']}

echo "Source file location: $source_loc"

if [[ $source_loc =~ $web_regex ]]
then
  # download locally
  source_file=${cmdarg_cfg['source-name']}
  if [ -z "$source_file" ]; then echo "ERROR: Source file name must be set if file is downloaded from a URL"; exit 1; fi
  mkdir "${DATA_DIR}/source" || true

  curl $source_loc > "${DATA_DIR}/source/${source_file}"
  rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Error downloading source file"; exit $rc; fi
  source_loc="${DATA_DIR}/source/${source_file}"
fi

# test if source exists
if [ ! -f $source_loc ]; then
    echo "ERROR: Source file could not be found"
    exit 1;
fi

source_mime=$(file -b --mime-type $source_loc)
echo "Mime-type for source file: $source_mime"
