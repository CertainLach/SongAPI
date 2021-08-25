// ==UserScript==
// @name Songsterr downloader
// @version 1.4
// @description Dosnload songs from songsterr.com
// @include *songsterr.com*
// @include songsterr.com*
// @include *songsterr.com
// @include songsterr.com
// @include www.songsterr.com*
// @include http://songsterr.com/*
// @include http://*.songsterr.com/*
// ==/UserScript==

function f6cf___INITIAL_STATE___getRevisionId() {
    // If custom revision is specified in url
    let revisionIdFromUrl = window.location.pathname.match(/r[0-9]+$/);
    if (revisionIdFromUrl)
        revisionIdFromUrl = revisionIdFromUrl[0];
    // Gets from server provided store in direct way, not available in extension
    // TODO: Support for changed store name
    let revisionIdFromState = window.__STATE__ && window.__STATE__.data && window.__STATE__.data.meta && window.__STATE__.data.meta.revisionId;
    // From flashvars
    let revisionIdForOldSongsterr = document.head.innerHTML.toString().match(/revision=([0-9]+)/);
    if (revisionIdForOldSongsterr)
        revisionIdForOldSongsterr = revisionIdForOldSongsterr[1];
    // From server provided store in page source level
    let revisionIdForNewSongsterr = document.body.innerHTML.toString().match(/"revisionId":([0-9]+)/);
    if (revisionIdForNewSongsterr)
        revisionIdForNewSongsterr = revisionIdForNewSongsterr[1];
    let revisionId = revisionIdFromUrl || revisionIdFromState || revisionIdForOldSongsterr || revisionIdForNewSongsterr;
    return revisionId;
}

function f6cf___INITIAL_STATE___download() {
    let revisionId = f6cf___INITIAL_STATE___getRevisionId();
    if (!revisionId) {
        alert('Couldn\'t get song revision id!');
        return;
    }
    let apiUrl = `https://www.songsterr.com/a/ra/player/songrevision/${revisionId}.xml`;
    // Using promise since old versions of chrome doesn't supports async/await
    fetch(apiUrl).then(res => res.text()).then(data => {
        let url = data.match(/<attachmentUrl>(.+?.gp[t354x])<\/attachmentUrl>/);
        if (!url) {
            alert('Couldn\'t find download url!');
            return;
        } else {
            url = [...url].slice(1);
        }
        let title = data.match(/<title>(.+?)<\/title>/);
        title = title ? title[1] : 'Unknown title';
        let artist = data.match(/<name>(.+?)<\/name>/);
        artist = artist ? artist[1] : 'Unknown artist';

        for (let urlVariant of url) {
            let format = urlVariant.split('.').slice(-1)[0];
            let name = `${artist} - ${title}.${format}`;
            fetch(urlVariant).then(res => res.blob()).then(blob => {
                // In case of CORS bypass available
                var a = new FileReader();
                a.onload = e => {
                    downloadURI(e.target.result, name);
                }
                a.readAsDataURL(blob);
            }).catch(e => {
                // CORS (In case of userscript)
                downloadURI(urlVariant, name);
            })
        }
    });

    function downloadURI(url, name) {
        let link = document.createElement('a');
        link.download = name;
        link.href = url;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}

// In case of chrome extension: listen for browserAction, in case of userscript - add download song button
if (this.chrome && this.chrome.browserAction) {
    function f6cf___INITIAL_STATE___bootstrapDownloader() {
        let revisionId = f6cf___INITIAL_STATE___getRevisionId();
        if (revisionId) {
            // Got revision without injection to page (New songsterr with revision id, or old songsterr)
            f6cf___INITIAL_STATE___download();
        } else {
            // Cant get a revision without injection (New songsterr)
            let patcher = document.createElement("script");
            patcher.innerHTML =
                f6cf___INITIAL_STATE___getRevisionId + ';' + f6cf___INITIAL_STATE___download + ";f6cf___INITIAL_" + "STATE___download()";
            (document.head || document.documentElement).appendChild(patcher);
        }
    }
    chrome.browserAction.onClicked.addListener(tab => {
        chrome.tabs.executeScript({
            code: f6cf___INITIAL_STATE___getRevisionId + ';' + f6cf___INITIAL_STATE___download + ';' + f6cf___INITIAL_STATE___bootstrapDownloader + ';f6cf___INITIAL_STATE___bootstrapDownloader()'
        });
    });
    const displayDownloadSongActionOnSongsterr = {
        conditions: [
            new chrome.declarativeContent.PageStateMatcher({
                pageUrl: { hostContains: 'songsterr.com' }
            })
        ],
        actions: [new chrome.declarativeContent.ShowPageAction()]
    };
    chrome.runtime.onInstalled.addListener((details) => {
        chrome.declarativeContent.onPageChanged.removeRules(undefined, function () {
            chrome.declarativeContent.onPageChanged.addRules([displayDownloadSongActionOnSongsterr])
        })
    });
} else {
    let button = document.createElement('button');
    button.innerText = 'Download this song';
    button.style = 'position: absolute; right: 0; top: 0';
    button.onclick = f6cf___INITIAL_STATE___download;
    document.body.appendChild(button);
}
