function saveFragments(this)
%saveFragments Save fragments

Fr = this.Fr;
save(this.File.fragments, 'Fr');       

