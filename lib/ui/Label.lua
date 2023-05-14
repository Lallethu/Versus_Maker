local Class = require('lib.Class')
local Vector2 = require('lib.Vector2')
local U = require('lib.Utils')

local Label = Class:derive('Label')

function Label:new(x, y, w, h, text, color, align)
    self.pos = Vector2(x or 0, y or 0)
    self.w = w
    self.h = h
    self.text = text
    self.color = color or U.color(1)
    self.align = align or 'center'
end

function Label:update(dt)
end

function Label:draw()
    local f = love.graphics.getFont()
    local _, lines = f:getWrap(self.text, self.w)
    local fh = f:getHeight()

    love.graphics.setColor(self.color)
    love.graphics.printf(self.text, self.pos.x, (self.pos.y - (fh / 2 * #lines)) - 2, self.w, self.align)
end

return Label
