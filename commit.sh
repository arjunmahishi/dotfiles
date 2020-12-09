#!/bin/sh

git add .
git commit -m "`hostname`: `date|awk '{print $NF"-"$2"-"$3,$4}'`"
git push origin master
