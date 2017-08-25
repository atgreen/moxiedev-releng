#!/bin/sh

alien -g -k -d moxielogic-moxie-elf-gcc-fsf-man-pages*rpm
perl -p -i -e 's/^Depends.*/Depends:/' moxielogic-moxie-elf-gcc*/debian/control
perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-moxie-elf-gcc*/debian/control
(cd moxielogic-moxie-elf-gcc*/debian/..;
 ./debian/rules binary)
rm -rf `find . -type d -name moxielogic-moxie-elf-gcc\*`

for target in moxie-elf moxiebox moxie-rtems; do

  alien -g -k -d moxielogic-${target}-gcc-[0-9]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-${target}-binutils , moxielogic-${target}-gcc-fsf-man-pages/' moxielogic-${target}-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`

  alien -g -k -d moxielogic-${target}-gcc-[c]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-${target}-gcc , moxielogic-${target}-gcc-libstdc++/' moxielogic-${target}-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`
  
  alien -g -k -d moxielogic-${target}-gcc-[l]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-${target}-gcc-c++/' moxielogic-${target}-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`

  for tools in binutils gdb; do
    alien -g -k -d moxielogic-${target}-${tool}-[0-9]*rpm
    perl -p -i -e 's/^Depends.*/Depends:/' moxielogic-${target}-${tool}*/debian/control
    perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-${tool}*/debian/control
    (cd moxielogic-${target}-${tool}*/debian/..;
     ./debian/rules binary)
    rm -rf `find . -type d -name moxielogic-${target}-${tool}\*`;
  done
  
done

