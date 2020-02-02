function updateDisplay(this, varargin)

% --- Parameters

ti = round(get(this.ui.time, 'Value'));
If = str2double(this.ui.Intfactor.String);

% --- Image ---------------------------------------------------------------

Img = If*double(imread(this.File.images, ti))/255;

set(this.Viewer, 'CurrentAxes', this.ui.image);
cla(this.ui.image);
hold(this.ui.image, 'on');

imshow(Img);

axis xy tight
% axtoolbar(this.ui.image, {'zoomin', 'pan'});

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% --- Shapes --------------------------------------------------------------

% --- Draw contours

Scm = hsv(numel(this.Sh));
Ccm = jet(numel(this.Sh));

for i = 1:numel(this.Sh)
    
    plot(this.Sh(i).contour.x, this.Sh(i).contour.y, '-', ...
        'color', Scm(i,:), 'Linewidth', 1)
    
    text(this.Sh(i).contour.x(1), this.Sh(i).contour.y(1), num2str(i), ...
        'color', 'w');
    
%     patch(Sh(i).contour.x, Sh(i).contour.y, Ccm(i,:), ...
%         'EdgeColor', 'none', 'FaceAlpha', 0.5)

end

% --- Cells ---------------------------------------------------------------




% --- Draw & play ---------------------------------------------------------

drawnow limitrate

% --- Play / pause
if this.Visu.viewPlay
    if ti==this.ui.time.Max
        this.ui.time.Value = this.ui.time.Min;
    else
        this.ui.time.Value = ti+1;
    end
    pause(1/this.Visu.fps);
    
    this.updateDisplay(varargin{:});
end
