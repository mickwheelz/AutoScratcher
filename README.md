# AutoScratcher
Simple NodeJS based tool to set up a scratch org, it pulls source, creates an org, pushes the source and runs an apex class after this is complete

Configuration for the tool is held in `config.json`, see below example

```javascript
{
	"gitURL": "git@github.com:mickwheelz/AutoScratcher.git",
	"gitBranch": "develop",
	"sourcePath": "AutoScratcher/",
	"aliasPrefix": "sprint",
	"aliasIncriment": 99,
	"scratchConfigPath": "/config/scratch-def.json",
	"apexClassPath": "example.cls"
}
```

The tool is executed by running `node index.js` and does the following

1. Pulls source code from branch (`gitBranch`) and repo (`gitURL`) specified in `config.json`
2. Creating new scratch org with alias of `aliaxPrefix` in `config.json` with the `aliasIncrement` added to the end, e.g `sprint99`
3. Pushes the cloned source code in to the newly created sctatch org
4. Executes the apex class specified in `apexClassPath` in `config.json`
5. Increments the `aliasIncriment` in `config.json` and saves it to disk
