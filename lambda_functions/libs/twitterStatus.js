const requireRoot = require('app-root-path').require;
const util = requireRoot("/libs/util");

const Twitter = require("twitter-promise")
const twitter = new Twitter({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_BOT_ACCESS_TOKEN,
  access_token_secret: process.env.TWITTER_BOT_ACCESS_TOKEN_SECRET,
});

const getTweets = async function getTweets(searchParams){
  const result = await twitter.get({
    path: "search/tweets",
    params: searchParams,
  })
  return result;
};

exports.getTweets = getTweets;

const searchAllTweets = async function searchAllTweets(searchParams){
  let allSearchResults = [];
  let maxId = null;
  while(true){
    let err;
    const searchQueries = Object.assign({ count: 100, max_id: maxId }, searchParams)
    const searchResults = await getTweets("search/tweets", searchQueries).catch(error => err = error);
    maxId = searchResults.data.search_metadata.max_id;
    if(err || maxId <= 0){
      break;
    }
    allSearchResults = allSearchResults.concat(searchResults.data.statuses);
  }
  return allSearchResults;
};

exports.searchAllTweets = searchAllTweets;

exports.searchAllResourceTweets = async function searchAllResourceTweets(searchParams){
  const tweets = await searchAllTweets(searchParams);
  return filterResourceTweets(tweets);
};

const getAllTimelineTweets = async function getAllTimelineTweets(searchParams){
  let allSearchResults = [];
  let maxId = null;
  while(true){
    let err;
    const searchQueries = Object.assign({ count: 200, max_id: maxId }, searchParams)
    const searchResults = await getTweets("statuses/user_timeline", searchQueries).catch(error => err = error);
    if(searchResults.length > 0){
      maxId = searchResults[searchResults.length - 1].id;
    }else{
      maxId = 0;
    }
    if(err || maxId <= 0){
      break;
    }
    allSearchResults = allSearchResults.concat(searchResults.data.statuses);
  }
  return allSearchResults;
};

exports.getAllTimelineTweets = getAllTimelineTweets;

exports.getAllTimelineResourceTweets = async function getAllTimelineResourceTweets(searchParams){
  const tweets = await getAllTimelineTweets(searchParams);
  return filterResourceTweets(tweets);
};

function filterResourceTweets(tweets){
  return tweets.filter(function(tweet){
    if(tweet.entities.urls.length > 0){
      return true;
    }
    if(tweet.entities.media && tweet.entities.media.length > 0){
      return true;
    }
    if(tweet.extended_entities && tweet.extended_entities.media.length > 0){
      return true;
    }
    return false;
  });
}