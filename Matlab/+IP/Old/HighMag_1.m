function Out = HighMag_1(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});
   
Img = p.Results.Img; 

% --- Parameters ----------------------------------------------------------

mr = 5;         % Morphological reconstruction erosion parameter
sm = 2;         % Smoothing (dilatation) factor

th = 0.075;

% =========================================================================

%         Img = imgaussfilt(Img, 0.5);

Tmp = imerode(Img, strel('disk', mr));
Tmp = imreconstruct(Tmp, Img);
Tmp = imdilate(Tmp, strel('disk', sm));
BW = imregionalmax(Tmp);

BW = bwpropfilt(BW, Img, 'MeanIntensity', [th, Inf]);

R = regionprops(BW, Img, {'PixelIdxList', 'WeightedCentroid'});

% === Output ==============================================================

Out = struct('Idx', {R.PixelIdxList}, 'pos', {R.WeightedCentroid});
