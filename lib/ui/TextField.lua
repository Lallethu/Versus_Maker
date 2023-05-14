local love = require('love')
local utf8 = require('utf8')
local Label = require('lib.ui.Label')
local U = require('lib.Utils')

local lg = love.graphics
local cursor = '|'

local TextField = Label:derive('TextField')

function TextField:new(x, y, w, h, text, place_holder, color, align, offset, multi_enter)
    TextField.super.new(self, x, y, w, h, text, color, align)
    self.focus = false
    self.offset = offset or false
    self.place_holder = place_holder or nil
    self.multi = multi_enter or false
    self.focused_color = U.color(0.375)
    self.unfocused_color = U.color(0.125)
    self.back_color = self.unfocused_color
    self.key_pressed = function(key)
        if key == 'backspace' then
            self:on_text_input(key)
        elseif key == 'return' or key == 'escape' then
            if self.focus then
                self:remove_end_chars(1)
                if self.multi and self.text ~= '' then
                    _G.events:invoke('onFieldSubmited', self)
                    self.text = '|'
                else
                    self.focus = false
                    self:set_focus(self.focus)
                end
            end
        end
    end
    self.text_input = function(text)
        self:on_text_input(text)
    end
end

function TextField:get_rect()
    return {x = self.pos.x, y = self.pos.y - self.h / 2, w = self.w, h = self.h}
end

function TextField:on_enter()
    _G.events:hook('key_pressed', self.key_pressed)
    _G.events:hook('text_input', self.text_input)
end

function TextField:on_exit()
    _G.events:unhook('key_pressed', self.key_pressed)
    _G.events:unhook('text_input', self.text_input)
end

function TextField:set_focus(focus)
    assert(type(focus) == 'boolean', 'focus should be of type boolean')
    if focus then
        self.back_color = self.focused_color
        if not self.focus then
            if self.text ~= '' then
                self.text = self.text .. cursor
            else
                self.text = cursor
            end
        end
    else
        self.back_color = self.unfocused_color
        if not focus and self.focus then
            self:remove_end_chars(1)
        end
    end
    self.focus = focus
end

function TextField:on_text_input(text)
    if not self.focus or not self.enabled then
        return
    end

    if text == 'backspace' then
        if self.text == cursor then
            return
        end
        self:remove_end_chars(2)
        self.text = self.text .. cursor
    else
        self:remove_end_chars(1)
        self.text = self.text .. text
        self.text = self.text .. cursor
    end
end

function TextField:remove_end_chars(num)
    local byteoffset = utf8.offset(self.text, -num)

    if byteoffset then
        self.text = string.sub(self.text, 1, byteoffset - 1)
    end
end

function TextField:get_value()
    return self.text
end

function TextField:draw()
    lg.setColor(self.back_color)

    if self.offset then
        love.graphics.rectangle('fill', self.pos.x - 8, self.pos.y - 19, self.w, self.h - 3)
    else
        love.graphics.rectangle('fill', self.pos.x - 8, self.pos.y - self.h / 2, self.w, self.h - 3)
    end

    TextField.super.draw(self)
    local f = love.graphics.getFont()
    local _, lines = f:getWrap(self.text, self.w)
    local fh = f:getHeight()

    if not self.focus and self.text == '' then
        love.graphics.printf(self.place_holder, self.pos.x, (self.pos.y - (fh / 2 * #lines)) - 2, self.w, self.align)
    else
        return
    end
end

return TextField
