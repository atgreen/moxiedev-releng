#!/bin/sh
set -x
# For this to work, the mock config file for $TARGET must point to the 
# local yum repo at $REPO.

CPU=x86_64

for TAG in el7; do

case $TAG in #(
  el7) TARGET=epel-7-$CPU;;
esac
  
RESULTDIR=/var/lib/mock/$TARGET/result
REPO=dist/MoxieLogic/$TAG

mkdir -p $REPO/RPMS/$CPU/debuginfo
mkdir -p $REPO/RPMS/noarch
mkdir -p $REPO/SRPMS
createrepo $REPO

PACKAGES="moxielogic-qemu moxielogic-moxie-elf-binutils bootstrap-moxie-elf-gcc moxielogic-moxie-elf-newlib moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gdb"

for i in moxie-rtems moxiebox; do
  PACKAGES="$PACKAGES moxielogic-$i-binutils moxielogic-$i-newlib moxielogic-$i-gcc moxielogic-$i-gdb";
done;

PACKAGES="moxielogic-repo-$TAG $PACKAGES"

for i in $PACKAGES; do
  mock -r $TARGET dist/$i-[0-9]*src.rpm;
  cp $RESULTDIR/root.log $REPO/$i-root.log;
  cp $RESULTDIR/build.log $REPO/$i-build.log;
  FILE=`ls $RESULTDIR/$i-*.rpm | head -1`
  if test x$FILE != "x"; then
    rm $REPO/RPMS/noarch/$i-[0-9]*.rpm
    mv $RESULTDIR/$i-*src.rpm  $REPO/SRPMS;
    case `ls $RESULTDIR/$i-*.rpm` in
    *noarch*)
      rm $REPO/RPMS/noarch/$i-[0-9]*.rpm
      mv $RESULTDIR/$i-*.rpm $REPO/RPMS/noarch;
      ;;
    *)
      rm $REPO/RPMS/$CPU/debuginfo/$i-debuginfo*.rpm
      rm $REPO/RPMS/$CPU/$i-[0-9]*.rpm
      mv $RESULTDIR/$i-debuginfo*.rpm $REPO/RPMS/$CPU/debuginfo;
      mv $RESULTDIR/$i-*.rpm $REPO/RPMS/$CPU;
      ;;
    esac
    createrepo $REPO;
  fi;
done

done
