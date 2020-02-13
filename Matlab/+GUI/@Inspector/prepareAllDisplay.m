function prepareAllDisplay(this, varargin)

this.Data = Tiff(this.File.data, 'w');
wb = waitbar(0, '', 'Name', 'Preparation');
warning off
for i = 1:this.Images.number
    this.ui.time.Value = i;
    this.loadTime;
    this.prepareDisplay(i, true);
    waitbar(i/this.Images.number, wb, sprintf('Preparing %i / %i', i, this.Images.number));
end
close(wb);
close(this.Data);
this.ui.time.Value = 1;
warning on

this.Data = Tiff(this.File.data, 'r+');
