const cheerio = require("cheerio");
const axios = require("axios");
const url = require("url");

const requireRoot = require('app-root-path').require;
const apiRenderTemplate = requireRoot("/libs/apiRenderTemplate");

exports.handler = async (event, context) => {
  const startTime = new Date();
  console.log(event);
  if(!event.image_url || !event.image_url){
    return apiRenderTemplate("failed", startTime, {
      reverse_images: {},
      websites: [],
    });
  }
  const searchResult = searchReverseImages(event);

  return apiRenderTemplate("success", startTime, searchResult);
};

async function searchReverseImages(searchParams){
  // 初期化
  const reverseImageObject = {
    response_url: "",
    suggest_word: "",
    image_query_tag: "",
    candidates: [],
    relative_image_search_query: "",
  };
  const response = await requestReverseImage(searchParams);
  reverseImageObject.response_url = response.request.res.responseUrl;
  const $ = cheerio.load(response.data);
  for(const searchElement of Object.values($("form").find("input"))){
    const ele = $(searchElement);
    // 今検索しているキーワード
    if(ele.attr("name") === "q"){
      reverseImageObject.suggest_word = ele.attr("value");
    // 指定した画像につけられた検索キー
    }else if(ele.attr("name") === "tbs"){
      reverseImageObject.image_query_tag = ele.attr("value");
    }
  }

  const candidates = []
  for(const candidateElement of Object.values($(".r5a77d").find("a"))){
    const ele = $(candidateElement);
    if(!ele.attr("href")) continue;
    candidates.push({
      url: ele.attr("href"),
      keyword: ele.text(),
    })
  }
  reverseImageObject.candidates = candidates;

  for(const relationElement of Object.values($("#imagebox_bigimages"))){
    const ele = $(relationElement);
    const relationImageSearchPath = ele.find("h3").find("a").attr("href")
    if(relationImageSearchPath){
      // ここで出てきたQueryをそのまま画像検索のAPIに投げてくれれば、それはそれでやる形にする
      reverseImageObject.relative_image_search_query = url.parse(relationImageSearchPath).query;
      break;
    }
  }

  const websites = scrapeGoogleWebsites(response.data);
  return {
    reverse_images: reverseImageObject,
    websites: websites,
  };
}

async function scrapeGoogleWebsites(html){
  const $ = cheerio.load(html);
  const websites = [];
  for(const element of Object.values($("#search").find("a"))){
    const ele = $(element);
    const linkAttributes = ele.attr();
    if(!linkAttributes || !linkAttributes.ping) continue;
    const h3Ele = ele.find("h3");
    // 存在しないものは検索結果ではない
    if(!h3Ele.attr()) continue;
    // 入れ子になっているものは検索結果の情報ではない
    if(h3Ele.children().length > 0) continue;
    websites.push({
      url: linkAttributes.href,
      title: h3Ele.text(),
    });
  }
}

async function requestReverseImage(searchParams) {
  return axios.get(GOOGLE_REVERSE_SEARCH_ROOT_URL, {
    params: searchParams,
    headers: {
      'user-agent': USER_AGENT
    }
  });
}