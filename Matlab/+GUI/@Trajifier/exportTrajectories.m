function exportTrajectories(this, varargin)

% Trajectory fragments and info
Fr = this.Fr(cellfun(@isnumeric, {this.Fr.status}));
nT = (max([Fr.status]));

% Prepare trajectory structure
empty = struct('idx', {{}}, 'pos', NaN(0,2), 'fluo', []);
tmp = repmat({empty}, [nT 1]);
Tr = struct('id', [], 't', [], 'soma', tmp, 'centrosome', tmp, 'cone', tmp);

for ti = 1:this.Images.number

    I = cellfun(@(x) ismember(ti,x), {Fr.t});
    for i = find(I)
        
        tid = Fr(i).status;
        j = find(Fr(i).t==ti, 1);
        k = find(Tr(tid).t==ti,1);
        
        if isempty(k)
            
            k = numel(Tr(tid).t) + 1;
            
            Tr(tid).t(k) = ti;
            
            Tr(tid).soma.idx{k} = [];
            Tr(tid).soma.pos(k,:) = [NaN NaN];
            Tr(tid).soma.fluo(k) = NaN;
            
            Tr(tid).centrosome.idx{k} = [];
            Tr(tid).centrosome.pos(k,:) = [NaN NaN];
            Tr(tid).centrosome.fluo(k) = NaN;
            
            Tr(tid).cone.idx{k} = [];
            Tr(tid).cone.pos(k,:) = [NaN NaN];
            Tr(tid).cone.fluo(k) = NaN;
            
        end
        
        if ~isnan(Fr(i).soma.pos(j,1))
            Tr(tid).soma.idx{k} = Fr(i).soma.idx{j};
            Tr(tid).soma.pos(k,:) = Fr(i).soma.pos(j,:);
            Tr(tid).soma.fluo(k) = Fr(i).soma.fluo(j);
        end
        
        if ~isnan(Fr(i).centrosome.pos(j,1))
            Tr(tid).centrosome.idx{k} = Fr(i).centrosome.idx{j};
            Tr(tid).centrosome.pos(k,:) = Fr(i).centrosome.pos(j,:);
            Tr(tid).centrosome.fluo(k) = Fr(i).centrosome.fluo(j);
        end
        
        if ~isnan(Fr(i).cone.pos(j,1))
            Tr(tid).cone.idx{k} = Fr(i).cone.idx{j};
            Tr(tid).cone.pos(k,:) = Fr(i).cone.pos(j,:);
            Tr(tid).cone.fluo(k) = Fr(i).cone.fluo(j);
        end
        
    end
end

% Save
save(this.File.trajectories, 'Tr');
