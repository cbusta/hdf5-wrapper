module lib_kind

! Module to declare kind types dor double precision and integer.
! By: Christian Bustamante
! Email: mail@cbustamante.co
! Last modified: 27 Nov, 2019, 17:00
! v 1.20
!
! To compile this module:
! $ ifort -c Lib_Kind.f90
! $ gfortran -c Lib_Kind.f90
! To use it put this just after the -program- statement:
! use lib_kind

implicit none
private
public :: dp, ip
integer,parameter :: dp = selected_real_kind(15, 307)
integer,parameter :: ip = selected_int_kind(9)

end module lib_kind