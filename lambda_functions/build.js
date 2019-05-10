const fs = require('fs');
const archiver = require('archiver');
const glob = require("glob");

// create a file to stream archive data to.
const output = fs.createWriteStream(__dirname + '/example.zip');
const archive = archiver('zip');
output.on('close', () => {
  console.log(archive.pointer() + ' total bytes');
  console.log('archiver has been finalized and the output file descriptor has closed.');
});
output.on('end', () => {
    console.log('Data has been drained');
});
archive.on('warning', (err) =>  {throw err;});
archive.on('error',  (err) =>  {throw err;});
archive.pipe(output);
// 圧縮対象ファイル
const file1 = __dirname + '/file1.txt';
archive.append(fs.createReadStream(file1), { name: 'file1.txt' });
archive.finalize();