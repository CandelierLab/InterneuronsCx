function Out = LowMag_R(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});

Img = p.Results.Img;

% =========================================================================

Out = ones(size(Img))*(median(Img(:))*0.75);