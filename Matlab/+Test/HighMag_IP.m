%#ok<*AGROW>
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'HighMag';
run = 's14e2';

% --- Image processing

t = 1;

force = true;

% -------------------------------------------------------------------------

DS = dataSource;
imDir = [DS.root study filesep run filesep 'Images' filesep];

% =========================================================================

% --- Preparation ---------------------------------------------------------

D = dir(imDir);
D([D.isdir]) = [];
n = numel(D);
ext = D(1).name(end-3:end);

info = imfinfo([imDir 'frame_' num2str(1, '%06i') ext]);
lImg = @(i) double(imread([imDir 'frame_' num2str(i, '%06i') ext]))/255;


% --- Load image --------------------------------------------------

Img = lImg(t);

% --- Foreground detection ----------------------------------------

Res = Img;

[Res, dos] = imnlmfilt(Res, 'DegreeOfSmoothing', 0.008);

% Res = medfilt2(Res, [1 1]*3);
Res = imgaussfilt(Res, 1);

Tmp = imerode(Res, strel('disk', 5));
Rec = imreconstruct(Tmp, Res);
     
% BW = Rec >= 0.025;

Th = adaptthresh(Rec, 0.5, ...
    'NeighborhoodSize', [1 1]*15, ...
    'ForegroundPolarity', 'bright', ...
    'Statistic', 'gaussian');
BW = imbinarize(Rec, Th);

BW = bwpropfilt(BW, Rec, 'MaxIntensity', [0.025 Inf]);
BW = bwpropfilt(BW, 'Area', [100 Inf]);

BW = bwmorph(BW, 'skel', 1);

% === Display =============================================================

figure(1)
clf
hold on


% imshow(Res)
% imshowpair(Img, Res, 'Montage');
imshowpair(Rec, BW, 'Montage')


axis ij image on
caxis([0 30])
% caxis auto
% 
% colorbar

title(num2str(t));
