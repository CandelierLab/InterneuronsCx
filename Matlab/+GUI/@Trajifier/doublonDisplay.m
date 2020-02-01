function doublonDisplay(this, varargin)

% --- Parameters

ti = round(get(this.ui.time, 'Value'));
If = str2double(this.ui.Intfactor.String);

% --- Image ---------------------------------------------------------------

Img = If*double(imread(this.File.images, ti))/255;

set(this.Viewer, 'CurrentAxes', this.ui.image);
cla(this.ui.image);
hold(this.ui.image, 'on');

imshow(Img);

axis xy tight

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% --- Points on image -----------------------------------------------------

Traj = find(string({this.Fr.status})==string(this.tid));

so = NaN(numel(Traj),2);
ce = NaN(numel(Traj),2);
co = NaN(numel(Traj),2);

for i = 1:numel(Traj)
    
    t = find(this.Fr(Traj(i)).t==ti);
    if isempty(t), continue; end
    
    so(i,:) = this.Fr(Traj(i)).soma.pos(t,:);
    ce(i,:) = this.Fr(Traj(i)).centrosome.pos(t,:);
    co(i,:) = this.Fr(Traj(i)).cone.pos(t,:);
    
end

scatter(so(:,1), so(:,2), 30, ...
    this.Visu.Color.trajs(this.tid,:), 'filled', ...
    'MarkerEdgeColor', 'k', ...
    'UIContextMenu', this.Visu.cMenu);

scatter(ce(:,1), ce(:,2), 30, ...
    this.Visu.Color.trajs(this.tid,:), 's', 'filled', ...
    'MarkerEdgeColor', 'k', ...
    'UIContextMenu', this.Visu.cMenu);

scatter(co(:,1), co(:,2), 30, ...
    this.Visu.Color.trajs(this.tid,:), 'd', 'filled', ...
    'MarkerEdgeColor', 'k', ...
    'UIContextMenu', this.Visu.cMenu);


if this.Visu.viewLocal
    
    % Check
    Traj = find(cellfun(@(x) isnumeric(x) && x==this.tid, {this.Fr.status}));
    
    if numel(Traj)
        
        % --- Get position
        
        dt = Inf;
        xc = NaN;
        yc = NaN;
        
        for i = 1:numel(Traj)
            [dt_, mi] = min(abs(this.Fr(Traj(i)).t-ti));
            if dt_==0
                xc = this.Fr(Traj(i)).soma.pos(mi,1);
                yc = this.Fr(Traj(i)).soma.pos(mi,2);
                break;
            elseif dt_<dt
                xc = this.Fr(Traj(i)).soma.pos(mi,1);
                yc = this.Fr(Traj(i)).soma.pos(mi,2);
                dt = dt_;
            end
        end
        
        % --- Crop image
        
        this.Visu.crop.x1 = round(max(xc-this.Visu.lsz/2, 1));
        this.Visu.crop.x2 = round(min(xc+this.Visu.lsz/2, this.Images.Width));
        this.Visu.crop.y1 = round(max(yc-this.Visu.lsz/2, 1));
        this.Visu.crop.y2 = round(min(yc+this.Visu.lsz/2, this.Images.Height));
        
        axis([this.Visu.crop.x1 this.Visu.crop.x2 this.Visu.crop.y1 this.Visu.crop.y2]);
        
    end
end

% --- Points on 3D view ---------------------------------------------------

set(this.Viewer, 'CurrentAxes', this.ui.view3d);

% --- Fragments

if this.Visu.viewFrag
    delete(this.Visu.hFr3);
    this.Visu.hFr3 = scatter3(this.Pts.unused(ti).x, this.Pts.unused(ti).y, ...
        ti*ones(numel(this.Pts.unused(ti).x),1), 30, ...
        'MarkerFaceColor', 'w', ...
        'MarkerEdgeColor', 'k');
end

% --- Quarantine

if this.Visu.viewQuar
    delete(this.Visu.hQ3);
    this.Visu.hQ3 = scatter3(this.Pts.quarantine(ti).x, this.Pts.quarantine(ti).y, ...
        ti*ones(numel(this.Pts.quarantine(ti).x),1), 30, ...
        'MarkerFaceColor', this.Visu.Color.quarantine, ...
        'MarkerEdgeColor', 'w');   
end

% --- Trajectories

if this.Visu.viewTraj
    delete(this.Visu.hTr3);
    this.Visu.hTr3 = scatter3(this.Pts.traj(ti).x, this.Pts.traj(ti).y, ...
        ti*ones(this.Pts.nTraj,1), 30, this.Visu.Color.trajs, 'filled', ...
        'MarkerEdgeColor', 'k');
end

if this.Visu.viewLocal
    axis(this.ui.view3d, [this.Visu.crop.x1 this.Visu.crop.x2 this.Visu.crop.y1 this.Visu.crop.y2 this.Visu.alim3d(5:6)]);
else
    axis(this.ui.view3d, this.Visu.alim3d);
end

% --- Draw & play ---------------------------------------------------------

drawnow limitrate