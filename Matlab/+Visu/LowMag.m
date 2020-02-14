clc

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Paramters ===========================================================

Study = 'LowMag';
Run = 'P18';

intFactor = 1;

fContour = 1;
fCell = 0.2;

force = true;

% -------------------------------------------------------------------------

DS = dataSource;
fImg = [DS.data Study filesep Run filesep Run '.tiff'];
fTraj = [DS.data Study filesep Run filesep 'Files' filesep 'Trajectories.mat'];

fOutput = [DS.data Study filesep Run filesep 'Files' filesep 'Result.tiff'];

% =========================================================================

close all
figure(1)
set(gcf, 'WindowStyle', 'docked');

% --- Image information

info = imfinfo(fImg);
nImg = numel(info);
info = info(1);

% --- Load trajectories

if ~exist('Tr', 'var') || force

    fprintf('Loading trajectories ...');
    tic
    
    tmp = load(fTraj);
    Tr = tmp.Tr;
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Prepare output tiff

tagstruct = struct('ImageLength', info.Height, ...
    'ImageWidth', info.Width, ...
    'Photometric', Tiff.Photometric.RGB, ...
	'BitsPerSample', 8, ...
	'SamplesPerPixel', 3, ...
	'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
    'Software', mfilename);

hOutput = Tiff(fOutput, 'w');

% --- Create output tiff

fprintf('Creating Tiff .');
tic

cm = hsv(numel(Tr));
cm = cm(randperm(numel(Tr)),:);

for i = 1:nImg
    
    % Raw image
    Raw = imread(fImg, i);
    
    % Color channels
    R = intFactor*Raw;
    G = intFactor*Raw;
    B = intFactor*Raw;
    
    
    for j = 1:numel(Tr)
    
        % --- Soma contours
        ti = find(Tr(j).t==i);
        
        if isempty(ti), continue; end
        if ti>numel(Tr(j).soma), continue; end
        if isempty(Tr(j).soma(ti).contour) || ~iscell(Tr(j).soma(ti).contour.x), continue; end
        
        I = sub2ind([info.Height info.Width], ...
            Tr(j).soma(ti).contour.y{1}, Tr(j).soma(ti).contour.x{1});
                 
        R(I) = R(I)*(1-fContour) + cm(j,1)*fContour*255;
        G(I) = G(I)*(1-fContour) + cm(j,2)*fContour*255;
        B(I) = B(I)*(1-fContour) + cm(j,3)*fContour*255;

        % --- Cells
        
        Idx = Tr(j).all(ti).idx;
        
        R(Idx) = R(Idx)*(1-fCell) + cm(j,1)*fCell*255;
        G(Idx) = G(Idx)*(1-fCell) + cm(j,2)*fCell*255;
        B(Idx) = B(Idx)*(1-fCell) + cm(j,3)*fCell*255;

    end
    
    % Reconstruction
    RGB = cat(3, R, G, B);
    
    % --- Save

    setTag(hOutput, tagstruct);
    write(hOutput, RGB);
    writeDirectory(hOutput);
    
    % --- Display
    
    clf
    imshow(RGB);
    
    axis xy
    
    title("Frame " + i);
    
    drawnow
    
    if ~mod(i,20), fprintf('.'); end

end

close(hOutput);

fprintf(' %.02f sec\n', toc);
