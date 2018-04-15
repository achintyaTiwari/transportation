# Horse API

Getting started:
---
1. Make sure Node.js and NPM installed.
2. Run `npm install` to install project dependencies.
3. Copy `config/template.json` to `config/development.json` and fill in your configuration.
4. Run `grunt dev`, the API should be up and running on the configured port.
5. Run `grunt test`, to run the test cases.

Deployment:
---
1. We use [pm2](https://www.npmjs.com/package/pm2) for process management and deployment
2. Add appropriate ssh key to your ssh agent `ssh-add <PATH_TO_SSH_KEY>`
3. Run `pm2 deploy <ENV>` to deploy the code.
4. On a new server you should setup the deployment environment by running `pm2 deploy <ENV> setup`
5. Where ENV can be any of the following,
    * development
    * staging
    * production 