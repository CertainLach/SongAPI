var unlocked="http://www.songsterr.com/a/wa/enabledFeatures?songId=269"
var base="http://www.songsterr.com/a/wa/enabledFeatures?songId=*"
chrome.webRequest.onBeforeRequest.addListener(
  function(info) {
    console.log("Checked permissions: " + info.url);
    console.log("Redirected to " + unlocked);
    return {redirectUrl: unlocked};
  },
  {
    urls: [
      base
    ]
  },
  ["blocking"]
);
