function main(varargin)

clc
close all
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

% === Parameters ==========================================================

% Debug / production status
prod = false;

% Intensity factor
intFactor = 3;

% Tracking
maxDist = 40;
maxTime = 10;
filtNumel = [5 Inf];

% GUI
Wheight = 50;

% Wcolor = [33 47 60]/255;    % Dark blue
% Wcolor = [84 153 199]/255;  % Blue
Wcolor = [0 0 0];  % Black

% =========================================================================

% --- Shared variables ----------------------------------------------------

DS = dataSource;
study = '';
run = '';

fPath = '';
fRaw = '';
fShapes = '';
fCells = '';
fFragments = '';
fTrajectories = '';

lImg = [];
Nimg = NaN;
Bkg = [];

% --- Studies -------------------------------------------------------------

D = dir(DS.data);
D(1:2) = [];
Studies = {D.name};

% --- User interface ------------------------------------------------------

vMain = figure('Name', 'Main', 'Menu', 'none', 'ToolBar', 'none');
vViewer = [];

% --- Position and appearance

set(0,'units','pixels') ;
monitors = get(0, 'MonitorPositions');
screen = monitors(1,:);
pos = [screen(1) screen(4)-Wheight+1 screen(3) Wheight];

switch computer
    case 'PCWIN64'
        Hbar = 41;
        viewPos = [screen(1) Hbar screen(3) screen(4)-Wheight-Hbar];
    case 'GLNXA64'
        viewPos = [screen(1) 0 screen(3) screen(4)-3*Wheight];
end
set(vMain, 'Position', pos);
set(vMain, 'color', Wcolor);

% --- Keep main window always on top

if true
    
    warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')
    drawnow expose
    jFrame = get(handle(vMain),'JavaFrame');
    drawnow
    jFrame_fHGxClient = jFrame.fHG2Client;
    jFrame_fHGxClient.getWindow.setAlwaysOnTop(true);
    
end

% --- Minimize Matlab window

if prod
    
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance();
    desktop.getMainFrame().setMinimized(true);
    
end

% --- Controls

pstudy = uicontrol('style', 'popupmenu', ...
    'position', [10 15 150 20], ...
    'string', Studies, 'FontName', 'Courier New', 'FontSize', 10, ...
    'Callback', @updateStudy, ...
    'Value', 1);

prun = uicontrol('style', 'popupmenu', ...
    'position', [170 15 150 20], ...
    'string', {'-'}, 'FontName', 'Courier New', 'FontSize', 10, ...
    'Callback', @updateRun, ...
    'Value', 1);

bviewer = uicontrol('style', 'togglebutton', ...
    'position', [330 15 100 24], ...
    'Callback', @cViewer, ...
    'string', 'Viewer', 'FontName', 'Courier New', 'FontSize', 10);

bdetect = uicontrol('style', 'pushbutton', ...
    'position', [440 15 100 24], ...
    'Callback', @cDetection, ...
    'string', 'Detection', 'FontName', 'Courier New', 'FontSize', 10);

binspect = uicontrol('style', 'togglebutton', ...
    'position', [550 15 100 24], ...
    'Callback', @cInspector, ...
    'string', 'Inspector', 'FontName', 'Courier New', 'FontSize', 10);

btrack = uicontrol('style', 'pushbutton', ...
    'position', [660 15 100 24], ...
    'Callback', @cTracking, ...
    'string', 'Tracking', 'FontName', 'Courier New', 'FontSize', 10);

btraj = uicontrol('style', 'togglebutton', ...
    'position', [770 15 100 24], ...
    'Callback', @cTrajifier, ...
    'string', 'Trajifier', 'FontName', 'Courier New', 'FontSize', 10);

% --- Initialization

updateStudy();

% ### Controls ############################################################

    % =====================================================================
    function updateStudy(varargin)
        
        % --- Study & run
        
        study = pstudy.String{pstudy.Value};
        
        D = dir([DS.data study filesep]);
        D(1:2) = [];
        prun.String = {D.name};
        
        updateRun();
        
    end

    % =====================================================================
    function updateRun(varargin)
        
        run = prun.String{prun.Value};
        
        % --- Files
        
        fPath = [DS.data study filesep run filesep 'Files' filesep];
        fRaw = [DS.data study filesep run filesep run '.tiff'];
        fShapes = [fPath 'Shapes.mat'];
        fCells = [fPath 'Cells.mat'];
        fFragments = [fPath 'Fragments.mat'];
        fTrajectories = [fPath 'Trajectories.mat'];
        
        % --- Image processing
        
        info = imfinfo(fRaw);
        Nimg = numel(info);
        
        lImg = @(i) double(imread(fRaw, i))/255;
        Bkg = IP.Bkg.(study)(lImg(1));
        
        % --- Checks ------------------------------------------------------
        
        % --- Create Files/
        
        if ~exist(fPath, 'file')
            mkdir(fPath);
        end
        
        % --- Check run.tiff
        
        if exist(fRaw, 'file')
            bviewer.Enable = 'on';
            bdetect.Enable = 'on';
        else
            bviewer.Enable = 'off';
            bdetect.Enable = 'off';
        end
        
        % --- Check Shapes.mat
        
        if exist(fShapes, 'file')
            binspect.Enable = 'on';
        else
            binspect.Enable = 'off';
        end
        
        % --- Check Cells.mat
        
        if exist(fCells, 'file')
            btrack.Enable = 'on';
        else
            btrack.Enable = 'off';
        end
        
        % --- Check Fragments.mat
        
        if exist(fFragments, 'file')
            btraj.Enable = 'on';
        else
            btraj.Enable = 'off';
        end
        
        closeViewer();
        
    end

    % =====================================================================
    function closeViewer()
        
        if ~isempty(vViewer)
            close(vViewer.Viewer);
            vViewer = [];
        end
        
    end

    % =====================================================================
    function cViewer(varargin)
        
         if isempty(vViewer)
            
            % Define Viewer object
            vViewer = GUI.SimpleViewer;
            assignin('base', 'this', vViewer);
            
            % Properties
            vViewer.study = study;
            vViewer.run = run;
            vViewer.Window.position = viewPos;
            vViewer.Window.color = Wcolor;
            vViewer.Visu.intensityFactor = intFactor;
            
            % Init viewer
            vViewer.init;
            
        else
            closeViewer();
        end

        
    end
    
    % =====================================================================
    function cDetection(varargin)

        closeViewer();

        % --- Checks
        
        if exist(fShapes, 'file')
           
            answer = questdlg('Shapes.mat already exists. Overwrite?', ...
                'Warning', 'Yes', 'No', 'No');
            
            if strcmp(answer, 'No')
                return; 
            end
            
        end
        
        % --- Processing
        
        Shape = struct('t', {}, 'idx', {});
        wb = waitbar(0, '', 'Name', 'Detection');

        for i = 1:Nimg
        
            Img = lImg(i);
        
            % --- Processing
            B = IP.(study)(Img - Bkg);
            
            for j = 1:numel(B)
               
                k = numel(Shape)+1;                
                Shape(k).t = i;
                Shape(k).idx = B(j).idx;
                
            end
        
            % Update waitbar and message
            waitbar(i/Nimg, wb, sprintf('Detection %i / %i', i, Nimg));

        end
        
        % --- Save
        
        waitbar(1, wb, 'Saving');
        save(fShapes, 'Shape');
        
        close(wb);
        updateRun();
        
    end

    % =====================================================================
    function cInspector(varargin)
        
        if isempty(vViewer)
            
            % Define Viewer object
            vViewer = GUI.Inspector;
            assignin('base', 'this', vViewer);
            
            % Properties
            vViewer.study = study;
            vViewer.run = run;
            vViewer.Window.position = viewPos;
            vViewer.Window.color = Wcolor;
            vViewer.Visu.intensityFactor = intFactor;
            
            % Init viewer
            vViewer.init;
            
        else
            closeViewer();
        end

    end

    % =====================================================================
    function cTracking(varargin)

        clc
        closeViewer();
        
        % --- Checks
        
        if exist(fFragments, 'file')
           
            answer = questdlg('Fragments.mat already exists. Overwrite?', ...
                'Warning', 'Yes', 'No', 'No');
            
            if strcmp(answer, 'No')
                return; 
            end
            
        end
        
        % --- Preparation -------------------------------------------------
        
        wb = waitbar(0, 'Tracking', 'Name', 'Tracking');
        waitbar(0, wb, 'Loading');
        
        tmp = load(fCells);
        Cell = tmp.Cell;
        
        % --- Tracking ----------------------------------------------------
        
        Tr = Tracking.Tracker;
    
        Tr.parameter('pos', 'max', maxDist);

        Tr.parameter('all', 'active', false);
        Tr.parameter('soma', 'active', false);
        Tr.parameter('centrosome', 'active', false);
        Tr.parameter('cones', 'active', false);
        
        empty = struct('idx', [], 'pos', struct('x', NaN, 'y', NaN), 'contour', struct('x', NaN, 'y', NaN));
        
        % --- Tracking
        
        T = [Cell.t];
        
        for i = 1:T(end)
            
            % --- Preparation
            Idx = find(T==i);
            n = numel(Idx);
            
            % --- Positions
            
            P = NaN(n,2);
            for k = 1:n

                % Positions
                if ~isempty(Cell(Idx(k)).soma)
                    P(k,:) = [Cell(Idx(k)).soma.pos.x Cell(Idx(k)).soma.pos.y];
                elseif ~isempty(Cell(Idx(k)).centrosome)
                    P(k,:) = [Cell(Idx(k)).centrosome.pos.x Cell(Idx(k)).centrosome.pos.y];
                else
                    P(k,:) = [Cell(Idx(k)).all.pos.x Cell(Idx(k)).all.pos.y];
                end
                
                % Fill in empty structures
                if isempty(Cell(Idx(k)).soma), Cell(Idx(k)).soma = empty; end
                if isempty(Cell(Idx(k)).centrosome), Cell(Idx(k)).centrosome = empty; end
                if isempty(Cell(Idx(k)).cones), Cell(Idx(k)).cones = empty; end
                
            end
            
            % --- Parameters
            
            % Active parameters            
            Tr.set('pos', P);
            
            % Passive parameters
            Tr.set('all', [Cell(Idx).all]');
            Tr.set('soma', [Cell(Idx).soma]');
            Tr.set('centrosome', [Cell(Idx).centrosome]');
            Tr.set('cones', {Cell(Idx).cones}');
            
            Tr.match('method', 'fast', 'verbose', false);
            
            % Waitbar            
            if ~mod(i, round(T(end)/100)), waitbar(i/T(end), wb, 'Tracking'); end
            
        end
        
        % --- Assemble
        
        waitbar(1, wb, 'Assembling');
        Tr.assemble('method', 'fast', 'max', maxTime, 'norm', 1, 'verbose', false);
        
        % --- Filter
        
        waitbar(1, wb, 'Filtering');
        Tr.filter('numel', filtNumel);
        
        % --- Convert
        
        waitbar(1, wb, 'Converting');
        
        Fr = struct('status', {}, 't', {}, 'all', {}, 'soma', {}, 'centrosome', {}, 'cones', {});
        Nt = numel(Tr.traj);
        for i = 1:Nt
            
            Fr(i).status = 'unused';
            Fr(i).t = Tr.traj(i).t;
            
            Fr(i).all = Tr.traj(i).all;
            Fr(i).soma = Tr.traj(i).soma;
            Fr(i).centrosome = Tr.traj(i).centrosome;
            Fr(i).cones = Tr.traj(i).cones;
                        
            % Waitbar
            waitbar(i/Nt, wb);
            
        end
        
        % --- Save
        
        waitbar(1, wb, 'Saving');
        save(fFragments, 'Fr');
        
        close(wb)
        updateRun();
        
        assignin('base', 'Fr', Fr)
        
    end

    % =====================================================================
    function cTrajifier(varargin)

        if isempty(vViewer)

            % Define Viewer object
            vViewer = GUI.Trajifier;
            assignin('base', 'this', vViewer);
            
            % Properties
            vViewer.study = study;
            vViewer.run = run;
            vViewer.Window.position = viewPos;
            vViewer.Window.color = Wcolor;
            vViewer.Visu.intensityFactor = intFactor;

            % Init viewer
            vViewer.init;
            
        else
            closeViewer();
        end
        
    end

end