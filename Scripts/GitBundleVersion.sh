#!/bin/bash

# This script automatically sets the version and short version string of
# an Xcode project from the Git repository containing the project.
#
# To use this script in Xcode 4, add the contents to a "Run Script" build
# phase for your application target.

set -o errexit
set -o nounset

INFO_PLIST="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Info"

# Use the latest version tag for CFBundleShortVersionString. I tag releases
# in Git using the format v0.0.0; this assumes you're doing the same.
SHORT_VERSION=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" describe --dirty | sed -e 's/^v//' -e 's/g//')

# I'd like to use the Git commit hash for CFBundleVersion.
# VERSION=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-parse --short HEAD)

# But Apple wants this value to be a monotonically increasing integer, so
# instead use the number of commits on the master branch. If you like to
# play fast and loose with your Git history, this may cause you problems.
# Thanks to @amrox for pointing out the issue and fix.
VERSION=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-list master | wc -l)

# defaults write $INFO_PLIST CFBundleShortVersionString $SHORT_VERSION

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "${TARGET_BUILD_DIR}"/"${INFOPLIST_PATH}"
