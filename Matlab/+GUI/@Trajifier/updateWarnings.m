function updateWarnings(this, varargin)

dlim = 15;

% --- Time overlaps

Traj = find(string({this.Fr.status})==string(this.tid));
T = cat(1,this.Fr(Traj).t);
[~,I] = unique(T);
doublons = unique(T(setdiff(1:numel(T),I)));

% --- Refine doublons

for i = 1:numel(doublons)
    
    tmp = false(numel(Traj),1);
    for j = Traj        
        k = find(this.Fr(j).t==doublons(i), 1, 'first');
        if ~isempty(k)
            tmp(j) = ~isnan(this.Fr(j).soma.pos(k,1));
        end
    end
    
    if nnz(tmp)<=1
        doublons(i) = NaN;
    end
end

this.doublons = doublons(~isnan(doublons));

% --- Update display

if isempty(this.doublons)
    
    W = "";
    
else
    
    W = string(numel(this.doublons));
    
    if numel(this.doublons) < dlim
        W = W + " doublons [ " + sprintf('%i ', this.doublons) + "]";
    else
        W = W + " doublons [ " + sprintf('%i ', this.doublons(1:dlim)) + "...]";
    end
    
end

this.ui.warnings.String = W.join(newline);