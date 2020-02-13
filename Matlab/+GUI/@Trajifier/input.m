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
        
        this.Fr(k).all = this.Fr(fid).all(I);
        this.Fr(k).soma = this.Fr(fid).soma(I);
        this.Fr(k).centrosome = this.Fr(fid).centrosome(I);
        this.Fr(k).cones = this.Fr(fid).cones(I);
        
        % --- Trim fragment
        
        % Indexes
        I = this.Fr(fid).t<ti;
        
        this.Fr(fid).t = this.Fr(fid).t(I);
        this.Fr(fid).all = this.Fr(fid).all(I);
        this.Fr(fid).soma = this.Fr(fid).soma(I);
        this.Fr(fid).centrosome = this.Fr(fid).centrosome(I);
        this.Fr(fid).cones = this.Fr(fid).cones(I);
        
        % --- Save and display
        
        this.prepareDisplay;
        this.updateDisplay;
        
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
        
% % %     case 'w'
% % %         % Width of the local view
% % %         this.Visu.lsz = max(min(round(value), this.Images.Width), 10);
% % %         this.ui.menu.shortcuts.String = this.getControls();
        
    case 'z'
        % Zoom
        
        if isstruct(this.zoom)
            this.zoom = NaN;
            axis(this.ui.image, 'tight');
        else
            this.zoom = struct('pos', this.mousePosition.image, 'size', 30);
            axis([this.zoom.pos(1)-this.zoom.size ...
                this.zoom.pos(1)+this.zoom.size ...
                this.zoom.pos(2)-this.zoom.size ...
                this.zoom.pos(2)+this.zoom.size]);
        end
        
        this.updateDisplay;    
        
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
            if ~isempty(Traj)
                this.ui.time.Value = max(cat(1,this.Fr(Traj).t));
                this.updateDisplay();
            end
        end
        
    case 'downarrow'
        % Beginning of current trajectory
        
        if ~isnan(this.tid)
            Traj = find(string({this.Fr.status})==string(this.tid));
            if ~isempty(Traj)
                this.ui.time.Value = min(cat(1,this.Fr(Traj).t));
                this.updateDisplay();
            end
        end
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        this.updateDisplay();
    
    case 'pageup'
        % First unused fragment
        this.ui.time.Value
        this.ui.time.Value = min(cellfun(@min, {this.Fr(string({this.Fr.status})=="unused").t}));
        this.ui.time.Value
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
        this.ui.action.String = "Trajectory " + this.tid + " selected";
        this.prepareDisplay();
        this.updateDisplay();
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end