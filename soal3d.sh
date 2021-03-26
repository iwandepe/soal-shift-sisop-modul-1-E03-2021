#!/bin/bash

pass=$(date +"%m%d%Y")

for folder in K*_*
do zip -q -r -P $pass Koleksi.zip $folder
rm -r $folder
done
