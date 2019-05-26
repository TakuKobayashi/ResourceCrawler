const requireRoot = require('app-root-path').require;
const util = requireRoot("/libs/util");
const cheerio = require("cheerio");
const axios = require("axios");

const GOOGLE_SEARCH_ROOT_URL = "https://www.google.co.jp/search";
const USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36";
const LIMIT_SEARCH_MILLISECOND = 240000;
const MAX_REQUEST_SLEEP_MILLISECOND = 1000;

const searchGoogleToObjects = async function searchGoogleToObjects(searchParams){
  const response = await searchGoogle(searchParams);
  const $ = cheerio.load(response.data)
  const results = [];

  for(const element of Object.values($(".rg_meta"))){
    const meta = parseJSON($(element).text());
    if(!meta) continue;
    results.push({
      id: meta.id,
      relation_id: meta.rid,
      website_name: meta.st,
      title: meta.pt,
      describe: meta.s,
      website_url: meta.ru,
      image_url: meta.ou,
    });
  }
  return results;
}

exports.searchGoogleToObjects = searchGoogleToObjects;

exports.searchAllGoogleImages = async function searchAllGoogleImages(searchObj){
  let allSearchResults = [];
  let counter = 0;
  const startTime = new Date();
  while((new Date() - startTime) < LIMIT_SEARCH_MILLISECOND){
    const searchQueries = Object.assign({
      tbm: "isch",
      start: counter,
      ijn: Math.floor(counter / 100)
    }, searchObj);
    const requestStartTime = new Date();
    const searchResults = await searchGoogleToObjects(searchQueries);
    if(searchResults.length <= 0){
      break;
    }
    counter = counter + searchResults.length;
    allSearchResults = allSearchResults.concat(searchResults);
    const elapsedMilliSecond = new Date() - requestStartTime;
    if(elapsedMilliSecond < MAX_REQUEST_SLEEP_MILLISECOND){
      await util.sleep(elapsedMilliSecond);
    }
  }

  return allSearchResults;
}

async function searchGoogle(searchParams) {
  return axios.get(GOOGLE_SEARCH_ROOT_URL, {
    params: searchParams,
    headers: {
      'user-agent': USER_AGENT
    }
  });
}

function parseJSON(text){
  let json = null;
  try{
    json = JSON.parse(text);
  } catch (error) {
    //console.log(error);
  }
  return json;
}