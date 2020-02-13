classdef Trajifier < handle
    %TRAJIFIER Viewer for merging Fragments into trajectories
    
    properties
        
        % Data
        study
        run
        File = struct('images', '', 'fragments', '');
        Images
        
        % GUI
        Viewer
        Window = struct('posittion', [], 'color', [])
        Visu = struct('intensityFactor', 1)
        ui = struct()
        keyboardInput = struct('active', false, 'command', '', 'buffer', '')
        mousePosition = struct('image', NaN(2,1), 'view3d', NaN(2,1))
        fid = NaN
        tid = NaN
        Pts
        zoom = NaN;
                
        % Fragments
        Fr
        
    end
    
    methods
        
        % --- CONTRUCTOR --------------------------------------------------
        
        function this = Trajifier(varargin)
            clc
        end
        
    end
end

