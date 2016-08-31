#!/bin/sh
set -x

#TARGETS=moxie-elf moxie-rtems moxiebox
TARGETS=moxie-elf

# PACKAGES="moxielogic-qemu moxielogic-moxie-elf-binutils bootstrap-moxie-elf-gcc moxielogic-moxie-elf-newlib moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gdb"

for i in $TARGETS; do
    rpmbuild --rebuild dist/moxielogic-$i-binutils*src.rpm;
#    rpmbuild --rebuild dist/moxielogic-$i-gdb*src.rpm;
    rpm -hiv /root/rpmbuild/RPMS/x86_64/moxielogic-$i-binutils\*.rpm;
done

for i in $TARGETS; do
    rpmbuild --rebuild dist/moxielogic-$i-bootstrap-gcc*src.rpm;
    rpm -hiv /root/rpmbuild/RPMS/x86_64/moxielogic-$i-bootstrap-gcc\*.rpm;
done

mkdir rpms
find /root/rpmbuild -name \*.rpm | xargs -n 1 -I RPMFILE cp -a RPMFILE rpms
