function Viewer = Trajifier(varargin)

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

% --- Data and files ------------------------------------------------------

fRaw = [DS.data study filesep run filesep run '.tiff'];

info = imfinfo(fRaw);
n = numel(info);

fFragments = [DS.data study filesep run filesep 'Files' filesep 'Fragments.mat'];
tmp = load(fFragments);
Fr = tmp.Fr;

% --- User interfaace -----------------------------------------------------

Wmenu = 210;

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
ui.v3d = axes('units', 'pixels', 'Position', [0 0 1 1]);
ui.image = axes('units', 'pixels', 'Position', [0 0 1 1]);

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
    'string', '3', ...
    'Callback', @updateImage);

% Control size callback
set(Viewer, 'ResizeFcn', @updateControlSize);
updateControlSize();

addlistener(ui.time, 'Value', 'PostSet', @updateImage);

update3d();
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
        
        ui.v3d.Position = [Wmenu+55 75 w/2-50 h-150];
        ui.image.Position = [Wmenu+w/2+50 75 w/2-50 h-150];
        
        ui.time.Position = [Wmenu+10 10 w-15 20];
        ui.title.Position = [Wmenu+w/2-100 h-70 200 20];
        
        % --- Menu
        
        % Magnification
        ui.deco.Intfactor.Position = [10 h-50 100 20];
        ui.Intfactor.Position = [100 h-50 100 20];
        
    end

    % === Image ===============================================================

    function update3d(varargin)
    
        cla(ui.v3d);
        hold(ui.v3d, 'on');
                
        % Display fragments
        for k = 1:numel(Fr)
            
            plot3(ui.v3d, Fr(k).cell.pos(:,1), Fr(k).cell.pos(:,2), Fr(k).t, ...
                '-', 'color', [1 1 1]*0.75);
        end
        
        axis(ui.v3d, 'on', 'tight', 'xy')
        daspect(ui.v3d, [1 1 1/5]);
        box(ui.v3d, 'on')
        view(ui.v3d, -35, 30);
        
    end
    
    function updateImage(varargin)
        
        % --- Get values
        
        ti = round(get(ui.time, 'Value'));
        If = str2double(ui.Intfactor.String);
        
        % --- 3D visualization --------------------------------------------
        
%         cla(ui.v3d)
%         hold on
% 

        
        
        % --- Image -------------------------------------------------------
        
        cla(ui.image)
        hold(ui.image, 'on')

        % Image
        Img = If*double(imread(fRaw, ti))/255;
        imshow(Img, 'Parent', ui.image);       
        
        % Objects

        for i = find(cellfun(@(x) ismember(ti,x), {Fr.t}))
            j =  find(Fr(i).t==ti);
            scatter(Fr(i).cell.pos(j,1), Fr(i).cell.pos(j,2), '+', ...
                'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'm')
        end
        
        % Misc
        axis(ui.image, 'on', 'tight', 'xy');
        
        ui.title.String = ['Frame ' num2str(ti)];
        drawnow limitrate
        
    end

end
