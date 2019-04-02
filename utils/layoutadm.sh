#!/bin/bash

function get_file_info
{
	typeset dst=$1
	typeset url=$2
	typeset src=$(basename $url)
	typeset suffix="."${src#*.}

	dst=$dst$suffix
	dstfile=/tmp/$dst
	rm -f $dstfile
	wget -O $dstfile $url -o ${dstfile}.out
	if (( $? != 0 )); then
		cat ${dstfile}.out >&2
		rm -f $dstfile
		return 1
	fi

	cat ${dstfile}.out | sed 's/^/DEBUG> /g ' >&2
	typeset md5=$(md5sum $dstfile | awk '{print $1}')
	echo "-   $dst: $src $md5"
	rm -f $dstfile
	return 0
}

raw_layout=${1?"*** layout file ***"}
while read line; do
	line=$(echo $line)
	[[ -z $line ]] && continue
	[[ $line == "#"* ]] && continue

	dst=$(echo $line | awk '{print $1}')
	url=$(echo $line | awk '{print $2}')
	get_file_info $dst $url || exit 1
done < $raw_layout
