const fs = require('fs');
const path = require('path');
const archiver = require('archiver');
const glob = require("glob");

const archiveCompresser = function (platformName, projectName) {
  // create a file to stream archive data to.
  const output = fs.createWriteStream(__dirname + '/' + [platformName, projectName].join('_') + '.zip');
  const archive = archiver('zip');
  output.on('close', () => {
    console.log(archive.pointer() + ' total bytes');
    console.log('archiver has been finalized and the output file descriptor has closed.');
  });
  output.on('end', () => {
    console.log('Data has been drained');
  });
  archive.on('warning', (err) => {
    throw err;
  });
  archive.on('error', (err) => {
    throw err;
  });
  archive.pipe(output);
  const filePathes = glob.sync('./lambda/' + platformName + '/' + projectName + '/**/*.js');
  for (const filePath of filePathes) {
    const fileName = path.basename(filePath);
    archive.append(fs.createReadStream(filePath), {
      name: fileName
    });
  }

  //archive.glob('./lambda/' + platformName + '/' + projectName + '/**/*.js');
  archive.glob('./libs/**/*.js');
  archive.glob('node_modules/**/');
  archive.finalize();
}

const platformNames = ['LineBot', 'FacebookBot'];
for (const plName of platformNames) {
  const projectPathes = glob.sync('./lambda/' + plName + '/*');
  for (const projectPath of projectPathes) {
    const projectName = path.basename(projectPath);
    archiveCompresser(plName, projectName);
  }
}