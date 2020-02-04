function updateInfos(this, c)

% --- Number of cells -----------------------------------------------------

switch numel(this.Cell)
    case 0
        S = "No cell defined";
    case 1
        S = "1 cell defined";
    otherwise
        S = numel(this.Cell) + " cells defined";
end

S(end+1) = "___________________________________" + newline;

% --- Current cell --------------------------------------------------------

if isnan(this.cid)
    S(end+1) = "No current cell";
else
    S(end+1) = "Current cell [" + this.cid + "]"; 
end

% --- Cell overview -------------------------------------------------------

if ~isnan(this.cid)
    
    % --- Soma
    
    if strcmp(this.step, 'soma')
        s = "* SOMA";
    else
        s = "* Soma";
    end
    
    if isempty(this.Cell(this.cid).soma)
        S(end+1) = s + " - undefined";
        nSo = 0;
    else
        S(end+1) = s + " - " + num2str(numel(this.Cell(this.cid).soma.idx)) + " pixels";
        nSo = numel(this.Cell(this.cid).soma.idx);
    end

    % --- Centrosome
    
    if strcmp(this.step, 'centrosome')
        s = "* CENTROSOME";
    else
        s = "* Centrosome";
    end
    
    if isempty(this.Cell(this.cid).centrosome)
        S(end+1) = s + " - undefined";
        nCe = 0;
    else
        S(end+1) = s + " - " + num2str(numel(this.Cell(this.cid).centrosome.idx)) + " pixels";
        nCe = numel(this.Cell(this.cid).centrosome.idx);
    end

    % --- Cones
    
    if strcmp(this.step, 'cones')
        s = "* CONES";
    else
        s = "* Cones";
    end
    
    nCo = 0;
    if isempty(this.Cell(this.cid).cones)
        S(end+1) = s + " - undefined";
    else
        S(end+1) = s + ":";
        for i = 1:numel(this.Cell(this.cid).cones)
            S(end+1) = " + " + num2str(numel(this.Cell(this.cid).cones(i).idx)) + " pixels";
            nCo = nCo + numel(this.Cell(this.cid).cones(i).idx);
        end
    end
    
    nTot = numel(this.Cell(this.cid).idx);
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
