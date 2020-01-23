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
    'Value', 2);

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
            btrack.Enable = 'on';
        else
            binspect.Enable = 'off';
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
        
        close(vViewer)
        vViewer = [];
        
    end

    % =====================================================================
    function cViewer(varargin)
        
        if isempty(vViewer)
            vViewer = GUI.viewer_Raw('Main', vMain, 'study', study, 'run', run, ...
                'color', Wcolor, 'position', viewPos, 'intensityFactor', intFactor);
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
        
        Shapes = struct('t', {}, 'cell', {}, 'soma', {}, 'centrosome', {}, 'cone', {});
        empty = struct('idx', [], 'pos', NaN(1,2), 'fluo', NaN);
        wb = waitbar(0, '', 'Name', 'Detection');

        for i = 1:Nimg
        
            Img = lImg(i);
        
            % --- Processing
            B = IP.(study)(Img - Bkg);
            
            for j = 1:numel(B)
               
                k = numel(Shapes)+1;                
                Shapes(k).t = i;
                Shapes(k).cell = B(j);
                Shapes(k).soma = empty;
                Shapes(k).centrosome = empty;
                Shapes(k).cone = empty;
                
            end
        
            % Update waitbar and message
            waitbar(i/Nimg, wb, sprintf('Detection %i / %i', i, Nimg));

        end
        
        % --- Save
        
        waitbar(1, wb, 'Saving');
        save(fShapes, 'Shapes');
        
        close(wb);
        updateRun();
        
    end

    % =====================================================================
    function cInspector(varargin)
        
        if isempty(vViewer)
            vViewer = GUI.Inspector('Main', vMain, 'study', study, 'run', run, ...
                'color', Wcolor, 'position', viewPos, 'intensityFactor', intFactor);
        else
            closeViewer();
        end
        
    end

    % =====================================================================
    function cTracking(varargin)

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
                
        tmp = load(fShapes);
        Shapes = tmp.Shapes;
        
        % --- Tracking ----------------------------------------------------
        
        wb = waitbar(0, 'Tracking', 'Name', 'Tracking');
    
        Tr = Tracking.Tracker;
    
%         Tr.parameter('cell_pos', 'hard', 'n1', 'max', maxDist);
        Tr.parameter('cell_pos', 'max', maxDist);

        Tr.parameter('cell_idx', 'active', false);
        Tr.parameter('cell_fluo', 'active', false);
        Tr.parameter('soma_idx', 'active', false);
        Tr.parameter('soma_pos', 'active', false);
        Tr.parameter('soma_fluo', 'active', false);
        Tr.parameter('centrosome_idx', 'active', false);
        Tr.parameter('centrosome_pos', 'active', false);
        Tr.parameter('centrosome_fluo', 'active', false);
        Tr.parameter('cone_idx', 'active', false);
        Tr.parameter('cone_pos', 'active', false);
        Tr.parameter('cone_fluo', 'active', false);

        % --- Tracking
        
        T = [Shapes.t];
        
        for i = 1:T(end)
            
            % --- Preparation
            Idx = find(T==i);
            n = numel(Idx);
            
            Cell = [Shapes(Idx).cell];
            Soma = [Shapes(Idx).soma];
            Centrosome = [Shapes(Idx).centrosome];
            Cone = [Shapes(Idx).cone];
            
            % --- Parameters
            
            % Active parameters            
            Tr.set('cell_pos', reshape([Cell.pos], [2 n])');
            
            % Passive parameters
            Tr.set('cell_idx', {Cell.idx}');
            Tr.set('cell_fluo', [Cell.fluo]');
            Tr.set('soma_idx', {Soma.idx}');
            Tr.set('soma_pos', reshape([Soma.pos], [2 n])');
            Tr.set('soma_fluo', [Soma.fluo]');
            Tr.set('centrosome_idx', {Centrosome.idx}');
            Tr.set('centrosome_pos', reshape([Centrosome.pos], [2 n])');
            Tr.set('centrosome_fluo', [Centrosome.fluo]');
            Tr.set('cone_idx', {Cone.idx}');
            Tr.set('cone_pos', reshape([Cone.pos], [2 n])');
            Tr.set('cone_fluo', [Cone.fluo]');
            
            Tr.match('method', 'fast', 'verbose', false);
            
            % Waitbar            
            if ~mod(i, round(T(end)/100)), waitbar(i/T(end), wb); end
            
        end
        
        % --- Assemble
        
        waitbar(1, wb, 'Assembling');
        Tr.assemble('method', 'fast', 'max', maxTime, 'norm', 1, 'verbose', false);
        
        % --- Filter
        
        waitbar(1, wb, 'Filtering');
        Tr.filter('numel', filtNumel);
        
        % --- Convert
        
        waitbar(1, wb, 'Converting');
        
        Fr = struct('status', {}, 't', {}, 'cell', {}, 'soma', {}, 'centrosome', {}, 'cone', {});
        Nt = numel(Tr.traj);
        for i = 1:Nt
            
            Fr(i).status = 'unused';
            Fr(i).t = Tr.traj(i).t;
            
            Fr(i).cell.idx = Tr.traj(i).cell_idx;
            Fr(i).cell.pos = Tr.traj(i).cell_pos;
            Fr(i).cell.fluo = Tr.traj(i).cell_fluo;
            
            Fr(i).soma.idx = Tr.traj(i).soma_idx;
            Fr(i).soma.pos = Tr.traj(i).soma_pos;
            Fr(i).soma.fluo = Tr.traj(i).soma_fluo;
            
            Fr(i).centrosome.idx = Tr.traj(i).centrosome_idx;
            Fr(i).centrosome.pos = Tr.traj(i).centrosome_pos;
            Fr(i).centrosome.fluo = Tr.traj(i).centrosome_fluo;
            
            Fr(i).cone.idx = Tr.traj(i).cone_idx;
            Fr(i).cone.pos = Tr.traj(i).cone_pos;
            Fr(i).cone.fluo = Tr.traj(i).cone_fluo;
            
            % Waitbar            
            waitbar(i/Nt, wb);
            
        end
        
        % --- Save
        
        waitbar(1, wb, 'Saving');
        save(fFragments, 'Fr');
        
        close(wb)
        updateRun();
        
    end

    % =====================================================================
    function cTrajifier(varargin)

        if isempty(vViewer)
            vViewer = GUI.Trajifier('Main', vMain, 'study', study, 'run', run, ...
                'color', Wcolor, 'position', viewPos, 'intensityFactor', intFactor);
        else
            closeViewer();
        end
        
        
    end

end