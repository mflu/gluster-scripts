#!/bin/bash

BRICK=$1
WHERE=$2
PERM=$3
ACTION=$4

if test -z $BRICK
then
   echo "Should provide BRICK dir"
   exit 0
fi

if test -z "$PERM"
then
  PERM="1000"
fi

if test -z "$ACTION"
then
   ACTION=list
fi

echo "$ACTION files with (size > 0 and perm is $PERM )in $WHERE to be fixed"

pushd $WHERE
for i in `find . -type f -size +0 -perm ${PERM}`
do
  ret=`attr -l $i | grep "glusterfs.dht.linkto"`
  if test "x$ret" = "x";
  then
     ls -la  $i
     if test "$ACTION" = "fix"
     then
       echo "fixing $i"
       chmod 0644 $i
     fi
     GFID=$(getfattr -n trusted.gfid --absolute-names -e hex $i | grep 0x | cut -d'x' -f2)
     GFID_FILE=${BRICK}/.glusterfs/${GFID:0:2}/${GFID:2:2}/${GFID:0:8}-${GFID:8:4}-${GFID:12:4}-${GFID:16:4}-${GFID:20:12}
     ls -la  $GFID_FILE
     if test "$ACTION" = "fix"
     then
      echo "fixing $GFID_FILE"
      chmod 0644 $GFID_FILE
     fi
  fi
done
popd
