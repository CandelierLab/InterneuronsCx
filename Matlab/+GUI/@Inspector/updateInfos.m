function updateInfos(this, c)

% --- Current cell --------------------------------------------------------

if isnan(this.cid)
    S = "No current cell";
else
    S = "Current cell [" + this.cid + "]"; 
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
    else
        S(end+1) = s + " - " + num2str(numel(this.Cell(this.cid).soma.idx)) + " pixels";
    end

    % --- Centrosome
    
    if strcmp(this.step, 'centrosome')
        s = "* CENTROSOME";
    else
        s = "* Centrosome";
    end
    
    if isempty(this.Cell(this.cid).centrosome)
        S(end+1) = s + " - undefined";
    else
        S(end+1) = s + " - " + num2str(numel(this.Cell(this.cid).centrosome.idx)) + " pixels";
    end

    % --- Cones
    
    if strcmp(this.step, 'cones')
        s = "* CONES";
    else
        s = "* Cones";
    end
    
    if isempty(this.Cell(this.cid).cones)
        S(end+1) = s + " - undefined";
    else
        S(end+1) = s + ":";
        for i = 1:numel(this.Cell(this.cid).cones)
            S(end+1) = " + " + num2str(numel(this.Cell(this.cid).cones(i).idx)) + " pixels";
        end
        
    end
    
    S(end+1) = newline + "Unassigned: " + num2str(0) + " pixels";
    S(end+1) = newline + "Total: " + num2str(0) + " pixels";
    
end

% --- Additional input
if exist('c', 'var')
    S(end+1) = "";
    S(end+1) = c;
end

this.ui.info.String = S.join(newline);
