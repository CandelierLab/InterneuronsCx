%#ok<*AGROW>
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'HighMag';
run = 's8e1';
% run = 's10e1';
% run = 's10e2';
% run = 's14e2';

% Background
r_bkg = 10;

% Image processing
sth = 3;
sigma = 3;
excl = 10;
th = 0.1;

% Tracking
fnumel = [5 Inf];

t = 1;

force = true;
savefile = true;

% -------------------------------------------------------------------------

DS = dataSource;
imDir = [DS.root study filesep run filesep 'Images' filesep];
fDir = [DS.root study filesep run filesep 'Files' filesep];

% =========================================================================

% --- Preparation ---------------------------------------------------------

D = dir(imDir);
D([D.isdir]) = [];
n = numel(D);
ext = D(1).name(end-3:end);

lImg = @(i) double(imread([imDir 'frame_' num2str(i, '%06i') ext]))/255;

% --- Background ----------------------------------------------------------

if ~exist('Bkg', 'var') || force

    fprintf('Computing background ...');
    tic
    
    Img = lImg(1);
    
    Tmp = ordfilt2(Img, 20, true(2*r_bkg));
    Tmp(1:r_bkg,:) = repmat(Tmp(r_bkg+1,:), [r_bkg 1]);
    Tmp(end-r_bkg+1:end,:) = repmat(Tmp(end-r_bkg-1,:), [r_bkg 1]);
    Tmp(:,1:r_bkg) = repmat(Tmp(:,r_bkg+1), [1 r_bkg]);
    Tmp(:,end-r_bkg+1:end) = repmat(Tmp(:,end-r_bkg-1), [1 r_bkg]);
    
    Bkg = Tmp;

    fprintf(' %.02f sec\n', toc);

end

% --- Localization --------------------------------------------------------

if ~exist('X', 'var') || force
    
    fprintf('Finding spots ...')
    tic
    
    T = [];
    X = [];
    Y = [];
    F = [];
    
    for i = 1:n
        
        % --- Load image
        
        Img = lImg(i)-Bkg;
        
        % --- Process image
        
        Noise = imtophat(Img, strel('disk',sth));
        Res = Img - Noise;
        
        G = imgaussfilt(Res, sigma);
        
        [y, x] = find(G==imdilate(G, strel('disk', excl)));
        f = G(sub2ind(size(Img), y, x));
        
        I = x>1 & x<size(Img,2) & y>1 & y<size(Img,1) & f>=th;
        
        T = [T ; i*ones(nnz(I),1)];
        X = [X ; x(I)];
        Y = [Y ; y(I)];
        F = [F ; f(I)];
        
    end
    
    fprintf(' %.02f sec\n', toc);
    
end

% --- Tracking ------------------------------------------------------------

if ~exist('Tr', 'var') || force
    
    % --- Stats
    
%     Tracking.pdf_distance_n1([T X Y]);
%     return
    
    % --- Definitions
    
    Tr = Tracking.Tracker;

    Tr.parameter('position', 'max', 20, 'norm', 10);
%     Tr.parameter('intensity', 'max', 0.2, 'norm', 0.01);

%   Tr.parameter('position', 'hard', 'n1', 'max', 40, 'norm', 10);
%   Tr.parameter('intensity', 'active', false);
    
    % --- Tracking
    
    for i = 1:n
    
        Idx = T==i;
        Tr.set('position', [X(Idx) Y(Idx)]);
        Tr.set('intensity', F(Idx));
        
        Tr.match('method', 'fast', 'verbose', false);
    
    end

    % --- Assemble

    Tr.assemble('method', 'fast', 'max', 10, 'norm', 1);

    % --- Filtering
        
    Tr.filter('numel', fnumel);
    
end



% --- Save ----------------------------------------------------------------

if savefile
       
    save([fDir 'tracking.mat'], 'Tr');
    
end

% === Display =============================================================

Tr.disp

I1 = find(T==t);
I2 = find(T==t+1);
Img1 = lImg(t);
Img2 = lImg(t+1);

figure(1)
clf
hold on

imshowpair(Img1, Img2)
hold on

scatter(X(I1), Y(I1), 100, '.', 'MarkerEdgeColor', 'c')
scatter(X(I2), Y(I2), 20, '+', 'MarkerEdgeColor', 'y')

for k = 1:numel(Tr.traj)
    plot3(Tr.traj(k).position(:,1), ...
        Tr.traj(k).position(:,2), ...
        Tr.traj(k).t, '-');   
end

axis ij image on
daspect([1 1 0.3])
view(40,20)
