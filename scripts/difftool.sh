#!/bin/bash

### BEGIN INFO
# Usage -
#
# this tool has the following operation modes:
#
# fully automatic mode:		./difftool -a
#
# manual manifest mode:		./difftool oldmanifest.xml newmanifest.xml [/path/to/goldenrepo]
#
# manual kernel diff mode:	./difftool -k commit_id_1 commit_id_2
#
# dependencies: git, diffutils, wget
# Description:	This script calculate the difference between two xml manifest
# 				files, then parses its results to git and print out the 
# 				git log of all repositories that changed.
### END INFO

source $(dirname $0)/../build_scripts/000_ENVVariables.sh

###
# test case
#
#source $(dirname $0)/testcase.sh

CLEARCASE_UPLOAD_DIR=${CLEARCASE_UPLOAD_DIR-/vobs/wtbu/CSSD_Linux_Releases/4430/Linux_27.x/PDB/DailyBuilds}
PREV_MANIFEST=${PREV_MANIFEST-undefined}
CURDIR=$(dirname $0)
LOGDIR=${LOGDIR-$CURDIR}
U_CONFIG_DIR=${U_CONFIG_DIR-$CURDIR}
LOGFILE=$LOGDIR/difftool.log
OUTFILE=$U_CONFIG_DIR/repo-changes.txt
MFST_STORE_DIR=${LOGDIR}
ARGS_MIN=2
ARGS_MAX=3
REPODIR=${GOLDEN_REPO-${BUILD_DIR}/${PROGRAM_NAME}/goldenrepo}
MODE="standalone"
found="false"	# flag to tell if previous manifest was found
max_tries=5 	# How many tries to fetch previous manifest file

# used tools and their opts
diff=/usr/bin/diff
diff_opts="-E -b -w -B"
git_opts="--pretty=format:'%h#%s#%cd#%cn#'"
wget_opts="--tries=2 -nd"

usage () {
	echo "usage: `basename $0` manifest1.xml manifest2.xml [path/to/repo]"
}

log () {
	echo "`date +%b\ %d\ %T` `basename $0`: $1" 1>>$LOGFILE	
	echo "`date +%b\ %d\ %T` `basename $0`: $1"
}

checkdeps () {
	if [ ! -x $diff ]; then
		log "error: diffutils not found in ${diff}. please check"
		exit 2
	fi
}

checkargs () {

	if [ $# -lt $ARGS_MIN ] || [ $# -gt $ARGS_MAX ]; then
		usage
		exit 85
	fi

	if [ ! -e $1 ] || [ ! -e $2 ]; then
		log "error: manifest file not found"
		exit 4
	fi

	if [ ! -z $3 ]; then
		if [ ! -d $3 ]; then
			log "repo directory $3 not found, please check"
			exit 3
		fi
		REPODIR=$3
	else
		if [ ! -d $REPODIR ]; then
			log "default repo dir $REPODIR not found, give me the correct path as third argument"
			exit 3
		fi
	fi
}

get_manifest_files () {
	cur_download_location="http://omapssp.dal.design.ti.com/$(echo ${CLEARCASE_UPLOAD_DIR}|sed -e 's#/vobs/wtbu/#VOBS/#')/L${RELANDDATE}"
	cur_manifest="L${RELANDDATE}_manifest.xml"
	cur_build=`echo ${RELANDDATE} |grep -o -E [0-9]+$`
	prev_build=$(($cur_build -1))

    # here we go, get the manifest files
	wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${cur_manifest} ${cur_download_location}/configuration/${cur_manifest}
	if [ $? -ne 0 ]; then
		rm -f ${MFST_STORE_DIR}/${cur_manifest}
		log "Current Daily Build manifest file ${cur_manifest} not found. Skipped"
		log "It was trying to fetch from: ${cur_download_location}/configuration/${cur_manifest}"
		exit 0
	fi
	log "Current Daily Build manifest file ${cur_manifest} found and downloaded"

	#lets try to find out the previous build manifest
	for ((x=0; x < max_tries; x++)); do
		previous_manifest=`echo $RELANDDATE |sed "s/[0-9]*$/${prev_build}/"`
		prev_download_location="http://omapssp.dal.design.ti.com/$(echo ${CLEARCASE_UPLOAD_DIR}|sed -e 's#/vobs/wtbu/#VOBS/#')/L${previous_manifest}"
		previous_manifest="L${previous_manifest}_manifest.xml"
		 
		wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${previous_manifest} ${prev_download_location}/configuration/${previous_manifest}

		if [ $? -ne 0 ]; then
			#oops! not found, decrement DailyBuild by one and try again
			rm -f ${MFST_STORE_DIR}/${previous_manifest}
			prev_build=$(($prev_build - 1))
			log "Previous manifest ${previous_manifest} not found"
		else
			# ahaa! here you are
			found="true"
			log "previous manifest ${previous_manifest} found!"
			break
		fi
	done

    if [ ${found} = "false" ]; then
        log "Not previous manifest file was found in ${max_tries} tries, will check for \"PREV_MANIFEST\"!"
        if [ ! -z ${PREV_MANIFEST} ]; then
            # try to fetch using PREV_MANIFEST (note that must be an url)
            wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${PREV_MANIFEST##*/} ${PREV_MANIFEST}
            if [ $? -ne 0 ]; then
                # cleanup current manifest file
                rm -f ${MFST_STORE_DIR}/${cur_manifest}
                log "Previous manifest not found in ${PREV_MANIFEST} I give up for now. Skipping"
                exit 0
            fi
            # well we found it in PREV_MANIVEST variable so continue
            previous_manifest=${PREV_MANIFEST##*/}
            found=true
        else
            # not PREV_MANIFEST setted nor previous manifest file was found, so exit
			rm -f ${MFST_STORE_DIR}/${cur_manifest}
            log "\"PREV_MANIFEST\" is empty so could not fetch previous manifest file. You sholud check environment. Skipping"
            exit 0
        fi
    fi
}

get_kernel_diffs () {
	# once we obtained repo diffs then we fetch kernel patch diffs
	echo "********** KERNEL DIFFS **************" >>$OUTFILE
	echo "debug: cur_kernel_commit_id is ${CUR_KERNEL_ID}" >>$OUTFILE
	echo "debug: prev_kernel_commit_id is ${PREV_KERNEL_ID}" >>$OUTFILE
	(cd ${REPODIR}/${KERNEL_DIR}; git log ${git_opts} ${PREV_KERNEL_ID}..${CUR_KERNEL_ID}) >>$OUTFILE 2>>${LOGFILE}
	if [ $? -ne 0 ];then
		echo "there was a problem with git log, check the difftool.log for details"
	fi
}

#################
#		main 
#################

checkdeps

while getopts "k:a" opt; do
	case $opt in
		a)
			log "$(basename $0) started in automatic mode...."
			MODE="automatic"
			;;
		k)
			MODE="kernel_diff"
			;;
		\?)
			log "Invaid option -$OPTARG"
			exit 0
			;;
	esac
done

if [ "${MODE}" = "standalone" ]; then
	checkargs $1 $2 $3
	OLD_MFST=$1
	NEW_MFST=$2
elif [ "${MODE}" = "kernel_diff" ]; then
	REPODIR="."
	unset KERNEL_DIR
	PREV_KERNEL_ID=$2
	CUR_KERNEL_ID=$3
	get_kernel_diffs
	exit 0
elif [ "${MODE}" = "automatic" ]; then
	get_manifest_files
	NEW_MFST=$MFST_STORE_DIR/${cur_manifest}
	OLD_MFST=$MFST_STORE_DIR/${previous_manifest}

	# next we grab kernel commit id
	wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/prev_kernel_commit_id $prev_download_location/configuration/kernel_commit_id
	if [ $? -ne 0 ]; then
		log "wget warning: there was an error trying to get previous kernel commit id from $prev_download_location/configuration/kernel_commit_id"
	else
		PREV_KERNEL_ID=`cat ${MFST_STORE_DIR}/prev_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
	fi

	# now we have kernel commit id then cleanup file
	rm -f ${MFST_STORE_DIR}/prev_kernel_commit_id

	wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/cur_kernel_commit_id $cur_download_location/configuration/kernel_commit_id
    if [ $? -ne 0 ]; then
        log "wget warning: there was an error trying to get previous kernel commit id from $prev_download_location/configuration/kernel_commit_id"
	else
		CUR_KERNEL_ID=`cat ${MFST_STORE_DIR}/cur_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
    fi

	# now we have kernel commit id then cleanup file
	rm -f ${MFST_STORE_DIR}/cur_kernel_commit_id
else
	echo "Unkown option selected... Exiting"
	exit 0
fi

# Extract only the differential tags 
# eliminate white spaces at the begining 
# and substitute the middle whitespaces (separators) with ":"

diff_tags=`$diff $diff_opts $OLD_MFST $NEW_MFST |sed -n '/<project.*>/p' |sed 's/[\r\n]/\n/g' |sed 's/^<\s*</<change=\"out\" /g' |sed 's/^>\s*</<change=\"in\" /g' |sed 's/^\s*//g' |sed 's/\s/:/g'`

echo "********************************************" >>$OUTFILE
echo "Changes between $OLD_MFST and $NEW_MFST" >>$OUTFILE
echo "********************************************" >>$OUTFILE

if [ -e ${OUTFILE} ]; then
	cat /dev/null > ${OUTFILE}
fi

for tag in $diff_tags
do
	fields=`echo $tag |sed 's/<//' |sed 's/\/>//g' |sed 's/\"//g' | awk -F: '{ print $1, $2, $3, $4, $5, $6}'`

	for data in $fields
	do
		attr=`echo $data |awk -F\= '{ print $1 }'` 
		val=`echo $data |awk -F\= '{ print $2 }'`

		case $attr in
			name)
				name=$val
				;;
			path)
				path=$val
				;;
			revision)
				revision_final=$val
				;;
			change)
				change=$val
		esac
	done

	if [ "$change" = "out" ]; then
		continue
	fi
	
	name_temp=`echo $name |sed 's/\//>/g'`

	diff_tmp=`$diff $diff_opts $OLD_MFST $NEW_MFST |sed -n '/<project.*>/p' |sed 's/[\r\n]/\n/g' |sed 's/^<\s*</<change=\"out\" /g' |sed 's/^>\s*</<change=\"in\" /g' |sed 's/^\s*//g' |sed 's/>$//g'|sed 's/\s/:/g' |sed 's/\//>/g' |sed -n "/${name_temp}/p"`

	revision_initial=`echo $diff_tmp |awk '{ print $1 }' |awk -Frevision '{ print $2 }' |awk -F\" '{ print $2 }'`

	inc_final=`echo $revision_final |awk -F\/ '{ print $3 }'`
	inc_initial=`echo $revision_initial |awk -F\> '{ print $3 }'`

	# If no "path" tag found, use "name" as path
	if [ -z ${path} ]; then
		path=${name}
	fi

	if [ ! -z $inc_final ]; then
		revision_final=`(cd $REPODIR/$path; git rev-parse $(git remote)/$inc_final)`
	fi

	if [ ! -z $inc_initial ]; then
		revision_initial=`(cd $REPODIR/$path; git rev-parse $(git remote)/$inc_initial)`
	fi

	#clean commit id from any no SHA1 chars
	revision_initial=`echo $revision_initial |sed 's/[^0-9a-zA-Z]//g'`
	revision_final=`echo $revision_final |sed 's/[^0-9a-zA-Z]//g'`

	if [ ${revision_initial} = ${revision_final} ]; then
		continue;
	fi

	echo "Project ${name}" >>$OUTFILE

	# better get git log in a subshell
	(cd $REPODIR/$path; git log ${git_opts} ${revision_initial}..${revision_final}) >>$OUTFILE 2>>${LOGFILE}
	if [ $? -ne 0 ]; then
		log "Warning: there was an error fetching git log for project ${name}!"
	fi

	#just blank line among tree commits (as separator)
	echo "" >>$OUTFILE

done

if [ "$MODE" = "automatic" ]; then
	get_kernel_diffs

	# cleanup manifest files if executed in automatic mode
	log "cleaning up downloaded manifest files"
	rm -f $OLD_MFST
	rm -f $NEW_MFST
fi

exit 0
