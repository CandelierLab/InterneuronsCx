function input(this, key, value)
%INPUT User input

switch key
       
    case 'c'
        
        % --- Create line
        l = drawline(this.ui.image, 'color', 'w', 'Linewidth', 1);
    
        % --- Find closest shape
        
        p1 = l.Position(1,:);
        p2 = l.Position(2,:);
        
        D2 = NaN(numel(this.Blob),1);
        for k = 1:numel(this.Blob)
            [i,j] = ind2sub([this.Images.Height, this.Images.Width], this.Blob(k).idx);
            D2(k) = mean((j-p1(1)).^2  + (i-p1(2)).^2 + (j-p2(1)).^2  + (i-p2(2)).^2);            
        end
        [~, bid] = min(D2);
        sid = this.Blob(bid).sid;
        
        % --- Cut shape
        
        [i,j] = ind2sub([this.Images.Height, this.Images.Width], this.Blob(bid).idx);
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
        
        % --- New shape
        
        nbid = numel(this.Blob)+1;
        nsid = numel(this.Shape)+1;
        
        % New Shape
        this.Shape(nsid).t = this.Shape(sid).t;
        this.Shape(nsid).idx = this.Blob(bid).idx(I2);
        
        % New blob
        this.Blob(nbid).sid = nsid;
        this.Blob(nbid).idx = this.Blob(bid).idx(I2);
        
        % --- Update current
        
        % Shape
        this.Shape(sid).idx = this.Blob(bid).idx(I1);
        
        % Blob
        this.Blob(bid).idx = this.Blob(bid).idx(I1);
        
        % --- Update display
        
        this.compute('Blob', ["pos", "contour"], [bid nbid]);        
        this.updateInfos;
        this.updateDisplay;

    case 'f'
        % Cell to shapes (unit to blobs)
        
        % --- Get unit id
        
        p = this.mousePosition.image;
        all = [this.Unit.all];
        pos = [all.pos];
        [~, uid] = min(([pos.x]-p(1)).^2 + ([pos.y]-p(2)).^2);
        
        % --- Define regions
        
        Mask = zeros(this.Images.Height, this.Images.Width);
        Mask(this.Unit(uid).all.idx) = 1;
        R = bwconncomp(Mask);
        for i = 1:numel(R.PixelIdxList)
        
            % --- Convert Unit to shapes
            
            sid = numel(this.Shape)+1;
            this.Shape(sid).t = this.ui.time.Value;
            this.Shape(sid).idx = R.PixelIdxList{i};
            
            % --- Convert Unit to blobs
            
            bid = numel(this.Blob)+1;
            this.Blob(bid).sid = sid;
            this.Blob(bid).idx = R.PixelIdxList{i};
            this.compute('Blob', ["pos", "contour"], bid);
        
        end
            
        % --- Delete cell & unit
        
        this.Cell(this.Unit(uid).cid) = [];
        this.Unit(uid) = [];
        
        % Update subsequent indexing
        for i = uid:numel(this.Unit)
            this.Unit(i).cid = this.Unit(i).cid-1;
        end
        
        % --- Display
        
        this.updateInfos;
        this.updateDisplay;

    case 'm'
        % Merge shapes
        
        % --- Blobs of interest
        
        p = GUI.ginputWhite(2);
        D1 = NaN(numel(this.Blob),1);
        D2 = NaN(numel(this.Blob),1);
        for k = 1:numel(this.Blob)
            D1(k) = (this.Blob(k).pos.x-p(1,1)).^2 + (this.Blob(k).pos.y-p(1,2)).^2;
            D2(k) = (this.Blob(k).pos.x-p(2,1)).^2 + (this.Blob(k).pos.y-p(2,2)).^2;
        end
        
        % Blob identifiers
        [~, bid1] = min(D1);
        [~, bid2] = min(D2);
        
        % Shapes identifiers
        sid1 = this.Blob(bid1).sid;
        sid2 = this.Blob(bid2).sid;
        
        % --- Merge shapes
        
        this.Shape(sid1).idx = union(this.Shape(sid1).idx, this.Shape(sid2).idx);
        this.Shape(sid2) = [];
        
        % --- Merge blobs 
        
        this.Blob(bid1).idx = union(this.Blob(bid1).idx, this.Blob(bid2).idx);
        this.compute('Blob', ["pos", "contour"], bid1);
        this.Blob(bid2) = [];
        
        % Update subsequent indexes
        for i = bid2:numel(this.Blob)
            this.Blob(i).sid = this.Blob(i).sid-1;
        end
        
        % --- Display
        
        this.updateInfos;
        this.updateDisplay();
        
    case 'n'
        % Add soma to current cell

        append('soma');
        
    case 'j'
        % Add centrosome to current cell

        append('centrosome');
        
    case 'k'
        % Add cone to current cell

        append('cone')

    case ','
        % Add undefined region to current cell

        append('undefined');

        
    case 's'
        % Save Shapes and Cells
        
        this.saveShapes();
        this.saveCells();
        this.ui.action.String = "Shapes & Cells saved @ " + datestr(now, 'hh:MM:ss');
        
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
        
    case 'A'
        % Set all remaining shapes to somas
              
        sid = NaN(numel(this.Blob),1);        
        for i = 1:numel(this.Blob)
            
            % Create a Unit
            uid = numel(this.Unit)+1;
            this.Unit(uid).t = this.ui.time.Value;
            this.Unit(uid).all = struct('idx', this.Blob(i).idx, ...
                'pos', this.Blob(i).pos, ...
                'contour', this.Blob(i).contour);
            this.Unit(uid).soma = this.Unit(uid).all;
            
            % Create a Cell
            ncid = numel(this.Cell)+1;
            this.Cell(ncid).t = this.ui.time.Value;
            this.Cell(ncid).all = this.Unit(uid).all;
            this.Cell(ncid).soma = this.Unit(uid).soma;
            this.Cell(ncid).centrosome = this.Unit(uid).centrosome;
            this.Cell(ncid).cones = this.Unit(uid).cones;
        
            sid(i) = this.Blob(i).sid;
            
        end
        
        % Delete Shapes
        this.Shape(sid) = [];
        
        this.loadTime;
        this.updateInfos;
        this.updateDisplay();
        
    case 'leftarrow'
        % Time -1
        
        if ~isnan(this.uid)
            this.input('return');
        end
        
        this.ui.time.Value = max(this.ui.time.Value-1, this.ui.time.Min);
        
        this.loadTime;
        this.updateInfos;
        this.updateDisplay();
        
    case 'rightarrow'
        % Time +1
        
        if ~isnan(this.uid)
            this.input('return');
        end
        
        this.ui.time.Value = min(this.ui.time.Value+1, this.ui.time.Max);
        
        this.loadTime;
        this.updateInfos;
        this.updateDisplay();
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        
        this.loadTime;
        this.updateInfos;
        this.updateDisplay();
    
    case 'pageup'
        % First free shape
        
        this.ui.time.Value = min([this.Shape.t]);
        
        this.loadTime;
        this.updateInfos;
        this.updateDisplay();
        
    case {'return', 'rightClick'}
        % End cell selection
        
        if ~isnan(this.uid)
                
            % --- Store cell
            
            if isempty(this.Unit(this.uid).all.idx)
                this.Unit(this.uid) = [];
            else
                ncid = numel(this.Cell)+1;
                this.Cell(ncid).t = this.ui.time.Value;
                this.Cell(ncid).all = this.Unit(this.uid).all;
                this.Cell(ncid).soma = this.Unit(this.uid).soma;
                this.Cell(ncid).centrosome = this.Unit(this.uid).centrosome;
                this.Cell(ncid).cones = this.Unit(this.uid).cones;
            end
            
            % --- Updates
            
            this.uid = NaN;
            this.updateInfos;
            this.updateDisplay;
            
        end
        
    case 'delete'
        % Delete shape
        
        % --- Get blob id
        
        p = this.mousePosition.image;
        pos = [this.Blob.pos];
        [~, bid] = min(([pos.x]-p(1)).^2 + ([pos.y]-p(2)).^2);
                
        % --- Delete shape
        
        this.Shape(this.Blob(bid).sid) = [];
        
        % --- Delete blob
        
        this.Blob(bid) = [];
        
        % --- Reassign blob subsequent indexes
        
        for i = bid:numel(this.Blob)
            this.Blob(i).sid = this.Blob(i).sid-1;
        end
        
        % --- Display
        
        this.updateInfos;
        this.updateDisplay;
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end

    function append(w)
        
        % Cell definition (if needed)
        if isnan(this.uid)
            this.uid = numel(this.Unit)+1;
            this.Unit(this.uid).t = this.ui.time.Value;
            this.Unit(this.uid).all = struct('idx', [], 'pos', [], 'contour', []);
        end
        
        % Get closest
        p = this.mousePosition.image;
        pos = [this.Blob.pos];
        [~, bid] = min((p(1)-[pos.x]).^2 + (p(2)-[pos.y]).^2);
        
        % Define element
        
        switch w
        
            case {'soma', 'centrosome'}
                this.Unit(this.uid).(w) = struct(...
                    'idx', this.Blob(bid).idx, ...
                    'pos', this.Blob(bid).pos, ...
                    'contour',  this.Blob(bid).contour);
                
            case 'cone'
                if isempty(this.Unit(this.uid).cones)
                    this.Unit(this.uid).cones = struct(...
                        'idx', this.Blob(bid).idx, ...
                        'pos', this.Blob(bid).pos, ...
                        'contour',  this.Blob(bid).contour);
                else
                    id = numel(this.Unit(this.uid).cones)+1;
                    this.Unit(this.uid).cones(id).idx = this.Blob(bid).idx;
                    this.Unit(this.uid).cones(id).pos = this.Blob(bid).pos;
                    this.Unit(this.uid).cones(id).contour = this.Blob(bid).contour;
                end
        end
        
        % Update 'all' in unit        
        this.Unit(this.uid).all.idx = union(this.Unit(this.uid).all.idx, ...
            this.Blob(bid).idx);
        this.compute('Unit', ["pos", "contour"], this.uid);
        
        % --- Remove shape
        
        % Remove shape
        this.Shape(this.Blob(bid).sid) = [];
        
        % Remove blob
        this.Blob(bid) = [];
        
        % Update subsequent blob indexing
        for ii = bid:numel(this.Blob)
            this.Blob(ii).sid = this.Blob(ii).sid-1;
        end
        
        % --- Display
        
        this.updateInfos;
        this.updateDisplay; 
        
    end

end