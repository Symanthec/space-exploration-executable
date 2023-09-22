#!/bin/bash


LOVE_URL="https://github.com/love2d/love/releases/download/11.4/"


# Right now Love is either AppImage or ZIP. Depending on this, we either unzip or chmod +x
EXECUTABLE=false


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Detected GNU/Linux system."
	LOVE_URL+="love-11.4-x86_64.AppImage"
	EXECUTABLE=true
	OUTPUT="love-linux.AppImage"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Detected Darwin system"
	LOVE_URL+="love-11.4-macos.zip"
	OUTPUT="love-macos.zip"
elif [[ "$OSTYPE" == "cygwin" ]]; then
	echo "Detected Windows with Cygwin"
	LOVE_URL+="love-11.4-win64.zip"
	OUTPUT="love-windows.zip"
elif [[ "$OSTYPE" == "msys" ]]; then
	echo "Detected Windows with MSYS"
	LOVE_URL+="love-11.4-win64.zip"
	OUTPUT="love-windows.zip"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
	echo "Detected FreeBSD system"
	LOVE_URL+="love-11.4-x86_64.AppImage"
	EXECUTABLE=true
	OUTPUT="love-linux.AppImage"
else
	echo "Unknown operating system! Make sure your $OSTYPE is one of: linux-gnu*, darwin*, cygwin, msys, win32, freebsd*"
fi


if [ ! -f $OUTPUT ] ; then
	echo "Files already downloaded. Aborting..."
	exit
fi

echo "Download from $LOVE_URL"
curl -L $LOVE_URL --output $OUTPUT
if [ "$EXECUTABLE" = true ] ; then
	chmod +x $OUTPUT
else
	echo "Unzipping $OUTPUT"
	unzip $OUTPUT
	rm $OUTPUT
fi
