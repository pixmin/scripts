#!/bin/bash

# Check if we are in a git repository
if ! git ls-files >& /dev/null; then
	echo -e "Must be run from a GIT repository folder"
	exit 0
fi

FILE=VERSION
CAL_VER=`date "+%y.%m"`
MINOR="0"

# Use version from file
if test -f "$FILE"; then
	
	read -r CURRENT_VERSION<$FILE

# Use version from latest annotated git tag
else

	LATEST_TAG=`git describe --abbrev=0`
	LATEST_TAG=`git tag -l --sort=-version:refname | head -n 1`
	if [[ $LATEST_TAG =~ ^v[0-9]{2}.[0-9]{2}.[0-9]{2}$ ]]; then
		CURRENT_VERSION=$LATEST_TAG
	fi
fi

# Get last part of CURRENT_VERSION
IFS='.' read -ra ADDR <<< "$CURRENT_VERSION"
for i in "${ADDR[@]}"; do
	MINOR=$i
done

# Bump minor version
NEW_MINOR=`printf %02d $((MINOR + 1))`

# Generate new tag version
NEW_VERSION="$CAL_VER.$NEW_MINOR"

echo "Bumping version to: $NEW_VERSION"

TAG="v$NEW_VERSION"
TAG_MESSAGE="Deployed version ${NEW_VERSION}"

echo -e "About to add and push tag '${TAG}' with message:"
echo -e ""
echo -e "\t${TAG_MESSAGE}"
echo -e ""
echo -e "All good?"
read RESPONSE
if [ "$RESPONSE" = "" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "Y" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "Yes" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "yes" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "YES" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "y" ]; then
	
	git tag -a -m "${TAG_MESSAGE}" "${TAG}"
	git push origin --tags

else
	echo -e "Cancelling... tag has NOT been pushed."
fi

# Store new version in file
#echo $NEW_VERSION > $FILE

