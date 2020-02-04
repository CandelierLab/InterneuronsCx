function initShapes(this)
%initshapes Initializes the Sh property at each time step.

ti = round(get(this.ui.time, 'Value'));

% --- Get contours

I = find([this.Shapes.t]==ti);
this.Sh = this.Shapes(I);
for i = 1:numel(I)
    this.Sh(i).sid = I(i);
end

this.computeShape(["contour", "pos"]);

this.ui.action.String = "Frame initialized with " + numel(this.Sh) + " shapes";
