//New (React.JS based) songsterr
function applyPatch(){
  if(window.__INITIAL_STATE__&&window.__INITIAL_STATE__.user)
    __INITIAL_STATE__.user.hasPlus=true;
}
let patcher = document.createElement('script');
patcher.innerHTML = applyPatch+';applyPatch()';
patcher.onload = function() {
    this.remove();
};
(document.head || document.documentElement).appendChild(patcher);
