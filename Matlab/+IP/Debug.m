clc

% === Parameters ==========================================================

Study = 'LowMag_R';
Run = 'M1';

t = 1;

% -------------------------------------------------------------------------

DS = dataSource;

fImg = [DS.data Study filesep Run filesep Run '.tiff'];

% =========================================================================

% --- Get Image info

info = imfinfo(fImg);
nImg = numel(info);
Height = info(1).Height;
Width = info(1).Width;

% --- Load image

lImg = @(i) double(imread(fImg, i))/255;
Bkg = IP.Bkg.(Study)(lImg(1));
Img = lImg(t);

Res = IP.(Study)(Img-Bkg);

% --- Display

clf
hold on

% % % imshow(Bkg*20)
% % % 
% % % % caxis auto
% % % colorbar
% % % 
% % % return

imshow(Img*10)
axis xy 

cm = hsv(numel(Res));

for i = 1:numel(Res)
    
    Mask = zeros(Height, Width);
    Mask(Res(i).idx) = 1;
    B = bwboundaries(Mask);
    
    for j = 1:numel(B)
        plot(B{j}(:,2), B{j}(:,1), 'color', cm(i,:));
    end
    
end