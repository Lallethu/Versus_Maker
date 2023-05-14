local Class = require('lib.Class')
local U = require('lib.Utils')

local Entity = Class:derive('Entity')

function Entity:new(...)
    self.components = {}
    local components_to_add = {...}

    if #components_to_add > 0 then
        for i = 1, #components_to_add do
            self:add(components_to_add[i])
        end
    end
end

local function priority_compare(e1, e2)
    return e1.priority < e2.priority
end

function Entity:add(component, name)
    if U.contains(self.components, component) then
        return
    end

    component.priority = component.priority or 1
    component.started = component.started or false
    component.enabled = (component.enabled == nil) or component.enabled
    component.entity = self

    self.components[#self.components + 1] = component

    if name ~= nil and type(name) == 'string' and name.len() > 0 then
        assert(self[name] == nil, 'This entity already contains a component of name: ' .. name)
        self[name] = component
    elseif component.type and type(component.type) == 'string' then
        assert(self[component.type] == nil, 'This entity already contains a component of name: ' .. component.type)
        self[component.type] = component
    end

    if self.started and not component.started and component.enabled then
        component.started = true
        if component.on_start then
            component:on_start()
        end
    end

    -- Sorts components
    table.sort(self.components, priority_compare)
end

function Entity:remove(component)
    local i = U.index_of(self.components, component)
    if i == -1 then
        return
    end

    if component.on_remove then
        component:on_remove()
    end

    table.remove(self.components, i)

    if component.type and type(component.type) == 'string' then
        self[component.type] = nil
        component.entity = nil
    end
end

function Entity:on_start()
    for i = 1, #self.components do
        local component = self.components[i]
        if component.enabled then
            if not component.started then
                component.started = true
                if component.on_start then
                    component:on_start()
                end
            end
        end
    end
end

function Entity:update(dt)
    for i = 1, #self.components do
        if self.components[i].enabled and self.components[i].update then
            self.components[i]:update(dt)
        end
    end
end

function Entity:draw()
    for i = 1, #self.components do
        if self.components[i].enabled and self.components[i].draw then
            self.components[i]:draw()
        end
    end
end

return Entity
