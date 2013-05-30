#!/bin/bash
################################################################################
source uefi-common
################################################################################
cd $UEFI_NEXT_GIT

# save current branch so we can return to it after saving the patches
curr_branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`

if [ "$1" == "" ]
then
	PATCH_DIR=$UEFI_SAVE_PATCHES_DIR/$(uefi_next_get_YYYYMM)
else
	PATCH_DIR=$UEFI_SAVE_PATCHES_DIR/$1
fi

BASE_TAG=`git tag --list linaro-base-* | tail -1`
BASE_COMMIT=`git log -1 $BASE_TAG | head -1 | sed 's/commit //'`

topics=(`git branch --list linaro-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	SAVE_DIR=$PATCH_DIR/$topic

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Saving all patches on $topic into $SAVE_DIR"
	git checkout $topic

	echo "Create patches since $BASE_COMMIT..."
	git format-patch $BASE_COMMIT

	echo "Move patches..."
	mkdir -p $SAVE_DIR
	mv *.patch $SAVE_DIR

done

git checkout $curr_branch
