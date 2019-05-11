const requireRoot = require('app-root-path').require;
const googleImageSearch = requireRoot("/libs/googleImageSearch")

exports.handler = async (event, context) => {
  const startTime = new Date();
  console.log(event);
  if(!event.q){
    return {
      message: "failed",
      executed_millisecond: (new Date() - startTime),
      params: event,
      results: [],
      timestamp: new Date().getTime(),
    };
  }
  const allSearchResults = await googleImageSearch.searchAllGoogleImages({q: event.q});

  return {
    message: "success",
    executed_millisecond: (new Date() - startTime),
    params: event,
    results: allSearchResults,
    timestamp: new Date().getTime(),
  }
};