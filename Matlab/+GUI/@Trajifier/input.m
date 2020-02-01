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
        
        % Find closest fragment and trajectory
        fid = this.getFragment();
        if isnan(fid) || strcmp(this.Fr(fid).status, 'quarantine')
            return
        end
        
        ti = round(get(this.ui.time, 'Value'));
        if ti==this.Fr(fid).t(1), return, end
        
        % --- New fragment
        
        % Indexes
        k = numel(this.Fr)+1;
        I = this.Fr(fid).t>=ti;
        
        this.Fr(k).status = 'unused';
        this.Fr(k).t = this.Fr(fid).t(I);
        
        this.Fr(k).soma.idx = this.Fr(fid).soma.idx(I);
        this.Fr(k).soma.pos = this.Fr(fid).soma.pos(I,:);
        this.Fr(k).soma.fluo = this.Fr(fid).soma.fluo(I);
        
        this.Fr(k).centrosome.idx = this.Fr(fid).centrosome.idx(I);
        this.Fr(k).centrosome.pos = this.Fr(fid).centrosome.pos(I,:);
        this.Fr(k).centrosome.fluo = this.Fr(fid).centrosome.fluo(I);
        
        this.Fr(k).cone.idx = this.Fr(fid).cone.idx(I);
        this.Fr(k).cone.pos = this.Fr(fid).cone.pos(I,:);
        this.Fr(k).cone.fluo = this.Fr(fid).cone.fluo(I);
        
        % --- Trim fragment
        
        % Indexes
        I = this.Fr(fid).t<ti;
        
        this.Fr(fid).t = this.Fr(fid).t(I);
        
        this.Fr(fid).soma.idx = this.Fr(fid).soma.idx(I);
        this.Fr(fid).soma.pos = this.Fr(fid).soma.pos(I,:);
        this.Fr(fid).soma.fluo = this.Fr(fid).soma.fluo(I);
        
        this.Fr(fid).centrosome.idx = this.Fr(fid).centrosome.idx(I);
        this.Fr(fid).centrosome.pos = this.Fr(fid).centrosome.pos(I,:);
        this.Fr(fid).centrosome.fluo = this.Fr(fid).centrosome.fluo(I);
        
        this.Fr(fid).cone.idx = this.Fr(fid).cone.idx(I);
        this.Fr(fid).cone.pos = this.Fr(fid).cone.pos(I,:);
        this.Fr(fid).cone.fluo = this.Fr(fid).cone.fluo(I);
        
        % --- Save and display
        
        this.prepareDisplay;
        this.updateDisplay;
%         this.saveFragments;
        
    case 'd'
        % Flashback duration
        this.Visu.fbd = max(min(round(value), this.Images.number), 1);
        this.ui.menu.shortcuts.String = this.getControls();
        
    case 'f'
        % Flashback last fragment and play
        
        Traj = find(string({this.Fr.status})==string(this.tid));        
        tf = this.Fr(Traj(end)).t(1);
        this.ui.time.Value = max(tf-this.Visu.fbd, this.ui.time.Min);
        
        this.Visu.viewPlay = true;
        this.updateDisplay();
        
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
            this.Visu.viewPlay = false;
            this.doublonDisplay();
        end
        
    case 'q'
        % Toggle quarantine
        
        % Find closest fragment and trajectory
        fid = this.getFragment();
        if isnan(fid) || isnumeric(this.Fr(fid).status)
            return
        end
            
        switch this.Fr(fid).status
            case 'unused'
                this.Fr(fid).status = 'quarantine';
                this.ui.action.String = "Placed " + fid + " in quarantine";
                
            case 'quarantine'
                this.Fr(fid).status = 'unused';
                this.ui.action.String = "Removed " + fid + " from quarantine";
        end
        
        this.prepareDisplay;
        this.updateDisplay;
        this.updateInfos;
        
%         this.saveFragments;
       
    case 'r'
        % Search trajectory
        
        fid = find(cellfun(@(x) x(1)==value, {this.Fr.status}),1,'first');
        if ~isempty(fid)
            this.tid = this.Fr(fid).status;
            this.ui.time.Value = this.Fr(fid).t(1);
            
            this.updateInfos();
            this.updateDisplay();
            
        end
        
    case 's'
        % Save fragments
        this.saveFragments();
        
        this.ui.action.String = "Fragments saved @ " + datestr(now, 'hh:MM:ss');
        
    case 't'
        % New trajectory
        this.tid = this.newTrajId;
        this.updateInfos();
        this.prepareDisplay();
        this.updateDisplay();
        
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
        
        % Find closest fragment and trajectory
        fid = this.getFragment();
        if isnan(fid) || isnumeric(this.Fr(fid).status) || strcmp(this.Fr(fid).status, 'quarantine')
            return
        end
        
        if isnan(this.tid), return; end
        this.Fr(fid).status = this.tid;

        this.updateInfos;
        this.updateWarnings;
        this.prepareDisplay;
        this.updateDisplay;
        % this.saveFragments;
        
    case '-'
        % Remove from trajectory
        
        % Find closest fragment and trajectory
        fid = this.getFragment();
        if isnan(fid) || ~isnumeric(this.Fr(fid).status)
            return
        end
        
        this.Fr(fid).status = 'unused';

        this.updateInfos;
        this.updateWarnings;
        this.prepareDisplay;
        this.updateDisplay;
        % this.saveFragments;
        
    case 'F'
        % Toggle fragment view
        this.Visu.viewFrag = ~this.Visu.viewFrag;
        this.prepareDisplay;
        this.updateDisplay;
        
    case 'S'
        % Export trajectories
        
        this.exportTrajectories;
        this.ui.action.String = "Trajectories saved @ " + datestr(now, 'hh:MM:ss');
        
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
        
        if ~isnan(this.tid)
            Traj = find(string({this.Fr.status})==string(this.tid)); 
            this.ui.time.Value = max(cat(1,this.Fr(Traj).t));
            this.updateDisplay();
        end
        
    case 'downarrow'
        % Beginning of current trajectory
        
        if ~isnan(this.tid)
            Traj = find(string({this.Fr.status})==string(this.tid)); 
            this.ui.time.Value = min(cat(1,this.Fr(Traj).t));
            this.updateDisplay();
        end
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        this.updateDisplay();
    
    case 'pageup'
        % First unused fragment
        this.ui.time.Value = min(cellfun(@min, {this.Fr(string({this.Fr.status})=="unused").t}));
        this.updateDisplay();
        
    case 'middleClick'
        % Select fragment (among visible)
        
        tmp = this.getFragment();
        if isnan(tmp), return; end
        this.fid = tmp;
        
        this.updateInfos;
        this.ui.action.String = "Fragment " + this.fid + " selected";
        this.prepareDisplay;
        this.updateDisplay;
        
    case 'leftClick'
        % Select trajectory (among visible)
        
        tmp = this.getFragment();
        if isnan(tmp) || ~isnumeric(this.Fr(tmp).status)
            this.ui.action.String = "Fragment not in a trajectory";
            return
        end
        this.tid = this.Fr(tmp).status;
        
        this.updateInfos;
        this.updateWarnings;
        this.ui.action.String = "Trajectory " + this.tid + " selected";
        this.prepareDisplay();
        this.updateDisplay();
        
    case 'centrosome'
        % Define point as centrosome
    
        % Find closest fragment and trajectory
        ti = round(get(this.ui.time, 'Value'));
        fid = this.getFragment();
        if isnan(fid), return; end
        
        i = find(this.Fr(fid).t==ti);
        this.Fr(fid).centrosome.idx{i} = this.Fr(fid).soma.idx{i};
        this.Fr(fid).centrosome.pos(i,:) = this.Fr(fid).soma.pos(i,:);
        this.Fr(fid).centrosome.fluo(i) = this.Fr(fid).soma.fluo(i);
        
        this.Fr(fid).soma.idx{i} = [];
        this.Fr(fid).soma.pos(i,:) = [NaN NaN];
        this.Fr(fid).soma.fluo(i) = NaN;

        this.updateWarnings;
        this.updateInfos;
        if isempty(this.doublons)
            this.prepareDisplay;
            this.updateDisplay;
        else
            this.input('n');
        end

    case 'cone'
        % Define point as cone
    
        % Find closest fragment and trajectory
        ti = round(get(this.ui.time, 'Value'));
        fid = this.getFragment();
        if isnan(fid), return; end
        
        i = find(this.Fr(fid).t==ti);
        this.Fr(fid).cone.idx{i} = this.Fr(fid).soma.idx{i};
        this.Fr(fid).cone.pos(i,:) = this.Fr(fid).soma.pos(i,:);
        this.Fr(fid).cone.fluo(i) = this.Fr(fid).soma.fluo(i);
        
        this.Fr(fid).soma.idx{i} = [];
        this.Fr(fid).soma.pos(i,:) = [NaN NaN];
        this.Fr(fid).soma.fluo(i) = NaN;

        this.updateWarnings;
        this.updateInfos;
        if isempty(this.doublons)
            this.prepareDisplay;
            this.updateDisplay;
        else
            this.input('n');
        end
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end