function updateInfos(this, c)

% Trajectory indexes
tI = unique([this.Fr(cellfun(@isnumeric, {this.Fr.status})).status]);

% --- Trajectories

switch numel(tI)
    case 0, S = "No trajectory defined.";
    case 1, S = "1 trajectory defined.";
    otherwise, S = numel(tI) + " trajectories defined.";
end

% --- Current trajectory

s = "Current trajectory " + this.tid;
I = find(cellfun(@(x) isnumeric(x) && x==this.tid, {this.Fr.status}));
if numel(I)
    t1 = min(cellfun(@min, {this.Fr(I).t}));
    t2 = max(cellfun(@max, {this.Fr(I).t}));
    s = s + " [" + string(I).join(' ') + "] from t=" + t1 + " to t=" + t2;
else
    s = s + " [empty]";
end
S(end+1) = s;
S(end+1) = "";

% --- Selected fragment

if isnan(this.fid)
    S(end+1) = 'No fragment selected.';
else
    S(end+1) = "Fragment selected: "  + this.fid;
    
    nt = numel(this.Fr(this.fid).t);
    t1 = min(this.Fr(this.fid).t);
    t2 = max(this.Fr(this.fid).t);
    S(end+1) = nt + " positions from t=" + t1 + " to t=" + t2;
    
end

% --- Additional input
if exist('c', 'var')
    S(end+1) = "";
    S(end+1) = c;
end

this.ui.info.String = S.join(newline);
