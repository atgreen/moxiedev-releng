FROM centos

MAINTAINER green@moxielogic.org

RUN yum -y install \
    gcc gcc-c++ rpmbuild make patch autoconf automake mpfr-devel \
    libgmp-devel mpc-devel flex bison rpm-build zlib-devel \
    python-devel texinfo ncurses-devel createrepo

CMD cd /opt && ./scripts/mksrpm.sh && ./scripts/mkrpms.sh





