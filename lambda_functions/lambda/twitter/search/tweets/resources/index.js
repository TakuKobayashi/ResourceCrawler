const requireRoot = require('app-root-path').require;
const twitterStatus = requireRoot("/libs/twitterStatus");
const apiRenderTemplate = requireRoot("/libs/apiRenderTemplate");

exports.handler = async (event, context) => {
  const startTime = new Date();
  console.log(event);
  if(!event.q || !event.user_id || !event.screen_name){
    return apiRenderTemplate("failed", startTime, convertToTweetToResources([]));
  }
  let allSearchResults = []
  if(event.user_id || event.screen_name){
    allSearchResults = await twitterStatus.getAllTimelineResourceTweets(event);
  }else{
    allSearchResults = await twitterStatus.searchAllResourceTweets(event);
  }

  return apiRenderTemplate("success", startTime, convertToTweetToResources(allSearchResults));
};

function convertToTweetToResources(tweets){
  const twitterWebsites = []
  const twitterImages = []
  const twitterVideos = []
  for(const tweet of tweets){
    for(const website_url of tweet.entities.urls){
      twitterWebsites.push({
        id: tweet.id.toString(),
        user_id: tweet.user.id.toString(),
        user_name: tweet.user.screen_name,
        tweet: tweet.text,
        website_url: website_url,
      })
    }
    if(tweet.extended_entities){
      for(const twitterMedia of tweet.extended_entities.media){
        if(twitterMedia.video_info){
          twitterVideos.push({
            id: tweet.id.toString(),
            user_id: tweet.user.id.toString(),
            user_name: tweet.user.screen_name,
            tweet: tweet.text,
            duration_millis: twitterMedia.video_info.duration_millis,
            thumbnail_image_url: twitterMedia.media_url_https,
            videos: twitterMedia.video_info.variants.map(variant => {
              return {
                url: variant.url,
                bitrate: variant.bitrate,
              }
            }),
          })
        } else {
          twitterImages.push({
            id: tweet.id.toString(),
            user_id: tweet.user.id.toString(),
            user_name: tweet.user.screen_name,
            tweet: tweet.text,
            image_url: twitterMedia.media_url_https,
          })
        }
      }
    }
    return {
      websites: twitterWebsites,
      images: twitterImages,
      videos: twitterVideos,
    };
  }
}