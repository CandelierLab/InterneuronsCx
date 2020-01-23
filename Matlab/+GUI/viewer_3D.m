function viewer_3D(varargin)

clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = '190424 D1_16b';
run = 'P2t';

% study = 'HighMag';
% run = 's8e1';

tlen = 5;

% -------------------------------------------------------------------------

DS = dataSource;
imDir = [DS.root study filesep run filesep 'Images' filesep];
fDir = [DS.root study filesep run filesep 'Files' filesep];

% =========================================================================

% --- Preparation ---------------------------------------------------------

D = dir(imDir);
D([D.isdir]) = [];
Nt = numel(D);
ext = D(1).name(end-3:end);
info = imfinfo([imDir D(1).name]);

lImg = @(i) double(imread([imDir 'frame_' num2str(i, '%06i') ext]))/255;
p3D = [];

% --- Load tracking

fprintf('Load tracking ...');
tic

% Load tracking
Tmp = load([fDir 'tracking.mat']);
Tr = Tmp.Tr;

% Convert for fast display
X = NaN(Tr.iter, numel(Tr.traj));
Y = NaN(Tr.iter, numel(Tr.traj));
T = NaN(Tr.iter, numel(Tr.traj));
for i = 1:numel(Tr.traj)
    X(Tr.traj(i).t,i) = Tr.traj(i).position(:,1);
    Y(Tr.traj(i).t,i) = Tr.traj(i).position(:,2);
    T(Tr.traj(i).t,i) = Tr.traj(i).t;
end

ID = ones(Tr.iter,1)*(1:numel(Tr.traj));
cm = lines(numel(Tr.traj));

fprintf(' %.02f sec\n', toc);

% --- Shared variables ----------------------------------------------------

Img = NaN;

% --- User interfaace -----------------------------------------------------

figure(1)
clf

% Axes
ax3D = axes('units', 'pixels', 'Position', [0 0 1 1]);
axImg = axes('units', 'pixels', 'Position', [0 0 1 1]);

% Title
tl = uicontrol('style', 'text', 'units','pixel', 'position', [0 0 1 1]);

% --- Controls

st = uicontrol('style','slider', 'position', [0 0 1 1], ...
    'min', 1, 'max', Nt, 'value', 1, 'SliderStep', [1 1]/(Nt+1));

% Control size callback
set(1, 'ResizeFcn', @updateControlSize);
updateControlSize();
addlistener(st, 'Value', 'PostSet', @updateImage);

% --- 3D display ----------------------------------------------------------

hold(ax3D, 'on');
imshow(lImg(1), 'Parent', ax3D);

for k = 1:numel(Tr.traj)
    plot3(ax3D, Tr.traj(k).position(:,1), ...
        Tr.traj(k).position(:,2), ...
        Tr.traj(k).t, '-');   
end


axis(ax3D, 'on', 'tight', 'xy')
daspect(ax3D, [1 1 1/5]);
box(ax3D, 'on')
view(ax3D, -35, 30);

updateImage();

% === Controls ============================================================

    function updateControlSize(varargin)
       
        % Get figure size       
        tmp = get(1, 'Outerposition');
        w = tmp(3);
        h = tmp(4);
       
        % Set widgets size
        st.Position = [35 10 w-45 20];
        ax3D.Position = [10 75 w/2-20 h-150];
        axImg.Position = [w/2+10 75 w/2-20 h-150];
        tl.Position = [w/2 h-50 50 20];
        
    end

% === Image ===============================================================

    function updateImage(varargin)
        
        % --- Slider ------------------------------------------------------
        
        ti = round(get(st, 'Value'));
                  
        % --- Display 3D --------------------------------------------------
        
        delete(p3D);
        p3D = scatter3(ax3D, X(ti,:), Y(ti,:), T(ti,:), 20, 'o', ...
            'MarkerFaceColor', 'flat', 'CData', cm(ID(ti,:),:));
        
        
        % --- Display 2D --------------------------------------------------
        
        cla(axImg)
        hold on
                   
        imshow(lImg(ti), 'Parent', axImg);
        
        % Points
        scatter(axImg, X(ti,:), Y(ti,:), 20, 'o', 'MarkerFaceColor', 'flat', ...
            'CData', cm(ID(ti,:),:));
                
        % Trajectories
                
        Ia = ti:min(ti+tlen, Tr.iter);
        Ib = max(ti-tlen,1):ti;
        
        if numel(Ib)>1
            for k = 1:numel(Tr.traj)
                if any(~isnan(X(Ib,k)))
                    line(axImg, X(Ib,k), Y(Ib,k), 'color', cm(k,:))
                end
            end
        end
        
%         if numel(Ia)>1
%             for k = 1:numel(Tr.traj)
%                 if any(~isnan(X(Ia,k)))
%                     line(X(Ia,k), Y(Ia,k), 'color', cm(k,:), 'LineStyle', '--');
%                 end
%             end
%         end
        
        axis(axImg, 'xy', 'tight');        
        
        tl.String = ['t = ' num2str(ti) ];
        
        drawnow limitrate
        
    end

end
