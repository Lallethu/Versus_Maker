local Dependence = {}
local os = require('os')

Dependence.SceneManager = require('lib.SceneMgr')
Dependence.Key = require('lib.Keyboard')
Dependence.Event = require('lib.Events')

Key = require('lib.Keyboard')
math.randomseed(os.time())

return Dependence
