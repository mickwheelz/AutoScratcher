const child_process = require('child_process');
var fs = require('fs');
let config = require('./config.json');

//SFDX commands
const jsonOption = ' --json';
const fileOption = ' -f ';
const aliasOption = ' -a ';
const usernameOption = ' -u ';
const noPropmtOption = '  --noprompt ';
const pushSourceCommand = 'sfdx force:source:push ';
const executeApexCommand = 'sfdx force:apex:execute ';
const createOrgCommand = 'sfdx force:org:create ';
const deleteOrgCommand = 'sfdx force:org:delete ';

//GIT consts
const cloneRepo = 'git clone ';
const branchOption = ' -b ';

//file consts
const deleteFiles = 'rm -rf ';

//Msg consts
const finishedMsg = 'Finished, Cleaning Up...';

//incerease the sprint number by 1
config.aliasIncriment = config.aliasIncriment+1;

let sprintName = config.aliasPrefix + config.aliasIncriment

console.log('*** Welcome ***');
console.log('This tool with set up a scratch org for you, based on the configuation in config.json in the root directory in which it runs')
console.log('We will create a scratch org with alias \'' + sprintName +'\'');
console.log('Then push the source code from branch \'' + config.gitBranch +'\'' + ' in repo \'' + config.gitURL + '\'' + ' to the org');
console.log('Finally, it will run the apex code in \'' + config.apexClassPath +'\'' + ' in the org');

console.log();
console.log('LETS GO!');
console.log();
console.log('Step 1 - Pulling source code from branch \'' + config.gitBranch + '\'' + ' in repo \'' + config.gitURL + '\'');

try {
    child_process.execSync(cloneRepo + branchOption + config.gitBranch + ' ' + config.gitURL);
}
catch(e) {
    console.log('*** Something went wrong with Step 1 ***');
    console.log(e);
    console.log(finishedMsg);
    child_process.execSync(deleteFiles + config.sourcePath);
}
console.log('Step 1 Complete');
console.log();

console.log('Step 2 - Creating new scratch org with alias \'' + sprintName + '\'');

let resultJSON = JSON.parse(child_process.execSync(createOrgCommand + fileOption + config.sourcePath + config.scratchConfigPath + aliasOption + sprintName + jsonOption));

if (resultJSON.status == 0) {
    console.log('Org Successfully Created, Username: \'' + resultJSON.result.username + '\'' + ', Org Id: \'' + resultJSON.result.orgId + '\'');
    console.log('Step 2 Complete');
    console.log();

    console.log('Step 3 - Pushing source code from: \'' + config.sourcePath + '\'' + ' to org: \'' + resultJSON.result.orgId + '\' with username: \'' + resultJSON.result.username + '\'');
    let pushResultJSON = JSON.parse(child_process.execSync(pushSourceCommand + usernameOption + resultJSON.result.username + jsonOption, {cwd: config.sourcePath}));
    if (pushResultJSON.status == 0) {
        console.log('Source code push completed successfully!')
        console.log('Step 3 Complete');
        console.log();

        console.log('Step 4 - Now executing apex class \'' + config.apexClassPath + '\'');
        let execResultJSON = JSON.parse(child_process.execSync(executeApexCommand + usernameOption + resultJSON.result.username + fileOption + config.apexClassPath + jsonOption));
        if (execResultJSON.result.compiled == true || execResultJSON.result == 0) {
            console.log('Apex class \'' + config.apexClassPath + '\' succesfully ran, your org is now ready!');
            console.log('Step 4 Complete');
            console.log();

            console.log('Step 5 - Updating Config File and Cleaning Up');
            fs.writeFile('config.json', JSON.stringify(config), 'utf8', function(err, data) {
                if (err){
                    console.log('*** Something went wrong updating config, details below ***');
                    console.log(err)
                }
                else {
                    console.log(finishedMsg);
                    child_process.execSync(deleteFiles + config.sourcePath);
                    console.log('All Steps Complete, Goodbye!')
                }
            });
        }
        else {
            console.log('*** Something went wrong with Step 4, details below***');
            console.log(JSON.stringify(execResultJSON));
            console.log(finishedMsg);
            child_process.execSync(deleteFiles + config.sourcePath);
        }
    }
    else {
        console.log('*** Something went wrong in Step 3, details below ***');
        console.log(JSON.stringify(pushResultJSON));
        console.log(finishedMsg);
        child_process.execSync(deleteFiles + config.sourcePath);
    }
}
else {
    console.log('*** Something went wrong in Step 2, details below ***');
    console.log(JSON.stringify(resultJSON));
    console.log(finishedMsg);
    child_process.execSync(deleteFiles + config.sourcePath);
}