function Out = HighMag(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});
   
Img = p.Results.Img; 

% === Output ==============================================================

Out = zeros(size(Img));