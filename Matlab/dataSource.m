function DS = dataSource()

p = mfilename('fullpath');
P = strsplit(p, filesep);

DS = struct();
DS.root = [strjoin(P(1:end-3), filesep) filesep];
DS.data = [DS.root 'Data' filesep];