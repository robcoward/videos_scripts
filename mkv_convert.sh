#!/bin/bash
#

VIDEOS_DIR=$1

outformat=mp4

find ${VIDEOS_DIR} -name "*mkv" -size +0 | while read to_convert 
do
  SOURCE_DIR=$(dirname $to_convert)
  SOURCE_FILE=$(basename $to_convert)
  MP4_FILE="$(basename $to_convert mkv)mp4"
  cd ${SOURCE_DIR}
  if [ ! -f ${MP4_FILE} ];
  then

    if ffmpeg -i ${SOURCE_FILE} 2>&1 | grep 'Invalid data found'		#check if it's video file
    then
      echo "ERROR File ${SOURCE_FILE} is NOT A VIDEO FILE can be converted!"
      continue	   	
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

    # Replace the original mkv file with an empty placeholder to prevent it being processed again
    echo -n > ${to_convert}
  else
    echo "WARN: Both ${SOURCE_FILE} and ${MP4_FILE} exist in ${SOURCE_DIR}"
  fi
done
