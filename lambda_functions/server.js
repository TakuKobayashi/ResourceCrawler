const express = require('express');
const app = express();

app.set("view engine", "ejs");

const port = process.env.PORT || 3000;

//wake up http server
const http = require('http');

//Enable to receive requests access to the specified port
const server = http.createServer(app).listen(port, function () {
  console.log('Server listening at port %d', port);
});

app.get('/', function(req, res){
  const data = {
    items: [
      {name: "<h1>リンゴ</h1>"},
      {name: "<h2>バナナ</h2>"},
      {name: "<h3>スイカ</h3>"}
    ]
  };
  res.render("./server.ejs", data);
});