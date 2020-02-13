function exportTrajectories(this, varargin)

% Trajectory fragments and info
Fr = this.Fr(cellfun(@isnumeric, {this.Fr.status}));
nTraj = max([Fr.status]);

empty = struct('idx', {}, 'pos', {}, 'contour', {});
Tr(nTraj) = struct('id', [], 't', [], 'all', empty, 'soma', empty, 'centrosome', empty, 'cones', {{}});

for i = 1:nTraj
    
    % Identifier
    Tr(i).id = i;
    
    J = find([Fr.status]==i);
    
    for j = J
        
        % Times
        Tr(i).t = union(Tr(i).t, Fr(j).t);
        
        for k = 1:numel(Fr(j).t)
        
            ti = find(Tr(i).t==Fr(j).t(k));
            
            Tr(i).all(ti) = Fr(j).all(k);
            
            if ~isempty(Fr(j).soma(k))
                Tr(i).soma(ti) = Fr(j).soma(k);
            end
            
            if ~isempty(Fr(j).centrosome(k))
                Tr(i).centrosome(ti) = Fr(j).centrosome(k);
            end
            
            if ~isempty(Fr(j).cones{k})
                Tr(i).cones{ti} = Fr(j).cones{k};
            end
            
        end
        
    end
    
end

% Save
save(this.File.trajectories, 'Tr');
