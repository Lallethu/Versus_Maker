local love = require('love')
local Class = require('lib.Class')
local Vector2 = require('lib.Vector2')
local U = require('lib.Utils')

local lg = love.graphics
local la = love.audio
local snd_btn_hover = la.newSource('assets/sfx/btn-hover-sfx.wav', 'static')

local function mouse_in_bounds(self, mx, my)
    return mx >= self.pos.x - self.w / 2 and mx <= self.pos.x + self.w / 2 and my >= self.pos.y - self.h / 2 and
        my <= self.pos.y + self.h / 2
end

local Button = Class:derive('Button')

function Button:new(x, y, w, h, text, render)
    self.pos = Vector2(x or 0, y or 0)
    self.w = w or 16
    self.h = h or 16
    self.render = (render == nil) or true
    self.text = text

    self.normal = U.color(0.5, 0.125, 0.125, 0.75)
    self.highlight = U.color(0.75, 0.125, 0.125, 1)
    self.pressed = U.color(1, 0.125, 0.125, 1)
    self.disabled = U.gray(0.4, 0.4)

    self.text_normal = U.color(1)
    self.text_disabled = U.gray(0.5, 1)

    self.text_color = self.text_normal
    self.color = self.normal
    self.prev_left_click = false
    self.interactible = true
end

function Button:text_colors(normal, disabled)
    assert(type(normal) == 'table', 'normal parameter must be a table!')
    assert(type(disabled) == 'table', 'disabled parameter must be a table!')

    self.text_normal = normal
    self.text_disabled = disabled
end

function Button:colors(normal, highlight, pressed, disabled)
    assert(type(normal) == 'table', 'normal parameter must be a table!')
    assert(type(highlight) == 'table', 'highlight parameter must be a table!')
    assert(type(pressed) == 'table', 'pressed parameter must be a table!')

    self.normal = normal
    self.highlight = highlight
    self.pressed = pressed
    self.disabled = disabled or self.disabled
end

function Button:left(x)
    self.pos.x = x + self.w / 2
end

function Button:top(y)
    self.pos.y = y + self.h / 2
end

function Button:enable(enabled)
    self.interactible = enabled
    if not enabled then
        self.color = self.disabled
        self.text_color = self.text_disabled
    else
        self.text_color = self.text_normal
    end
end

function Button:create_outline(color)
    color = color or U.color(1, 1, 1, 1)
    assert(type(color) == 'table', 'color must be a table with four values : R 0-1, G 0-1, B 0-1, A 0-1')
    love.graphics.setColor(color)
    love.graphics.rectangle('line', self.pos.x - self.w / 2, self.pos.y - self.h / 2, self.w, self.h, 4, 4)
    love.graphics.setColor(1, 1, 1, 1)
end

function Button:update(dt)
    if not self.interactible then
        return
    end

    local mx, my = love.mouse.getPosition()
    local left_click = love.mouse.isDown(1)
    local in_bounds = mouse_in_bounds(self, mx, my)

    if in_bounds and not left_click then
        if self.prev_left_click and self.color == self.pressed then
            _G.events:invoke('onBtnClick', self)
            la.play(snd_btn_hover)
        end
        self.color = self.highlight
    elseif in_bounds and left_click and not self.prev_left_click then
        self.color = self.pressed
    elseif not in_bounds then
        self.color = self.normal
    end

    self.prev_left_click = left_click
end

function Button:draw()
    if not self.render then
        return
    else
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(self.color)
        love.graphics.rectangle('fill', self.pos.x - self.w / 2, self.pos.y - self.h / 2, self.w, self.h, 4, 4)

        local f = love.graphics.getFont()
        local _, lines = f:getWrap(self.text, self.w)
        local fh = f:getHeight()

        love.graphics.setColor(self.text_color)
        love.graphics.printf(self.text, self.pos.x - self.w / 2, self.pos.y - (fh / 2 * #lines), self.w, 'center')
        love.graphics.setColor(r, g, b, a)
    end
end

return Button
