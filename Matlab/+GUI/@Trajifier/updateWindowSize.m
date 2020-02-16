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
this.ui.image.Position = [this.Window.menuWidth+20 235 700 700];
this.ui.view3d.Position = [this.Window.menuWidth+730 235 700 600];

% --- Time

this.ui.time.Position = [this.Window.menuWidth+20 200 700 20];
this.ui.title.Position = [this.Window.menuWidth+10 h-50 680 20];

% --- Menu

% Shortcuts
this.ui.menu.shortcuts.Position = [10 40 380 h-110];

% --- Title

this.ui.title.BackgroundColor = this.Window.color;
this.ui.title.ForegroundColor = 'w';

% --- Infos

this.ui.info.Position = [this.Window.menuWidth+20 10 750 150];
this.ui.warnings.Position = [this.Window.menuWidth+770 10 750 150];

this.ui.prepareTime.Position = [350 10 100 20];

% --- Action

this.ui.action.Position = [10 10 this.Window.menuWidth 30];

