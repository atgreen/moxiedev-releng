#!/bin/sh

# download-tools-sources.sh
#
# Copyright (c) 2012, 2013, 2014, 2016, 2020  Anthony Green
# 
# The above named program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301, USA.

# A basic script to download the upstream GNU toolchain sources.


RETRY_MAX=10

echo "Downloading binutils sources..."
RETRIES=$RETRY_MAX
DELAY=10
COUNT=1
while [ $COUNT -lt $RETRIES ]; do
  git clone --depth=1 http://sourceware.org/git/binutils-gdb.git
  if [ $? -eq 0 ]; then
      RETRIES=0
      break
  fi
  let COUNT=$COUNT+1
  sleep $DELAY
done

echo "Downloading GCC sources..."
RETRIES=$RETRY_MAX
DELAY=10
COUNT=1
while [ $COUNT -lt $RETRIES ]; do
  #  svn checkout svn://gcc.gnu.org/svn/gcc/trunk gcc
  git clone --depth=1 https://gcc.gnu.org/git/gcc.git
  if [ $? -eq 0 ]; then
      RETRIES=0
      break
  fi
  let COUNT=$COUNT+1
  sleep $DELAY
done

echo "Downloading newlib and libgloss..."
RETRIES=$RETRY_MAX
DELAY=10
COUNT=1
while [ $COUNT -lt $RETRIES ]; do
  cvs -z3 -d:pserver:anoncvs@sourceware.org:/cvs/src co \
      newlib \
      libgloss
  if [ $? -eq 0 ]; then
      RETRIES=0
      break
  fi
  let COUNT=$COUNT+1
  sleep $DELAY
done

cp gcc/config.sub binutils-gdb
cp gcc/config.sub src

git clone -q --depth=1 git://github.com/atgreen/RTEMS.git
(cd RTEMS; ./bootstrap)

git clone -q --depth=1 git://github.com/atgreen/qemu-moxie.git

if ! test -d qemu; then
  ln -s qemu-moxie qemu
fi
