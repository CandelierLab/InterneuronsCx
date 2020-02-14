function loadTime(this, varargin)
%initBlobs Initializes the blob list for a given time.

this.ui.time.Value = round(this.ui.time.Value);
ti = this.ui.time.Value;

% --- Initialize blobs

this.Blob = struct('sid', {}, 'idx' , {}, 'pos', {}, 'contour', {});

I = find([this.Shape.t]==ti);
for i = 1:numel(I)
    this.Blob(i).sid = I(i);
    this.Blob(i).idx = this.Shape(I(i)).idx;
end

% --- Get positions and contours

this.compute('Blob', ["pos", "contour"]);

% --- Initialize units

this.Unit = struct('cid', {}, 'all' , {}, 'soma', {}, 'centrosome', {}, 'cones', {});

I = find([this.Cell.t]==ti);
for i = 1:numel(I)
    this.Unit(i).cid = I(i);
    this.Unit(i).all = this.Cell(I(i)).all;
    this.Unit(i).soma = this.Cell(I(i)).soma;
    this.Unit(i).centrosome = this.Cell(I(i)).centrosome;
    this.Unit(i).cones = this.Cell(I(i)).cones;
end

% --- Display

this.ui.action.String = "Frame initialized with " + numel(this.Blob) + " shapes";