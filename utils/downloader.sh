#!/bin/bash
#
# Download files via 'wget', please make sure you have both WGET(1) [1] and
# JQ(1) [2] installed before use it.
#
# [1] WGET(1) - The non-interactive network downloader
# [2] JQ(1)   - Command-line JSON processor
#               https://stedolan.github.io/jq/
#

NAME=$(basename $0)
CDIR=$(dirname $0)
TMPDIR=${TMPDIR:-"/tmp"}

function get_baseurl
{
	typeset f_json=$1
	jq -r .baseurl[] $f_json | base64 -d
}

function get_map
{
	typeset f_json=$1
	typeset f_sec=$2
	if [[ $f_sec == "all" ]]; then
		jq -r .map[] $f_json | egrep ':' | sed 's%"%%g'
	else
		jq -r .map[] $f_json | egrep ':' | sed 's%"%%g' | egrep $2
	fi
}

function download_one
{
	typeset dst=$1
	typeset src=$2
	typeset baseurl=$3
	typeset md5_exp=$4
	typeset download_dir=${DOWNLOAD_DIR:-"/tmp"}
	typeset cmd="wget -O $download_dir/$dst $baseurl/$src"
	if [[ $DRYRUN == "yes" ]]; then
		echo $cmd
		rc=$?
	else
		if [[ -f $download_dir/$dst ]]; then
			typeset md5_got=$(md5sum $download_dir/$dst | \
			                  awk '{print $1}')
			if [[ $md5_got == $md5_exp ]]; then
				echo "INFO: skipping $dst as it does exist"
				return 0
			fi
		fi

		echo ">>> $cmd"
		eval "$cmd"
		typeset rc=$?
		if (( rc == 0 )); then
			typeset md5_got=$(md5sum $download_dir/$dst | \
			                  awk '{print $1}')
			if [[ $md5_got != $md5_exp ]]; then
				echo "Oops, $download_dir/$dst is invalid" >&2
				echo "md5 exp: $md5_exp" >&2
				echo "md5 got: $md5_got" >&2
				rc=1
			fi
		fi
		echo ">>>"
	fi
	return $rc
}

function download
{
	typeset baseurl=$1
	typeset f_json=$2
	typeset f_sec=$3

	typeset -i rc=0
	if [[ $f_sec == "all" ]]; then
		typeset f_map=$TMPDIR/$NAME.map.$$
		get_map $f_json $f_sec > $f_map
		while read line; do
			typeset dst=$(echo $line | awk -F':' '{print $1}')
			typeset src=$(echo $line | awk -F':' '{print $2}' | \
		                      awk '{print $1}')
			typeset md5=$(echo $line | awk -F':' '{print $2}' | \
		                      awk '{print $2}')
			download_one $(echo $dst) $(echo $src) $baseurl $md5
			if (( $? != 0 )); then
				echo "ERROR: fail to download file $dst" >&2
				((rc += 1))
			fi
		done < $f_map
		rm -f $f_map
	else
		typeset s_map=$(get_map $f_json $f_sec)
		typeset dst=$(echo $s_map | awk -F':' '{print $1}')
		typeset src=$(echo $s_map | awk -F':' '{print $2}' | \
		              awk '{print $1}')
		typeset md5=$(echo $s_map | awk -F':' '{print $2}' | \
		              awk '{print $2}')
		download_one $(echo $dst) $(echo $src) $baseurl $md5
		if (( $? != 0 )); then
			echo "ERROR: fail to download file $dst" >&2
			rc=1
		fi
	fi

	return $rc
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
f_sec=${2:-"all"}

f_json=$TMPDIR/$NAME.$$.json
trap "rm -f $f_json" EXIT

yaml_setup && ./yamladm tojson $f_yaml > $f_json

baseurl=$(get_baseurl $f_json)
download $baseurl $f_json $f_sec
exit $?
