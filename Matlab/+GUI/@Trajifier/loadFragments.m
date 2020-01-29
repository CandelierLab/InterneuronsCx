function loadFragments(this)
%loadFragments Load fragments.

tmp = load(this.File.fragments);
this.Fr = tmp.Fr;
