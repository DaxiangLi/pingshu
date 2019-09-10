#!/bin/bash

NAME=$(basename $0)
CDIR=$(dirname $0)
TMPDIR=${TMPDIR:-"/tmp"}

BIN_MP3_URL=$CDIR/get_mp3_url
function get_mp3_urls
{
	typeset f_json=$1
	typeset n=$(cat $f_json | egrep '\.mp3' | wc -l)
	typeset -a a_urls=""
	for (( i = 1; i <= n; i++ )); do
		typeset id=$(printf "%03d" $i)
		typeset s=$(egrep "$id.mp3" $f_json)
		typeset dst=$(echo $s | awk '{print $1}' | \
			      awk -F'"' '{print $2}')
		typeset url=$(echo $s | awk '{print $2}' | \
			      awk -F'"' '{print $2}')
		typeset mp3_url=$($BIN_MP3_URL $url)

		echo $dst $mp3_url
	done
}

function yaml_setup
{
	[[ $PYTHONPATH == *"oyaml"* ]] && return 0

	[[ ! -d /tmp/oyaml ]] && \
		git clone https://github.com/wimglenn/oyaml.git /tmp/oyaml
	export PYTHONPATH=/tmp/oyaml:$PYTHONPATH
	return 0
}

f_yaml=${1?"*** YAML file, e.g. ../data/lsxx/layout01.yaml ***"}

f_json=$TMPDIR/$NAME.$$.json
trap "rm -f $f_json" EXIT

yaml_setup && ./yamladm tojson $f_yaml > $f_json
echo '```'
get_mp3_urls $f_json
echo '```'
exit $?
