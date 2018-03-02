#!/bin/bash

git tag -d $1
# delete remote tag '12345' (eg, GitHub version too)
git push origin :refs/tags/$1
