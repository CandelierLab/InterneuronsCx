%#ok<*AGROW>
clc
warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')

% === Parameters ==========================================================

study = 'LowMag';
run = 'P1';

force = true;

% -------------------------------------------------------------------------

DS = dataSource;

% =========================================================================

% Stack = memmapfile([DS.data study filesep run filesep run '.dat'], ...
%     'format', {'uint8', [512 512 194], 'raw'})

% imshow(Stack.Data.raw(:,:,1));

GUI.Trajifier('study', study, 'run', run);


