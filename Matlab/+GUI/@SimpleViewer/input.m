function input(this, key, value)
%INPUT User input

switch key
        
    case ' '
        this.Visu.viewPlay = ~this.Visu.viewPlay;
        if this.Visu.viewPlay
            this.updateDisplay();
        end
        
    case 'leftarrow'
        % Time -1
        this.ui.time.Value = max(this.ui.time.Value-1, this.ui.time.Min);
        this.updateDisplay();
        
    case 'rightarrow'
        % Time +1
        this.ui.time.Value = min(this.ui.time.Value+1, this.ui.time.Max);
        this.updateDisplay();
        
    case 'pagedown'
        % Rewind
        this.ui.time.Value = this.ui.time.Min;
        this.updateDisplay();
        
    otherwise
        
        this.ui.action.String = "[Input] " + key;
        
end