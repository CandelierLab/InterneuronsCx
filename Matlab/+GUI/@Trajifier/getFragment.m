function id = getFragment(this)
%getFragment Get the id of the closest fragment among the visible ones.
%   The fragment can be unused, in quarantine or in a trajecotry.

id = NaN;

% --- Check that the mouse is on the image

 if this.mousePosition.image(1)<1 || ...
         this.mousePosition.image(1)>this.Images.Width || ...
         this.mousePosition.image(2)<1 || ...
         this.mousePosition.image(2)>this.Images.Height
     return
 end

% --- Get positions

ti = round(get(this.ui.time, 'Value'));
x = NaN(numel(this.Fr),1);
y = NaN(numel(this.Fr),1);

for i = 1:numel(this.Fr)
    
    % --- Filters
    
    if ischar(this.Fr(i).status)
        if (strcmp(this.Fr(i).status, 'unused') && ~this.Visu.viewFrag) || ...
                (strcmp(this.Fr(i).status, 'quarantine') && ~this.Visu.viewQuar)
            continue
        end
    elseif ~this.Visu.viewTraj
        continue; 
    end
    
    I = ti==this.Fr(i).t;
    if ~any(I), continue; end
    
    % --- Positions
    
    x(i) = this.Fr(i).soma.pos(I,1);
    y(i) = this.Fr(i).soma.pos(I,2);
    
end

% --- Output

if any(~isnan(x))
    [~, id] = nanmin((x-this.mousePosition.image(1)).^2 + (y-this.mousePosition.image(2)).^2);
end