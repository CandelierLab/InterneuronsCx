classdef SimpleViewer < handle
    %VIEWER Viewer for the data
    
    properties
        
        % Data
        study
        run
        File = struct('images', '');
        Images
        
        % GUI
        Viewer
        Window = struct('posittion', [], 'color', [])
        Visu = struct('intensityFactor', 1)
        ui = struct()
        
    end
    
    methods
        
        % --- CONTRUCTOR --------------------------------------------------
        
        function this = SimpleViewer(varargin)
            clc
        end
        
    end
end

