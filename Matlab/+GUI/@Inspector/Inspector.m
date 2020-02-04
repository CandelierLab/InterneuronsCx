classdef Inspector < handle
    %INSPECTOR Viewer for organizing shapes (temporal paradigm)
    
    properties
        
        % Data
        study
        run
        File = struct('images', '', 'shapes', '');
        Images
        
        % GUI
        Viewer
        Window = struct('posittion', [], 'color', [])
        Visu = struct('intensityFactor', 1)
        ui = struct()
        keyboardInput = struct('active', false, 'command', '', 'buffer', '')
        mousePosition = struct('image', NaN(2,1))
                
        % Shapes
        Shape
        Blob
        
        % Cells
        Cell
        Unit
        uid = NaN;
        step = '';
        
    end
    
    methods
        
        % --- CONTRUCTOR --------------------------------------------------
        
        function this = Inspector(varargin)
            clc
        end
        
    end
end

