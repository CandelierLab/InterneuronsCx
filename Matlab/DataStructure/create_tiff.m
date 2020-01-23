
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'Noco75P23';

% =========================================================================

DS = dataSource;
D = dir([DS.data study filesep]);
D(1:2) = [];

for i = 1:numel(D)
    
    [~, run] = fileparts(D(i).name);

    fTiff = [DS.data study filesep run filesep run '.tiff'];
    
    if exist(fTiff, 'file'), continue; end
    
    fprintf('Processing %s ...', run);
    tic
    
    imDir = [DS.data study filesep run filesep 'Images' filesep];
    
    d = dir([imDir '*.pgm']);
    for j = 1:numel(d)
    
        Img = imread([imDir d(j).name]);
        
        if j==1
            imwrite(Img, fTiff);
        else
            imwrite(Img, fTiff, 'WriteMode', 'append');
        end
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end
