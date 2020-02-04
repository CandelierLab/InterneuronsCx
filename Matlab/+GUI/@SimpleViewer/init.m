function init(this, varargin)
%INIT Viewer initialization
%   - Figure creation and widget placement
%   - Define callbacks and events

% === Data source =========================================================

DS = dataSource;
this.File.images = [DS.data this.study filesep this.run filesep this.run '.tiff'];

% Get image info
tmp = imfinfo(this.File.images);
this.Images = tmp(1);
this.Images.number = numel(tmp);

% === Figure ==============================================================

% --- Parameters

this.Window.menuWidth = 400;
this.Visu.frameFormat = ['%0' num2str(ceil(log10(this.Images.number))) 'i'];

this.Visu.fps = 50;

% Views
this.Visu.viewPlay = false;

% --- Figure

this.Viewer = findobj('type', 'figure', 'name', 'Viewer');

if isempty(this.Viewer)
    this.Viewer = figure('name', 'Viewer');
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

% --- Controls ------------------------------------------------------------

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

% --- Listeners

this.Viewer.ResizeFcn = @this.updateWindowSize;
this.Viewer.Position = this.Window.position;
this.Viewer.KeyPressFcn = @keyInput;
addlistener(this.ui.time, 'Value', 'PostSet', @this.updateDisplay);

this.updateDisplay();

    % === GUI nested functions ============================================

    function keyInput(varargin)
       
        event = varargin{2};
        
        if ismember(event.Key, {'leftarrow', 'rightarrow', 'uparrow', ...
                'downarrow', 'pageup', 'pagedown', 'delete'})
            this.input(event.Key);
        else
            this.input(event.Character);
        end
        
    end
end
