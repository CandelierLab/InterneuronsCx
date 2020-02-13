function updateWindowSize(this, varargin)

% --- Figure size
tmp = get(this.Viewer, 'Outerposition');
W = tmp(3);
H = tmp(4);

% --- Window

set(this.Viewer, 'Menu', 'none', 'ToolBar', 'none', 'color', this.Window.color);
if ~isempty(this.Window.position)
    set(this.Viewer, 'Position', this.Window.position);
end
h = H-30;

% --- Axes

this.ui.image.Position = [this.Window.menuWidth+20 50 W-2*this.Window.menuWidth-40 h-120];

% --- Time

this.ui.time.Position = [this.Window.menuWidth+20 10 W-2*this.Window.menuWidth-40 20];
this.ui.title.Position = [this.Window.menuWidth+20 h-50 W-2*this.Window.menuWidth-40 20];

% --- Menu

% Intensity factor
this.ui.menu.Intfactor.Position = [10 h-50 200 20];
this.ui.Intfactor.Position = [210 h-50 50 25];

% Shortcuts
this.ui.menu.shortcuts.Position = [10 40 380 h-110];

% --- Title

this.ui.title.BackgroundColor = this.Window.color;
this.ui.title.ForegroundColor = 'w';

% --- Infos

this.ui.info.Position = [W-this.Window.menuWidth 10 this.Window.menuWidth h-100];

% --- Action

this.ui.action.Position = [10 10 this.Window.menuWidth 30];

