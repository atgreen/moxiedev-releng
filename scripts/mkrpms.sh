#!/bin/sh
set -x

TARGETS="moxiebox moxie-elf moxie-rtems"

# PACKAGES="moxielogic-qemu moxielogic-moxie-elf-binutils bootstrap-moxie-elf-gcc moxielogic-moxie-elf-newlib moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gdb"

for i in $TARGETS; do
    rpmbuild --rebuild dist/moxielogic-$i-binutils*src.rpm;
    rpmbuild --rebuild dist/moxielogic-$i-gdb*src.rpm;
    rpm -hiv /root/rpmbuild/RPMS/x86_64/moxielogic-$i-binutils*.rpm;
done

export PATH=/opt/moxielogic/bin:$PATH

for i in $TARGETS; do
    rpmbuild --rebuild dist/bootstrap-$i-gcc*src.rpm;
    rpm -hiv /root/rpmbuild/RPMS/x86_64/bootstrap-$i-gcc*.rpm;
    rpmbuild --rebuild dist/moxielogic-$i-newlib*src.rpm;
    rpm -hiv /root/rpmbuild/RPMS/noarch/moxielogic-$i-newlib*.rpm;
    rpmbuild --rebuild dist/moxielogic-$i-gcc*src.rpm;
    rpm -e bootstrap-$i-gcc
    rpm -e moxielogic-$i-binutils
    rpm -e moxielogic-$i-newlib
done

mkdir rpms
find /root/rpmbuild -name \*.rpm | xargs -n 1 -I RPMFILE cp -a RPMFILE rpms
