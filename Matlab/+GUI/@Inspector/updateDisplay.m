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
axtoolbar(this.ui.image, {'zoomin', 'pan'});

this.ui.title.String = ['Frame ' num2str(ti, this.Visu.frameFormat) ' / ' num2str(this.Images.number)];

% --- Shapes --------------------------------------------------------------

% --- Draw contours

Scm = hsv(numel(this.Blob));

for i = 1:numel(this.Blob)
    
    plot(this.Blob(i).contour.x{1}, this.Blob(i).contour.y{1}, '-', ...
        'color', Scm(i,:), 'Linewidth', 1)
    
    text(this.Blob(i).pos.x, this.Blob(i).pos.y, num2str(i), ...
        'color', 'k', 'backgroundColor', 'w', ...
        'fontname', 'Courier New', 'FontSize', 8, ...
        'margin', 1, 'edgecolor', Scm(i,:));

end

% --- Cells ---------------------------------------------------------------

Ucm = jet(numel(this.Unit));

for i = 1:numel(this.Unit)
    
    % --- Soma
    
    if isempty(this.Unit(i).soma)
        xSo = NaN;
        ySo = NaN;
    else
        xSo = this.Unit(i).soma.pos.x;
        ySo = this.Unit(i).soma.pos.y;
    end
    
    % --- Centrosome
    
    if isempty(this.Unit(i).centrosome)
        xCe = NaN;
        yCe = NaN;
    else
        xCe = this.Unit(i).centrosome.pos.x;
        yCe = this.Unit(i).centrosome.pos.y;
    end
    
    if isempty(this.Unit(i).cones)
        xCo = [];
        yCo = [];
    else
        xCo = NaN(numel(this.Unit(i).cones),1);
        yCo = NaN(numel(this.Unit(i).cones),1);
        for j = 1:numel(this.Unit(i).cones)
            xCo(j) = this.Unit(i).cones(j).pos.x;
            yCo(j) = this.Unit(i).cones(j).pos.y;
        end
    end
    
    % --- Links
    
% % %     % Soma-centrosome
% % %     plot([xSo xCe], [ySo yCe], '-', 'color', Ucm(i,:), 'Linewidth', 2);
% % %     
% % %     % Centrosome-cones
% % %     for k = 1:numel(xCo)
% % %         plot([xCe xCo(k)], [yCe yCo(k)], '-', 'color', Ucm(i,:), 'Linewidth', 2);
% % %     end
    
    % --- Patch
    
    for k = 1:numel(this.Unit(i).all.contour.x) 
        patch(this.Unit(i).all.contour.x{k}, this.Unit(i).all.contour.y{k}, Ucm(i,:), ...
            'EdgeColor', Ucm(i,:), ...
            'FaceAlpha', 0.3);
    end
    

    % --- Markers
    
    scatter([xSo ; xCe ; xCo], [ySo ; yCe ; yCo], 200, ...
        'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k');
    
    % --- Texts
    
    text(xSo-3.5, ySo+1, 'So', 'color', 'k', 'FontSize', 7);
    text(xCe-3.5, yCe+1, 'Ce', 'color', 'k', 'FontSize', 7);
    text(xCo-3.5, yCo+1, 'Co', 'color', 'k', 'FontSize', 7);
    
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
