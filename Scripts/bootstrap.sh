#!/bin/sh
# Ensure local dependencies are up to date.

cd $(dirname "$0")/..

# check for mogenerator
if [ ! -f /usr/local/bin/mogenerator ]
then
	installed=`which mogenerator`

	if [ ! -z "$installed" ]
	then
		ln -s $installed /usr/local/bin/mogenerator
	else
		
		if [ ! -f /usr/local/bin/brew ]
		then
    		ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
    	fi
    	brew install mogenerator
	fi
fi

git submodule update --init --recursive