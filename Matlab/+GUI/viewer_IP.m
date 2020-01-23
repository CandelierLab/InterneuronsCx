function viewer_IP(varargin)

clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

DS = dataSource;

% =========================================================================

% --- Studies -------------------------------------------------------------

D = dir(DS.data);
D(1:2) = [];
Studies = {D.name};

% --- Functions -----------------------------------------------------------

D = dir([DS.root 'Programs' filesep 'Matlab' filesep '+IP' filesep]);
D([D.isdir]) = [];
funList = cellfun(@(x) x(1:end-2), {D.name}, 'UniformOutput', false);

% --- Shared variables ----------------------------------------------------

imDir = '';
lImg = [];
Img = NaN;
Bkg = NaN;

% --- User interfaace -----------------------------------------------------

figure(1);
set(1, 'WindowStyle', 'docked');
clf

% Axis
ax = axes('units', 'pixels', 'Position', [0 0 1 1]);

% Title
tl = uicontrol('style', 'text', 'units','pixel', 'position', [0 0 1 1]);

% --- Controls

pstudy = uicontrol('style', 'popupmenu', 'position', [0 0 1 1], ...
    'string', Studies, 'Callback', @updateOptions, ...
    'Value', 2);

prun = uicontrol('style', 'popupmenu', 'position', [0 0 1 1], ...
    'string', {'-'}, 'Callback', @updateOptions, ...
    'Value', 1);

pfun = uicontrol('style', 'popupmenu', 'position', [0 0 1 1], ...
    'string', funList, 'Callback', @updateOptions, ...
    'Value', 1);

cblob = uicontrol('style', 'checkbox', 'position', [0 0 1 1], ...
    'string', 'Blobs', 'Value', true, 'Callback', @updateImage);

cpos = uicontrol('style', 'checkbox', 'position', [0 0 1 1], ...
    'string', 'Positions', 'Value', true, 'Callback', @updateImage);

st = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', 1, 'value', 1, 'SliderStep', [1 1]);

bref = uicontrol('style', 'pushbutton', 'position', [0 0 1 1], ...
    'string', 'Refresh', 'Callback', @updateImage);

magn = uicontrol('style', 'edit', 'position', [0 0 1 1], ...
    'string', '1', 'Callback', @updateImage);


% Control size callback
set(1, 'ResizeFcn', @updateControlSize);
updateControlSize();

addlistener(st, 'Value', 'PostSet', @updateImage);

updateOptions();

% === Controls ============================================================

    function updateControlSize(varargin)
       
        % Get figure size       
        tmp = get(1, 'Outerposition');
        w = tmp(3);
        h = tmp(4);
       
        % Set widgets size
        
        pstudy.Position = [15 h-50 100 20];
        prun.Position = [125 h-50 100 20];
        pfun.Position = [235 h-50 150 20];
        
        cblob.Position = [15 h-80 100 20];
        cpos.Position = [15 h-100 100 20];       
        bref.Position = [125 h-100 100 30];
        
        magn.Position = [w-100 h-60 60 25];
        
        st.Position = [35 10 w-45 20];
        ax.Position = [75 75 w-100 h-150];
        tl.Position = [w/2-100 h-70 200 20];
        
    end

    function updateOptions(varargin)
       
        % --- Study & run
        
        study = pstudy.String{pstudy.Value};
        
        D = dir([DS.data study filesep]);
        D(1:2) = [];
        prun.String = {D.name};
        
        run = prun.String{prun.Value};
        
        % --- Images
        
        imDir = [DS.data study filesep run filesep 'Images' filesep];
        
        D = dir(imDir);
        D([D.isdir]) = [];
        Nt = numel(D);
        ext = D(1).name(end-3:end);
        info = imfinfo([imDir D(1).name]);
        
        lImg = @(i) double(imread([imDir 'frame_' num2str(i, '%06i') ext]))/255;
        
        st.Max = Nt;
        st.SliderStep = [1 1]/(Nt+1);
        
        % --- Background
        
        Bkg = IP.Bkg.(pfun.String{pfun.Value})(lImg(1));
        
        updateImage();
        
    end

% === Image ===============================================================

    function updateImage(varargin)
        
        % --- Get sliders values
        
        ti = round(get(st, 'Value'));
                  
        % --- Image
        
        Img = lImg(ti);
        
        % --- Processing
        
        B = IP.(pfun.String{pfun.Value})(Img-Bkg);
        
        % --- Magnification
        
        mag = str2double(magn.String);
        
        % --- Display
        
        cla
        hold on

        if cblob.Value
            
            % Mask
            Mask = zeros(size(Img));
            for i = 1:numel(B)
                Mask(B(i).idx) = 1;
            end
            
            % Boundaries
            Jmg = Img;
            Bo = bwboundaries(Mask);
            for i = 1:numel(Bo)
                Jmg(sub2ind(size(Jmg), Bo{i}(:,1), Bo{i}(:,2))) = 1;
            end
            
            % Display            
            RGB = cat(3, Jmg.*~Mask, Jmg, Jmg);
            imshowpair(RGB, uint8(Img*255*mag), 'montage');
            
        else
            
            imshowpair(Img, uint8(Img*255*mag), 'montage');
            
        end
            
        if cpos.Value & ~isempty(B)
            pos = cat(1,B.pos);
            scatter(pos(:,1), pos(:,2), 'r+')
        end
        
        axis xy tight        
        
        tl.String = ['t = ' num2str(ti) ];
        
        drawnow limitrate
        
    end

end
