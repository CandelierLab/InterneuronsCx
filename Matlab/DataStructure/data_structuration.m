
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'Piliers';

% =========================================================================

DS = dataSource;
D = dir([DS.root study filesep '*.avi']);

for i = 1:numel(D)
    
    [~, run] = fileparts(D(i).name);
    
    % --- Create directories
    
    tmpDir = [DS.root study filesep 'Tmp']; 
    runDir = [DS.root study filesep run]; 
    imDir = [runDir filesep 'Images'];
    
    % --- Move images
    
    movefile(runDir, tmpDir);
    mkdir(runDir);
    movefile(tmpDir, imDir);
    
    % --- Move movie
    
    movefile([DS.root study filesep D(i).name], [runDir filesep D(i).name]);

    % --- Create files foilder
    
    mkdir([runDir filesep 'Files']);

end
