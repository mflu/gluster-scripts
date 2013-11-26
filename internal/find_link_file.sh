#!/bin/bash

BRICK=$1
ACTION=$2

if test -z $BRICK
then
   echo "Should provide BRICK dir"
   exit 0
fi

if test -z "$ACTION"
then
   ACTION=list
fi

echo "$ACTION files to be fixed"

for i in `find . -type f -size 0 -perm 0777`
do
  ret=`attr -l $i | grep "glusterfs.dht.linkto"`
  echo $i
  if test "$ACTION" = "fix"
  then
  echo "fixing $i"
  chmod 1000 $i
  fi
  if test "x$ret" != "x";
  then
     GFID=$(getfattr -n trusted.gfid --absolute-names -e hex $i | grep 0x | cut -d'x' -f2)
     GFID_FILE=${BRICK}/.glusterfs/${GFID:0:2}/${GFID:2:2}/${GFID:0:8}-${GFID:8:4}-${GFID:12:4}-${GFID:16:4}-${GFID:20:12}
     echo $GFID_FILE
     if test "$ACTION" = "fix"
     then
     echo "fixing $GFID_FILE"
     chmod 1000 $GFID_FILE
     fi
  fi
done
