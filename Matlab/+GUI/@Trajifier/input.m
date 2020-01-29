function input(this, key, value)
%INPUT User input


switch key
    
    case 'b'
        % Flashback & play
        this.ui.time.Value = max(this.ui.time.Value-this.Visu.fbd, ...
            this.ui.time.Min);
        this.Visu.viewPlay = true;
        this.updateDisplay();
        
    case 'c'
        % Cut fragment
        
        % % %         [ci, ti] = this.findClosest();
        % ti = round(get(this.ui.time, 'Value'));
        
        % % %         % --- New fragment
        % % %
        % % %         % Indexes
        % % %         k = numel(Fr)+1;
        % % %         I = Fr(ci).t>=ti;
        % % %
        % % %         Fr(k).status = 'unused';
        % % %         Fr(k).t = Fr(ci).t(I);
        % % %
        % % %         Fr(k).soma.idx = Fr(ci).soma.idx(I);
        % % %         Fr(k).soma.pos = Fr(ci).soma.pos(I,:);
        % % %         Fr(k).soma.fluo = Fr(ci).soma.fluo(I);
        % % %
        % % %         Fr(k).centrosome.idx = Fr(ci).centrosome.idx(I);
        % % %         Fr(k).centrosome.pos = Fr(ci).centrosome.pos(I,:);
        % % %         Fr(k).centrosome.fluo = Fr(ci).centrosome.fluo(I);
        % % %
        % % %         Fr(k).cone.idx = Fr(ci).cone.idx(I);
        % % %         Fr(k).cone.pos = Fr(ci).cone.pos(I,:);
        % % %         Fr(k).cone.fluo = Fr(ci).cone.fluo(I);
        % % %
        % % %         % --- Trim fragment
        % % %
        % % %         % Indexes
        % % %         I = Fr(ci).t<ti;
        % % %
        % % %         Fr(ci).t = Fr(ci).t(I);
        % % %
        % % %         Fr(ci).soma.idx = Fr(ci).soma.idx(I);
        % % %         Fr(ci).soma.pos = Fr(ci).soma.pos(I,:);
        % % %         Fr(ci).soma.fluo = Fr(ci).soma.fluo(I);
        % % %
        % % %         Fr(ci).centrosome.idx = Fr(ci).centrosome.idx(I);
        % % %         Fr(ci).centrosome.pos = Fr(ci).centrosome.pos(I,:);
        % % %         Fr(ci).centrosome.fluo = Fr(ci).centrosome.fluo(I);
        % % %
        % % %         Fr(ci).cone.idx = Fr(ci).cone.idx(I);
        % % %         Fr(ci).cone.pos = Fr(ci).cone.pos(I,:);
        % % %         Fr(ci).cone.fluo = Fr(ci).cone.fluo(I);
        % % %
        % % %         % --- Save and display
        % % %
        % % %         update3dview;
        % % %         updateImage;
        % % %         saveFragments;
        
    case 'd'
        % Flashback duration
        this.Visu.fbd = max(min(round(value), this.Images.number), 1);
        this.ui.menu.shortcuts.String = this.getControls();
        
    case 'f'
        % Flashback last fragment and play
        
        % % %         ui.time.Value = max(Fr(Traj(end)).t(1)-fbd, ui.time.Min);
        % % %         viewPlay = true;
        % % %         updateImage();
        
    case 'g'
        % Global view
        this.Visu.viewLocal = false;
        this.ui.menu.shortcuts.String = this.getControls();
        this.updateDisplay();
        
    case 'l'
        % Local view
        this.Visu.viewLocal = true;
        this.ui.menu.shortcuts.String = this.getControls();
        this.updateDisplay();
        
    case 'n'
        % Next doublon
        if isempty(this.doublons)
            this.ui.action.String = 'No doublon found';
        else
            if this.ui.time.Value>=this.doublons(end)
                nt = this.doublons(1);
            else
                nt = this.doublons(find(this.doublons>this.ui.time.Value, 1, 'first'));
            end
            this.ui.time.Value = nt;
            this.updateDisplay();
        end
        
    case 'q'
        % Toggle quarantine
        
        % % %         if inImage
        % % %
        % % %             ci = findClosest();
        % % %             if isempty(ci), return; end
        % % %
        % % %             switch Fr(ci).status
        % % %
        % % %                 case 'unused'
        % % %                     Fr(ci).status = 'quarantine';
        % % %                     ui.action.String = ['Placed '  num2str(ci) ' in quarantine'];
        % % %
        % % %                 case 'quarantine'
        % % %                     Fr(ci).status = 'unused';
        % % %                     ui.action.String = ['Removed '  num2str(ci) ' from quarantine'];
        % % %             end
        % % %
        % % %             update3dview;
        % % %             updateImage;
        % % %
        % % %             saveFragments;
        % % %
        % % %         end
        
    case 's'
        % Save fragments
        this.saveFragments();
        
    case 't'
        % New trajectory
        this.tid = this.newTrajId;
        this.updateInfos();
        
    case 'v'
        % Framerate
        this.Visu.fps = max(min(round(value), 50), 1);
        this.ui.menu.shortcuts.String = this.getControls();
        
    case 'w'
        % Width of the local view
        this.Visu.lsz = max(min(round(value), this.Images.Width), 10);
        this.ui.menu.shortcuts.String = this.getControls();
        
    case ' '
        this.Visu.viewPlay = ~this.Visu.viewPlay;
        if this.Visu.viewPlay
            this.updateDisplay();
        end
        
    case '+'
        % Add to trajectory
        
    case '-'
        % Remove from trajectory
        
% % %         if isempty(Traj), return; end
% % %         
% % %         if inImage
% % %             
% % %             % --- Find closest Fragment
% % %             
% % %             mi = findClosest(Traj);
% % %             
% % %             ui.action.String = ['Removed fragment ' num2str(Traj(mi))];
% % %             
% % %             Fr(Traj(mi)).status = 'unused';
% % %             Traj(mi) = [];
% % %             
% % %             update3dview();
% % %             updateImage();
% % %             updateInfos();
% % %             updateWarnings();
% % %             
% % %         end
        
        
    case 'F'
        % Toggle fragment view
        this.Visu.viewFrag = ~this.Visu.viewFrag;
        this.prepareDisplay;
        this.updateDisplay;
        
    case 'T'
        % Toggle trajectory view
        this.Visu.viewTraj = ~this.Visu.viewTraj;
        this.prepareDisplay;
        this.updateDisplay;
        
    case 'Q'
        % Toggle quarantine view
        this.Visu.viewQuar = ~this.Visu.viewQuar;
        this.prepareDisplay;
        this.updateDisplay;
        
    case 'leftarrow'
        % Time -1
        this.ui.time.Value = max(this.ui.time.Value-1, this.ui.time.Min);
        this.updateDisplay();
        
    case 'rightarrow'
        % Time +1
        this.ui.time.Value = min(this.ui.time.Value+1, this.ui.time.Max);
        this.updateDisplay();
        
    case 'uparrow'
        % End of current trajectory
        
% % %         if ~isempty(Traj)
% % %             ui.time.Value = max(cat(1,Fr(Traj).t));
% % %             updateImage();
% % %         end
        
    case 'downarrow'
        % Beginning of current trajectory
        
% % %         if ~isempty(Traj)
% % %             ui.time.Value = min(cat(1,Fr(Traj).t));
% % %             updateImage();
% % %         end
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        this.updateDisplay();
    
    case 'leftClick'
        % Select fragment in the visible ones
        
        this.ui.action.String = "Fragment selection";
        
    case 'middleClick'
        % Select trajectory in the visible ones
        
        this.ui.action.String = "Trajectory selection";
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end