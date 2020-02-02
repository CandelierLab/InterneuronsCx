function initShapes(this)
%initshapes Initializes the Sh property at each time step.

ti = round(get(this.ui.time, 'Value'));
this.Sh = this.Shapes([this.Shapes.t]==ti);

% --- Get contours

this.computeShape(["contour", "pos"]);

this.ui.action.String = "Frame initialized with " + numel(this.Sh) + " shapes";
