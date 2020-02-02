function Out = HighMag(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});
   
Img = p.Results.Img; 

% =========================================================================

Res = Img;

% --- Noise filtering

Res = imnlmfilt(Res, 'DegreeOfSmoothing', 0.008);
Res = imgaussfilt(Res, 1);

Tmp = imerode(Res, strel('disk', 5));
Rec = imreconstruct(Tmp, Res);
     
% --- Thresholding

Th = adaptthresh(Rec, 0.5, ...
    'NeighborhoodSize', [1 1]*15, ...
    'ForegroundPolarity', 'bright', ...
    'Statistic', 'gaussian');
BW = imbinarize(Rec, Th);

% --- Object filtering

BW = bwpropfilt(BW, Rec, 'MaxIntensity', [0.035 Inf]);
BW = bwpropfilt(BW, 'Area', [100 Inf]);

% --- Thinning

BW = bwmorph(BW, 'skel', 1);

% --- Object extraction

R = regionprops(BW, Img.^2, {'PixelIdxList'});

% === Output ==============================================================

Out = struct('idx', {R.PixelIdxList});