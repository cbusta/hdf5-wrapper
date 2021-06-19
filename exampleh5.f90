program exampleh5
! Example that shows how to write and read data from an HDF5 file.
! If reading this data in Matlab, the function Read_HDF5.m may be useful.
! By: Christian Bustamante
! Email: mail@cbustamante.co
! Last modified: 18 June 2021, 01:20

    use lib_kind
    use lib_rwhdf5
    implicit none

    real(dp)       :: xw(2,3), yw(4,3,2)
    real(dp)       :: xr(2,3), yr(4,3,2)
    integer(hid_t) :: fileid

    ! Generating random data to be stored
    call random_number(xw)
    call random_number(yw)

    ! Exporting arrays
    ! Create a new file using the default properties
    call hdf5_openf('data.h5',fileid)
    ! Writing datasets to h5 file
    call hdf5_write(xw, fileid,'x')
    call hdf5_write(yw, fileid,'y')
    ! Close file
    call hdf5_closef(fileid)

    ! Importing data
    call hdf5_read('data.h5','x', xr)
    call hdf5_read('data.h5','y', yr)


end program exampleh5