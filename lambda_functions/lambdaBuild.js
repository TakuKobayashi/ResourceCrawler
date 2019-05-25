const fs = require('fs');
const path = require('path');
const archiver = require('archiver');
const glob = require("glob");

const requireRoot = require('app-root-path');
const lambdaRoutes = require(requireRoot + "/config/lambdaRoutes");

const archiveCompresser = function (platformName, projectName) {
  // create a file to stream archive data to.
  const output = fs.createWriteStream(platformName + '.zip');
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
  const filePathes = glob.sync(projectName + '/**/*.js');
  for (const filePath of filePathes) {
    const fileName = path.basename(filePath);
    archive.append(fs.createReadStream(filePath), {
      name: fileName
    });
  }

  archive.glob(projectName + '/**/*.js');
  archive.glob(requireRoot + '/libs/**/*.js');
  archive.glob(requireRoot + '/node_modules/**/');
  archive.finalize();
}

for (const plName of Object.keys(lambdaRoutes.projectToRoot)) {
  const projectPathes = glob.sync(requireRoot + lambdaRoutes.projectToRoot[plName]);
  for (const projectPath of projectPathes) {
    const projectName = path.basename(projectPath);
    archiveCompresser(plName, projectName);
  }
}