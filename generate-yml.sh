#!/bin/sh

DATADIR_KEY="\$DATADIR"
DATADIR_VALUE=$1

DNS_KEY="\$DNS"
DNS_VALUE=$2

IMAGE_KEY="\$IMAGE"
OUT_VALUE1="insidin/alpine-hadoop"

OUT_VALUE2="insidin/alpine-hadoop-py"
OUT_SUFFIX2=".py"

THEFILE=$3

SUFFIX="mine"

sed -e "s/$DATADIR_KEY/$(echo $DATADIR_VALUE | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" -e "s/$DNS_KEY/$(echo $DNS_VALUE | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $THEFILE > $THEFILE.tmp.$SUFFIX

sed -e "s/$IMAGE_KEY/$(echo $OUT_VALUE1 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $THEFILE.tmp.$SUFFIX > $THEFILE.$SUFFIX

sed -e "s/$IMAGE_KEY/$(echo $OUT_VALUE2 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $THEFILE.tmp.$SUFFIX > $THEFILE$OUT_SUFFIX2.$SUFFIX

rm $THEFILE.tmp.$SUFFIX