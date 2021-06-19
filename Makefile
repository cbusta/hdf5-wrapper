# Makefile written to be used with *ifort* in Linux
# Christian Bustamante
# 14 Apr 2020 @ 02:42

# FC = name of the compiler
FC = ifort

# HDF5 paths
HDF5_PATH    = /usr/local/hdf5-1.10.5
HDF5_INCLUDE = $(HDF5_PATH)/include
HDF5_LIB     = $(HDF5_PATH)/lib

# Compiler options
FFLAGS  = -nologo -O3 -xHost -heap-arrays
FFLAGS += -no-prec-div -fp-model fast=2
FFLAGS += -check none 

# Including HDF5
FFLAGS += -I$(HDF5_INCLUDE)

# Debugging flags
DFLAGS  = -debug -g -traceback -warn -check all -check bounds

# List libraries used by the program here (linking)
LIBS  = -L$(HDF5_LIB)
LIBS += -lhdf5_fortran -lhdf5 -lz

# Suffix-rules:  Begin by throwing away all old suffix- 
# rules, and then create new ones for compiling *.f90-files. 
.SUFFIXES: 
.SUFFIXES: .f90 .o

%.o: %.f90
	$(FC) -o $@ -c $(FFLAGS) $<

# Include the dependency-list created by makedepf90 below 
include tree.dep

# Utility targets
.PHONY: clean veryclean deptree

clean:
	rm -f *.o *.mod *.MOD *.i90

veryclean: clean
	rm -f *~
