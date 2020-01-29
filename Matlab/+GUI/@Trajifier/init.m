function init(this, varargin)
%INIT Trajifier initialization
%   - Figure creation and widget placement
%   - Define callbacks and events

% === Data source =========================================================

DS = dataSource;
this.File.images = [DS.data this.study filesep this.run filesep this.run '.tiff'];
this.File.fragments = [DS.data this.study filesep this.run filesep 'Files' filesep 'Fragments.mat'];

% Get image info
tmp = imfinfo(this.File.images);
this.Images = tmp(1);
this.Images.number = numel(tmp);

% Load fragments
this.loadFragments;

this.tid = this.newTrajId;

% === Figure ==============================================================

% --- Parameters

this.Window.menuWidth = 400;
this.Visu.Color.fragment = [1 1 1]*0.5; %[84 153 199]/255;
this.Visu.Color.selected = [203 67 53]/255;
this.Visu.Color.quarantine = [0.86 0.46 0.2];
this.Visu.frameFormat = ['%0' num2str(ceil(log10(this.Images.number))) 'i'];
this.Visu.aspRatio = this.Images.number/this.Images.Width;
this.Visu.alim3d = [1 this.Images.Height 1 this.Images.Width 1 this.Images.number];

this.Visu.lsz = 150;   % Local size (in pixels) 
this.Visu.fps = 50;
this.Visu.fbd = 20;

% Views
this.Visu.crop = struct('x1', 1, 'x2', this.Images.Width, 'y1', 1, 'y2', this.Images.Height);
this.Visu.viewLocal = false;
this.Visu.viewPlay = false;
this.Visu.viewFrag = true;
this.Visu.viewTraj = true;
this.Visu.viewQuar = false;

% Handles
this.Visu.hFr3 = [];
this.Visu.hQ3 = [];
this.Visu.hTr3 = [];
this.Visu.hTrs3 = {};

% --- Figure

this.Viewer = findobj('type', 'figure', 'name', 'Trajifier');

if isempty(this.Viewer)
    this.Viewer = figure('name', 'Trajifier');
else
    figure(this.Viewer.Number);
end

clf(this.Viewer)

%  --- User Interface -----------------------------------------------------

% --- Axis

this.ui.image = axes('units', 'pixels', 'Position', [0 0 1 1]);
this.ui.view3d = axes('units', 'pixels', 'Position', [0 0 1 1]);

% --- Title

this.ui.title = uicontrol('style', 'text', 'position', [0 0 1 1], ...
    'FontName', 'Courier New', 'FontSize', 12);

% --- Menu

this.ui.menu.shortcuts = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', this.Window.color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

this.ui.menu.shortcuts.String = this.getControls();

% --- Actions

this.ui.action = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', this.Window.color, 'ForegroundColor', 'y', ...
    'position', [0 0 1 1]);

% --- Info

this.ui.info = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', this.Window.color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

this.ui.prepareTime = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', this.Window.color, 'ForegroundColor', [1 1 1]*0.5, ...
    'position', [0 0 1 1]);

% --- Warnings

this.ui.warnings = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, 'HorizontalAlignment', 'left', ...
    'backgroundColor', this.Window.color, 'ForegroundColor', this.Visu.Color.quarantine, ...
    'position', [0 0 1 1]);

% --- Controls ------------------------------------------------------------

Input = struct('active', false, 'command', '', 'buffer', '');

% --- Intensity factor

this.ui.menu.Intfactor = uicontrol('style', 'text', ...
    'string', 'Intensity factor', 'FontName', 'Courier New', 'FontSize', 11, ...
    'backgroundColor', this.Window.color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

this.ui.Intfactor = uicontrol('style', 'edit', ...
    'position', [0 0 1 1], ...
    'string', num2str(this.Visu.intensityFactor), 'FontName', 'Courier New', 'FontSize', 11, ...
    'Callback', @this.updateDisplay);

% --- Time

this.ui.time = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', this.Images.number, 'value', 1, 'SliderStep', [1 1]./(this.Images.number-1));

% --- Context menu

this.Visu.cMenu = uicontextmenu(this.Viewer);

% Create child menu items for the uicontextmenu
uimenu(this.Visu.cMenu, 'Label', 'soma', 'Callback', @contextMenu);
uimenu(this.Visu.cMenu, 'Label', 'centrosome', 'Callback', @contextMenu);
uimenu(this.Visu.cMenu, 'Label', 'cone', 'Callback', @contextMenu);

% --- Listeners

this.Viewer.ResizeFcn = @this.updateWindowSize;
this.Viewer.Position = this.Window.position;
this.Viewer.KeyPressFcn = @keyInput;
this.Viewer.WindowButtonDownFcn = @mouseClick;
this.Viewer.WindowButtonMotionFcn = @mouseMove;
addlistener(this.ui.time, 'Value', 'PostSet', @this.updateDisplay);

this.updateInfos();
this.prepareDisplay('reset', "traj");
this.updateDisplay();

    % === GUI nested functions ============================================
    
    function mouseMove(varargin)
       
        tmp = get(this.ui.image, 'CurrentPoint');
        this.mousePosition.image = [tmp(1,1) tmp(1,2)];
        
        tmp = get(this.ui.view3d, 'CurrentPoint');
        this.mousePosition.view3d = [tmp(1,1) tmp(1,2)];
        
    end

    function mouseClick(varargin)
        
        switch this.Viewer.SelectionType
            
            case 'normal'
                this.input('leftClick');
                
            case 'extend'
                this.input('middleClick');
                
            case 'alt'
                % Right click: nothing to do (context menu)
                
        end
        
    end

    function contextMenu(varargin)
       
        this.input(varargin{1}.Text);
        this.ui.action.String = varargin{1}.Text;
                
    end

    function keyInput(varargin)
       
        event = varargin{2};
        % this.ui.action.String = [event.Character '/' event.Key];

        if Input.active
        
            switch event.Key
                
                case 'return'                       
                    this.input(Input.command, str2double(Input.buffer));
                    Input.active = false;
                    Input.command = '';
                    Input.buffer = '';
                    
                otherwise
                    Input.buffer(end+1) = event.Character;
            end
            
        else
            
            if ismember(event.Character, {'d', 'v', 'w'})
                Input.active = true;
                Input.command = event.Character;
                return
            end
            
            if ismember(event.Key, {'leftarrow', 'rightarrow', 'uparrow', ...
                    'downarrow', 'pagedown', 'delete'})
                this.input(event.Key);
            else
                this.input(event.Character);
            end
            
        end
        
    end
end
