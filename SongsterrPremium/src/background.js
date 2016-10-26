//Old songsterr compat
chrome.webRequest.onBeforeRequest.addListener(
  ()=>{
    {redirectUrl: "http://www.songsterr.com/a/wa/enabledFeatures?songId=269"}
  },
  {
    urls: [
      "http://www.songsterr.com/a/wa/enabledFeatures?songId=*"
    ]
  },
  ["blocking"]
);
