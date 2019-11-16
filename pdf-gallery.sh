#!/usr/bin/env bash
# Copyright (c) 2019
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# HTML index file that will be created or overwritten
IDXHTML="idx.html"
# Subdirectory containing thumbnail images
SUBDIR="idx"
# File extension for documents in current directory
EXT="pdf"
# Temporary file; will be deleted upon exit
TMPFILE="~tmp.${EXT}"
# Force creation of thumbnails even if they already exist (parameter)
FORCE=0
# Display help message (parameter)
USAGE=0
# Max. number of conversion errors before abortion (parameter)
MAXERRORS=5
# Keep old thumbnails where document does not exist anymore (parameter)
KEEPTNAILS=0
# Reverse sort order of document files (parameter)
REVERSESORT=0
# Sort document files by modification date (parameter)
DATESORT=0
# Quiet, suppress output, no warning or error messages (parameter)
QUIET=0
# Output debug messages to standard output (parameter)
DEBUG=0

declare -A img_array
declare -a img_sorted

###############################################################################
# Functions
###############################################################################
# Display short help text and check ImageMagick requirements
function usage() {
	CONVERT="$(which convert 2>/dev/null)"
	PDFTK="$(which pdftk 2>/dev/null)"

	echo ""
	echo "$(basename $0) creates an HTML thumbnail gallery of all *.${EXT} files in"
	echo "current directory"
	echo ""
	echo "Files that will be indexed: *.${EXT}"
	echo "HTML index file: ${IDXHTML}"
	echo "Subdirectory with thumbnails: ./${SUBDIR}"
	echo ""
	echo "Tools used for file conversion:"
	echo "ImageMagick convert: ${CONVERT:-MISSING}"
	echo "pdftk: ${PDFTK:-MISSING}"
	check_imagemagick
	echo ""
	echo "Usage: $(basename $0) [-m] [-r] [-f] [-k] [-e <max_errors>] [-q] [-d] [-h]"
	echo -e "\t-m: Sort by ${EXT} file modification date (newest first)"
	echo -e "\t-r: Reverse sort order"
	echo -e "\t-f: Force creation of thumbnails even if they already exist"
	echo -e "\t-e <max_errors>: Maximum number of errors for creating thumbnails (default: ${MAXERRORS})"
	echo -e "\t-k: Keep old thumbnails that are associated to vanished ${EXT} files"
	echo -e "\t-q: Quiet, suppress output (no warning or error messages)"
	echo -e "\t-d: Output debug messages"
	echo -e "\t-h: Display usage, check requirements and exit"
	echo ""
}

# Write log message to stdout, error message to stderr
function log() {
	[[ ${QUIET} -eq 1 ]] && return
	[[ "$1" =~ ^ERROR ]] && echo $1 1>&2 && return
	[[ $DEBUG -eq 1 || "$1" =~ ^WARNING ]] && echo -e $1
}

# Check ImageMagick is installed and supports file conversion
function check_imagemagick() {
	which convert 1>/dev/null 2>&1
	RET=$?
	[[ $? -ne 0 ]] && echo "ERROR: convert not found (ImageMagick)"

	which identify 1>/dev/null 2>&1
	[[ $? -ne 0 ]] && echo "ERROR: identify not found (ImageMagick)" && return 1

	identify -list format | egrep "^[[:space:]]+JPEG" | grep -q "rw-"
	RET=$?
	[[ ${RET} -ne 0 ]] && echo "ERROR: ImageMagick does not support jpeg files"

	return ${RET}
}

# Convert document to jpg thumbnail; conversion errors will be returned
function do_convert() {
	INFILE=$1
	INEXT=$(echo $1 | sed -n "s/.*\.\(...\)/\1/gp")
	OUTFILE=$2
	RET=2

	rm -f ${TMPFILE}

	case ${INEXT} in
		pdf)
			OUT=$(pdftk "${INFILE}" cat 1 output "${TMPFILE}" 2>&1)
			RET=$?
			if [[ ${RET} -eq 0 ]] ; then
				#convert "${TMPFILE}" -define jpeg:size=1200x1500 -thumbnail '400x500' -background white -alpha remove "${OUTFILE}"
				OUT=$(convert -density 300 "${TMPFILE}" -define jpeg:size=1200x1500 -geometry x500 -background white -alpha remove -trim "${OUTFILE}" 2>&1)
				RET=$?
				if [[ ${RET} -ne 0 ]] ; then
					log "ERROR: Unable to convert file \"${INFILE}\" (convert=${RET})"
					log "DEBUG:\n${OUT}"
				fi
			else
				log "ERROR: Unable to convert file \"${INFILE}\" (pdftk=${RET})"
				log "DEBUG:\n${OUT}"
			fi
			;;
		*)
			log "ERROR: Files of type *.${INEXT} not (yet?) supported"
			RET=1
			;;
	esac

	rm -f ${TMPFILE}
	return ${RET}
}	

###############################################################################
# Command line options
###############################################################################
while getopts mrfhke:qd opt ; do
	case $opt in
		m) DATESORT=1;;
		r) REVERSESORT=1;;
		f) FORCE=1;;
		h) USAGE=1;;
		k) KEEPTNAILS=1;;
		e)
			MAXERRORS=${OPTARG}
			CHECKPAR="$(echo $MAXERRORS | sed -n "s/^\([0-9]\+\)$/\1/gp")"
			if [[ "${MAXERRORS}" != "${CHECKPAR}" ]] ; then
				log "ERROR: Invalid parameter -e ${MAXERRORS}"
				exit 1
			fi
			;;
		q) QUIET=1;;
		d) DEBUG=1;;
		?)
			exit 1
			;;
	esac
done

# Print usage and exit
if [[ ${USAGE} -eq 1 ]] ; then
	usage
	exit 0
fi

###############################################################################
# Check requirements (pdftk, ImageMagick)
###############################################################################
which pdftk 1>/dev/null 2>&1
[[ $? -ne 0 ]] && echo "ERROR: pdftk not found" && exit 1

check_imagemagick
[[ $? -ne 0 ]] && exit 1

###############################################################################
# Main
###############################################################################
# Create subdirectory with thumbnails
[[ ! -d "${SUBDIR}" ]] && mkdir "${SUBDIR}"
ERRCOUNT=0
[[ ${REVERSESORT} -eq 0 ]] && ORDER="" || ORDER="-r"
case ${DATESORT} in
	1)
		[[ ${REVERSESORT} -eq 0 ]] && ORDER="-t" || ORDER="-rt"
		;;
	*)
		;;
esac

while read i ; do
	BASE=$(basename "$i" .${EXT})
	NEWFILE="${SUBDIR}/idx-${BASE}.jpg"
	if [[ ! -f "${NEWFILE}" || ${FORCE} -eq 1 ]] ; then
		log "INFO: Processing $i ..."
		do_convert "$i" "${NEWFILE}"
		if [[ $? -eq 0 ]] ; then
			img_array[$i]="${NEWFILE}"
			img_sorted+=("$i")
		else
			ERRCOUNT=$((${ERRCOUNT} + 1))
			if [[ ${ERRCOUNT} -ge ${MAXERRORS} && ${FORCE} -eq 0 ]] ; then
				log "ERROR: Too many errors -> aborting (try using -f command line option)"
				exit 2
			fi
		fi
	else
		log "INFO: Skipping $i ..."
		img_array[$i]=${NEWFILE} && img_sorted+=("$i")
	fi
done< <(ls -1 ${ORDER} *.${EXT})

if [[ ${#img_sorted[@]} == 0 ]] ; then
	log "INFO: No ${EXT} files found"
	exit 0
fi

# Delete old thumbnails
if [[ $KEEPTNAILS -eq 0 ]] ; then
	while read TNAIL ; do
		FOUND=0
		for i in "${!img_array[@]}" ; do
			if [[ "${TNAIL}" == "${img_array[$i]}" ]] ; then
				FOUND=1
			fi
		done
		[[ ${FOUND} -ne 1 ]] &&	log "WARNING: Deleting old thumbnail ${TNAIL}" && rm -f "${TNAIL}"
	done< <(ls ${SUBDIR}/*.jpg)
fi

# Create html index file
log "INFO: Creating html file ..."

cat <<EOF >${IDXHTML} 
<html>
<head>
	<style>
		img {
			width: 100%;
			height: 100%;
			object-fit: contain;
			border: 1px solid #ddd;
			border-radius: 4px;
			padding: 3px;
		}
		img:hover {
			box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);
		}
		table {
			border-collapse: separate;
			border-spacing: 10px 5px;
			font-family: Arial, Helvetica, sans-serif;
		}
		td {
			text-align: center;
			vertical-align: top;
		}
	</style>
</head>
<body>
EOF

COLID=0
echo -e "<table>\n\t<tr>\n" >>${IDXHTML}
for i in "${img_sorted[@]}"; do 
	echo -e "\t\t<td><a target=\"_blank\" href=\"$i\"><img src=\"${img_array[$i]}\"></img></a><br/>$i</td>\n" >>${IDXHTML} 
	COLID=$((${COLID}+1))
	if [[ ${COLID} -ge 4 ]] ; then
		echo -e "\t</tr>\n\t<tr>\n" >>${IDXHTML}
		COLID=0
	fi
done
echo -e "\t</tr>\n</table></body>\n</html>\n" >>${IDXHTML}

rm -rf ${TMPFILE}
log "OK"
[[ $ERRCOUNT -ne 0 ]] && exit 1
exit 0
