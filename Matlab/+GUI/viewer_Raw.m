function Viewer = viewer_Raw(varargin)

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Input ===============================================================

p = inputParser;
addParameter(p, 'Main', [], @(x) true);
addParameter(p, 'dataSource', dataSource, @isstruct);
addParameter(p, 'study', '', @ischar);
addParameter(p, 'run', '', @ischar);
addParameter(p, 'position', [], @isnumeric);
addParameter(p, 'color', [1 1 1], @isnumeric);

parse(p, varargin{:});  
Main = p.Results.Main; 
DS = p.Results.dataSource;
study = p.Results.study;
run = p.Results.run;
position = p.Results.position;
color = p.Results.color;

% =========================================================================

fname = [DS.data study filesep run filesep run '.tiff'];

info = imfinfo(fname);
n = numel(info);

Wmenu = 210;

% --- User interfaace -----------------------------------------------------

% --- Figure

Viewer = findobj('type', 'figure', 'name', mfilename);

if isempty(Viewer)
    Viewer = figure('name', mfilename);
else
    figure(Viewer.Number);
end

clf(Viewer)

% --- Display elements

ui = struct();

% Axis
ui.axes = axes('units', 'pixels', 'Position', [0 0 1 1]);

% Title
ui.title = uicontrol('style', 'text', 'position', [0 0 1 1]);

ui.deco.menu = annotation('rectangle', 'units','pixel', 'FaceColor', 'w');

% --- Control elements

ui.time = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', n, 'value', 1, 'SliderStep', [1 1]./(n-1));

ui.deco.Intfactor = uicontrol('style', 'text', ...
    'string', 'Int. factor', ...
    'backgroundColor', 'w', ...
    'position', [0 0 1 1]);
ui.Intfactor = uicontrol('style', 'edit', ...
    'position', [0 0 1 1], ...
    'string', '1', ...
    'Callback', @updateImage);

% Control size callback
set(Viewer, 'ResizeFcn', @updateControlSize);
updateControlSize();

addlistener(ui.time, 'Value', 'PostSet', @updateImage);
updateImage();

% === Controls ============================================================

    function updateControlSize(varargin)
        
        % --- Figure size       
        tmp = get(Viewer, 'Outerposition');
        W = tmp(3); w = W - Wmenu;
        H = tmp(4);
        
        % --- Integrated version
        
        if ~isempty(Main)

            % --- Window
            
            set(Viewer, 'Menu', 'none', 'ToolBar', 'none', 'color', color);
            if ~isempty(position)
                set(Viewer, 'Position', position);
            end
            h = H-30;
            
            ui.title.BackgroundColor = color;
            ui.title.ForegroundColor = 'w';
            
        else
            
            % --- Window
            set(Viewer, 'WindowStyle', 'docked');
            h = H;
            
        end
        

       
        % --- Main elements        
        
        ui.deco.menu.Position = [0 0 Wmenu h+1];
        ui.axes.Position = [Wmenu+55 75 w-100 h-150];
        ui.time.Position = [Wmenu+10 10 w-15 20];
        ui.title.Position = [Wmenu+w/2-100 h-70 200 20];
        
        % --- Menu
        
        % Magnification
        ui.deco.Intfactor.Position = [10 h-50 100 20];
        ui.Intfactor.Position = [100 h-50 100 20];
        
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
        
        ui.title.String = ['Frame ' num2str(ti)];
        
        drawnow limitrate
        
    end

end
