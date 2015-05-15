function Download(){
	var regexp = new RegExp("http\:\/\/www\.songsterr\.com\/a\/wsa\/");
	var res = regexp.test(window.location);
	if (res){
		id=document.documentElement.innerHTML.split("songId=")[1].split("&base=")[0];
		response="";
		var xhReq = new XMLHttpRequest();
 		xhReq.open("GET", "http://www.songsterr.com/a/ra/player/song/"+id+".xml", false);
 		xhReq.send(null);
 		response = xhReq.responseText;
    	url=response.split("<attachmentUrl>")[1].split("</attachmentUrl>")[0];
    	window.location=url;
    	alert("Started downloading.")
	}
	else
	{
		alert("Not on songsterr, cancelling.")
	}
}
chrome.browserAction.onClicked.addListener(function(tab) {
  chrome.tabs.executeScript({
    code: Download+'Download();'
  });
});
