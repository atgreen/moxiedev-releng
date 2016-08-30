FROM centos

MAINTAINER green@moxielogic.org

RUN yum -y install gcc gcc-c++ rpmbuild make patch autoconf automake mpfr-devel libgmp-devel mpc-devel flex bison

CMD pwd && ls -l /opt


