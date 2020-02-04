function load(this)
%load Load shapes & cells

% --- Shapes

tmp = load(this.File.shapes);
this.Shape = tmp.Shape;

% --- Cells

if exist(this.File.cells, 'file')
    tmp = load(this.File.cells);
    this.Cell = tmp.Cell;
else
    this.Cell = struct('t', {}, 'all', {}, 'soma', {}, 'centrosome', {}, 'cones', {});
end


