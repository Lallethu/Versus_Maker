local Class = require('lib.Class')
local U = require('lib.Utils')

local EntityManager = Class:derive('EntityMgr')

local function layer_compare(e1, e2)
    return e1.layer < e2.layer
end

function EntityManager:new()
    self.entities = {}
end

function EntityManager:add(entity)
    if U.contains(self.entities, entity) then
        return
    end
    entity.layer = entity.layer or 1
    entity.started = entity.started or false
    entity.updated = entity.updated or false
    entity.enabled = (entity.enabled == nil) or entity.enabled
    self.entities[#self.entities + 1] = entity

    table.sort(self.entities, layer_compare)
end

function EntityManager:on_enter()
    for i = 1, #self.entities do
        local e = self.entities[i]
        if e.on_enter then
            e:on_enter()
        end
    end
end

function EntityManager:on_exit()
    for i = 1, #self.entities do
        local e = self.entities[i]
        if e.on_enter then
            e:on_exit()
        end
    end
end

function EntityManager:update(dt)
    for i = #self.entities, 1, -1 do
        local e = self.entities[i]

        if e.remove == true then
            e.remove = false
            if e.on_remove then
                e:on_remove()
            end
            table.remove(self.entities, i)
        end

        if e.enabled then
            if not e.started then
                if e.on_start then
                    e:on_start()
                end
                e.started = true
            else --if e.update then
                e:update(dt)
                e.updated = true
            end
        end
    end
end

function EntityManager:draw()
    for i = 1, #self.entities do
        if self.entities[i].enabled and self.entities[i].draw and self.entities[i].updated then
            self.entities[i]:draw()
        end
    end
end

return EntityManager
