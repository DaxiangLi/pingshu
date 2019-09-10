#!/bin/bash
#
# Download files via 'wget', please make sure you have WGET(1) [1] installed
# before using it.
#
# [1] WGET(1) - The non-interactive network downloader
#

NAME=$(basename $0)
CDIR=$(dirname $0)
TMPDIR=${TMPDIR:-"/tmp"}

function download_one
{
	typeset dst=$1
	typeset url=$2
	typeset download_dir=${DOWNLOAD_DIR:-"/tmp"}
	typeset cmd="wget -O $download_dir/$dst $url"
	if [[ $DRYRUN == "yes" ]]; then
		echo $cmd
		rc=$?
	else
		[[ -f $download_dir/$dst ]] && \
		    echo "Oh, file $dst does exist" && return 0

		echo ">>> $cmd"
		eval "$cmd"
		typeset rc=$?
		echo ">>>"
	fi
	return $rc
}

function download
{
	typeset f_md=$1
	typeset f_sec=$2

	typeset -i rc=0
	if [[ $f_sec == "all" ]]; then
		while read line; do
			echo "$line" | egrep '.mp3' > /dev/null 2>&1
			(( $? != 0 )) && continue

			typeset dst=$(echo $line | awk '{print $1}')
			typeset url=$(echo $line | awk '{print $2}')
			download_one $dst $url
			if (( $? != 0 )); then
				echo "ERROR: fail to download file $dst" >&2
				((rc += 1))
			fi
		done < $f_md
	else
		typeset dst=$(egrep $f_sec $f_md | awk '{print $1}')
		typeset url=$(egrep "$dst" $f_md | awk '{print $NF}')
		download_one $dst $url
		if (( $? != 0 )); then
			echo "ERROR: fail to download file $dst" >&2
			rc=1
		fi
	fi

	return $rc
}

f_md=${1?"*** md file, e.g. ../data/lsxx/layout01_mp3.md ***"}
f_sec=${2:-"all"}
download $f_md $f_sec
exit $?
