%#ok<*AGROW>
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = '190424 D1_16b';
run = 'P2t';

% --- Image processing

t = 14;

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

% --- Background --------------------------------------------------

Bkg = IP.Bkg.LowMag(lImg(1));

% --- Load image --------------------------------------------------

Img = lImg(t);

% --- Foreground detection ----------------------------------------

Res = Img - Bkg;

Res = imnlmfilt(Res, 'DegreeOfSmoothing', 0.03);

Th = adaptthresh(Res, 0.1, ...
    'NeighborhoodSize', [1 1]*15, ...
    'ForegroundPolarity', 'bright', ...
    'Statistic', 'gaussian');

BW = imbinarize(Res, Th);
 
BW = bwpropfilt(BW, 'Area', [50 Inf]);

% === Display =============================================================

figure(1)
clf
hold on


% imshow(Res)
% imshowpair(Img-Bkg, Res, 'Montage');
imshowpair(Img, BW, 'Montage')


axis ij image on
caxis([0 100])
% caxis auto
% 
% colorbar

title(num2str(t));
