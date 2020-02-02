function loadShapes(this)
%loadShapes Load shapes.

tmp = load(this.File.shapes);
this.Shapes = tmp.Shapes;
