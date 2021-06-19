<!-- TITLE -->
<h1 align="center">HDF5 Fortran Wrapper</h1>
<p align="center">
    By: Christian Bustamante <br>
    <a href="https://cbustamante.co">https://cbustamante.co/</a><br>
    <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/cbusta/hdf5_wrapper/total">
    <img alt="GitHub" src="https://img.shields.io/github/license/cbusta/hdf5_wrapper">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/cbusta/hdf5_wrapper?color=orange">
    <img alt="Website" src="https://img.shields.io/website?up_color=blue&up_message=here&url=https%3A%2F%2Fcbustamante.co%2F">
    <br>
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/cbusta/hdf5_wrapper?style=social">
    <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/cbusta/hdf5_wrapper?style=social">
    <br>
    <a href="https://twitter.com/intent/follow?screen_name=cdbusta"><img src="https://img.shields.io/twitter/follow/cdbusta?style=social&logo=twitter" alt="follow on Twitter"></a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li><a href="#about">About the package</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#contents">Package contents</a></li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>

## About
This package provides a Fortran wrapper for HDF5 (.h5 files). 
It provides a simpler interface that allows easy writing and reading of h5 files for double precision and integer arrays of up to six dimensions.
On top of the Fortran wrapper, the package provides a Matlab function that simplifies the process of reading entire h5 files. 
As opposed to having to read variable by variables, this function reads all variables and put them in a Matlab structure.

## Requirements
Using this package requires a Fortran compiler and the HDF5 library.
- Fortran compiler: tested and built with `ifort` version 19.0.5.281 for Linux and Windows. It has also been tested in `gfortran`.
- [HDF5](https://www.hdfgroup.org/solutions/hdf5/) libraries: tested and built using HDF5 1.10.5, but it has also been used with other library versions.

## Contents
The following source files are provided with the package:
- `Lib_Rwhdf5.f90`: Fortran wrapper that defines interfaces for reading and writing h5 files.
- `Lib_Kind.f90`: declares double precision and integer types.
- `exampleh5.f90`: example that illustrates the usage of the package. It writes two arrays into `data.h5`.
- `Makefile`: used to build `exampleh5.f90`. It depends on `tree.dep` that specifies the compilation order.
- `Read_HDF5.m`: Matlab function that reads and h5 file.
- `example_readh5.m`: example that illustrates how to use the function `Read_HDF5.m` to read `data.h5`.


## Usage
After having he HDF5 library installed, load the two provided Fortran modules into your program.
```
use lib_kind
use lib_rwhdf5
implicit none
```
The Fortran wrapper provides 4 major subroutines and 1 integer type: 
- Subroutines `hdf5_openf` and `hdf5_closef` are used to open and close an h5 file. This are needed only when writing into an h5 file (not when reading).
- Subroutines `hdf5_read` and `hdf5_write` are used to read and write data into an h5 file. The write subroutine should be used after an h5 file has been created with `hdf5_openf`. The file should be closed after all variables have been writen to it.
- Integer type `hid_t`: needed to "label" an h5 file when opened.

Finaly, note that the `Makefile` specifies and `HDF5_PATH` variable that needs to be adjusted depending on where the `include` and `lib` folders of the HDF5 library has been installed.
