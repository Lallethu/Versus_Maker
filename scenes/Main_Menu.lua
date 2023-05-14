local Scene = require('lib.Scene')
local Button = require('lib.ui.Button')
local Label = require('lib.ui.Label')
local CheckBox = require('lib.ui.Checkbox')
local U = require('lib.Utils')

local entered = false
local lg = love.graphics
local le = love.event
local la = love.audio
local sw = lg.getWidth()
local sh = lg.getHeight()
local volume_up = lg.newImage('assets/gfx/volume-up.png')
local volume_off = lg.newImage('assets/gfx/volume-off.png')

local MainMenu = Scene:derive('Menu')

function MainMenu:new(scene_mgr)
    MainMenu.super.new(self, scene_mgr)

    local btn_create = Button(sw / 2, sh / 2 - 30, 144, 46, 'Create A Versus')
    local btn_exit = Button(sw / 2, sh / 2 + 230, 140, 40, 'Exit')

    local game_title = Label(0, 120, lg.getWidth(), 40, 'Versus Maker')
    btn_create:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})
    btn_exit:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})
    self.check_box = CheckBox(1000, 650, 200, 40, 'azezaeaze')

    self.em:add(btn_create)
    self.em:add(btn_exit)
    self.em:add(self.check_box)
    self.em:add(game_title)

    self.click = function(btn)
        self:on_click(btn)
    end
    self.onCheck = function(box, value)
        self:on_check(box, value)
    end
end

function MainMenu:enter()
    MainMenu.super.enter(self)
    _G.events:hook('onBtnClick', self.click)
    _G.events:hook('onCheckboxClicked', self.onCheck)
end

function MainMenu:exit()
    MainMenu.super.exit(self)
    _G.events:unhook('onBtnClick', self.click)
    _G.events:unhook('onCheckboxClicked', self.onCheck)
end

function MainMenu:on_click(button)
    if button.text == 'Create A Versus' then
        self.scene_mgr:switch('Versus_Planification')
    elseif button.text == 'Exit' then
        le.quit()
    end
end

function MainMenu:on_check(box)
    if box.checked then
        lg.draw(volume_off, box.pos.x, box.pos.y)
        la.setVolume(0)
    else
        lg.draw(volume_up, box.pos.x, box.pos.y)
        la.setVolume(0.37687)
    end
end

function MainMenu:update(dt)
    self.super.update(self, dt)

    if Key:key_down('escape') then
        le.quit()
    end
end

function MainMenu:draw()
    self.super.draw(self)
    _G.events:invoke('onCheckboxClicked', self.check_box)
end

return MainMenu
