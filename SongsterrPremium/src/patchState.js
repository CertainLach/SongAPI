// ==UserScript==
// @name Songsterr premium hack
// @version 1.2
// @description Patch redux state to get Songsterr premium features for free
// @include *songsterr.com*
// @include songsterr.com*
// @include *songsterr.com
// @include songsterr.com
// @include www.songsterr.com*
// @include http://songsterr.com/*
// @include http://*.songsterr.com/*
// ==/UserScript==

// New (React.JS based) songsterr
function f6cf___INITIAL_STATE___applyPatch(){
    setInterval(()=>{
        // New patch (yay)
        Object.keys(window).filter(k=>/^_+[a-z0-9]+_+$/i.test(k)).forEach(k=>window[k]&&window[k].user&&window[k].user.hasPlus===false&&(window[k].user.hasPlus=true));
    },1000);
}
let patcher = document.createElement('script');
patcher.innerHTML = f6cf___INITIAL_STATE___applyPatch+';f6cf___INITIAL_STATE___applyPatch()';
(document.head || document.documentElement).appendChild(patcher);
