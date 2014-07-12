require('coffee-script/register')
require('chai').should()

global.Sanbox = require('sandbox-runner')

global.treeConcat = require('../index.coffee')
