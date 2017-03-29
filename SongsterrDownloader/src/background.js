function f6cf___INITIAL_STATE___download(){
	let id = window.location.pathname.split('-').slice(-1)[0].substr(1).split('t')[0]*1;
	let apiUrl = `https://www.songsterr.com/api/v2/song/${id}`;
	// Using promise since old versions of chrome doesn't supports async/await
	fetch(apiUrl).then(res=>res.json()).then(data=>{
		let format=data.source.split('.').slice(-1)[0];
		let artist=data.artist || 'Unknown artist';
		let title=data.title || 'Unknown title';
		let name=`${artist} - ${title}.${format}`;
		console.log(name);
		downloadURI(data.source, name); 
		// Well, chrome uses content-disposition instead of normal name...
		// Because: http://stackoverflow.com/questions/23872902/chrome-download-attribute-not-working
		// TODO: Proxy download url to songsterr origin
	});

	function downloadURI(url, name) {
		let link = document.createElement('a');
		link.download = name;
		link.href = url;
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
		//delete link; because this line is useless, since garbage collector autimaticelly remove them
	}
}
chrome.browserAction.onClicked.addListener(tab=>{
  chrome.tabs.executeScript({
    code: f6cf___INITIAL_STATE___download+';f6cf___INITIAL_STATE___download();'
  });
});
