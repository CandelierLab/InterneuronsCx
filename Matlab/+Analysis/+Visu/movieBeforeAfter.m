clc
set(gcf, 'WindowStyle', 'docked');

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Paramters ===========================================================

Study = 'HighMag';
Run = 's10e1';

fContour = 1;
fCell = 0.2;

force = true;

% -------------------------------------------------------------------------

DS = dataSource;
fImg = [DS.data Study filesep Run filesep Run '.tiff'];
fParam = [DS.data Study filesep Run filesep 'Files' filesep 'Parameters.mat'];
fOutput = [DS.data Study filesep Run filesep 'Files' filesep 'Result.tiff'];

mDir = [DS.data Study filesep Run filesep 'Files/Movie/'];

% =========================================================================

% --- Get parameters

tmp = load(fParam);
Param = tmp.Param;

% --- Image information

info = imfinfo(fImg);
nImg = numel(info);
info = info(1);

% --- Create output

fprintf('Computing .');
tic

for i = 1:nImg
    
    % Images
    B = repmat(imread(fImg, i), [1 1 3])*intFactor;
    A = imread(fOutput, i);
    I = 255*ones(info.Height, 1, 3);
    
    M = cat(2, B, I, A);
    
    % --- Display
    
    clf
    imshow(M);
    
    axis xy
    
    drawnow
    
    if ~mod(i,20), fprintf('.'); end

    % -- Save
    
    imwrite(M, [mDir 'frame_' num2str(i, '%06i') '.png']);
    
end

fprintf(' %.02f sec\n', toc);
