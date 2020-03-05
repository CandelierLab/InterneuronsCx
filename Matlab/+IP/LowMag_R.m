function Out = LowMag_R(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});

Img = p.Results.Img;

% --- Parameters ----------------------------------------------------------

sigma = 5;
th_num = 1000;

% =========================================================================

% --- Noise filtering

Res = imnlmfilt(Img, 'DegreeOfSmoothing', 0.03);

% --- Thresholding

Th = adaptthresh(Res, 0.1, ...
    'NeighborhoodSize', [1 1]*15, ...
    'ForegroundPolarity', 'bright', ...
    'Statistic', 'gaussian');

BW = imbinarize(Res, Th);

% --- Object filtering

BW = bwpropfilt(BW, 'Area', [50 Inf]);

% --- Object extraction

R = regionprops(BW, Res, {'PixelIdxList'});

R = R(cellfun(@numel, {R.PixelIdxList})<th_num);

% === Output ==============================================================

Out = struct('idx', {R.PixelIdxList});