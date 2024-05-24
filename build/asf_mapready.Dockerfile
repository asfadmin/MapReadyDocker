FROM redhat/ubi8:8.10 as builder

# Redhat environment with ASF MapReady

# Build apps
RUN yum update -y && \
    yum install -y cmake gcc perl \
                   libaio git gcc-c++ sqlite-devel \
                   libtiff-devel libcurl-devel glib2-devel \
                   libjpeg-turbo-devel libpng-devel \
                   automake libtool diffutils \
                   libxml2-devel fftw-devel

# Install MapReady dependencies
ARG proj_ver=5.2.0
RUN echo "installing proj${proj_ver}" && \
    mkdir -p /tmp/build_mp/ && cd /tmp/build_mp/ && \
    curl -L https://github.com/OSGeo/PROJ/releases/download/${proj_ver}/proj-${proj_ver}.tar.gz -O && \
    tar -xvf proj-${proj_ver}.tar.gz && cd proj-${proj_ver} && \
    ./configure && make && make install && \
    ln -s /usr/local/include/*.h /usr/include/

ARG libgeotiff_ver=1.4.3
RUN echo "Building libgeotiff" && \
    cd /tmp/build_mp/ && ` #yum install -y proj${proj_ver}-devel` && \
    curl -L https://github.com/OSGeo/libgeotiff/releases/download/${libgeotiff_ver}/libgeotiff-${libgeotiff_ver}.tar.gz -O  && \
    tar -xvf libgeotiff-${libgeotiff_ver}.tar.gz && \
    mkdir libgeotiff-${libgeotiff_ver}/build && cd libgeotiff-${libgeotiff_ver}/build && \
    export CFLAGS="-I/usr/include -I/usr/include -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" && \
    cmake .. -DCMAKE_PREFIX_PATH=/usr/local/ && cmake --build . && cmake --build . --target install

ARG gsl_ver=2.1
RUN echo "Building lib-gsl" && \
    mkdir -p /tmp/build_mp/gsl && cd /tmp/build_mp/gsl/ && \
    curl https://mirror.us-midwest-1.nexcess.net/gnu/gsl/gsl-${gsl_ver}.tar.gz -O && \
    tar -xvf gsl-${gsl_ver}.tar.gz && cd gsl-${gsl_ver} && \
    ./configure && make && make install

ARG gdal_ver=2.1.2
RUN echo "Building gdal" && \
    mkdir /tmp/build_mp/gdal && cd /tmp/build_mp/gdal && \
    curl https://download.osgeo.org/gdal/${gdal_ver}/gdal-${gdal_ver}.tar.gz -O && \
    tar xvf gdal-${gdal_ver}.tar.gz && \
    cd gdal-${gdal_ver} && \
    ./configure --with-proj=/usr/local && make && make install

ARG shapelib_ver=1.3.0
RUN echo "Building shapelib" && \
    cd /tmp/build_mp/ && \
    curl -L https://download.osgeo.org/shapelib/shapelib-${shapelib_ver}.tar.gz -O && \
    tar -xvf shapelib-${shapelib_ver}.tar.gz && \
    `#mkdir shapelib-${shapelib_ver}/build && cd shapelib-${shapelib_ver}/build` && \
    `#cmake .. && cmake --build . && cmake --build . --target install`  && \
    `#cd ..  && ./configure` && \
    cd shapelib-${shapelib_ver} && make && make install && \
    ln -s /usr/local/include/shapelib /usr/include/ && \
    ln -s /usr/local/include/shapefil.h /usr/include/ && \
    ln -s /usr/local/lib/libshp.a /usr/lib/

# Its not clear to me if there is better way to do this or not. NetCDF install failes without
# running both `make and cmake`.
ARG hdf5_ver=1.14.3
RUN echo "Building hdf5" && \
    cd /tmp/build_mp/ && \
    curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_ver%.*}/hdf5-${hdf5_ver}/src/hdf5-${hdf5_ver}.tar.gz -O && \
    tar -xvf hdf5-${hdf5_ver}.tar.gz && \
    cd hdf5-${hdf5_ver} && ./configure --prefix=/usr/local/hdf5 && \
    make && make install && \
    ln -s /usr/local/hdf5 /usr/include/ && \
    cd /tmp/build_mp/hdf5-${hdf5_ver}/config && \
    cmake .. && cmake --build . && cmake --build . --target install

ARG netcdf_ver=4.7.4
RUN echo "building netcdf" && \
    cd /tmp/build_mp/ && \
    curl -L https://github.com/Unidata/netcdf-c/archive/refs/tags/v${netcdf_ver}.tar.gz -O && \
    tar -xvf v${netcdf_ver}.tar.gz && \
    mkdir netcdf-c-${netcdf_ver}/build && cd netcdf-c-${netcdf_ver}/build && \
    cmake .. -DCMAKE_FIND_ROOT_PATH=/usr/local/hdf5 && \
    cmake --build . && cmake --build . --target install

ARG cunit_ver=3.0.2
RUN echo "Installing CUnit" && \
    cd /tmp/build_mp/ && \
    curl -L https://gitlab.com/cunity/cunit/-/archive/${cunit_ver}/cunit-${cunit_ver}.tar.gz -O && \
    tar -xvf cunit-${cunit_ver}.tar.gz && \
    mkdir cunit-${cunit_ver}/build && cd cunit-${cunit_ver}/build && \
    cmake .. && cmake --build . && cmake --build . --target install && \
    ln -s /usr/local/include/CUnit /usr/include/ && \
    ln -s /usr/local/include/CUnit/*.h /usr/include/

ARG bison_ver=3.0.5
RUN echo "Installing Bison"  && \
    cd /tmp/build_mp/ && \
    yum install -y diffutils && \
    curl -L https://ftp.gnu.org/gnu/bison/bison-${bison_ver}.tar.gz -O && \
    tar -xvf bison-${bison_ver}.tar.gz && \
    cd bison-${bison_ver} && ./configure && make && make install

ARG flex_ver=2.6.1
RUN echo "Installing Flex" && \
    cd /tmp/build_mp/ && \
    curl -L https://github.com/westes/flex/releases/download/v${flex_ver}/flex-${flex_ver}.tar.gz -O && \
    tar -xvf flex-${flex_ver}.tar.gz && cd flex-${flex_ver} && \
    ./configure && make && make install

# Install MapReady     -- CFLAGS += -I/usr/proj72/include
RUN cd /tmp/build_mp && \
    git clone https://github.com/asfadmin/ASF_MapReady.git && \
    cd ASF_MapReady && \
    ln -s /usr/local/include/xtiffio.h /usr/include/ && \
    ln -s /usr/proj*/include/*.h /usr/include/ && \
    ln -s /usr/local/hdf5/lib/libhdf5.* /usr/local/lib/ && \
    ln -s /usr/local/lib64/libnetcdf* /usr/local/lib/ && \
    export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig &&  \
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig/ && \
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/HDF_Group/HDF5/${hdf5_ver}/lib/pkgconfig/ && \
    export CFLAGS="-I/usr/include -I/usr/local/include/CUnit/ -I/usr/local/include/CUnit/ -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/ && \
    ./configure && make && make install && \
    echo "/usr/local/lib/" > /etc/ld.so.conf.d/mapready.conf && ldconfig && \
    rm -rf /tmp/build_mp

FROM scratch
COPY --from=builder / /

ENTRYPOINT /bin/bash
