require('./spec_helper')

fakeFs = require('./FakeVinylFs')
runInSanbox = require('./sanboxRunner')

xdescribe 'concat json', ->