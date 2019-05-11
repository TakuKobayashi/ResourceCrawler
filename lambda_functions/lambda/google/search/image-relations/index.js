const cheerio = require("cheerio");
const axios = require("axios");
const url = require("url");

const requireRoot = require('app-root-path').require;
const googleImageSearch = requireRoot("/libs/googleImageSearch")

const GOOGLE_RELATION_SEARCH_ROOT_URL = "https://www.google.com/async/imgrc";
const USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36";

exports.handler = async (event, context) => {
  const startTime = new Date();
  console.log(event);
  if(!event.id || !event.relation_id){
    return {
      message: "failed",
      executed_millisecond: (new Date() - startTime),
      params: event,
      results: [],
      timestamp: new Date().getTime(),
    };
  }
  const relationPath = await getRelationSearchUrl({docid: event.relation_id, imgdii: event.id, async: "_fmt:prog"});
  if(!relationPath){
    return {
      message: "failed",
      executed_millisecond: (new Date() - startTime),
      params: event,
      results: [],
      timestamp: new Date().getTime(),
    };
  }
  const relationUrl = url.parse(relationPath, true);
  const allSearchResults = await googleImageSearch.searchAllGoogleImages(relationUrl.query);

  return {
    message: "success",
    executed_millisecond: (new Date() - startTime),
    params: event,
    results: allSearchResults,
    timestamp: new Date().getTime(),
  };
};

async function getRelationSearchUrl(searchParams){
  const response = await searchRelationImages(searchParams);
  const $ = cheerio.load(response.data);
  for(const element of Object.values($("a"))){
    const urlString = $(element).attr("href");
    // URLを探してあれば、そのURLを使うようにする
    if(urlString){
      return urlString;
    }
  }
  return null;
}

async function searchRelationImages(searchParams) {
  return axios.get(GOOGLE_RELATION_SEARCH_ROOT_URL, {
    params: searchParams,
    headers: {
      'user-agent': USER_AGENT
    }
  });
}