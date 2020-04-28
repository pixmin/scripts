#!/bin/bash

# Version 0.0.7

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
### [x] Read server destination from .gitlab-ci.yml

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

# Check if we have a .gitlab-ci.yml file
SERVER=""
if test -f ".gitlab-ci.yml"; then
	SERVER=`cat .gitlab-ci.yml | grep deploy-prod -A 100 | grep -m 1 SERVER_GROUP | cut -f 2 -d "'"`
fi

# Defaults
CAL_VER=`date "+%y.%m"`

# Use version from latest annotated git tag
LATEST_TAG=`git describe --abbrev=0 2>/dev/null`
LATEST_TAG=`git tag -l --sort=-version:refname | head -n 1`
if [[ $LATEST_TAG =~ ^v[0-9]{2}.[0-9]{2}.[0-9]{2}$ ]]; then
	CURRENT_VERSION=$LATEST_TAG
fi

# Show commits since last tag => HEAD
COMMITS_COUNT=`git --no-pager log --oneline --no-merges $LATEST_TAG..HEAD | wc -l | tr -d ' '`
echo -e "$COMMITS_COUNT Commits since last tag ${CYAN}$CURRENT_VERSION${RESET}:"
echo -e ""
git --no-pager log --oneline --no-merges $LATEST_TAG..HEAD
echo -e ""

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
	NEW_MINOR=`printf %02d $((10#$MINOR + 1))`
else
	NEW_MINOR="01"
fi

# Generate new tag version
NEW_VERSION="$CAL_VER.$NEW_MINOR"

TAG="v$NEW_VERSION"
TAG_MESSAGE="deployed version ${NEW_VERSION}"
if [ "$SERVER" != "" ]; then
	TAG_MESSAGE="Auto ${TAG_MESSAGE} to [${SERVER}]"
else
	TAG_MESSAGE="Manually ${TAG_MESSAGE}"
fi

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
