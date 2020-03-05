function init(this, varargin)
%INIT Inspector initialization
%   - Figure creation and widget placement
%   - Define callbacks and events

% === Data source =========================================================

DS = dataSource;
this.File.images = [DS.data this.study filesep this.run filesep this.run '.tiff'];
this.File.red = [DS.data this.study filesep this.run filesep this.run '_R.tiff'];
this.File.shapes = [DS.data this.study filesep this.run filesep 'Files' filesep 'Shapes.mat'];
this.File.cells = [DS.data this.study filesep this.run filesep 'Files' filesep 'Cells.mat'];
this.File.data = [DS.data this.study filesep this.run filesep 'Files' filesep 'Display.tiff'];

% Get image info
tmp = imfinfo(this.File.images);
this.Images = tmp(1);
this.Images.number = numel(tmp);

% === Figure ==============================================================

% --- Parameters

this.Window.menuWidth = 400;
this.Visu.frameFormat = ['%0' num2str(ceil(log10(this.Images.number))) 'i'];

% Views
this.Visu.viewPlay = false;

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

% --- Time

this.ui.time = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', this.Images.number, 'value', 1, 'SliderStep', [1 1]./(this.Images.number-1), ...
    'Callback', @this.reloadDisplay);

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

% === Data ================================================================

% Load shapes & cells
this.load;

% Raw image file
this.Raw = Tiff(this.File.images, 'r');
if exist(this.File.red, 'file')
    this.Red = Tiff(this.File.red, 'r');
end

% Get data fid
this.Visu.tagstruct = struct('ImageLength', this.Images.Height, ...
    'ImageWidth', this.Images.Width, ...
    'Photometric', Tiff.Photometric.RGB, ...
	'BitsPerSample', 8, ...
	'SamplesPerPixel', 3, ...
	'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
    'Software', 'GUI.Inspector');

if ~exist(this.File.data, 'file')
    this.prepareAllDisplay;
else
    this.Data = Tiff(this.File.data, 'r+');
end

this.Data = Tiff(this.File.data, 'r+');

this.loadTime();
this.updateDisplay();
this.updateInfos();

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
                this.input('rightClick');
                
        end
        
    end

    function keyInput(varargin)
       
        event = varargin{2};
    
        if ismember(event.Key, {'leftarrow', 'rightarrow', 'uparrow', ...
                'downarrow', 'pageup', 'pagedown', 'return', 'delete'})
            this.input(event.Key);
        else
            this.input(event.Character);
        end
        
    end
end
