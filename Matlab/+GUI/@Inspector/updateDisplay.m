function updateDisplay(this, varargin)

% --- Parameters ----------------------------------------------------------

ti = round(get(this.ui.time, 'Value'));
If = str2double(this.ui.Intfactor.String);

% --- Image ---------------------------------------------------------------

set(this.Viewer, 'CurrentAxes', this.ui.image);
cla(this.ui.image);
hold(this.ui.image, 'on');

Img = If*double(imread(this.File.images, ti))/255;

imshow(Img);

axis xy tight
% axtoolbar(this.ui.image, {'zoomin', 'pan'});

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% --- Shapes --------------------------------------------------------------

% --- Draw contours

Scm = hsv(numel(this.Sh));

for i = 1:numel(this.Sh)
    
    plot(this.Sh(i).contour.x, this.Sh(i).contour.y, '-', ...
        'color', Scm(i,:), 'Linewidth', 1)
    
    text(this.Sh(i).contour.x(1), this.Sh(i).contour.y(1), num2str(i), ...
        'color', 'w');

end

% --- Cells ---------------------------------------------------------------

Ccm = jet(numel(this.Cell));

for i = 1:numel(this.Cell)
    
    % --- Soma
    
    if isempty(this.Cell(i).soma)
        xSo = NaN;
        ySo = NaN;
    else
        xSo = this.Cell(i).soma.pos(1);
        ySo = this.Cell(i).soma.pos(2);
    end
    
    % --- Centrosome
    
    if isempty(this.Cell(i).centrosome)
        xCe = NaN;
        yCe = NaN;
    else
        xCe = this.Cell(i).centrosome.pos(1);
        yCe = this.Cell(i).centrosome.pos(2);
    end
    
    if isempty(this.Cell(i).cones)
        xCo = [];
        yCo = [];
    else
        xCo = NaN(numel(this.Cell(i).cones),1);
        yCo = NaN(numel(this.Cell(i).cones),1);
        for j = 1:numel(this.Cell(i).cones)
            xCo(j) = this.Cell(i).cones(j).pos(1);
            yCo(j) = this.Cell(i).cones(j).pos(2);
        end
    end
    
    % Markers
    scatter(xSo, ySo, 200, 'MarkerFaceColor', Ccm(i,:), 'MarkerEdgeColor', 'k');
    scatter(xCe, yCe, 200, 'MarkerFaceColor', Ccm(i,:), 'MarkerEdgeColor', 'k');
    scatter(xCo, yCo, 200, 'MarkerFaceColor', Ccm(i,:), 'MarkerEdgeColor', 'k');
    
    text(xSo-2, ySo+2, 's', 'color', 'k');
    
    % --- Centrosome
    
    scatter(this.Cell(i).soma.pos(1), this.Cell(i).soma.pos(2), 200, ...
        'MarkerFaceColor', Ccm(i,:), 'MarkerEdgeColor', 'k');

    text(this.Cell(i).soma.pos(1)-2, this.Cell(i).soma.pos(2)+2, ...
        's', 'color', 'k');
    
    % plot([this.Cell(i).soma.pos(1) this.Cell(i).centrosome.pos(1)], [], 'y.-');

end

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
