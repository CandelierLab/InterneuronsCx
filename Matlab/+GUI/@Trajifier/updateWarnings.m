function updateWarnings(this, varargin)

dlim = 15;

W = 'TO DO !!';

% % % % --- Check for overlaps ------------------------------------------
% % % 
% % % T = cat(1,Fr(Traj).t);
% % % [~,I] = unique(T);
% % % doublons = unique(T(setdiff(1:numel(T),I)));
% % % 
% % % if ~isempty(doublons)
% % %     
% % %     W = [W num2str(numel(doublons))];
% % %     
% % %     if numel(doublons) < dlim
% % %         W = [W ' doublons [ ' sprintf('%i ', doublons) ']' newline];
% % %     else
% % %         W = [W ' doublons [ ' sprintf('%i ', doublons(1:dlim)) '...]' newline];
% % %     end
% % %     
% % % end

this.ui.warnings.String = W;