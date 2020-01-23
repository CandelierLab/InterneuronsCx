
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'LowMag';
run = 'P1';

format = '%06i';

% =========================================================================

DS = dataSource;

ftiff = [DS.data study filesep run filesep run '.tiff'];
fdat = [DS.data study filesep run filesep run '.dat'];

% if exist(fdat, 'file')
%     return
% end

info = imfinfo(ftiff);
n = numel(info);

fid = fopen(fdat, 'a');

for i = 1:n
   
    Img = imread(ftiff, i);
    fwrite(fid, Img, 'uint8');
    
end

fclose(fid);