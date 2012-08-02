#!/bin/bash

######INFO
# difftool.sh
#
# pull repository differences tool
#
# Copyright (C) 2010 Texas Instruments, Inc.
#
# This package is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# THIS PACKAGE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#  History
#  -------
#  0.9 2010-09-08 Jaime A. Garcia <jagarcia@ti.com> Created initial version
#
######
#
# Usage -
#
# this tool has the following operation modes:
#
# fully automatic mode:		./difftool -a
# manual manifest mode:		./difftool oldmanifest.xml newmanifest.xml [/path/to/goldenrepo]
# manual kernel diff mode:	./difftool -k commit_id_1 commit_id_2
#
# dependencies: git, diffutils, wget
# Description:	This script calculate the difference between two xml manifest
# 				files, then parses its results to git and print out the
# 				git log of all repositories that changed.
### END INFO

[ -e ${SCRIPTS}/000_ENVVariables.sh ] && source ${SCRIPTS}/000_ENVVariables.sh

###
# test case
#
#source $(dirname $0)/testcase.sh

CLEARCASE_UPLOAD_DIR=${CLEARCASE_UPLOAD_DIR-/vobs/wtbu/CSSD_Linux_Releases/4430/Linux_27.x/PDB/DailyBuilds}
PREV_MANIFEST=${PREV_MANIFEST}
CURDIR=$(dirname $0)
LOGDIR=${LOGDIR-$CURDIR}
U_CONFIG_DIR=${U_CONFIG_DIR-$CURDIR}
LOGFILE=${LOGFILE-${LOGDIR}/difftool.log}
PREV_OUT_FILE=$U_CONFIG_DIR/prev_manifest-changes.txt
REPO_OUT_FILE=$U_CONFIG_DIR/repo-changes.txt
OUTFILE=${OUTFILE-${REPO_OUT_FILE}}
MFST_STORE_DIR=${LOGDIR}
ARGS_MIN=2
ARGS_MAX=3
REPODIR=${MYDROID-${BUILD_DIR}/${PROGRAM_NAME}/goldenrepo}
MODE="standalone"
prev_manifest_found="false"	# flag to tell if previous manifest was found
max_tries=5 	# How many tries to fetch previous manifest file

# used tools and their opts
diff=/usr/bin/diff
diff_opts="-E -b -w -B"
git_opts=${git_opts-"--no-pager"}
git_log_opts=${git_log_opts-"--pretty=format:'%h#%s#%cd#%cn#'"}
wget_opts="--tries=2 -nd"

# tool options
OUT_DEVICE=${OUT_DEVICE-file}

usage () {
	echo "usage: `basename $0` old_manifest.xml new_manifest.xml [path/to/repository]"
}

log () {
	if [ "${OUT_DEVICE}" = "file" ]; then
		echo "`date +%b\ %d\ %T` `basename $0`: $1" 1>>$LOGFILE
	fi
	echo "`date +%b\ %d\ %T` `basename $0`: $1"
}

checkdeps () {
	if [ ! -x $diff ]; then
		log "error: diffutils not found in ${diff}. please check"
		exit 0
	fi
}

checkargs () {

	if [ $# -lt $ARGS_MIN ] || [ $# -gt $ARGS_MAX ]; then
		usage
		exit 0
	fi

	if [ ! -e $1 ] || [ ! -e $2 ]; then
		log "error: manifest file not found"
		exit 0
	fi

	if [ ! -z $3 ]; then
		if [ ! -d $3 ]; then
			log "repo directory $3 not found, please check"
			exit 0
		fi
		REPODIR=$3
	else
		if [ ! -d $REPODIR ]; then
			log "default repo dir $REPODIR not found, give me the correct path as third argument"
			exit 0
		fi
	fi
}

get_current_manifest () {
    cur_download_location="http://omapssp.dal.design.ti.com/$(echo ${CLEARCASE_UPLOAD_DIR}|sed -e 's#/vobs/wtbu/#VOBS/#')/L${RELANDDATE}"
    cur_manifest="L${RELANDDATE}_manifest.xml"

    # try to locate current manifest file
	#
	#we changed the method, now we will try to fetch the cur manifest file locally
    #wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${cur_manifest} ${cur_download_location}/configuration/${cur_manifest}
    if [ ! -e ${U_CONFIG_DIR}/${cur_manifest} ]; then
        log "Current Daily Build manifest file ${cur_manifest} not found. Skipped"
        log "It was trying to fetch from: ${U_CONFIG_DIR}/${cur_manifest}"
        exit 0
    fi
	cp ${U_CONFIG_DIR}/${cur_manifest} ${MFST_STORE_DIR}/${cur_manifest}
    log "Current Daily Build manifest file ${cur_manifest} found and copied"
}

get_current_kernel_commit_id () {
	kernel_id_found=true
	if [ ! -e ${U_CONFIG_DIR}/kernel_commit_id ]; then
		kernel_id_found=false
		log "Current kernel_commit_id file ${U_CONFIG_DIR}/kernel_commit_id not found, will skip kernel log diff fetching"
	else
		cp ${U_CONFIG_DIR}/kernel_commit_id ${MFST_STORE_DIR}/cur_kernel_commit_id
	fi
}

search_previous_manifest () {

	cur_build=`echo ${RELANDDATE} |grep -o -E [0-9]+$`
	prev_build=$(($cur_build -1))
	db_index_file="index.html"

	wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${db_index_file} http://omapssp.dal.design.ti.com/$(echo ${CLEARCASE_UPLOAD_DIR}|sed -e 's#/vobs/wtbu/#VOBS/#')
	index_content=`cat ${MFST_STORE_DIR}/${db_index_file}`
	if [ -z "$index_content" ]; then
		log "I could not get index file for the manifest container URL because is missing or is invalid, see log file for details."
		prev_manifest_found="false"
		return
	fi

	#lets try to find out the previous build manifest
	for ((x=0; x < max_tries; x++)); do
		if [ ${prev_build} -eq 0 ]; then
			log "\$RELANDDATE reached value of zero so I can't continue looking back. Will try PREV_MANIFEST instead."
			break
		fi

		res=`grep -oiE \"L${REL}[\-\._a-zA-Z0-9]*${RELEASE_BRANCH}[\-\._a-zA-Z0-9]*[^0-9]${prev_build}[^0-9]\" ${MFST_STORE_DIR}/${db_index_file}`
		res=`echo $res|sed 's/\"//g'|sed 's/\/$//'`
		previous_manifest="${res}_manifest.xml"
		prev_download_location="http://omapssp.dal.design.ti.com/$(echo ${CLEARCASE_UPLOAD_DIR}|sed -e 's#/vobs/wtbu/#VOBS/#')/${res}"

		wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${previous_manifest} ${prev_download_location}/configuration/${previous_manifest}

		if [ $? -ne 0 ]; then
			#oops! not found, decrement DailyBuild by one and try again
			rm -f ${MFST_STORE_DIR}/${previous_manifest}
			prev_build=$(($prev_build - 1))
			log "Previous manifest ${previous_manifest} not found"
		else
			# ahaa! here you are
			prev_manifest_found="true"
			log "previous manifest ${previous_manifest} found!"
			break
		fi
	done

	if [ "${prev_manifest_found}" = "false" ]; then
		log "Couldn't get previous manifest in ${max_tries} tries"
	fi
	#clean up DB index file
	rm -f ${MFST_STORE_DIR}/${db_index_file}
}

get_kernel_diffs () {
	# once we obtained repo diffs then we fetch kernel patch diffs
	if [ "${OUT_DEVICE}" = "stdout" ]; then
		(cd ${YOUR_PATH}/${KERNEL_DIR}; git ${git_opts} log ${git_log_opts} ${PREV_KERNEL_ID}..${CUR_KERNEL_ID}) 2>&1
	else
    		echo "********** KERNEL DIFFS **************" >>$OUTFILE
    		echo "cur_kernel_commit_id is ${CUR_KERNEL_ID}" >>$OUTFILE
	    	echo "prev_kernel_commit_id is ${PREV_KERNEL_ID}" >>$OUTFILE
		(cd ${YOUR_PATH}/${KERNEL_DIR}; git ${git_opts} log ${git_log_opts} ${PREV_KERNEL_ID}..${CUR_KERNEL_ID}) 2>&1 >>$OUTFILE
	fi

	if [ $? -ne 0 ];then
		log "Warning: there was a problem getting kernel diffs, please check the difftool.log for details"
	else
		log "Fetched kernel log diffs and appended to the file $OUTFILE"
	fi
}

get_repo_diff () {
# Extract only the differential tags
# eliminate white spaces at the begining
# and substitute the middle whitespaces (separators) with ":"

diff_tags=`$diff $diff_opts $OLD_MFST $NEW_MFST |sed -n '/<project.*>/p' |sed 's/[\r\n]/\n/g' |sed 's/^<\s*</<change=\"out\" /g' |sed 's/^>\s*</<change=\"in\" /g' |sed 's/^\s*//g' |sed 's/\s/^/g'`

if [ -e ${OUTFILE} ] && [ "${OUT_DEVICE}" = "file" ]; then
	cat /dev/null > ${OUTFILE}
fi

for tag in $diff_tags
do
	fields=`echo $tag |sed 's/<//' |sed 's/\/>//g' |sed 's/\"//g' | awk -F^ '{ print $1, $2, $3, $4, $5, $6}'`
	name=undefined
	path=undefined
	revision=undefined

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
	if [ -z ${path} ] || [ "${path}" = "undefined" ]; then
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

	# better get git log in a subshell
	if [ "${OUT_DEVICE}" = "stdout" ]; then
		echo "Project ${name}" 2>&1
		(cd $REPODIR/$path; git ${git_opts} log ${git_log_opts} ${revision_initial}..${revision_final}) 2>&1
		#just blank line among tree commits (as separator)
	        echo ""
	else
		echo "Project ${name}" >>$OUTFILE
		(cd $REPODIR/$path; git ${git_opts} log ${git_log_opts} ${revision_initial}..${revision_final}) >>$OUTFILE 2>>${LOGFILE}
		#just blank line among tree commits (as separator)
	    echo "" >>$OUTFILE
	fi
	if [ $? -ne 0 ]; then
		log "Warning: there was an error fetching git log for project ${name}!"
	fi
done
}

#################
#		main
#################

checkdeps

OPTIND=1         # Reset in case getopts has been used previously in the shell
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
	get_repo_diff
	exit 0
elif [ "${MODE}" = "kernel_diff" ]; then
	YOUR_PATH="."
	unset KERNEL_DIR
	PREV_KERNEL_ID=$2
	CUR_KERNEL_ID=$3
	get_kernel_diffs
	exit 0
elif [ "${MODE}" = "automatic" ]; then

	get_current_manifest
	get_current_kernel_commit_id

	#############################################################
	# first we try out the PREV_MANIFEST enviroment variable
	##
	if [ ! -z ${PREV_MANIFEST} ]; then
		# try to fetch using PREV_MANIFEST (note that must be an url)
		wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/${PREV_MANIFEST##*/} ${PREV_MANIFEST}

		if [ $? -ne 0 ]; then
			# cleanup current manifest file
			log "PREV_MANIFEST not found in ${PREV_MANIFEST}. Skipping"
		else

			# well we found it in PREV_MANIVEST variable so continue
			previous_manifest=${PREV_MANIFEST##*/}

			#get the download url based on PREV_MANIFEST and get ride of configuration part in order it can be rebuilded properly
			prev_download_location=`echo ${PREV_MANIFEST%/*} |sed 's/\/configuration//'`

			log "PREV_MANIFEST found. Manifest file downloaded from ${PREV_MANIFEST}"

			OUTFILE=${PREV_OUT_FILE}
			NEW_MFST=$MFST_STORE_DIR/${cur_manifest}
			OLD_MFST=$MFST_STORE_DIR/${previous_manifest}
			get_repo_diff
			log "PREV_MANIFEST diffs fetched and saved in ${OUTFILE}"
			log "cleaning up PREV_MANIFEST file downloaded in $MFST_STORE_DIR/${previous_manifest}"

			if [ "${kernel_id_found}" = "true" ]; then
				CUR_KERNEL_ID=`cat ${MFST_STORE_DIR}/cur_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
				# based on PREV_MANIFEST try to fetch previous_kernel_commit_id
				wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/prev_kernel_commit_id $prev_download_location/configuration/kernel_commit_id
				if [ $? -ne 0 ]; then
					log "wget warning: there was an error trying to get previous kernel commit id from $prev_download_location/configuration/kernel_commit_id"
				else
					PREV_KERNEL_ID=`cat ${MFST_STORE_DIR}/prev_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
					# and now get the diff log for the kernel
					get_kernel_diffs
				fi
				# now we have kernel commit id then cleanup file
				rm -f ${MFST_STORE_DIR}/prev_kernel_commit_id
			fi
		fi
	[ -f $MFST_STORE_DIR/${previous_manifest} ] && rm -f $MFST_STORE_DIR/${previous_manifest}
	else
		log "\"PREV_MANIFEST\" is empty so could not fetch previous manifest file. You sholud check environment. Continuing"
	fi


	#################################################################
	# now we try out looking back in time searching for previous manifest
	##
	search_previous_manifest

	if [ "${prev_manifest_found}" = "false" ]; then
		log "previous manifest not found in ${max_tries} tries, skipping"
		log "cleaning up downloaded current manifest $MFST_STORE_DIR/${cur_manifest}"
		rm -f $MFST_STORE_DIR/${cur_manifest}
		exit 0
	fi
	NEW_MFST=$MFST_STORE_DIR/${cur_manifest}
	OLD_MFST=$MFST_STORE_DIR/${previous_manifest}

	# next we grab the previous kernel_commit_id
	wget ${wget_opts} -a ${LOGFILE} -O ${MFST_STORE_DIR}/prev_kernel_commit_id $prev_download_location/configuration/kernel_commit_id
	if [ $? -ne 0 ]; then
		kernel_id_found="false"
		log "wget warning: there was an error trying to get previous kernel commit id from $prev_download_location/configuration/kernel_commit_id"
	else
		log "previous kernel_commit_id found and downloaded from:"
		log "$prev_download_location/configuration/kernel_commit_id"
		PREV_KERNEL_ID=`cat ${MFST_STORE_DIR}/prev_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
	fi

	# now we have kernel commit id then cleanup file
	rm -f ${MFST_STORE_DIR}/prev_kernel_commit_id

	#Now we fetch repo diffs
	OUTFILE=${REPO_OUT_FILE}

	get_repo_diff
	log "repo changes fetched and saved to ${OUTFILE}"

	if [ "${kernel_id_found}" = "true" ]; then
		CUR_KERNEL_ID=`cat ${MFST_STORE_DIR}/cur_kernel_commit_id |grep -o -E '[a-z0-9]{40}'`
    	get_kernel_diffs
	fi

    # cleanup manifest files if executed in automatic mode
    log "cleaning up downloaded manifest files"
    rm -f $OLD_MFST
    rm -f $NEW_MFST


    exit 0
else
	echo "Unkown option selected... Exiting"
	exit 0
fi
