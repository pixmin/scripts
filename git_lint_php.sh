#!/bin/bash

# This script either checks the PHP syntax of:
# - new or modified files (if any)
# - or, files from the last commit

dirty=`git status --porcelain | egrep "\.php$" | awk {'print $2'}`

if [ -z "$dirty" ]
then
	echo -e "Checking files from latest commit:\n"
	for file in $(git diff --name-status HEAD~1 HEAD | egrep "^[ACMR].*\.php$" | cut -c 3-); do [ -f $file ] && php -l $file; done
else
	echo -e "Checking uncommited files:\n"
	git status -s | grep -o ' \S*php$' | while read f; do php -l $f; done
fi

