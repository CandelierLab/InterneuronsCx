function computeShape(this, varargin)
%computeShape Compute shape properties

% --- Input ---------------------------------------------------------------

p = inputParser;
addRequired(p, 'type', @isstring);
addOptional(p, 'id', [], @isnumeric);
parse(p, varargin{:});

type = p.Results.type;
id = p.Results.id(:)';

% -------------------------------------------------------------------------

if isempty(id)
    id = 1:numel(this.Sh);
end

Img = imread(this.File.images, this.ui.time.Value);

for i = id
    
    Mask = false(this.Images.Height, this.Images.Width);
    Mask(this.Sh(i).idx) = true;
    
    % --- Contours
    
    if ismember("contour", type)
        
        B = bwboundaries(Mask);
        this.Sh(i).contour.x = B{1}(:,2);
        this.Sh(i).contour.y = B{1}(:,1);
        
    end
    
    % --- Position
    
    if ismember("pos", type)
       
        tmp = regionprops(Mask, Img, {'WeightedCentroid'});
        this.Sh(i).x = tmp.WeightedCentroid(1);
        this.Sh(i).y = tmp.WeightedCentroid(2);
        
    end
    
    % --- Fluorescence
    
    if ismember("fluo", type)
        
        
        
    end
    
end

     
%     
%     
% end

