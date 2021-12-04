function dstruc = Read_HDF5(fname)
% READ_HDF5.m
% Reads an h5 file (HDF5) with datasets on the root "/" group, and returns
% a structure with each one of them.
% Usage:
% dstruc = Read_HDF5(fname)
% Inputs:
% fname  - string with the filename
% Output:
% dstruc - matlab sturcture with all datasets
% Note:
% Fortran and Matlab use column-major order for arrays, so working with
% HDF5 files created in one of these two languages and then read by the
% other will not generate any issues. However, when reading HDF5 files
% created in languages that use row-major order, e.g. C applications or
% Python, array dimension should be permuted. If reading a matrix,
% transposing it should suffice. For higher dimension arrays, permuting the
% dimension in reverse order is needed.
% Example:
% Suppose when importing an array X0 from an HDF5 file generated with
% row-major order, it "comes" with dimensions (n1,n2,n3,n4). 
% Then permute the dimensions with
% ndim = numel(size(dstruc.X0));
% X1   = permute(dstruc.X0,[ndim:-1:1]);
% where shape(X1) = (n4,n3,n2,n1) is the original or inteded array's shape.
% 
% Christian Bustamante
% September 08, 2016

% Obtaining number of datasets
hinfo  = hdf5info(fname);
n      = length(hinfo.GroupHierarchy.Datasets);
vname  = cell(1,n);

% Obtaining dataset names
more here

for i = 1:n
    temp = hinfo.GroupHierarchy.Datasets(i).Name;
    vname{i} = temp(2:end);
    clear temp
end

% Extrating dataset and writing it into a variable with its name
for i = 1:n
    vn   = matlab.lang.makeValidName(vname{i});
    dset = hdf5read(hinfo.GroupHierarchy.Datasets(i)); %#ok<NASGU>
    eval(['dstruc.' vn ' = dset;']);
    clear vn dset
end




