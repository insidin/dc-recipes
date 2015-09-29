#!/bin/sh

DATADIR_KEY="\$DATADIR"
DATADIR_VALUE=$1

DNS_KEY="\$DNS"
DNS_VALUE=$2

THEFILE=$3

SUFFIX="mine"

exec sed -e "s/$DATADIR_KEY/$(echo $DATADIR_VALUE | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" -e "s/$DNS_KEY/$(echo $DNS_VALUE | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $THEFILE > $THEFILE.$SUFFIX

