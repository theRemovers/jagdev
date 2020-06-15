#!/bin/bash

if [ -e lib/.install ]
then
    exit 0
fi

rm -rf lib/lib
rm -rf lib/include

mkdir -p lib/lib && ln -s $(find /usr/lib/m68k-atari-mint -name libgcc.a | grep m68000) lib/lib
git clone https://github.com/theRemovers/jlibc && cd jlibc && make install && cd ..
git clone https://github.com/theRemovers/rmvlib && cd rmvlib && make install && cd ..

touch lib/.install
