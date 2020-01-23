function Viewer = Trajifier(varargin)

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
Fcolor = [84 153 199]/255;

info = imfinfo(fName);
n = numel(info);
frameFormat = ['%0' num2str(ceil(log10(n))) 'i'];
aspRatio = n/info(1).Width;
alim3d = [1 info(1).Height 1 info(1).Width 1 n];

viewPlay = false;
viewFrag = true;
viewTraj = true;
viewQuar = true;

% --- Load Fragments ------------------------------------------------------

tmp = load(FrName);
Fr = tmp.Fr;

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
axtoolbar(ui.view3d, {'rotate', 'restoreview'});

% --- Title

ui.title = uicontrol('style', 'text', 'position', [0 0 1 1], ...
    'FontName', 'Courier New', 'FontSize', 12);

% --- Side panels

ui.menu.shortcuts = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

ui.menu.shortcuts.String = [ ...
    '----- CONTROLS ---------------------------' newline ...
    newline ...
    'VIEW' newline ...
    '  Global [g]' newline ...
    '  Local [l]' newline ...
    '  Size [w...]' newline ...
    '  Toggle fragments view [F]' newline ...
    '  Toggle trajectories view [T]' newline ...
    '  Toggle quarantine view [Q]' newline ...
    newline ...
    'NAVIGATION' newline ...
    '  Play/pause [space]' newline ...
    '  Frames per second [v...]' newline ...
    '  Flashback and play [b]' newline ...
    '  Flashback duration [d...]' newline ...
    '  ±1 frame [' char(hex2dec('2190')) ',' char(hex2dec('2192')) ']' newline ...
    '  Rewind [Ctrl+' char(hex2dec('2193')) ']' newline ...
    newline ...
    'TRAJECTORIES' newline ...
    '  End [' char(hex2dec('2191')) ']' newline ...
    '  Beginning [' char(hex2dec('2193')) ']' newline ...
    '  Include fragment [Left click]' newline ...
    '  Remove fragment [Del]', newline ...
    '  Flashback last fragment and play [f]' newline ...
    '  Toggle quarantine status [q]' newline ...
    newline ...
    'ASSIGNMENTS [Left click]' newline ...
    ' Time point quarantine' newline ...
    ' Define as cell' newline ...
    ' Define as soma' newline ...
    ' Define as centrosome' newline ...
    ' Define as cone' newline ...
    newline ...
    'INTERFACE' newline ...
    '  Save trajectories [s]' newline ...
    ];

ui.info = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

ui.info.String = 'Some info ...';

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
uimenu(cMenu, 'Label', 'cell', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'soma', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'centrosome', 'Callback', @rightClick);
uimenu(cMenu, 'Label', 'cone', 'Callback', @rightClick);

% --- Listeners

set(Viewer, 'ResizeFcn', @updateControlSize);
set(Viewer, 'Position', position);
set(Viewer, 'KeyPressFcn', @keyInput);

addlistener(ui.time, 'Value', 'PostSet', @updateImage);

updateImage();
update3dview();

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
        ui.view3d.Position = [Wmenu+730 235 700 700];
        
        % --- Time
        
        ui.time.Position = [Wmenu+20 200 700 20];
        ui.title.Position = [Wmenu+10 h-50 680 20];
        
        % --- Menu
        
        % Intensity factor
        ui.menu.Intfactor.Position = [10 h-50 200 20];
        ui.Intfactor.Position = [210 h-50 50 25];
        
        % Shortcuts
        ui.menu.shortcuts.Position = [10 10 380 h-80];
                
        % --- Title
        
        ui.title.BackgroundColor = color;
        ui.title.ForegroundColor = 'w';
        
        % --- Info
               
        ui.info.Position = [Wmenu+20 10 W-Wmenu-30 150];
        
    end
    
    % --- KEY INPUTS ------------------------------------------------------

    function keyInput(varargin)
       
        event = varargin{2};
        ui.info.String = event.Character;
        
        switch event.Character
            
            case ' '
                viewPlay = ~viewPlay;
                if viewPlay
                    updateImage();
                end
                
            case 'F'
                viewFrag = ~viewFrag;
                update3dview;
                
            case 'T'
                viewTraj = ~viewTraj;
                update3dview;
                
            case 'Q'
                viewQuar = ~viewQuar;
                update3dview;
        end
        
    end

    % --- LEFT CLICK ------------------------------------------------------

    function leftClick(varargin)
       
        get(ui.image, 'CurrentPoint');
        ui.info.String = 'L Click';
        
        % Check that click is inside height x width
        
    end

    % --- RIGHT CLICK -----------------------------------------------------

    function rightClick(varargin)
       
        varargin{1}.Text;
        get(ui.image, 'CurrentPoint');
        
        ui.info.String = 'R Click';
        
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
        cla(ui.image)
        hold(ui.image, 'on');

        h = imshow(Img);
        
        % Callbacks
        h.ButtonDownFcn = @leftClick;
        h.UIContextMenu = cMenu;
        
        axis xy tight        
        ui.title.String = ['Frame ' num2str(ti, frameFormat) ' / ' num2str(n)];                
        drawnow limitrate
        
        if viewPlay
            if ti==ui.time.Max
                ui.time.Value = ui.time.Min;
            else
                ui.time.Value = ti+1;
            end
            updateImage(varargin{:});
        end
        
    end

% === 3D view =============================================================

    function update3dview(varargin)
        
        % --- 3D view -----------------------------------------------------
        
        set(Viewer, 'CurrentAxes', ui.view3d);
        cla(ui.view3d)
        hold(ui.view3d, 'on');
        
        % --- Fragments
        if viewFrag
            
            I = find(strcmp({Fr.status}, 'unused'));
            for i = I
                plot3(Fr(i).cell.pos(:,1), Fr(i).cell.pos(:,2), Fr(i).t, ...
                    '-', 'color', Fcolor);
            end
        
        end
        
        grid on
        axis(alim3d);
        daspect([1 1 aspRatio])
        view(65,25)
        
    end

end

