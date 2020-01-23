function Out = LowMag(varargin)

% === Input ===============================================================

p = inputParser;
addRequired(p, 'Img', @isnumeric);
parse(p, varargin{:});

Img = p.Results.Img;

% --- Parameters ----------------------------------------------------------

% Background
r_bkg = 10;

% =========================================================================

Out = ordfilt2(Img, 20, true(2*r_bkg));
Out(1:r_bkg,:) = repmat(Out(r_bkg+1,:), [r_bkg 1]);
Out(end-r_bkg+1:end,:) = repmat(Out(end-r_bkg-1,:), [r_bkg 1]);
Out(:,1:r_bkg) = repmat(Out(:,r_bkg+1), [1 r_bkg]);
Out(:,end-r_bkg+1:end) = repmat(Out(:,end-r_bkg-1), [1 r_bkg]);