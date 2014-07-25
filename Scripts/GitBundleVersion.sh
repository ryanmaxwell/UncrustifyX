#!/bin/bash

# This script automatically sets the version and short version string of
# an Xcode project from the Git repository containing the project.
#
# To use this script in Xcode, add the contents to a "Run Script" build
# phase for your application target.

set -o errexit
set -o nounset

VERSION_HASH=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-parse --short HEAD)
VERSION_INTEGER=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-list master | wc -l)

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION_INTEGER" "${PROJECT_DIR}/${INFOPLIST_FILE}"