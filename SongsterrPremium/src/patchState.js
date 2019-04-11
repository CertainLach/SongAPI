// ==UserScript==
// @name Songsterr premium hack
// @version 1.3
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
function f6cf___INITIAL_STATE___applyPatch() {

	setInterval(() => {
		// New patch (yay)
		Object.keys(window)
			.filter(k => /^_+[a-z0-9]+_+$/i.test(k))
			.forEach(
				k =>
					window[k] &&
					window[k].user &&
					window[k].user.hasPlus === false &&
					(window[k].user.hasPlus = true)
			);
	}, 1000);

	// Hook appendChild, to override added script (plus_features with demo_features)
	const _appendChild = Element.prototype.appendChild;
	let foundRootChunk = null;
	/// UNHARDCODE
	let demoChunkUrl = 'https://www.songsterr.com/static/js/demo-player-actions.9aebd905.js';
	let plusChunkId = 8;
	let demoEntry = 373;
	let plusEntry = 372;
	/// UNHARDCODE
	let plusChunkCode = null;

	setInterval(async () => {
		if (!foundRootChunk) {
			foundRootChunk = [...document.getElementsByTagName('script')].filter(s => s.src.includes('/static/js/main')).map(s => s.src)[0];
			if (foundRootChunk) {
				console.log('Extracting action chunk ids');
				fetch(foundRootChunk).then(e => e.text()).then(e => {
					// TODO: Extract currently hardcoded constants from e
					fetch(demoChunkUrl).then(e => e.text()).then(e => {
						console.log(e);
						e = e.replace(/webpackJsonp\|\|\[\]\).push\(\[\[([0-9]+)\]/, `webpackJsonp||[]).push([[${plusChunkId}]`);
						e = e.replace(/demo/g, 'plus');
						e = e.replace(demoEntry, plusEntry);
						plusChunkCode = e;
						console.log(e);
					});
				});
			}
		}
	}, 2000);
	Element.prototype.appendChild = function (...a) {

		if (a.length === 1) {
			let scriptNode = a[0];
			if (scriptNode.nodeName.toLowerCase() === 'script') {
				let src = scriptNode.src;
				console.log(`Loading script ${src}`);
				if (src.includes('plus-player-actions')) {
					console.log('PLUS ACTIONS LOADING! ALARM!!!');
					//const scriptCode = await fetch(src)
					// Simulate loading timeout
					if (plusChunkCode) {
						scriptNode.src = `data:application/javascript;charset=UTF-8,${encodeURIComponent(plusChunkCode)}`
					}
				}
			}
		}
		return _appendChild.call(this, ...a);
	};
}
let patcher = document.createElement("script");
patcher.innerHTML =
	f6cf___INITIAL_STATE___applyPatch + ";f6cf___INITIAL_STATE___applyPatch()";
(document.head || document.documentElement).appendChild(patcher);
