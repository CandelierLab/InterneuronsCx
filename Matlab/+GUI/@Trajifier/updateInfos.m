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
    s = s + " [ " + string(I).join(' ') + "]";
else
    s = s + " [ empty ]";
end
S(end+1) = s;

% --- Selected fragment

if isnan(this.fid)
    s = 'No fragment selected.';
else
    s = "Fragment selected: "  + this.fid;
end
S(end+1) = s;

% Additional input
if exist('c', 'var')
    S(end+2) = c;
end

this.ui.info.String = S.join(newline);
