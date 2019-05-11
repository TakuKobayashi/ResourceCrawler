const cheerio = require("cheerio");
const axios = require("axios");

const GOOGLE_SEARCH_ROOT_URL = "https://www.google.co.jp/search";
const USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36";

exports.handler = async (event, context) => {
  console.log(event);
  return event;
};

async function searchGoogleToObjects(searchParams){
  const response = await searchGoogle(searchParams);
  const $ = cheerio.load(response.data)
  const results = [];

  for(const element of Object.values($(".rg_meta"))){
    const meta = parseJSON($(element).text());
    if(!meta) continue;
    results.push({
      id: meta.id,
      relation_id: meta.rid,
      site_name: meta.st,
      title: meta.pt,
      describe: meta.s,
      url: meta.ru,
      image_url: meta.ou,
    });
  }
  return results;
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