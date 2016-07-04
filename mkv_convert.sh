#!/bin/bash
#

SOURCE_FILE=$1
MP4_FILE=$2

outformat=mp4

# Check FFMPEG Installation
if ffmpeg -formats > /dev/null 2>&1 
then
  ffversion=`ffmpeg -version 2> /dev/null | grep ffmpeg | sed -n 's/ffmpeg\s//p'`
  echo "Your ffmpeg verson is $ffversion"
else
  echo "ERROR: You need ffmpeg installed with x264 and libfdk_aac encoder"
  exit
fi

if ffmpeg -formats 2> /dev/null | grep "E mp4" > /dev/null
then
  echo "Check mp4 container format ... OK"
else
  echo "Check mp4 container format ... NOK"
  exit
fi

if ffmpeg -formats 2> /dev/null | grep "E matroska" > /dev/null
then
  echo "Check mkv container format ... OK"
else
  echo "Check mkv container format ... NOK"
  exit
fi

if ffmpeg -codecs 2> /dev/null | grep "libfdk_aac" > /dev/null
then
  echo "Check AAC Audio Encoder ... OK"
else
  echo "Check AAC Audio Encoder ... NOK"
  exit
fi

if ffmpeg -codecs 2> /dev/null | grep "libx264" > /dev/null
then
  echo "Check x264 the free H.264 Video Encoder ... OK"
else
  echo "Check x264 the free H.264 Video Encoder ... NOK"
  exit
fi


if ffmpeg -i ${SOURCE_FILE} 2>&1 | grep 'Invalid data found'		#check if it's video file
then
  echo "ERROR File ${SOURCE_FILE} is NOT A VIDEO FILE can be converted!"
  exit	   	
fi

if ffmpeg -i ${SOURCE_FILE} 2>&1 | grep Video: | grep h264		#check video codec
then
  vcodec=copy
else
  vcodec=libx264
fi

if ffmpeg -i ${SOURCE_FILE} 2>&1 | grep Video: | grep "High 10"	#10 bit H.264 can't be played by Hardware.
then
  vcodec=libx264
fi

if [ ffmpeg -i ${SOURCE_FILE} 2>&1 | grep Audio: | grep aac ] || [ 	ffmpeg -i ${SOURCE_FILE} 2>&1 | grep Audio: | grep mp3 ]	#check audio codec
then
  acodec=copy
else
  acodec=libfdk_aac
fi

echo "Converting ${SOURCE_FILE}"
echo "Video codec: $vcodec Audio codec: $acodec Container: $outformat" 

# using ffmpeg for real converting
echo "ffmpeg -i ${SOURCE_FILE} -y -f $outformat -acodec $acodec -ab 192k -ac 2 -absf aac_adtstoasc -async 1 -vcodec $vcodec -vsync 0 -profile:v main -level 3.1 -qmax 22 -qmin 20 -x264opts no-cabac:ref=2 -threads 0 ${MP4_FILE}"

ffmpeg -i ${SOURCE_FILE} -y -f $outformat -acodec $acodec -ab 192k -ac 2 -absf aac_adtstoasc -async 1 -vcodec $vcodec -vsync 0 -profile:v main -level 3.1 -qmax 22 -qmin 20 -x264opts no-cabac:ref=2 -threads 0 ${MP4_FILE}

