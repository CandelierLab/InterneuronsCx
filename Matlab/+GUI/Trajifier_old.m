function Viewer = Trajifier_old(varargin)

clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Input ===============================================================

p = inputParser;
addParameter(p, 'Main', [], @(x) true);
addParameter(p, 'dataSource', dataSource, @isstruct);
addParameter(p, 'study', '', @ischar);
addParameter(p, 'run', '', @ischar);
addParameter(p, 'position', [], @isnumeric);
addParameter(p, 'intensityFactor', 1, @isnumeric);
addParameter(p, 'color', [1 1 1], @isnumeric);

parse(p, varargin{:});  
Main = p.Results.Main; 
DS = p.Results.dataSource;
study = p.Results.study;
run = p.Results.run;
position = p.Results.position;
intFactor = p.Results.intensityFactor;
color = p.Results.color;

% =========================================================================

% --- File names ----------------------------------------------------------

fName = [DS.data study filesep run filesep run '.tiff'];
FrName = [DS.data study filesep run filesep 'Files' filesep 'Fragments.mat'];

% --- Misc variables ------------------------------------------------------

Wmenu = 400;

Fcolor = [1 1 1]*0.5; %[84 153 199]/255;
Ccolor = [203 67 53]/255;
Qcolor = [0.86 0.46 0.2];

info = imfinfo(fName);
n = numel(info);
info = info(1);
frameFormat = ['%0' num2str(ceil(log10(n))) 'i'];
aspRatio = n/info.Width;
alim3d = [1 info.Height 1 info.Width 1 n];

lsz = 150;   % Local size (in pixels) 
fps = 50;
fbd = 20;

% --- Input

Input = struct('active', false, 'command', '', 'buffer', '');

% --- Display

Mouse = struct('image', NaN(2,1), 'view3D', NaN(2,1));

viewLocal = false;
Crop = struct('x1', 1, 'x2', info.Width, 'y1', 1, 'y2', info.Height);

viewPlay = false;
viewFrag = true;
viewTraj = true;
viewQuar = false;

% Handles
hFr3 = [];
hQ3 = [];
hTr3 = [];
hTrs3 = {};

% --- Trajectories

Traj = [];      % Current
doublons = [];

% --- Load Fragments ------------------------------------------------------

tmp = load(FrName);
Fr = tmp.Fr;

% --- Already defined trajectories

Trajs = {};
for i = 1:numel(Fr)
    if isnumeric(Fr(i).status)
        if Fr(i).status>numel(Trajs)
            Trajs{Fr(i).status} = i;
        else
            Trajs{Fr(i).status}(end+1) = i;
        end
    end
end

Tcolor = lines(numel(Trajs));

% --- User interface ------------------------------------------------------

% --- Figure

Viewer = findobj('type', 'figure', 'name', mfilename);

if isempty(Viewer)
    Viewer = figure('name', mfilename);
else
    figure(Viewer.Number);
end

clf(Viewer)

% --- Display -------------------------------------------------------------

ui = struct();

% --- Axis

ui.image = axes('units', 'pixels', 'Position', [0 0 1 1]);
ui.view3d = axes('units', 'pixels', 'Position', [0 0 1 1]);

% --- Title

ui.title = uicontrol('style', 'text', 'position', [0 0 1 1], ...
    'FontName', 'Courier New', 'FontSize', 12);

% --- Menu

ui.menu.shortcuts = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

ui.menu.shortcuts.String = getControls();

% --- Actions

ui.action = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', 'y', ...
    'position', [0 0 1 1]);

% --- Info

ui.info = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);


% --- Warnings

ui.warnings = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', Qcolor, ...
    'position', [0 0 1 1]);

% --- Controls ------------------------------------------------------------

% --- Intensity factor

ui.menu.Intfactor = uicontrol('style', 'text', ...
    'string', 'Intensity factor', 'FontName', 'Courier New', 'FontSize', 11, ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);
ui.Intfactor = uicontrol('style', 'edit', ...
    'position', [0 0 1 1], ...
    'string', num2str(intFactor), 'FontName', 'Courier New', 'FontSize', 11, ...
    'Callback', @updateImage);

% --- Time
ui.time = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', n, 'value', 1, 'SliderStep', [1 1]./(n-1));

% --- Context menu

cMenu = uicontextmenu;

% Create child menu items for the uicontextmenu
uimenu(cMenu, 'Label', 'Remove point', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'soma', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'centrosome', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'cone', 'Callback', @rightClick);

% --- Listeners

Viewer.ResizeFcn = @updateControlSize;
Viewer.Position = position;
Viewer.KeyPressFcn = @keyInput;
Viewer.WindowButtonDownFcn = @Click;
Viewer.WindowButtonMotionFcn = @mouseMove;

addlistener(ui.time, 'Value', 'PostSet', @updateImage);

updateInfos();
update3dview();
updateImage();

% === Controls ============================================================

    function updateControlSize(varargin)
        
        % --- Figure size       
        tmp = get(Viewer, 'Outerposition');
        W = tmp(3);
        H = tmp(4);
        
        % --- Window
            
        set(Viewer, 'Menu', 'none', 'ToolBar', 'none', 'color', color);
        if ~isempty(position)
            set(Viewer, 'Position', position);
        end
        h = H-30;
        
        % --- Axes
        ui.image.Position = [Wmenu+20 235 700 700];
        ui.view3d.Position = [Wmenu+730 235 700 600];
        
        % --- Time
        
        ui.time.Position = [Wmenu+20 200 700 20];
        ui.title.Position = [Wmenu+10 h-50 680 20];
        
        % --- Menu
        
        % Intensity factor
        ui.menu.Intfactor.Position = [10 h-50 200 20];
        ui.Intfactor.Position = [210 h-50 50 25];
        
        % Shortcuts
        ui.menu.shortcuts.Position = [10 40 380 h-110];
                
        % --- Title
        
        ui.title.BackgroundColor = color;
        ui.title.ForegroundColor = 'w';
        
        % --- Info
         
        ui.info.Position = [Wmenu+20 10 750 150];
        
        % --- Action
        
        ui.action.Position = [10 10 Wmenu 30];
        
        % --- Warning
        ui.warnings.Position = [Wmenu+770 10 750 150];
        
    end
    
    % --- KEY INPUTS ------------------------------------------------------

    function keyInput(varargin)
       
        event = varargin{2};
        ui.action.String = [event.Character '/' event.Key];
        
        if Input.active
        
            switch event.Key
                case 'return'
                    
                    switch Input.command
                        
                        case 'w'
                            lsz = max(min(round(str2double(Input.buffer)), info.Width),10);
                            ui.menu.shortcuts.String = getControls();
                            
                        case 'v'
                            fps = max(min(round(str2double(Input.buffer)), 50),1);
                            ui.menu.shortcuts.String = getControls();
                            
                        case 'd'
                            fbd = max(min(round(str2double(Input.buffer)), n),1);
                            ui.menu.shortcuts.String = getControls();
                            
                    end
                    
                    Input.active = false;
                    Input.command = '';
                    Input.buffer = '';
                    
                otherwise
                    Input.buffer(end+1) = event.Character;
            end
            
        else
            
            switch event.Character
                
                case ' '
                    viewPlay = ~viewPlay;
                    if viewPlay
                        updateImage();
                    end
                    
                case 'g'
                    viewLocal = false;
                    Crop = struct('x1', 1, 'x2', info.Width, 'y1', 1, 'y2', info.Height);
                    ui.menu.shortcuts.String = getControls();
                    updateImage();
                    
                case 'l'
                    viewLocal = true;
                    ui.menu.shortcuts.String = getControls();
                    updateImage();
                    
                case 'w'
                    Input.active = true;
                    Input.command = 'w';
                    
                case 'b'
                    ui.time.Value = max(ui.time.Value-fbd, ui.time.Min);
                    viewPlay = true;
                    updateImage();
                    
                case 'v'
                    Input.active = true;
                    Input.command = 'v';
                    
                case 'd'
                    Input.active = true;
                    Input.command = 'd';
                    
                case 'n'
                    if isempty(doublons)
                        ui.action.String = 'No doublon found';
                    else
                        if ui.time.Value>=doublons(end)
                            nt = doublons(1);
                        else
                            nt = doublons(find(doublons>ui.time.Value,1,'first'));
                        end
                        ui.time.Value = nt;
                        updateImage();
                    end
                    
                case 'f'                    
                    if isempty(Traj), return; end
                    ui.time.Value = max(Fr(Traj(end)).t(1)-fbd, ui.time.Min);
                    viewPlay = true;
                    updateImage();
                    
                case 'c'
                    
                    ci = findClosest();
                    ti = round(get(ui.time, 'Value'));
                    
                    % --- New fragment
                    
                    % Indexes
                    k = numel(Fr)+1;
                    I = Fr(ci).t>=ti;
                    
                    Fr(k).status = 'unused';
                    Fr(k).t = Fr(ci).t(I);
                    
                    Fr(k).soma.idx = Fr(ci).soma.idx(I);
                    Fr(k).soma.pos = Fr(ci).soma.pos(I,:);
                    Fr(k).soma.fluo = Fr(ci).soma.fluo(I);
                    
                    Fr(k).centrosome.idx = Fr(ci).centrosome.idx(I);
                    Fr(k).centrosome.pos = Fr(ci).centrosome.pos(I,:);
                    Fr(k).centrosome.fluo = Fr(ci).centrosome.fluo(I);
                    
                    Fr(k).cone.idx = Fr(ci).cone.idx(I);
                    Fr(k).cone.pos = Fr(ci).cone.pos(I,:);
                    Fr(k).cone.fluo = Fr(ci).cone.fluo(I);
                   
                    % --- Trim fragment
                    
                    % Indexes
                    I = Fr(ci).t<ti;
                    
                    Fr(ci).t = Fr(ci).t(I);
                    
                    Fr(ci).soma.idx = Fr(ci).soma.idx(I);
                    Fr(ci).soma.pos = Fr(ci).soma.pos(I,:);
                    Fr(ci).soma.fluo = Fr(ci).soma.fluo(I);
                    
                    Fr(ci).centrosome.idx = Fr(ci).centrosome.idx(I);
                    Fr(ci).centrosome.pos = Fr(ci).centrosome.pos(I,:);
                    Fr(ci).centrosome.fluo = Fr(ci).centrosome.fluo(I);
                    
                    Fr(ci).cone.idx = Fr(ci).cone.idx(I);
                    Fr(ci).cone.pos = Fr(ci).cone.pos(I,:);
                    Fr(ci).cone.fluo = Fr(ci).cone.fluo(I);
                                        
                    % --- Save and display
                    
                    update3dview;
                    updateImage;
                    saveFragments;
                    
                case 'q'
                    
                    if inImage
                        
                        ci = findClosest();                        
                        if isempty(ci), return; end
                        
                        switch Fr(ci).status 
                            
                            case 'unused'
                                Fr(ci).status = 'quarantine';
                                ui.action.String = ['Placed '  num2str(ci) ' in quarantine'];
                                
                            case 'quarantine'
                                Fr(ci).status = 'unused';
                                ui.action.String = ['Removed '  num2str(ci) ' from quarantine'];
                        end
                    
                        update3dview;
                        updateImage;
                    
                        saveFragments;
                        
                    end
                    
                case 's'
                    
                    idx = getNextTrajIdx();
                    for i = Traj
                        Fr(i).status = idx;
                    end
                    saveFragments;

                    Trajs{end+1} = Traj;
                    Traj = [];
                    
                    Tcolor = lines(numel(Trajs));
                    
                    update3dview;
                    updateImage;
                    
                case 'F'
                    viewFrag = ~viewFrag;
                    update3dview;
                    updateImage;
                    
                case 'T'
                    
                    viewTraj = ~viewTraj;
                    update3dview;
                    updateImage;
                    
                case 'Q'
                    
                    viewQuar = ~viewQuar;
                    update3dview;
                    updateImage;
                    
                otherwise
                    
                    switch event.Key
                        
                        case 'leftarrow'
                            ui.time.Value = max(ui.time.Value-1, ui.time.Min);
                            updateImage();
                            
                        case 'rightarrow'
                            ui.time.Value = min(ui.time.Value+1, ui.time.Max);
                            updateImage();
                            
                        case 'uparrow'
                            if ~isempty(Traj)
                                ui.time.Value = max(cat(1,Fr(Traj).t));
                                updateImage();
                            end
                            
                        case 'downarrow'
                            if ~isempty(Traj)
                                ui.time.Value = min(cat(1,Fr(Traj).t));
                                updateImage();
                            end
                            
                        case 'pagedown'
                            ui.time.Value = ui.time.Min;
                            updateImage();
                            
                        case 'delete'
                            
                            if isempty(Traj), return; end
                            
                            if inImage
                                
                                % --- Find closest Fragment
                                
                                mi = findClosest(Traj);
                                
                                ui.action.String = ['Removed fragment ' num2str(Traj(mi))];
                                
                                Fr(Traj(mi)).status = 'unused';
                                Traj(mi) = [];
                                
                                update3dview();
                                updateImage();
                                updateInfos();
                                updateWarnings();
                                
                            end
                    end
            end
        end
    end

    % --- Mouse -----------------------------------------------------------

    function mouseMove(varargin)
       
        tmp = get(ui.image, 'CurrentPoint');
        Mouse.image = [tmp(1,1) tmp(1,2)];
        
        tmp = get(ui.view3d, 'CurrentPoint');
        Mouse.view3d = [tmp(1,1) tmp(1,2)];
        
    end
    
    % --- CLICK -----------------------------------------------------------

    function Click(varargin)
                
        % --- Check for left click
        if ~strcmp(Viewer.SelectionType, 'normal')
            return
        end
        
        % --- Click on image ----------------------------------------------
        
        % Mouse position
        
        if inImage
        
            % --- Find closest Fragment
            
            ti = round(get(ui.time, 'Value'));
            [x, y, k] = getpos(ti, 'unused');
            [~, mi] = min((x-Mouse.image(1)).^2 + (y-Mouse.image(2)).^2);
            
            Traj(end+1) = k(mi);
        
            update3dview();
            updateImage(); 
            updateInfos();
            updateWarnings();
            
            ui.action.String = ['Added fragment ' num2str(k(mi))];
            
        end
        
    end

    % --- RIGHT CLICK -----------------------------------------------------

    function rightClick(varargin)
       
        varargin{1}.Text;
        get(ui.image, 'CurrentPoint');
        
        updateInfos('R Click');
        
        % Check that click is inside height x width
                
    end

% === Image ===============================================================

    function updateImage(varargin)
        
        % --- Values
        
        ti = round(get(ui.time, 'Value'));
        If = str2double(ui.Intfactor.String);
                  
        % --- Image -------------------------------------------------------
        
        Img = If*double(imread(fName, ti))/255;
        
        set(Viewer, 'CurrentAxes', ui.image);
        cla(ui.image);
        hold(ui.image, 'on');

        h = imshow(Img);
        
        % Context menu
        h.UIContextMenu = cMenu;
        
        axis xy tight
        
        updatePoints(ti);
        
        ui.title.String = ['Frame ' num2str(ti, frameFormat) ' / ' num2str(n)];                
        drawnow limitrate
        
        % Play/pause
        if viewPlay
            if ti==ui.time.Max
                ui.time.Value = ui.time.Min;
            else
                ui.time.Value = ti+1;
            end
            pause(1/fps);
            
            updateImage(varargin{:});
        end
        
    end

    function updatePoints(ti)
        
        % --- Get time point ----------------------------------------------
        
        if ~exist('ti', 'var')
            ti = round(get(ui.time, 'Value'));
        end
        
        % --- Get positions -----------------------------------------------

        Pos = struct('unused', struct('x', [], 'y', []), ...
            'current', struct('x', [], 'y', []), ...
            'trajs', struct('id', [], 'x', [], 'y', []), ...
            'quarantine', struct('x', [], 'y', []));
        
        for i = 1:numel(Fr)
            t_ = find(Fr(i).t==ti);
            if isempty(t_), continue; end
            
            if ismember(i, Traj)
                Pos.current.x(end+1) = Fr(i).soma.pos(t_,1);
                Pos.current.y(end+1) = Fr(i).soma.pos(t_,2);
                continue
            end
            
            switch Fr(i).status
                
                case 'unused'                    
                    Pos.unused.x(end+1) = Fr(i).soma.pos(t_,1);
                    Pos.unused.y(end+1) = Fr(i).soma.pos(t_,2);
                    
                case 'quarantine'
                    Pos.quarantine.x(end+1) = Fr(i).soma.pos(t_,1);
                    Pos.quarantine.y(end+1) = Fr(i).soma.pos(t_,2);
                    
                otherwise
                    Pos.trajs.id(end+1) = Fr(i).status;
                    Pos.trajs.x(end+1) = Fr(i).soma.pos(t_,1);
                    Pos.trajs.y(end+1) = Fr(i).soma.pos(t_,2);
                    
            end
        
        end
        
        % --- Get Crop ----------------------------------------------------
        
        if viewLocal && ~isempty(Traj)

            % --- Get position
            
            dt = Inf;
            xc = NaN;
            yc = NaN;
            
            for i = 1:numel(Traj)
                [dt_, mi] = min(abs(Fr(Traj(i)).t-ti));
                if dt_==0
                    xc = Fr(Traj(i)).soma.pos(mi,1);
                    yc = Fr(Traj(i)).soma.pos(mi,2);
                    break;
                elseif dt_<dt
                    xc = Fr(Traj(i)).soma.pos(mi,1);
                    yc = Fr(Traj(i)).soma.pos(mi,2);
                    dt = dt_;
                end
            end
            
            % --- Crop image
            
            Crop.x1 = round(max(xc-lsz/2, 1));
            Crop.x2 = round(min(xc+lsz/2, info.Width));
            Crop.y1 = round(max(yc-lsz/2, 1));
            Crop.y2 = round(min(yc+lsz/2, info.Height));
            
        end
                
        % --- 3D view -----------------------------------------------------
        
        set(Viewer, 'CurrentAxes', ui.view3d);
        
        % --- Current trajectory
        
        delete(hTr3);
        hTr3 = scatter3(Pos.current.x, Pos.current.y, ti*ones(numel(Pos.current.x),1), 20, ...
            'MarkerFaceColor', Ccolor, 'MarkerEdgeColor', 'k');
        
        % --- Unused fragments
        
        if viewFrag
            delete(hFr3);
            hFr3 = scatter3(Pos.unused.x, Pos.unused.y, ti*ones(numel(Pos.unused.x),1), 20, ...
                'MarkerFaceColor', Fcolor, 'MarkerEdgeColor', 'k');           
        end
        
        % --- Quarantine
        
        if viewQuar
            delete(hQ3);
            hQ3 = scatter3(Pos.quarantine.x, Pos.quarantine.y, ti*ones(numel(Pos.quarantine.x),1), 30, 's', ...
                'MarkerFaceColor', Qcolor, 'MarkerEdgeColor', 'k');           
        end
        
        % --- Trajectories
        
        if viewTraj
            cellfun(@delete, hTrs3);
            hTrs3 = {};
            
            for i = unique(Pos.trajs.id(:))'
                
                I = Pos.trajs.id==i;
                hTrs3{end+1} = scatter3(Pos.trajs.x(I), Pos.trajs.y(I), ti*ones(nnz(I),1), 30, 'd', ...
                    'MarkerFaceColor', Tcolor(i,:), 'MarkerEdgeColor', 'k');
            end
            
        end
        
        if viewLocal
            axis(ui.view3d, [Crop.x1 Crop.x2 Crop.y1 Crop.y2 alim3d(5:6)]);
        else
            axis(ui.view3d, alim3d);
        end

        % --- Image -------------------------------------------------------
        
        set(Viewer, 'CurrentAxes', ui.image);

        % --- Current trajectory

        scatter(Pos.current.x, Pos.current.y, ...
            'MarkerFaceColor', Ccolor, 'MarkerEdgeColor', 'k');
        
        % --- Unused fragments

        if viewFrag
            scatter(Pos.unused.x, Pos.unused.y, 20, ...
                'MarkerFaceColor', Fcolor, 'MarkerEdgeColor', 'k');
        end
        
        % --- Quarantine

        if viewQuar
            scatter(Pos.quarantine.x, Pos.quarantine.y, 30, 's', ...
                'MarkerFaceColor', Qcolor, 'MarkerEdgeColor', 'k');
        end
        
        % --- Trajectoriees
        
        if viewTraj
            
            for i = unique(Pos.trajs.id(:))'
                
                I = Pos.trajs.id==i;
%                 scatter(Pos.trajs.x(I), Pos.trajs.y(I), 30, 'd', ...
%                     'MarkerFaceColor', Tcolor(i,:), 'MarkerEdgeColor', 'k');
            end
            
        end
        
        if viewLocal
            axis([Crop.x1 Crop.x2 Crop.y1 Crop.y2]);
        end
        
    end

% === 3D view =============================================================

    function update3dview(varargin)
        
        % --- 3D view -----------------------------------------------------
        
        set(Viewer, 'CurrentAxes', ui.view3d);
        cla(ui.view3d)
        hold(ui.view3d, 'on');
        
        for i = 1:numel(Fr)
            
            % Current Trajectory            
            if any(Traj==i)
                plot3(Fr(i).soma.pos(:,1), Fr(i).soma.pos(:,2), Fr(i).t, ...
                    '-', 'color', Ccolor, 'LineWidth', 2);
                continue
            end
        
            switch Fr(i).status
                
                case 'unused'
                    if viewFrag   
                        plot3(Fr(i).soma.pos(:,1), Fr(i).soma.pos(:,2), Fr(i).t, ...
                                '-', 'color', Fcolor);
                    end
        
                case 'quarantine'
                    if viewQuar
                        plot3(Fr(i).soma.pos(:,1), Fr(i).soma.pos(:,2), Fr(i).t, ...
                            '-', 'color', Qcolor);
                    end
                    
                otherwise
                     if viewTraj
                         plot3(Fr(i).soma.pos(:,1), Fr(i).soma.pos(:,2), Fr(i).t, ...
                             '-', 'color', Tcolor(Fr(i).status,:));
                     end
        
            end
        
        end
        
        
        grid on
        if viewLocal
            axis([Crop.x1 Crop.x2 Crop.y1 Crop.y2 alim3d(5:6)]);
        else
            axis(alim3d);
        end
        daspect([1 1 aspRatio])
        view(-25,25)
        axtoolbar(ui.view3d, {'rotate'});
        xlabel('x', 'color', 'w')
        ylabel('y', 'color', 'w')
        zlabel('t', 'color', 'w')
        
        drawnow limitrate
        
    end

% === Controls & infos ====================================================

    function C = getControls()
        
        C = [ ...
            '----- CONTROLS ---------------------------' newline ...
            newline ...
            'VIEW' newline];
        
        if viewLocal
            C = [C '  Global [g]' newline '  Local [l]    #' newline];
        else
            C = [C '  Global [g]   #' newline '  Local [l]' newline];
        end
        
        C = [C '  Size [w...]                  ' num2str(lsz) ' pix' newline ...
            '  Toggle fragments view [F]' newline ...
            '  Toggle trajectories view [T]' newline ...
            '  Toggle quarantine view [Q]' newline ...
            newline ...
            'NAVIGATION' newline ...
            '  Play/pause [space]' newline ...
            '  Frames per second [v...]     ' num2str(fps, '%02i') ' fps' newline ...
            '  Flashback and play [b]' newline ...
            '  Flashback duration [d...]    '  num2str(fbd) ' frames' newline ...
            '  ±1 frame [' char(8592) ',' char(8594) '] (on pause)' newline ...
            '  Rewind [Page down]' newline ...
            newline ...
            'FRAGMENTS' newline ...
            '  Cut [c] (at t-1)' newline ...
            '  Toggle quarantine status [q]' newline ...
            newline ...
            'TRAJECTORIES' newline ...
            '  Include fragment [Left click]' newline ...
            '  Remove fragment [Del]', newline ...
            '  End [' char(8593) ']' newline ...
            '  Beginning [' char(8595) ']' newline ...
            '  Next doublon [n]' newline ...
            '  Flashback last fragment and play [f]' newline ...
            '  Save trajectories [s]' newline ...
            newline ...
            'ASSIGNMENTS [Left click]' newline ...
            ' Time point quarantine' newline ...
            ' Define as soma' newline ...
            ' Define as centrosome' newline ...
            ' Define as cone'];
        
    end

    function updateInfos(c)
                
        % --- Trajectories
        
        switch numel(Trajs)
            case 0, S = 'No trajectory defined.';
            case 1, S = '1 trajectory defined.';
            otherwise, S = [num2str(numel(Trajs)) ' trajectories defined.'];
        end
        S(end+1) = newline;
        
        % --- Current trajectory
        
        switch numel(Traj)
            case 0, S = [S 'No fragment in use.'];
            case 1, S = [S '01 fragment in use. '];
            otherwise, S = [S num2str(numel(Traj)) ' fragments in use.'];
        end
        
        if numel(Traj)
            S = [S ' [ ' sprintf('%i ', Traj) ']'];
        end
        S(end+1) = newline;
        
        % Additional input
        if nargin
            S = [S newline newline c];
        end
            
        ui.info.String = S;
        
    end

    function updateWarnings()
        
        dlim = 15;
        
        W = '';
        
        % --- Check for overlaps ------------------------------------------
        
        T = cat(1,Fr(Traj).t);
        [~,I] = unique(T);
        doublons = unique(T(setdiff(1:numel(T),I)));
        
        if ~isempty(doublons)
        
            W = [W num2str(numel(doublons))];
            
           if numel(doublons) < dlim
               W = [W ' doublons [ ' sprintf('%i ', doublons) ']' newline];
           else
               W = [W ' doublons [ ' sprintf('%i ', doublons(1:dlim)) '...]' newline];
           end
            
        end
        
        ui.warnings.String = W;
        
    end


% === Functions ===========================================================

    function [x, y, k] = getpos(ti, status)
        
        I = find(strcmp({Fr.status}, status));
        x = [];
        y = [];
        k = [];
        
        for i = I
            t_ = find(Fr(i).t==ti);
            if isempty(t_), continue; end
            x(end+1) = Fr(i).soma.pos(t_,1);
            y(end+1) = Fr(i).soma.pos(t_,2);
            k(end+1) = i;
        end

    end

    function b = inImage()
        
        b = Mouse.image(1)>=1 && Mouse.image(1)<=info.Width && ...
            Mouse.image(2)>=1 && Mouse.image(2)<=info.Height;
        
    end

    function mi = findClosest(subset)
        
        if ~exist('subset', 'var')
            subset = 1:numel(Fr);
        elseif ischar(subset)
            subset = find(strcmp({Fr.status}, subset));
        end
        
        if isempty(subset)
            mi = [];
            return
        end
        
        ti = round(get(ui.time, 'Value'));
        x = NaN(numel(subset),1);
        y = NaN(numel(subset),1);
        for i = 1:numel(subset)
            I = ti==Fr(subset(i)).t;
            if ~any(I), continue; end
            x(i) = Fr(subset(i)).soma.pos(I,1);
            y(i) = Fr(subset(i)).soma.pos(I,2);
        end
        [~, mi] = nanmin((x-Mouse.image(1)).^2 + (y-Mouse.image(2)).^2);
    end

    function saveFragments()
        save(FrName, 'Fr');        
    end

    function id = getNextTrajIdx()
       
        Tidx = [Fr(cellfun(@isnumeric, {Fr.status})).status];
        if isempty(Tidx)
            id = 1;
        else
            id = max(Tidx)+1;
        end

    end
end
