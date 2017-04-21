//Old songsterr compat
chrome.webRequest.onBeforeRequest.addListener(
  ()=>({redirectUrl: "https://www.songsterr.com/a/wa/enabledFeatures?songId=269"}),
  {
    urls: [
      "http://www.songsterr.com/a/wa/enabledFeatures?songId=*",
      "https://www.songsterr.com/a/wa/enabledFeatures?songId=*",
    ]
  },
  ["blocking"]
);
