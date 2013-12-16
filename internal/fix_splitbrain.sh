#!/bin/bash

BRICK=$1
SBFILE=$2
ACTION=$3

if test $# -lt 2
then
   echo "usage: fix_splitbrain.sh brick brick_file"
   exit 1
fi

if test -z $BRICK
then
  echo "You should specify the brick"
  exit 1
fi

if test -z $SBFILE
then
  echo "You should specify the file"
  exit 1
fi

if test -z $ACTION
then
  ACTION=list
fi

if test -e ${BRICK}${SBFILE}
then
  LINKTO=$(getfattr -n trusted.glusterfs.dht.linkto --absolute-names ${BRICK}${SBFILE} 2>/dev/null | grep = | cut -d'x' -f2)
  GFID=$(getfattr -n trusted.gfid --absolute-names -e hex ${BRICK}${SBFILE} | grep 0x | cut -d'x' -f2)
  echo "LINK TO: " $LINKTO
  echo "GFID: "$GFID
  if test $ACTION = "list"
  then
    attr -l ${BRICK}${SBFILE} > /dev/null
    ls -la ${BRICK}${SBFILE}
    ls -la ${BRICK}/.glusterfs/${GFID:0:2}/${GFID:2:2}/${GFID:0:8}-${GFID:8:4}-${GFID:12:4}-${GFID:16:4}-${GFID:20:12}
  else
    if test $ACTION = "fix"
    then
      while true; do
        read -p "Do you wish to delete the brick file and its gfid file?" yn
        case $yn in
          [Yy]* ) rm -rf ${BRICK}${SBFILE}; rm -rf ${BRICK}/.glusterfs/${GFID:0:2}/${GFID:2:2}/${GFID:0:8}-${GFID:8:4}-${GFID:12:4}-${GFID:16:4}-${GFID:20:12}; echo "You had better stat the file from client to trigger self-heal"; break;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
        esac
      done
    else
      echo "Could not support other actions!"
    fi
  fi
#else
  #echo "${BRICK}${SBFILE} does not exist!"
fi
