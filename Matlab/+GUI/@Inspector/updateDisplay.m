function updateDisplay(this, varargin)

warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved');

% --- Parameters ----------------------------------------------------------

ti = round(get(this.ui.time, 'Value'));
If = str2double(this.ui.Intfactor.String);

% --- Image ---------------------------------------------------------------

set(this.Viewer, 'CurrentAxes', this.ui.image);
cla(this.ui.image);
hold(this.ui.image, 'on');

this.Data.setDirectory(ti)
imshow(If*read(this.Data));

axis xy 

if isstruct(this.zoom)
    axis([this.zoom.pos(1)-this.zoom.size ...
        this.zoom.pos(1)+this.zoom.size ...
        this.zoom.pos(2)-this.zoom.size ...
        this.zoom.pos(2)+this.zoom.size]);
else
    axis tight
end

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% Request focus
jFig = get(this.Viewer, 'JavaFrame');
jFig.requestFocus;