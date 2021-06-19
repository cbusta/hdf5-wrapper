module lib_rwhdf5
   
! Module to export and import data to and from an HDF5 (h5) file.
! By: Christian Bustamante
! Email: mail@cbustamante.co
! Last modified: 18 June 2021, 01:08
! v 2.01
!
! To compile this module:
! $ ifort -c Lib_Rwhdf5.f90 Lib_Kind.f90 -I$(HDF_HOME)/include -L$(HDF_HOME)/lib hdf5_fortran.lib
! $ gfortran -c Lib_Rwhdf5.f90 Lib_Kind.f90 -I/usr/include/hdf5/serial -L/usr/lib/x86_64-linux-gnu/libhdf5_serial_fortran.a 
! The current HDF5 package for serial implementation in Ubuntu is libhdf5-serial-dev
! Note: may need extra flags when linking to main program
! To use it put this just after the -program- statement:
! use lib_rwhdf5
!
! Note:
! Fortran and Matlab use column-major order for arrays, so working with HDF5 files created in one of these two languages 
! and then read by the the other will not generate any issues. However, when reading HDF5 files created in languages 
! that use row-major order, e.g. C applications or Python, array dimension should be permuted. If reading a matrix, transposing
! it should suffice. For higher dimension arrays, permuting the dimension in reverse order is needed.
! Example:
! Suppose when importing an array X0 from an HDF5 file generated with row-major order, it "comes" with dimensions (n1,n2,n3,n4).
! Then permute the dimensions with
! X1 = reshape(X0, shape(X1), order=(/i=4,1,-1/))
! where shape(X1) = (n4,n3,n2,n1) is the original or inteded array's shape.
!
! Subroutines:
! (Rwhdf5) 01. hdf5_openf       - Initializes and creates an HDF5 file before writing to it
! (Rwhdf5) 02. hdf5_write       - Writes a n-dimensional array (n=0,1,2,3,4,5,6 including scalars) in the specified HDF5 file [Interface]
! (Rwhdf5) 03. hdf5_read        - Reads a n-dimensional array (n=0,1,2,3,4,5,6 including scalars) from the specified HDF5 file [Interface]
! (Rwhdf5) 04. hdfw_data_scl    - Writes a double precission scalar in the specified HDF5 file
! (Rwhdf5) 05. hdfw_data_vec    - Writes a double precission vector in the specified HDF5 file
! (Rwhdf5) 06. hdfw_data_mat    - Writes a double precission matrix in the specified HDF5 file
! (Rwhdf5) 07. hdfw_data_arr3   - Writes a double precission 3-dimensional array in the specified HDF5 file
! (Rwhdf5) 08. hdfw_data_arr4   - Writes a double precission 4-dimensional array in the specified HDF5 file
! (Rwhdf5) 09. hdfw_data_arr5   - Writes a double precission 5-dimensional array in the specified HDF5 file
! (Rwhdf5) 10. hdfw_data_arr6   - Writes a double precission 6-dimensional array in the specified HDF5 file
! (Rwhdf5) 11. hdfw_data_scl_i  - Writes an integer scalar in the specified HDF5 file
! (Rwhdf5) 12. hdfw_data_vec_i  - Writes an integer vector in the specified HDF5 file
! (Rwhdf5) 13. hdfw_data_mat_i  - Writes an integer matrix in the specified HDF5 file
! (Rwhdf5) 14. hdfw_data_arr3_i - Writes an integer 3-dimensional array in the specified HDF5 file
! (Rwhdf5) 15. hdfw_data_arr4_i - Writes an integer 4-dimensional array in the specified HDF5 file
! (Rwhdf5) 16. hdfw_data_arr5_i - Writes an integer 5-dimensional array in the specified HDF5 file
! (Rwhdf5) 17. hdfw_data_arr6_i - Writes an integer 6-dimensional array in the specified HDF5 file
! (Rwhdf5) 18. hdfr_openf       - Initializes and opens an HDF5 file before reading from it
! (Rwhdf5) 19. hdfr_data_scl    - Reads a double precission scalar from the specified HDF5 file
! (Rwhdf5) 20. hdfr_data_vec    - Reads a double precission vector from the specified HDF5 file
! (Rwhdf5) 21. hdfr_data_mat    - Reads a double precission matrix from the specified HDF5 file
! (Rwhdf5) 22. hdfr_data_arr3   - Reads a double precission 3-dimensional array from the specified HDF5 file
! (Rwhdf5) 23. hdfr_data_arr4   - Reads a double precission 4-dimensional array from the specified HDF5 file   
! (Rwhdf5) 24. hdfr_data_arr5   - Reads a double precission 5-dimensional array from the specified HDF5 file   
! (Rwhdf5) 25. hdfr_data_arr6   - Reads a double precission 6-dimensional array from the specified HDF5 file   
! (Rwhdf5) 26. hdfr_data_scl_i  - Reads an integer scalar from the specified HDF5 file
! (Rwhdf5) 27. hdfr_data_vec_i  - Reads an integer vector from the specified HDF5 file
! (Rwhdf5) 28. hdfr_data_mat_i  - Reads an integer matrix from the specified HDF5 file
! (Rwhdf5) 29. hdfr_data_arr3_i - Reads an integer 3-dimensional array from the specified HDF5 file
! (Rwhdf5) 30. hdfr_data_arr4_i - Reads an integer 4-dimensional array from the specified HDF5 file   
! (Rwhdf5) 31. hdfr_data_arr5_i - Reads an integer 5-dimensional array from the specified HDF5 file   
! (Rwhdf5) 32. hdfr_data_arr6_i - Reads an integer 6-dimensional array from the specified HDF5 file   
! (Rwhdf5) 33. hdf5_closef      - Closes an HDF5 file
!
! Note: depends on Lib_Kind and the HDF5 library (include and lib directories needed when linking)
   
use lib_kind
use hdf5
implicit none
private
public :: hdf5_write, hdf5_read, hdf5_openf, hdf5_closef, HID_T

interface hdf5_write
    ! Writes a n-dimensional array (n=0,1,2,3,4,5,6 including scalars) in the specified HDF5 file.
    ! Supports double precission -real(dp)- and integers arrays only. Other variable types
    ! should be converted into dp with the function real(*,dp).
    ! When using this, an HDF5 file should have been already created (an opened). See -hdf5_openf-
    ! After writing that HDF5 file should be closed. See -hdf5_closef-
    ! Usage:
    ! call hdf5_write(wdata,fileid,dsetname)
    ! Inputs:
    ! wdata    - data (n-dimensional array)
    ! fileid   - file id, as provided by -hdf5_openf-
    ! dsetname - dataset name (string)
    module procedure hdfw_data_scl
    module procedure hdfw_data_vec
    module procedure hdfw_data_mat
    module procedure hdfw_data_arr3
    module procedure hdfw_data_arr4
    module procedure hdfw_data_arr5
    module procedure hdfw_data_arr6    
    module procedure hdfw_data_scl_i
    module procedure hdfw_data_vec_i
    module procedure hdfw_data_mat_i
    module procedure hdfw_data_arr3_i
    module procedure hdfw_data_arr4_i
    module procedure hdfw_data_arr5_i
    module procedure hdfw_data_arr6_i
end interface

interface hdf5_read
    ! Reads a n-dimensional array (n=0,1,2,3,4,5,6 including scalars) from the specified HDF5 file.
    ! Supports double precission -real(dp)- and integer arrays only.
    ! Usage:
    ! call hdf5_read(filename,dsetname,rdata)
    ! Inputs:
    ! filename - name for h5 file with .h5 at the end (string)
    ! dsetname - name of the dataset to be read. This is the name of array in the h5 file (string)
    ! rdata    - name of array that will receive read data
    ! Note: note that when reading, you do not need to open and close the h5 file!
    module procedure hdfr_data_scl
    module procedure hdfr_data_vec
    module procedure hdfr_data_mat
    module procedure hdfr_data_arr3
    module procedure hdfr_data_arr4
    module procedure hdfr_data_arr5
    module procedure hdfr_data_arr6
    module procedure hdfr_data_scl_i
    module procedure hdfr_data_vec_i
    module procedure hdfr_data_mat_i
    module procedure hdfr_data_arr3_i
    module procedure hdfr_data_arr4_i
    module procedure hdfr_data_arr5_i
    module procedure hdfr_data_arr6_i  
end interface
   
contains
   
   
    subroutine hdf5_openf(filename,fileid)
        ! Initializes and creates an HDF5 file.
        ! Usage:
        ! call hdf5_openf(filename,fileid)
        ! Inputs:
        ! filename - name for h5 file (string)
        ! Otuput:
        ! fileid   - file id to be passed to all other subroutines in this module
        character(*),intent(in)   :: filename
        integer(HID_T),intent(out):: fileid
        integer                   :: error
        ! Initialize FORTRAN interface
        call h5open_f(error)
        ! Create h5 file
        call h5fcreate_f(filename, h5f_acc_trunc_f, fileid, error)
    end subroutine hdf5_openf
     
   
    subroutine hdfw_data_scl(wdata,fileid,dsetname)
        ! Writes a double precission scalar in the specifie HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_scl
   
   
    subroutine hdfw_data_vec(wdata,fileid,dsetname)
        ! Writes a double precission 1-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_vec
   
   
    subroutine hdfw_data_mat(wdata,fileid,dsetname)
        ! Writes a double precission 2-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:,:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_mat
   
   
    subroutine hdfw_data_arr3(wdata,fileid,dsetname)
        ! Writes a double precission 3-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:,:,:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr3
   
   
    subroutine hdfw_data_arr4(wdata,fileid,dsetname)
        ! Writes a double precission 4-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:,:,:,:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr4
  
  
    subroutine hdfw_data_arr5(wdata,fileid,dsetname)
        ! Writes a double precission 5-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:,:,:,:,:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr5
  
  
    subroutine hdfw_data_arr6(wdata,fileid,dsetname)
        ! Writes a double precission 6-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        real(dp),intent(in)       :: wdata(:,:,:,:,:,:)
        integer(HID_T),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(HID_T)            :: dspaceid, dsetid
        integer(HSIZE_T)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_double, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_double, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr6
    
    
    subroutine hdfw_data_scl_i(wdata,fileid,dsetname)
        ! Writes an integer scalar in the specifie HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)    :: wdata
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_scl_i
   
   
    subroutine hdfw_data_vec_i(wdata,fileid,dsetname)
        ! Writes an integer 1-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)    :: wdata(:)
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_vec_i
   
   
    subroutine hdfw_data_mat_i(wdata,fileid,dsetname)
        ! Writes an integer 2-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)      :: wdata(:,:)
        integer(hid_t),intent(in)   :: fileid
        character(*),intent(in)     :: dsetname
        integer(hid_t)              :: dspaceid, dsetid
        integer(hsize_t)            :: vdims(rank(wdata))
        integer                     :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_mat_i
    

    subroutine hdfw_data_arr3_i(wdata,fileid,dsetname)
        ! Writes an integer 3-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)       :: wdata(:,:,:)
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr3_i
   
   
    subroutine hdfw_data_arr4_i(wdata,fileid,dsetname)
        ! Writes an integer 4-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)    :: wdata(:,:,:,:)
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr4_i
  
  
    subroutine hdfw_data_arr5_i(wdata,fileid,dsetname)
        ! Writes an integer 5-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)    :: wdata(:,:,:,:,:)
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr5_i
  
  
    subroutine hdfw_data_arr6_i(wdata,fileid,dsetname)
        ! Writes an integer 6-dimensional array in the specified HDF5 file.
        ! Belongs to the interface -hdfw_data-. See usage there.
        integer(ip),intent(in)    :: wdata(:,:,:,:,:,:)
        integer(hid_t),intent(in) :: fileid
        character(*),intent(in)   :: dsetname
        integer(hid_t)            :: dspaceid, dsetid
        integer(hsize_t)          :: vdims(rank(wdata))
        integer                   :: error
        ! Dimensions
        vdims = shape(wdata)
        ! Create dataspace
        call h5screate_simple_f(rank(wdata), vdims, dspaceid, error)
        ! Create dataset (double precision)
        call h5dcreate_f(fileid, dsetname, h5t_native_integer, dspaceid, dsetid, error)
        ! Write the data to dataset (double precision)
        call h5dwrite_f(dsetid, h5t_native_integer, wdata, vdims, error)
        ! Close dataset
        call h5dclose_f(dsetid, error)
        ! Close dataspace
        call h5sclose_f(dspaceid, error)
    end subroutine hdfw_data_arr6_i
  
  
    subroutine hdfr_openf(filename,fileid)
        ! Initializes and opens an HDF5 file.
        ! Usage:
        ! call hdfr_openf(filename,fileid)
        ! Inputs:
        ! filename - name for h5 file (string)
        ! fileid   - file id
        character(*),intent(in)   :: filename
        integer(HID_T),intent(out):: fileid
        integer                   :: error
        ! Initialize FORTRAN interface
        call h5open_f(error)
        ! Open an existing file
        call h5fopen_f(filename, h5f_acc_rdwr_f, fileid, error)
    end subroutine hdfr_openf
  
  
    subroutine hdfr_data_scl(filename,dsetname,rdata)
        ! Reads a double precission scalar from the specified HDF5 file. The dataset is
        ! read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_scl
  
  
    subroutine hdfr_data_vec(filename,dsetname,rdata)
        ! Reads a double precission 1-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_vec
  
  
    subroutine hdfr_data_mat(filename,dsetname,rdata)
        ! Reads a double precission 2-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:,:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_mat
  
  
    subroutine hdfr_data_arr3(filename,dsetname,rdata)
        ! Reads a double precission 3-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:,:,:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr3
  
  
    subroutine hdfr_data_arr4(filename,dsetname,rdata)
        ! Reads a double precission 4-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:,:,:,:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr4
  
  
    subroutine hdfr_data_arr5(filename,dsetname,rdata)
        ! Reads a double precission 5-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:,:,:,:,:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr5
    
  
    subroutine hdfr_data_arr6(filename,dsetname,rdata)
        ! Reads a double precission 6-dimensional array from the specified HDF5 file. The
        ! dataset is read as real(dp).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        real(dp),intent(inout)     :: rdata(:,:,:,:,:,:)
        integer(HID_T)             :: fileid
        integer(HSIZE_T)           :: vdims(rank(rdata))
        integer(HID_T)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_double, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr6
    
    
    subroutine hdfr_data_scl_i(filename,dsetname,rdata)
        ! Reads an integer scalar from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_scl_i
  
  
    subroutine hdfr_data_vec_i(filename,dsetname,rdata)
        ! Reads an integer 1-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_vec_i
  
  
    subroutine hdfr_data_mat_i(filename,dsetname,rdata)
        ! Reads an integer 2-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:,:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_mat_i
  
  
    subroutine hdfr_data_arr3_i(filename,dsetname,rdata)
        ! Reads an integer 3-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:,:,:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr3_i
  
  
    subroutine hdfr_data_arr4_i(filename,dsetname,rdata)
        ! Reads an integer 4-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:,:,:,:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr4_i
  
  
    subroutine hdfr_data_arr5_i(filename,dsetname,rdata)
        ! Reads an integer 5-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:,:,:,:,:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr5_i
  
    
    subroutine hdfr_data_arr6_i(filename,dsetname,rdata)
        ! Reads an integer 6-dimensional array from the specified HDF5 file. The
        ! dataset is read as integer(ip).
        ! Belongs to the interface -hdfr_data-. See usage there.
        character(*),intent(in)    :: filename
        character(*),intent(in)    :: dsetname
        integer(ip),intent(inout)  :: rdata(:,:,:,:,:,:)
        integer(hid_t)             :: fileid
        integer(hsize_t)           :: vdims(rank(rdata))
        integer(hid_t)             :: dsetid
        integer                    :: error
        ! Open existing file
        call hdfr_openf(filename,fileid)
        ! Open an existing dataset
        call h5dopen_f(fileid, dsetname, dsetid, error)
        ! Read the dataset
        vdims = rank(rdata)
        call h5dread_f(dsetid, h5t_native_integer, rdata, vdims, error)
        ! Close the dataset
        call h5dclose_f(dsetid, error)
        ! Close file
        call hdf5_closef(fileid)
    end subroutine hdfr_data_arr6_i

  
    subroutine hdf5_closef(fileid)
        ! Closes an HDF5 file.
        ! Usage:
        ! call hdf5_closef(filename,fileid)
        ! Inputs:
        ! fileid   - file id, as provided by -hdfw_openf- or -hdfr_openf-
        integer(HID_T),intent(in) :: fileid
        integer                   :: error
        call h5fclose_f(fileid, error)
        call h5close_f(error)
    end subroutine hdf5_closef

   
end module lib_rwhdf5
