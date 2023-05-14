local U = require('lib.Utils')
local Class = require('lib.Class')
local Vector2 = require('lib.Vector2')

local lg = love.graphics
local lm = love.mouse
local line_width = 4
local padding = 10
local box_height_percentage = 0.9

local Checkbox = Class:derive('Checkbox')

function Checkbox:new(x, y, w, h, text, draw)
    self.pos = Vector2(x or 0, y or 0)
    self.w = w
    self.h = h
    self.text = text
    self.cb_height = self.h * box_height_percentage
    self.cb_width = self.cb_height
    self.checked = false
    self.draw_check = draw or false

    self.normal = U.gray(0.5, 1)
    self.highlight = U.gray(0.78, 1)
    self.pressed = U.gray(1, 1)
    self.disabled = U.gray(0.5, 0.5)

    self.color = self.normal
    self.prev_left_click = false
    self.interactible = true
end

function Checkbox:colors(normal, highlight, pressed, disabled)
    assert(type(normal) == 'table', 'normal parameter must be a table!')
    assert(type(highlight) == 'table', 'highlight parameter must be a table!')
    assert(type(pressed) == 'table', 'pressed parameter must be a table!')
    self.normal = normal
    self.highlight = highlight
    self.pressed = pressed
    self.disabled = disabled or self.disabled
end

function Checkbox:set_box(width, height)
    height = height or width
    self.cb_height = math.min(self.h, height)
    self.cb_width = math.min(self.w, width)
end

function Checkbox:enable(enabled)
    self.interactible = enabled
    if not enabled then
        self.color = self.disabled
    else
        self.color = self.normal
    end
end

function Checkbox:update(dt)
    if not self.interactible then
        return
    end

    local mx, my = lm.getPosition()
    local left_click = lm.isDown(1)
    local in_bounds = U.mouse_in_rect(mx, my, self.pos.x, self.pos.y, self.w, self.h)

    if in_bounds and not left_click then
        if self.prev_left_click and self.color == self.pressed then
            self.checked = not self.checked
            _G.events:invoke('onCheckboxClicked', self, self.checked)
        end
        self.color = self.highlight
    elseif in_bounds and left_click and not self.prev_left_click then
        self.color = self.pressed
    elseif not in_bounds then
        self.color = self.normal
    end

    self.prev_left_click = left_click
end

function Checkbox:draw()
    if self.draw_check then
        local r, g, b, a = lg.getColor()
        local f = lg.getFont()
        local _, lines = f:getWrap(self.text, self.w - (self.cb_width + padding))
        local fh = f:getHeight()
        local lw = lg.getLineWidth()

        lg.setColor(self.color)
        lg.setLineWidth(line_width)
        lg.rectangle('line', self.pos.x, self.pos.y, self.cb_width, self.cb_height, 5, 5)

        if self.checked then
            lg.rectangle(
                'fill',
                self.pos.x + line_width,
                self.pos.y + line_width,
                self.cb_width - 2 * line_width,
                self.cb_height - 2 * line_width
            )
        end

        lg.printf(
            self.text,
            self.pos.x + self.cb_width + padding,
            self.pos.y + self.h / 2 - (fh / 2 * #lines),
            self.w - (self.cb_width + padding),
            'left'
        )

        lg.setColor(r, g, b, a)
        lg.setLineWidth(lw)
    else
        return
    end
end

return Checkbox
