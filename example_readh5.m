% Example showing how to read data from an HDF5 file
% This reads the data from data.h5 generated after executing the fortran
% sample program exampleh5.f90
% By: Christian Bustamante
% Email: mail@cbustamante.co
% Last modified: 18 June 2021, 01:25

Out = Read_HDF5('data.h5');

% Displaying arrays stored in data.h5
Out
Out.x
Out.y
