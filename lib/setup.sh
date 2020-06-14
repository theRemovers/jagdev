#!/bin/sh

M68KTOOLS=/usr/lib/m68k-atari-mint

LIBGCC=`find "$M68KTOOLS" -name libgcc.a | grep m68000`

if [ $? ]
then
  mkdir -p lib
  cp "$LIBGCC" "lib/libgcc.a"
else
  echo "Cannot find libgcc"  
  exit 1
fi

