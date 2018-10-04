#!/bin/sh
set -x

(cd binutils-gdb;
date=`sed -n -e 's/^.* BFD_VERSION_DATE \(.*\)$/\1/p' bfd/version.h`;
perl -p -i -e "s/DATE/$date/" gdb/version.in
)

BUILDNUM=`cat BUILDNUM`
DATE=`date +"%a %b %d %Y"`

GCC_VERSION=`cat gcc/gcc/BASE-VER`
GDB_VERSION=`cat binutils-gdb/gdb/version.in | sed -e "s/\-//"`
BINUTILS_VERSION=`cat binutils-gdb/bfd/version.m4 | awk -F "[,() ]" -f scripts/v.awk | tr -d []`
NEWLIB_VERSION=`cat newlib/newlib/configure | awk -F "\"" -f scripts/nv.awk |  sed "s/.$//"` 

if ! test -d dist; then
  mkdir dist
fi
rm -f dist/*.spec
rm -f dist/*.rpm

cp patches/* dist

for i in moxie-elf moxie-rtems moxiebox; do
  cp specs/moxielogic-$i-binutils.spec.in dist/moxielogic-$i-binutils.spec
  sed -i "s/@VERSION@/$BINUTILS_VERSION/g" dist/moxielogic-$i-binutils.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-binutils.spec
  cp specs/moxielogic-$i-gcc.spec.in dist/moxielogic-$i-gcc.spec
  sed -i "s/@VERSION@/$GCC_VERSION/g" dist/moxielogic-$i-gcc.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-gcc.spec
  cp specs/bootstrap-$i-gcc.spec.in dist/bootstrap-$i-gcc.spec
  sed -i "s/@VERSION@/$GCC_VERSION/g" dist/bootstrap-$i-gcc.spec
  sed -i "s/@DATE@/$DATE/g" dist/bootstrap-$i-gcc.spec
  cp specs/moxielogic-$i-newlib.spec.in dist/moxielogic-$i-newlib.spec
  sed -i "s/@VERSION@/$NEWLIB_VERSION/g" dist/moxielogic-$i-newlib.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-newlib.spec
  cp specs/moxielogic-$i-gdb.spec.in dist/moxielogic-$i-gdb.spec
  sed -i "s/@VERSION@/$GDB_VERSION/g" dist/moxielogic-$i-gdb.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-gdb.spec
  
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-binutils.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-gcc.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/bootstrap-$i-gcc.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-newlib.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-gdb.spec
done;

tar \
  --exclude .git \
  --exclude binutils-gdb/gas \
  --exclude binutils-gdb/binutils \
  --exclude binutils-gdb/ld \
  --exclude binutils-gdb/gold \
  --exclude binutils-gdb/gprof \
  -czf dist/moxie-gdb.tar.gz binutils-gdb

(cd gcc; ./contrib/gcc_update --touch)

tar \
  --exclude .svn \
  --exclude libjava \
  --exclude libada \
  --exclude gnattools \
  --exclude zlib \
  --exclude libffi \
  --exclude libmudflap \
  --exclude boehm-gc \
  --exclude libgfortran \
  --exclude ada \
  --exclude libobjc \
  --exclude ppl \
  --exclude cloog-ppl \
  -czf dist/moxie-gcc.tar.gz gcc

tar \
  --exclude .git \
  --exclude binutils-gdb/gdb \
  --exclude binutils-gdb/sim \
  --exclude binutils-gdb/readline \
  --exclude binutils-gdb/libdecnumber \
  --exclude binutils-gdb/gold \
  -czf dist/moxie-binutils.tar.gz binutils-gdb
  
tar \
  --exclude .git \
  -czf dist/moxie-newlib.tar.gz newlib

for i in moxie-elf moxie-rtems moxiebox; do

  rpmbuild \
    --define "_sourcedir dist" \
    --define "_srcrpmdir dist" \
    --define "VERSION $GDB_VERSION" \
    -bs dist/moxielogic-$i-gdb.spec

  rpmbuild --nodeps --define "_source_filedigest_algorithm 0" \
	   --define "_binary_filedigest_algorithm 0" \
	   --define "VERSION $GCC_VERSION" \
	   --define "_sourcedir dist" \
	   --define "_srcrpmdir dist" \
	   -bs dist/moxielogic-$i-gcc.spec

  rpmbuild --nodeps --define "_source_filedigest_algorithm 0" \
	   --define "_binary_filedigest_algorithm 0" \
	   --define "VERSION $GCC_VERSION" \
	   --define "_sourcedir dist" \
	   --define "_srcrpmdir dist" \
	   -bs dist/bootstrap-$i-gcc.spec

  rpmbuild --define "_sourcedir dist" \
	   --define "_srcrpmdir dist" \
	   --define "VERSION $BINUTILS_VERSION" \
	   -bs dist/moxielogic-$i-binutils.spec

  rpmbuild --nodeps --define "_source_filedigest_algorithm 0" \
	   --define "_binary_filedigest_algorithm 0" \
	   --define "_sourcedir dist" \
	   --define "_srcrpmdir dist" \
	   -bs dist/moxielogic-$i-newlib.spec
done;

