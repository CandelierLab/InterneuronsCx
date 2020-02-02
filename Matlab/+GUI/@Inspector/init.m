function init(this, varargin)
%INIT Trajifier initialization
%   - Figure creation and widget placement
%   - Define callbacks and events

% === Data source =========================================================

DS = dataSource;
this.File.images = [DS.data this.study filesep this.run filesep this.run '.tiff'];
this.File.shapes = [DS.data this.study filesep this.run filesep 'Files' filesep 'Shapes.mat'];
this.File.fragments = [DS.data this.study filesep this.run filesep 'Files' filesep 'Fragments.mat'];

% Get image info
tmp = imfinfo(this.File.images);
this.Images = tmp(1);
this.Images.number = numel(tmp);

% Load shapes
this.loadShapes;

% Cells
this.Cell = struct('t', {}, 'idx', {}, 'soma', {}, 'centrosome', {}, 'cones', {});

% === Figure ==============================================================

% --- Parameters

this.Window.menuWidth = 400;
this.Visu.Color.shape = [84 153 199]/255;
% this.Visu.Color.selected = [203 67 53]/255;
% this.Visu.Color.quarantine = [0 0 0];
this.Visu.frameFormat = ['%0' num2str(ceil(log10(this.Images.number))) 'i'];
this.Visu.fps = 50;

% Views
this.Visu.viewPlay = false;

% Handles
% this.Visu.hFr3 = [];

% --- Figure

this.Viewer = findobj('type', 'figure', 'name', 'Inspector');

if isempty(this.Viewer)
    this.Viewer = figure('name', 'Inspector');
else
    figure(this.Viewer.Number);
end

clf(this.Viewer)

%  --- User Interface -----------------------------------------------------

% --- Axis

this.ui.image = axes('units', 'pixels', 'Position', [0 0 1 1]);

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
    'min', 1, 'max', this.Images.number, 'value', 1, 'SliderStep', [1 1]./(this.Images.number-1), ...
    'visible', false);

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

this.initShapes();
this.updateInfos();
this.updateDisplay();

    % === GUI nested functions ============================================
    
    function mouseMove(varargin)
       
        tmp = get(this.ui.image, 'CurrentPoint');
        this.mousePosition.image = [tmp(1,1) tmp(1,2)];
        
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
                
    end

    function keyInput(varargin)
       
        event = varargin{2};

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
            
            if ismember(event.Character, {'d', 'r', 'v', 'w'})
                Input.active = true;
                Input.command = event.Character;
                return
            end
            
            if ismember(event.Key, {'leftarrow', 'rightarrow', 'uparrow', ...
                    'downarrow', 'pageup', 'pagedown', 'delete'})
                this.input(event.Key);
            else
                this.input(event.Character);
            end
            
        end
        
    end
end
