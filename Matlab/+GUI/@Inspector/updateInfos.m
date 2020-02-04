function updateInfos(this, c)

% --- Number of Blobs & cells ---------------------------------------------

switch numel(this.Blob)
    case 0
        S = "No shape defined";
    case 1
        S = "1 shape defined";
    otherwise
        S = numel(this.Blob) + " shapes defined";
end

switch numel(this.Unit)
    case 0
        S(end+1) = "No cell defined";
    case 1
        S(end+1) = "1 cell defined";
    otherwise
        S(end+1) = numel(this.Unit) + " cells defined";
end

S(end+1) = "___________________________________" + newline;

% --- Current cell --------------------------------------------------------

if isnan(this.uid)
    S(end+1) = "No current cell";
else
    S(end+1) = "Current cell [" + this.uid + "]"; 
end

% --- Cell overview -------------------------------------------------------

if ~isnan(this.uid)
    
    % --- Soma
    
    if strcmp(this.step, 'soma')
        s = "* SOMA";
    else
        s = "* Soma";
    end
    
    if isempty(this.Unit(this.uid).soma)
        S(end+1) = s + " - undefined";
        nSo = 0;
    else
        S(end+1) = s + " - " + num2str(numel(this.Unit(this.uid).soma.idx)) + " pixels";
        nSo = numel(this.Unit(this.uid).soma.idx);
    end

    % --- Centrosome
    
    if strcmp(this.step, 'centrosome')
        s = "* CENTROSOME";
    else
        s = "* Centrosome";
    end
    
    if isempty(this.Unit(this.uid).centrosome)
        S(end+1) = s + " - undefined";
        nCe = 0;
    else
        S(end+1) = s + " - " + num2str(numel(this.Unit(this.uid).centrosome.idx)) + " pixels";
        nCe = numel(this.Unit(this.uid).centrosome.idx);
    end

    % --- Cones
    
    if strcmp(this.step, 'cones')
        s = "* CONES";
    else
        s = "* Cones";
    end
    
    nCo = 0;
    if isempty(this.Unit(this.uid).cones)
        S(end+1) = s + " - undefined";
    else
        S(end+1) = s + ":";
        for i = 1:numel(this.Unit(this.uid).cones)
            S(end+1) = " + " + num2str(numel(this.Unit(this.uid).cones(i).idx)) + " pixels";
            nCo = nCo + numel(this.Unit(this.uid).cones(i).idx);
        end
    end
    
    nTot = numel(this.Unit(this.uid).all.idx);
    nNa = nTot - nSo - nCe - nCo;
    
    S(end+1) = newline + "Unassigned: " + nNa + " pixels";
    S(end+1) = newline + "Total: " + nTot + " pixels";
    
end

% --- Additional input
if exist('c', 'var')
    S(end+1) = "";
    S(end+1) = c;
end

this.ui.info.String = S.join(newline);
