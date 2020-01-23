
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'HighMag';
run = 's10e1';

format = '%06i';

% =========================================================================

DS = dataSource;
imDir = [DS.root study filesep run filesep 'Images' filesep];
D = dir([imDir '*.pgm']);
n = numel(D);

for i = 1:n
   
    movefile([imDir 'frame_' num2str(i+3, format) '.pgm'], [imDir 'frame_' num2str(i, format) '.pgm']);
    
end


