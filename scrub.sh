#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: scrub.sh <pattern>"
  exit 1
fi

PATTERN=$1

# Use the current working directory. You can hardcode this if you want to.
DIR=`pwd`

echo "Searching filenames for $PATTERN"
echo "==============================="
find $DIR -iname "*$PATTERN*"
echo ""

echo "Searching file contents for $PATTERN (includes git)"
echo "==================================================="
FILES=`grep -irlI $PATTERN $DIR`
for f in $FILES; do
  git ls-files --error-unmatch $f &>/dev/null
  IS_GIT_TRACKED=$?
  if [ $IS_GIT_TRACKED -eq 0 ]; then
    grep --with-filename -i $PATTERN $f
  fi
done
echo ""
