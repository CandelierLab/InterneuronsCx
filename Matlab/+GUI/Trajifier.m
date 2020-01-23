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

% Stack info
ftiff = [DS.data study filesep run filesep run '.tiff'];
info = imfinfo(ftiff);
n = numel(info);

% % % % Stack memory mapping
% % % Stack = memmapfile([DS.data study filesep run filesep run '.dat'], ...
% % %     'format', {'uint8', [info.Height info.Width n], 'raw'});

fFragments = [DS.data study filesep run filesep 'Files' filesep 'Fragments.mat'];
tmp = load(fFragments);
Fr = tmp.Fr;

% --- User interface ------------------------------------------------------

Ws = 150;

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
ui.image = axes('units', 'pixels', 'Position', [0 0 1 1]);

% Title
ui.title = uicontrol('style', 'text', 'position', [0 0 1 1]);

ui.deco.left = annotation('rectangle', 'units','pixel', 'FaceColor', 'w');
ui.deco.right = annotation('rectangle', 'units','pixel', 'FaceColor', 'w');

% --- Control elements

ui.time = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', n, 'value', 1, 'SliderStep', [1 1]./(n-1));

% Control size callback
set(Viewer, 'ResizeFcn', @updateControlSize);
updateControlSize();

addlistener(ui.time, 'Value', 'PostSet', @updateImage);

set(Viewer, 'KeyPressFcn', @newControl);

updateImage();

% === Controls ============================================================

    function updateControlSize(varargin)
        
        % --- Figure size       
        tmp = get(Viewer, 'Outerposition');
        W = tmp(3); w = W - 2*Ws;
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
        
        ui.deco.left.Position = [0 0 Ws h+1];
        ui.deco.right.Position = [W-Ws 0 Ws h+1];
        
        ui.image.Position = [Ws+50 75 w-100 h-150];
        
        ui.time.Position = [Ws+10 10 w-15 20];
        ui.title.Position = [Ws+w/2-100 h-70 200 20];
        
        % --- Left Panel
        
        
        % --- Right Panel
        
    end

    function newControl(varargin)
        
       varargin{2} 
        
    end

    % === Image ===============================================================

    function updateImage(varargin)
        
        % --- Get values
        
        ti = round(get(ui.time, 'Value'));
        If = 3;
        
        % --- Image -------------------------------------------------------
        
        cla(ui.image)
        hold(ui.image, 'on')

        % Image
        % Img = If*double(Stack.data.raw(:,:,ti))/255;
        Img = If*double(imread(ftiff, ti))/255;
        imshow(Img, 'Parent', ui.image);       
        
        % Objects

%         for i = find(cellfun(@(x) ismember(ti,x), {Fr.t}))
%             j =  find(Fr(i).t==ti);
%             scatter(Fr(i).cell.pos(j,1), Fr(i).cell.pos(j,2), '+', ...
%                 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'm')
%         end
        
        % Misc
        axis(ui.image, 'on', 'tight', 'xy');
        
        ui.title.String = ['Frame ' num2str(ti)];
        
        drawnow limitrate
        
    end

end
