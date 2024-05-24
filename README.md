# Dockerized MapReady

## GOAL

Compile [ASF MapReady](https://github.com/asfadmin/asf_mapready) using a modern Docker Base Image

## Docker Base

### [redhat/ubi8:8.10](https://hub.docker.com/r/redhat/ubi8/tags#:~:text=TAG-,8.10,-Last%20pushed%20a)

## Method

Mostly trial and error, googling `gcc` / `make` / `cmake` errors, and a little luck. 

## Specific Dependencies 

I think most of the problems centered around finding versions that worked with `Proj` < 6.0. This is likely the source of most of the build failures reported in [issues](https://github.com/asfadmin/ASF_MapReady/issues/).

### [proj](https://proj.org/) [`v5.2.0`](https://github.com/OSGeo/PROJ/releases/tag/5.2.0)

This was a big one. There is an [implicit dependancy](https://github.com/asfadmin/ASF_MapReady/issues/128) in MapReady to an internal header file in proj. This header was deprecated after version 4, but not removed until version 6. 

### [libgeotiff](https://trac.osgeo.org/geotiff/) [`v1.4.3`](https://github.com/OSGeo/libgeotiff/releases/tag/1.4.3)

I needed version of `libgeotiff` that was old enough to work with the ancient version of `prof`, but new enough that it had all the `cmake` architecture and `pkgconfig` support. Also, it had to be [`libgeotiff` version < 1.5](https://github.com/OSGeo/libgeotiff/commit/3c3351849fa010afafc23df73ed137c2eab0e1d2) when `PJ_CONTEXT` was introduced, causing Issue #[505](https://github.com/asfadmin/ASF_MapReady/issues/505). 

### [gsl](https://www.gnu.org/software/gsl/) `v2.1`

IIRC, nothing special here. This one sort of work out of the box and didn't require tinkering

### [gdal](https://gdal.org/index.html) `v2.1.2`

`gdal` needs to be old enough to be compatible with ancient versions of `proj`. There may have also been some dependencie from MapReady itself that I'm not recalling.

### [shapelib](http://shapelib.maptools.org/) `v1.3.0`

Not much to be said about this. 

### [hdf5](https://portal.hdfgroup.org/documentation/) [`v1.14.3`](https://portal.hdfgroup.org/documentation/hdf5-docs/release_specifics/hdf5_1_14.html)

LOTS of fumbling around here because both MapReady issues [498](https://github.com/asfadmin/ASF_MapReady/issues/498) and [505](https://github.com/asfadmin/ASF_MapReady/issues/505) seem to suggest an incompatible version of hdf5. In the end, the newest version worked just fine.

### [netcdf](https://www.unidata.ucar.edu/software/netcdf/) [`v4.7.4`](https://docs.unidata.ucar.edu/netcdf-c/current/RELEASE_NOTES.html#:~:text=4.7.4%20%2D%20March%2027%2C%202020)

I think there was some problem with newer version, but I don't recall the specifics.

### Build Tools:

* [CCunit](https://cunity.gitlab.io/cunit/) `3.0.2`
* [bison](https://www.gnu.org/software/bison/): `3.0.5`
* [flex](https://github.com/westes/flex): `2.6.1`


## Usage

```
# Pull public image from GitHub Container Registry
docker run -it ghcr.io/asfadmin/mapready:v1.1.1

# Do MapReady Stuff
[root@43b365c2b259 /]# /usr/local/bin/asf_import 

Usage:
   asf_import [-amplitude | -sigma | -gamma | -beta | -power] [-db]
              [-format <inputFormat>] [-ancillary-file <file>]
              [-colormap <colormap_file>] [-band <band_id | all>]
              [-no-ers2-gain-fix] [-image-data-type <type>] [-lut <file>]
              [-lat <lower> <upper>] [-prc] [-log <logFile>]
              [-quiet] [-real-quiet] [-license] [-version] [-multilook]
              [-azimuth-look-count <looks>] [-range-look-count <looks>]
              [-azimuth-scale[=<scale>] | -fix-meta-ypix[=<pixsiz>]]
              [-range-scale[=<scale>] [-complex] [-metadata <file>]
              [-interferogam <file>] [-coherence <file>] [-slave <file>]
              [-baseline <file>] [-cpx_gamma <file>] [-line <start line subset>]
              [-sample <start sample subset>] [-width <subset width>]
              [-height <subset height>] [-uavsar <type>]
              [-subset <latUL> <lonUL> <latLR> <lonLR>] [-help]
              <inBaseName> <outBaseName>
```

## Caveats

### _This code is old, the original repo hasn't seen activity in years._

### _There is lots more clean-up to do_

### _Does it do what its supposed to? Did anything change? 🤷‍♂️_

## Good Luck!
