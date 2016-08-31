#!/bin/sh
set -x

# PACKAGES="moxielogic-qemu moxielogic-moxie-elf-binutils bootstrap-moxie-elf-gcc moxielogic-moxie-elf-newlib moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gdb"
PACKAGES="moxielogic-moxie-elf-binutils moxielogic-moxie-elf-gdb"

# for i in moxie-elf moxie-rtems moxiebox; do
for i in moxie-elf; do
    #  PACKAGES="$PACKAGES moxielogic-$i-binutils moxielogic-$i-newlib moxielogic-$i-gcc moxielogic-$i-gdb";
  PACKAGES="$PACKAGES moxielogic-$i-binutils moxielogic-$i-gdb";    
done;

PACKAGES="moxielogic-repo-$TAG $PACKAGES"

for i in $PACKAGES; do
  # scrub the yum cache because we probably just placed new content in $REPO 
  rpmbuild --rebuild dist/$i-*src.rpm;
done
