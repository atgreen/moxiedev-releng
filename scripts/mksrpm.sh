#!/bin/sh
set -x
BUILDNUM=`cat BUILDNUM`
BUILDNUM=`expr $BUILDNUM + 1`
echo $BUILDNUM > BUILDNUM
DATE=`date +"%a %b %d %Y"`
GCC_VERSION=`cat gcc/gcc/BASE-VER`
GDB_VERSION=`cat binutils-gdb/gdb/version.in | sed -e "s/\-//"`
BINUTILS_VERSION=`cat binutils-gdb/bfd/version.m4 | awk -F "[,() ]" -f scripts/v.awk | tr -d []`
NEWLIB_VERSION=`cat src/newlib/configure | awk -F "\"" -f scripts/nv.awk` 
QEMU_VERSION=`cat qemu-moxie/VERSION`

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
  cp specs/moxielogic-$i-newlib.spec.in dist/moxielogic-$i-newlib.spec
  sed -i "s/@VERSION@/$NEWLIB_VERSION/g" dist/moxielogic-$i-newlib.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-newlib.spec
  cp specs/moxielogic-$i-gdb.spec.in dist/moxielogic-$i-gdb.spec
  sed -i "s/@VERSION@/$GDB_VERSION/g" dist/moxielogic-$i-gdb.spec
  sed -i "s/@DATE@/$DATE/g" dist/moxielogic-$i-gdb.spec
  
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-binutils.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-gcc.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-$i-newlib.spec
  sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-moxie-elf-gdb.spec
done;

cp specs/moxielogic-rtems4.11.spec.in dist/moxielogic-rtems4.11.spec
sed -i "s/@VERSION@/4.11/g" dist/moxielogic-rtems4.11.spec
sed -i "s/@DATE@/$DATE/g" dist/moxielogic-rtems4.11.spec
sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-rtems4.11.spec

cp specs/moxielogic-qemu.spec.in dist/moxielogic-qemu.spec
sed -i "s/@VERSION@/$QEMU_VERSION/g" dist/moxielogic-qemu.spec
sed -i "s/@DATE@/$DATE/g" dist/moxielogic-qemu.spec
sed -i "s/@BUILDNUM@/$BUILDNUM/g" dist/moxielogic-qemu.spec


(cd qemu; make clean > /dev/null 2>&1)
tar --exclude .git -czf dist/moxielogic-qemu.tar.gz qemu-moxie

rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" --define "VERSION $QEMU_VERSION" --define "_sourcedir dist" --define "_srcrpmdir dist" -bs dist/moxielogic-qemu.spec

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
--exclude fortran \
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
--exclude CVS \
-czf dist/moxie-newlib.tar.gz src

for i in moxie-elf moxie-rtems moxiebox; do

rpmbuild \
--define "_sourcedir dist" \
--define "_srcrpmdir dist" \
--define "VERSION $GDB_VERSION" \
-bs dist/moxielogic-$i-gdb.spec

rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" --define "VERSION $GCC_VERSION" --define "_sourcedir dist" --define "_srcrpmdir dist" -bs dist/moxielogic-$i-gcc.spec

rpmbuild \
--define "_sourcedir dist" \
--define "_srcrpmdir dist" \
--define "VERSION $BINUTILS_VERSION" \
-bs dist/moxielogic-$i-binutils.spec

rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" \
--define "_sourcedir dist" \
--define "_srcrpmdir dist" \
-bs dist/moxielogic-$i-newlib.spec

done;

cp dist/moxielogic-moxie-elf-gcc.spec dist/bootstrap-moxie-elf-gcc.spec
perl -p -i -e 's/moxielogic-moxie-elf-gcc/bootstrap-moxie-elf-gcc/g' dist/bootstrap-moxie-elf-gcc.spec
perl -p -i -e 's/with_newlib 1/with_newlib 0/g' dist/bootstrap-moxie-elf-gcc.spec
rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" --define "VERSION $GCC_VERSION" --define "_sourcedir dist" --define "_srcrpmdir dist" -bs dist/bootstrap-moxie-elf-gcc.spec

tar \
--exclude .git \
-czf dist/rtems.tar.gz RTEMS

rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" \
--define "_sourcedir dist" \
--define "_srcrpmdir dist" \
-bs dist/moxielogic-rtems4.11.spec

cp scripts/RPM-GPG-KEY-MoxieLogic dist
for TAG in f20 f21 el6 el7; do
    EXPR=s/TAG/$TAG/g
    cp scripts/Moxie_Logic.repo.in dist/Moxie_Logic.repo
    cp specs/moxielogic-repo.spec.in dist/moxielogic-repo-$TAG.spec
    perl -p -i -e "$EXPR" dist/Moxie_Logic.repo
    perl -p -i -e "$EXPR" dist/moxielogic-repo-$TAG.spec
    rpmbuild --nodeps --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0" --define "_sourcedir dist" --define "_srcrpmdir dist" -bs dist/moxielogic-repo-$TAG.spec
done
