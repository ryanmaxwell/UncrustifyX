#!/bin/bash

# This script automatically sets the version and short version string of
# an Xcode project from the Git repository containing the project.
#
# To use this script in Xcode, add the contents to a "Run Script" build
# phase for your application target, after the other phases.

set -o errexit
set -o nounset

VERSION=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-list --count HEAD)

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "${TARGET_BUILD_DIR}"/"${INFOPLIST_PATH}"
