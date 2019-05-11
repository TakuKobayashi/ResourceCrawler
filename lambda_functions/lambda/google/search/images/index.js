const requireRoot = require('app-root-path').require;
const googleImageSearch = requireRoot("/libs/googleImageSearch")

exports.handler = async (event, context) => {
  console.log(event);
  if(!event.q){
    return [];
  }
  const allSearchResults = googleImageSearch.searchAllGoogleImages({q: event.q});

  return allSearchResults;
};