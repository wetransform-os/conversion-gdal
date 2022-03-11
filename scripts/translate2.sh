#!/bin/bash

source ./cmdarg.sh

CMDARG_ERROR_BEHAVIOR=exit

cmdarg_info "header" "Helper script for conversion of images files using gdal_translate"
cmdarg_info "author" "Simon Templer <simon@wetransform.to>"
cmdarg_info "copyright" "(C) 2019 wetransform GmbH"
cmdarg 'i:' 'source' 'Source file location (http/https URL or local file path)'
cmdarg 'n?' 'source-name' 'If input is a URL, provide a name for the downloaded file, if the format detection relies on the file extension'
cmdarg 'w?' 'world' 'World file information as string, values separated by semicolons'
cmdarg 'd?' 'target-dir' 'Target directory where to put files'
cmdarg 'o:' 'target-name' 'The main target file name (file name only)'
cmdarg 'f:' 'target-format' 'GDAL target format'
cmdarg 'a?' 'args' 'Custom arguments'
cmdarg 'b?' 'fallback-args' 'Custom arguments for a second conversion try if the first fails'
cmdarg 'r?' 'warp-args' 'Custom arguments for a post processing of the image with gdalwarp'
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
    echo "ERROR: Multiple source files not supported"
    exit 1;
  fi

  echo "New source is ${source_loc}"
fi

# Create world file, if applicable
world=${cmdarg_cfg['world']}
if [ -n "$world" ]; then
  # create world file
  echo "Creating world file from parameter..."
  # source location w/o extension
  worldfile_loc="$(<<< "${source_loc}" sed -r 's/^(.*)\..*/\1/')"
  # write semicolon separated world information to file
  while IFS=';' read -ra ARR; do
    printf "%s\n" "${ARR[@]}" > "${worldfile_loc}.wld"
  done <<< "$world"
  echo "World file:"
  cat "${worldfile_loc}.wld"
fi

gdalinfo -noct $source_loc

# create target directory
target_dir=${cmdarg_cfg['target-dir']}
if [ -z "$target_dir" ]; then
  target_dir="${DATA_DIR}/target"
fi
mkdir -p $target_dir || true

# store JSON info for further processing
info_json="$target_dir/source-info.json"
gdalinfo -json -noct $source_loc > "$info_json"

# file name w/ extension
org_file_name=$(basename -- $source_loc)

# detect case of grayscale single band file
BANDS=$(cat "$info_json" | jq '.bands | length')
if [ "$BANDS" == "1" ] || [ "$BANDS" == "2" ]; then
  echo "File only has one or two bands"
  BAND_1_COLOR=$(cat "$info_json" | jq '.bands[0].colorInterpretation')
  if [ "$BAND_1_COLOR" == "\"Gray\"" ]; then
    echo "First band is Grayscale"

    # if there is only one band -> try to convert to gray + alpha
    if [ "$BANDS" == "1" ]; then
      ba_new_source="$target_dir/single-band-alpha-$org_file_name"
      eval rm $ba_new_source || true
      ba_cmd="time gdalwarp -wo \"UNIFIED_SRC_NODATA=YES\" -dstalpha -co TILED=YES -co COMPRESS=LZW \"$source_loc\" \"$ba_new_source\""
      eval $ba_cmd
      rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Trying to add alpha channel to single band file failed"; exit $rc;
      else
        echo "Added alpha to single band file";
        source_loc=$ba_new_source
      fi
    fi

    # convert Grey + Alpha image to RGBA
    ba_new_source="$target_dir/grey-rbga-$org_file_name"
    eval rm $ba_new_source || true
    ba_cmd="time gdal_translate -b 1 -b 1 -b 1 -b 2 -ot \"Byte\" -co PHOTOMETRIC=RGB -co TILED=YES -co COMPRESS=LZW \"$source_loc\" \"$ba_new_source\""
    eval $ba_cmd
    rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Trying to convert greyscale+alpha to RGBA"; exit $rc;
    else
      echo "Converted grayscale image to RGBA";
      source_loc=$ba_new_source
    fi
  fi
fi

# cleanup
rm "$info_json" || true

# build gdal_translate comman
# see https://www.gdal.org/gdal_translate.html
convert_cmd="time gdal_translate"
convert_cmd2="time gdal_translate"

custom_args=${cmdarg_cfg['args']}
fallback_args=${cmdarg_cfg['fallback-args']}

if [ -n "$custom_args" ]; then
  # add custom arguments
  convert_cmd="$convert_cmd $custom_args"
fi
if [ -n "$fallback_args" ]; then
  # add custom fallback arguments
  convert_cmd2="$convert_cmd2 $fallback_args"
fi

target_loc="$target_dir/${cmdarg_cfg['target-name']}"
target_format=${cmdarg_cfg['target-format']}
convert_cmd="$convert_cmd -of \"$target_format\" -co TILED=YES -co COMPRESS=LZW \"$source_loc\" \"$target_loc\""
convert_cmd2="$convert_cmd2 -of \"$target_format\" -co TILED=YES -co COMPRESS=LZW \"$source_loc\" \"$target_loc\""

# run
echo "Executing conversion..."
eval $convert_cmd
rc=$?
if [ $rc -ne 0 ]; then
  # retry conversion
  eval $convert_cmd2
  rc=$?
fi
if [ $rc -ne 0 ]; then echo "ERROR: Conversion failed"; exit $rc; else echo "Conversion successful"; fi

gdalinfo -noct $target_loc

# post-processing
warp_args=""
custom_warp_args=${cmdarg_cfg['warp-args']}

if [ -n "$custom_warp_args" ]; then
  # add custom arguments
  warp_args="$custom_warp_args"
fi

# test if file is has no ALPHA but NODATA (better do it with -json and jq?)
gdalinfo -noct $target_loc | grep "NoData Value"
rc=$?
if [ $rc -ne 0 ]; then
  echo "No NoData value detected in target file"
else
  # NODATA found
  gdalinfo -noct $target_loc | grep Alpha
  rc=$?
  if [ $rc -ne 0 ]; then
    # No ALPHA found -> try to convert NODATA to ALPHA
    warp_args="$warp_args -wo \"UNIFIED_SRC_NODATA=YES\" -dstalpha"
  else
    # ALPHA found -> do nothing
    echo "File already has Alpha channel"
  fi
fi

if [ -n "$warp_args" ]; then
  # run post-processing
  warp_cmd="time gdalwarp -co TILED=YES -co COMPRESS=LZW $warp_args $target_loc.tmp $target_loc"
  warp_cmd="mv $target_loc $target_loc.tmp && $warp_cmd && rm $target_loc.tmp"
  eval $warp_cmd
  rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Post-processing failed"; exit $rc; else echo "Post-processing successful"; fi
else
  echo "No post-processing required"
fi

# generate overviews using gdaladdo - https://gdal.org/programs/gdaladdo.html
overview_cmd="time gdaladdo -r bilinear -minsize 256 $target_loc"
eval $overview_cmd
rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Adding overviews failed"; exit $rc; else echo "Adding overviews successful"; fi

gdalinfo -noct $target_loc
