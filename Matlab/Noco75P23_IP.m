%#ok<*AGROW>
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'Noco75P23';
run = 'Noco75P23';

% Background
r_bkg = 10;

% Imaage processing
sigma = 5;
excl = 5;
th = 0.05;

t = 1;

force = true;

% -------------------------------------------------------------------------

DS = dataSource;
imDir = [DS.root study filesep run filesep 'Images' filesep];

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
    
    for i = t
        
        % --- Load image
        
        Img = lImg(i)-Bkg;
        
        % --- Process image
        
        Noise = imtophat(Img, strel('disk',1));
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

% === Display =============================================================

I1 = find(T==t);
I2 = find(T==t+1);
Img = lImg(t);

figure(1)
clf

a1 = axes;
imshow(Img)

axis ij image on

a2 = axes;
hold on

scatter(X(I1), Y(I1), 25, F(I1), 'filled');

axis ij image on
axis([1 size(Img,1) 1 size(Img,2)]);

colormap(a1, 'gray');
colormap(a2, jet());

caxis(a2, [0 max(f)]);
a2.Visible = 'off';
linkprop([a1 a2],'Position');
colorbar

title(a1, num2str(t));
