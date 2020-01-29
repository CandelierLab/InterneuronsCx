function prepareDisplay(this, varargin)
%prepareDisplay Prepare the display

% Input: traj='reset'

tic

% --- Input ---------------------------------------------------------------

p = inputParser;
addParameter(p, 'reset', {}, @isstring);
parse(p, varargin{:});

reset = p.Results.reset;

% --- Reset ---------------------------------------------------------------

% --- Trajectories

if ismember("traj", reset)

    tI = unique([this.Fr(cellfun(@isnumeric, {this.Fr.status})).status]);
    this.Visu.Color.trajs = lines(numel(tI));
    
end

% --- Local view ----------------------------------------------------------

if this.Visu.viewLocal
   
    
    
else
    this.Visu.crop = struct('x1', 1, 'x2', this.Images.Width, ...
        'y1', 1, 'y2', this.Images.Height);
end
        
% --- 3D view -------------------------------------------------------------

set(this.Viewer, 'CurrentAxes', this.ui.view3d);
cla(this.ui.view3d)
hold(this.ui.view3d, 'on');

% --- Plot trajectories

for i = 1:numel(this.Fr)
    
    % Linewidth
    if i==this.fid 
        lw = 2;
    else
        lw = 0.5;
    end
        
    
    switch this.Fr(i).status
        
        case 'unused'
            if this.Visu.viewFrag
                plot3(this.Fr(i).soma.pos(:,1), ...
                    this.Fr(i).soma.pos(:,2), ...
                    this.Fr(i).t, ...
                    '-', 'Linewidth', lw, ...
                    'color', this.Visu.Color.fragment);
            end
            
        case 'quarantine'
            if this.Visu.viewQuar
                plot3(this.Fr(i).soma.pos(:,1), ...
                    this.Fr(i).soma.pos(:,2), ...
                    this.Fr(i).t, ...
                    '-', 'Linewidth', lw, ...
                    'color', this.Visu.Color.quarantine);
            end
            
        otherwise
            if this.Visu.viewTraj
                plot3(this.Fr(i).soma.pos(:,1), ...
                    this.Fr(i).soma.pos(:,2), ...
                    this.Fr(i).t, ...
                    '-', 'Linewidth', lw, ...
                    'color', this.Visu.Color.trajs(this.Fr(i).status,:));
            end
            
    end
    
end

grid on
if this.Visu.viewLocal
    axis([this.Visu.crop.x1 this.Visu.crop.x2 this.Visu.crop.y1 this.Visu.crop.y2 this.Visu.alim3d(5:6)]);
else
    axis(this.Visu.alim3d);
end

daspect([1 1 this.Visu.aspRatio])
view(-25,25)
axtoolbar(this.ui.view3d, {'rotate'});
xlabel('x', 'color', 'w')
ylabel('y', 'color', 'w')
zlabel('t', 'color', 'w')

drawnow limitrate

% --- Positions -----------------------------------------------------------

empty(this.Images.number) = struct('x', [], 'y', []);
this.Pos = struct('unused', empty, 'quarantine', empty, 'traj', empty);

this.Pos.unused

for i = 1:numel(this.Fr)
    
    switch this.Fr(i).status
        
        case 'unused'
            
            for j = 1:numel(this.Fr(i).t)
                this.Pos.unused(this.Fr(i).t(j)).x(end+1) = this.Fr(i).soma.pos(j,1);
                this.Pos.unused(this.Fr(i).t(j)).y(end+1) = this.Fr(i).soma.pos(j,2);
            end
                        
    end
    
end

% Display processing time
this.ui.prepareTime.String = round(toc*1000) + " ms";
