#!/bin/bash
dlurl=https://github.com/HL7China/fhir-ig-publisher/releases/latest/download/publisher.jar
publisher_jar=publisher.jar
input_cache_path=./input-cache/

set -e
if ! type "curl" > /dev/null; then
	echo "ERROR: Script needs curl to download latest IG Publisher. Please install curl."
	exit 1
fi

FORCE=false

while :; do
    case $1 in
        -f|--force) FORCE=true ;;
        --)
            shift
            break
            ;;
        *) break
    esac
    shift
done

publisher="$input_cache_path$publisher_jar"
if test -f "$publisher"; then
	echo "IG Publisher FOUND in input-cache"
	jarlocation="$publisher"
	jarlocationname="Input Cache"
	upgrade=true
else
	publisher="../$publisher_jar"
	upgrade=true
	if test -f "$publisher"; then
		echo "IG Publisher FOUND in parent folder"
		jarlocation="$publisher"
		jarlocationname="Parent Folder"
		upgrade=true
	else
		echo IG Publisher NOT FOUND in input-cache or parent folder...
		jarlocation=$input_cache_path$publisher_jar
		jarlocationname="Input Cache"
		upgrade=false
	fi
fi

if [[ "$FORCE" != true ]]; then
  if "$upgrade"; then
    message="Overwrite $jarlocation? (Y/N) "
  else
    echo Will place publisher jar here: "$jarlocation"
    message="Ok (enter 'y' or 'Y' to continue, any other key to cancel)?"
  fi
  read -r -p "$message" response
fi

if [[ "$FORCE" == true ]] || [[ "$response" =~ ^([yY])$ ]]; then
	echo "Downloading most recent publisher to $jarlocationname - it's ~100 MB, so this may take a bit"
#	wget "https://fhir.github.io/latest-ig-publisher/org.hl7.fhir.publisher.jar" -O "$jarlocation" 
	curl -L $dlurl -o "$jarlocation" --create-dirs
else
	echo cancel...
fi
