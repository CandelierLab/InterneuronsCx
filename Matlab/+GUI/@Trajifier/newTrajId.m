function id = newTrajId(this)

tI = unique([this.Fr(cellfun(@isnumeric, {this.Fr.status})).status]);
tmp = sort(setdiff(1:(max(tI)+1), tI));
id = tmp(1);