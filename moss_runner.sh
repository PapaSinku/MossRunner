#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
	exit
fi

rm -rf */

ZIPFOLDER_NAME="BashFolder.zip"
FILES_NAME="files"
ROOT_FOLDER="$PWD"
NOTEBOOK_SUFFIX=".ipynb"
PATH_SUFFIX="/"
PYTHON_SUFFIX=".py"

for i in `seq $#`
do
	unzip ${!i}
done

mkdir $FILES_NAME

# Remove all spaces in folder
remove_spaces () {
	find -name "* *" -print0 | sort -rz | \
		while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done
}

remove_spaces

for d in */ ; do
	echo "$d"
	cd "$ROOT_FOLDER/$d"
	archivename=""
	if [[ `find . -name "*.zip"` ]]
	then
		unzip -o *.zip
		archivename="$(basename *.zip .zip)"
	else
    	unar *.rar
		archivename="$(basename *.rar .rar)"
	fi
	remove_spaces
	if [[ `find . -name "*.ipynb"` ]]
	then
		cd "$ROOT_FOLDER/$FILES_NAME"
		mkdir "$d"
		cd "$ROOT_FOLDER/$d"
	else
		echo "ignoring $d"
		continue
	fi
	find . -name "*.ipynb" |  while IFS= read -r filename; do 
    	jupyter-nbconvert $filename --to python
		foo=${filename%"$NOTEBOOK_SUFFIX"}
		foo="$foo$PYTHON_SUFFIX"
		cp $foo "$ROOT_FOLDER/$FILES_NAME/$d/"
	done
	
	cd "$ROOT_FOLDER/$FILES_NAME/$d/"
	archivename="$archivename$PYTHON_SUFFIX"
	cat *.py > "../$archivename"
	cd "$ROOT_FOLDER"
done

echo "===================================="
echo "sending to moss..."
cd "$ROOT_FOLDER"
./moss ./files/*.py
echo "===============Done================="