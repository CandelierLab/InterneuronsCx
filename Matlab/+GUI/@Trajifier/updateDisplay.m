function updateDisplay(this, varargin)

% --- Parameters

ti = round(get(this.ui.time, 'Value'));
If = str2double(this.ui.Intfactor.String);

% --- Image ---------------------------------------------------------------

Img = If*double(imread(this.File.images, ti))/255;

set(this.Viewer, 'CurrentAxes', this.ui.image);
cla(this.ui.image);
hold(this.ui.image, 'on');

h = imshow(Img);

% Context menu
h.UIContextMenu = this.Visu.cMenu;

axis xy tight

% updatePoints(ti);

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% --- Points on image -----------------------------------------------------

if this.Visu.viewFrag    
    
    scatter(this.Pos(ti).unused.x, this.Pos(ti).unused.y, 20, ...
        'MarkerFaceColor', [1 1 1], ...
        'MarkerEdgeColor', 'k');
    
end


% --- Points on 3D view ---------------------------------------------------


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
