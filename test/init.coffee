require "#{ __dirname }/../app/globals"
supertest = require 'supertest'

global.sinon = require 'sinon'
global.chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chaiSinon = require 'sinon-chai'
chaiThings = require 'chai-things'
chai.use(chaiAsPromised)
chai.use(chaiSinon)
chai.use(chaiThings)
chai.should()
global.helpers = require './helpers'
global.testData = helpers.testData
global.expressRequest  = require 'mock-express-request'
global.expressResponse = require 'mock-express-response'
global.apiBaseUrl = process.env.API_HOST or "http://localhost:3000/v1"
global.api = supertest(apiBaseUrl)
global._ = require 'lodash'