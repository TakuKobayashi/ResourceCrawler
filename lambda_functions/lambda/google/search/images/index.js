const requireRoot = require('app-root-path').require;
const googleImageSearch = requireRoot("/libs/googleImageSearch");
const apiRenderTemplate = requireRoot("/libs/apiRenderTemplate");

exports.handler = async (event, context) => {
  const startTime = new Date();
  console.log(event);
  if(!event.q){
    return apiRenderTemplate("failed", startTime, {images: []});
  }
  const allSearchResults = await googleImageSearch.searchAllGoogleImages(event);

  return apiRenderTemplate("success", startTime, {images: allSearchResults});
};