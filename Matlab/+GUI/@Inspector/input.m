function input(this, key, value)
%INPUT User input


switch key
       
    case 'c'
        
        % --- Create line
        l = drawline(this.ui.image, 'color', 'w', 'Linewidth', 1);
    
        % --- Find closest shape
        
        p1 = l.Position(1,:);
        p2 = l.Position(2,:);
        
        D2 = NaN(numel(this.Sh),1);
        for k = 1:numel(this.Sh)
            [i,j] = ind2sub([this.Images.Height, this.Images.Width], this.Sh(k).idx);
            D2(k) = mean((j-p1(1)).^2  + (i-p1(2)).^2 + (j-p2(1)).^2  + (i-p2(2)).^2);            
        end
        [~, sid] = min(D2);
        
        % --- Cut shape
        
        [i,j] = ind2sub([this.Images.Height, this.Images.Width], this.Sh(sid).idx);
        U = [j-p1(1) i-p1(2) zeros(size(i))];
        V = repmat([p2-p1 0], [numel(i) 1]);
        W = cross(U, V);
        I1 = W(:,3)<=0;
        I2 = W(:,3)>0;
        
        if ~nnz(I1) || ~nnz(I2)
            this.ui.action.String = "Nothing to cut";
            pause(0.5);
            delete(l);
            return;
        end
        
        % New shape
        nid = numel(this.Sh)+1;
        this.Sh(nid).t = this.Sh(sid).t;
        this.Sh(nid).idx = this.Sh(sid).idx(I2);
        
        % Update shape
        this.Sh(sid).idx = this.Sh(sid).idx(I1);
        
        % --- Display
        
        this.computeShape(["contour", "pos"], [sid nid]);
        
        this.updateInfos;
        this.updateDisplay;

    case 'n'
        % New cell

        % --- Check former cell is complete
        if ~isnan(this.cid)
        
            % -- !! ---
            
        end
        
        this.cid = numel(this.Cell)+1;
        this.Cell(this.cid).t = this.ui.time.Value;
        this.step = 'soma';
        this.updateInfos;
        
    case 's'
        % Save shapes
% % %         this.saveFragments();
% % %         
% % %         this.ui.action.String = "Fragments saved @ " + datestr(now, 'hh:MM:ss');
        
        
    case 'leftarrow'
        % Time -1
        this.ui.time.Value = max(this.ui.time.Value-1, this.ui.time.Min);
        
        this.initShapes;
        this.updateInfos;
        this.updateDisplay();
        
    case 'rightarrow'
        % Time +1
        this.ui.time.Value = min(this.ui.time.Value+1, this.ui.time.Max);
        
        this.initShapes;
        this.updateInfos;
        this.updateDisplay();
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        this.updateDisplay();
    
    case 'pageup'
        % First free shape
% % %         this.ui.time.Value = min(cellfun(@min, {this.Fr(string({this.Fr.status})=="unused").t}));
% % %         this.updateDisplay();
        
    case 'leftClick'
        % Split shapes
        
        if ~isnan(this.cid)
        
            % Get closest
            p = this.mousePosition.image;
            [~, mi] = min((p(1)-[this.Sh.x]).^2 + (p(2)-[this.Sh.y]).^2);
            
            switch this.step
                
                case 'soma'
                     
                    this.Cell(this.cid).soma = struct(...
                        'idx', this.Sh(mi).idx, ...
                        'pos', [this.Sh(mi).x this.Sh(mi).y]);
                    
                    this.step = 'centrosome';
                    
                case 'centrosome'

                    this.Cell(this.cid).centrosome = struct(...
                        'idx', this.Sh(mi).idx, ...
                        'pos', [this.Sh(mi).x this.Sh(mi).y]);
                    
                    this.step = 'cones';
                    
                case 'cones'
                    
                    if isempty(this.Cell(this.cid).cones)
                        this.Cell(this.cid).cones = struct(...
                            'idx', this.Sh(mi).idx, ...
                            'pos', [this.Sh(mi).x this.Sh(mi).y]);
                    else
                        id = numel(this.Cell(this.cid).cones)+1;
                        this.Cell(this.cid).cones(id).idx = this.Sh(mi).idx;
                        this.Cell(this.cid).cones(id).pos = [this.Sh(mi).x this.Sh(mi).y];
                    end
                    
            end
       
            this.updateInfos;
            
        end
    
    case 'middleClick'
        % Select fragment (among visible)
        
        tmp = this.getFragment();
        if isnan(tmp), return; end
        this.fid = tmp;
        
        this.updateInfos;
        this.ui.action.String = "Fragment " + this.fid + " selected";
        this.prepareDisplay;
        this.updateDisplay;
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end