#!/bin/bash

if [ -e lib/.install ]
then
    exit 0
fi

rm -rf lib/lib
rm -rf lib/include

mkdir -p lib/lib && ln -s $(find /usr/lib/m68k-atari-mint -name libgcc.a | grep m68000) lib/lib
cd jlibc && git fetch && git rebase origin/master && make clean && make install && cd ..
cd rmvlib && git fetch && git rebase origin/master && make clean && make install && cd ..

touch lib/.install
