//New (React.JS based) songsterr
function f6cf___INITIAL_STATE___applyPatch(){
    //New patch (yay)
    Object.keys(window).filter(k=>/^_[a-z0-9]+_$/i.test(k)).forEach(k=>window[k]&&window[k].user&&window[k].user.hasPlus===false&&(window[k].user.hasPlus=true));
    //I'll just leave it here
    if(window.__INITIAL_STATE__&&window.__INITIAL_STATE__.user)
        __INITIAL_STATE__.user.hasPlus=true;
}
let patcher = document.createElement('script');
patcher.innerHTML = f6cf___INITIAL_STATE___applyPatch+';f6cf___INITIAL_STATE___applyPatch()';
//Because it not always works as excepted
// patcher.onload = function() {
//     this.remove();
// };
(document.head || document.documentElement).appendChild(patcher);
