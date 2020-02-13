function compute(this, varargin)
%computeShape Compute shape properties

% --- Input ---------------------------------------------------------------

p = inputParser;
addRequired(p, 'type', @(x) ismember(x, {'Blob', 'Unit'}));
addRequired(p, 'target', @isstring);
addOptional(p, 'id', [], @isnumeric);
parse(p, varargin{:});

type = p.Results.type;
target = p.Results.target;
id = p.Results.id(:)';

% -------------------------------------------------------------------------

if isempty(id)
    id = 1:numel(this.(type));
end

Img = imread(this.File.images, round(this.ui.time.Value));

for i = id
    
    % --- initialization
    
    switch type
        case 'Blob'
            Obj = this.Blob(i);
        case 'Unit'
            Obj = this.Unit(i).all;
    end
    
    Mask = false(this.Images.Height, this.Images.Width);
    Mask(Obj.idx) = true;
    
    % --- Position
    
    if ismember("pos", target)
       
        tmp = regionprops(Mask, Img, {'Area', 'WeightedCentroid'});
        if numel(tmp)>1
            [~,mi] = max([tmp.Area]);
            tmp = tmp(mi);
        end
        Obj.pos.x = tmp.WeightedCentroid(1);
        Obj.pos.y = tmp.WeightedCentroid(2);
        
    end
    
    % --- Contours
    
    if ismember("contour", target)
        
        B = bwboundaries(Mask);
        Obj.contour.x = cell(numel(B),1);
        Obj.contour.y = cell(numel(B),1);
        for k = 1:numel(B)
            Obj.contour.x{k} = B{k}(:,2);
            Obj.contour.y{k} = B{k}(:,1);
        end
        
    end
    
    % --- Assignment
    
    switch type
        case 'Blob'
            this.Blob(i) = Obj;
        case 'Unit'
            this.Unit(i).all = Obj;
    end
    
end