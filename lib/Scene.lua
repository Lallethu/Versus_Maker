local Class = require('lib.Class')
local EntityMgr = require('lib.EntityMgr')

local Scene = Class:derive('Scene')

function Scene:new(scene_mgr)
    self.scene_mgr = scene_mgr
    self.em = EntityMgr()
end

function Scene:enter()
    self.em:on_enter()
end

function Scene:exit()
    self.em:on_exit()
end

function Scene:update(dt)
    self.em:update(dt)
end

function Scene:draw()
    self.em:draw()
end

function Scene:destroy()
end

return Scene
