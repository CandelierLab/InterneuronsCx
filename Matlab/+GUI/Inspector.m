function Viewer = Inspector(varargin)

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

fname = [DS.data study filesep run filesep run '.tiff'];

info = imfinfo(fname);
n = numel(info);
frameFormat = ['%0' num2str(ceil(log10(n))) 'i'];

Wmenu = 400;
Winfo = 400;

% --- User interfaace -----------------------------------------------------

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

ui.axes = axes('units', 'pixels', 'Position', [0 0 1 1]);

% --- Title

ui.title = uicontrol('style', 'text', 'position', [0 0 1 1], ...
    'FontName', 'Courier New', 'FontSize', 12);

% --- Side panels

ui.menu.shortcuts = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

ui.info = uicontrol('style', 'text', ...
    'FontName', 'Courier New', 'FontSize', 11, ...
    'backgroundColor', color, 'ForegroundColor', 'w', ...
    'position', [0 0 1 1]);

ui.menu.shortcuts.String = '                                          ';
ui.info.String = '                                          ';

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

% --- Listeners

set(Viewer, 'ResizeFcn', @updateControlSize);
set(Viewer, 'Position', position);

addlistener(ui.time, 'Value', 'PostSet', @updateImage);
updateImage();

% === Controls ============================================================

    function updateControlSize(varargin)
        
        % --- Figure size       
        tmp = get(Viewer, 'Outerposition');
        W = tmp(3);
        H = tmp(4);
        w = W - Wmenu - Winfo;
        
        % --- Window
            
        set(Viewer, 'Menu', 'none', 'ToolBar', 'none', 'color', color);
        if ~isempty(position)
            set(Viewer, 'Position', position);
        end
        h = H-30;
        
        % --- Structure elements
        
        ui.axes.Position = [Wmenu+55 75 w-100 h-150];
        ui.time.Position = [Wmenu+10 10 w-15 20];
        ui.title.Position = [Wmenu+w/2-100 h-70 200 20];
        
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
               
        ui.info.Position = [W-Winfo-10 10 380 h-80];
        
    end

% === Image ===============================================================

    function updateImage(varargin)
        
        % --- Get values
        
        ti = round(get(ui.time, 'Value'));
        If = str2double(ui.Intfactor.String);
                  
        % --- Image
        
        Img = If*double(imread(fname, ti))/255;
        
        % --- Display
        
        cla
        hold on

        imshow(Img);
        
        axis xy tight
        
        ui.title.String = ['Frame ' num2str(ti, frameFormat) ' / ' num2str(n)];
        
        drawnow limitrate
        
    end

end

