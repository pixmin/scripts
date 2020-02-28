#!/bin/bash

# Version 0.0.5

### Script used to bump a project version using GIT tags
###
### Can use a file to store the version numver, or use GIT tags
###
### Inspired by
### https://gist.github.com/mareksuscak/1f206fbc3bb9d97dec9c

### TODO:
### [ ] Run from outside project and scan subfolders for git projects
### [x] Check if on branch master, warn if not
### [x] Check if YY.MM changed, if so reset last part to zero
### [ ] Read server destination from .gitlab-ci.yml

### COLORS
RED="\033[1;31m"
GREEN="\033[0;32m"
GREY="\033[1;30m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

# Check if we are in a git repository
if ! git ls-files >& /dev/null; then
	echo -e "Must be run from a GIT repository folder"
	exit 0
fi

# Check if we are on master branch
BRANCH_NAME="$(git symbolic-ref HEAD 2>/dev/null)" ||
BRANCH_NAME="(unnamed branch)"     # detached HEAD
BRANCH_NAME=${BRANCH_NAME##refs/heads/}
if [ "$BRANCH_NAME" != "master" ]; then
	echo -e "${RED}Not on master branch!${RESET} Continue?"
	echo -e "${GREY}CTRL + C to stop, anything else to continue.${RESET}"
	read
fi

# Filename containing the version number
FILE=VERSION

# Defaults
CAL_VER=`date "+%y.%m"`

# Check if we have a file
if test -f "$FILE"; then
	
	# Use version from file
	read -r CURRENT_VERSION<$FILE

else

	# Use version from latest annotated git tag
	LATEST_TAG=`git describe --abbrev=0`
	LATEST_TAG=`git tag -l --sort=-version:refname | head -n 1`
	if [[ $LATEST_TAG =~ ^v[0-9]{2}.[0-9]{2}.[0-9]{2}$ ]]; then
		CURRENT_VERSION=$LATEST_TAG
	fi
fi

# Generate a new version number if we could not extract one
if [ "$CURRENT_VERSION" = "" ]; then
	CURRENT_VERSION="${CAL_VER}.00"
fi

# Get last part of CURRENT_VERSION
IFS='.' read -ra ADDR <<< "$CURRENT_VERSION"
BASE_VERSION="${ADDR[0]}.${ADDR[1]}"
MINOR=${ADDR[2]}

# Check if we have the same version base (0Y.0M)
if [ "$BASE_VERSION" = "v$CAL_VER" ]; then
	# Bump minor version
	NEW_MINOR=`printf %02d $((MINOR + 1))`
else
	NEW_MINOR="01"
fi

# Generate new tag version
NEW_VERSION="$CAL_VER.$NEW_MINOR"

echo -e ""
echo -e "Found current version:\t $CURRENT_VERSION"
echo -e "Bumping new version to:\t v$NEW_VERSION"
echo -e ""

TAG="v$NEW_VERSION"
TAG_MESSAGE="Deployed version ${NEW_VERSION}"

echo -e "About to add and push annotated tag '${GREEN}${TAG}${RESET}' with message:"
echo -e ""
echo -e "\t${CYAN}${TAG_MESSAGE}${RESET}"
echo -e ""
echo -e "All good? ${GREY}[ENTER] to continue...${RESET}"

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
	echo -e "${RED}Cancelling... nothing happened.${RESET}"
fi

# Store new version in file
#echo $NEW_VERSION > $FILE
