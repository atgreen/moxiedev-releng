#!/bin/sh
set -x

PACKAGES="moxielogic-qemu moxielogic-moxie-elf-binutils bootstrap-moxie-elf-gcc moxielogic-moxie-elf-newlib moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gdb"

for i in moxie-elf moxie-rtems moxiebox; do
  PACKAGES="$PACKAGES moxielogic-$i-binutils moxielogic-$i-newlib moxielogic-$i-gcc moxielogic-$i-gdb";
done;

PACKAGES="moxielogic-repo-$TAG $PACKAGES"

rpmbuild -ba dist/moxie-elf-binutils-[0-9]*src.rpm;
find ./ -name \*rpm

for i in $PACKAGES; do
  # scrub the yum cache because we probably just placed new content in $REPO 
  rpmbuild -ba dist/$i-[0-9]*src.rpm;
done

