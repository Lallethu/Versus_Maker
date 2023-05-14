--REQUIRES
local Scene = require('lib.Scene')
local Button = require('lib.ui.Button')
local Label = require('lib.ui.Label')
local TextField = require('lib.ui.TextField')
local U = require('lib.Utils')

title = ''
local entered = false
local lg = love.graphics
local le = love.event
local la = love.audio
local sw = lg.getWidth()
local sh = lg.getHeight()
local inputs = {}
participants = {}
local snd_remove = la.newSource('assets/sfx/remove-sfx.wav', 'static')

local VersusPlanning = Scene:derive('Planification')

function VersusPlanning:new(scene_mgr)
    VersusPlanning.super.new(self, scene_mgr)

    local label_name = Label(262, 120, 175, 40, 'Versus Title :', {1, 1, 1, 1}, 'left')
    self.TextField_name = TextField(426, 120, 215, 40, '', 'Enter a Versus Name', {1, 1, 1}, 'left')

    local label_players = Label(253, 200, 175, 40, 'Players Name :', {1, 1, 1, 1}, 'left')
    self.TextField_players = TextField(426, 200, 215, 40, '', 'Name', {1, 1, 1}, 'left', false, true)

    local label_remove_name = Label(246, 500, 175, 40, 'Remove a Name :', {1, 1, 1, 1}, 'left')
    self.TextField_remove_name =
        TextField(426, 500, 238, 40, '', 'Player Name to Remove', {1, 1, 1}, 'left', false, true)

    local label_players_list = Label(790, 50, 240, 40, 'List of Participants :', {1, 1, 1, 1}, 'left')

    self.btn_start = Button(sw / 2 + 360, sh / 2 + 20, 140, 50, 'Sorting Teams')
    self.btn_start:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})

    local btn_back = Button(sw / 2, sh / 2 + 230, 140, 40, 'Back To Menu')
    btn_back:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})

    self.players_list_back_rect = TextField(785, 85, 240, 275, '', '', {1, 1, 1}, 'left', true, false)

    self.em:add(btn_back)
    self.em:add(self.btn_start)
    self.em:add(label_name)
    self.em:add(self.TextField_name)
    self.em:add(label_remove_name)
    self.em:add(self.TextField_remove_name)
    self.em:add(label_players)
    self.em:add(self.players_list_back_rect)
    self.em:add(self.TextField_players)
    self.em:add(label_players_list)

    inputs.txf_name = self.TextField_name
    inputs.txf_remove_name = self.TextField_remove_name
    inputs.txf_players = self.TextField_players

    self.click = function(btn)
        self:on_click(btn)
    end
    self.field_submited = function(field_text)
        self:on_field_submited(field_text)
    end
    self.tbl_field = function(value)
        self:on_tbl_filled(value)
    end
end

function VersusPlanning:enter()
    VersusPlanning.super.enter(self)
    for i = 1, 10 do
        participants[i] = ''
    end
    _G.events:hook('onBtnClick', self.click)
    _G.events:hook('onFieldSubmited', self.field_submited)
    _G.events:hook('onTblFilled', self.tbl_field)
end

function VersusPlanning:exit()
    VersusPlanning.super.exit(self)
    _G.events:unhook('onBtnClick', self.click)
    _G.events:unhook('onFieldSubmited', self.field_submited)
    _G.events:unhook('onTblFilled', self.tbl_field)
end

function VersusPlanning:on_click(button)
    if button.text == 'Sorting Teams' then
        if participants[10] ~= '' and title ~= '' then
            self.TextField_name.text = ''
            self.scene_mgr:switch('Versus_Tree')
        end
    end
    if button.text == 'Back To Menu' then
        self.scene_mgr:switch('Main_Menu')
    end
end

function VersusPlanning:on_field_submited(field_text)
    _G.events:invoke('onTblFilled', self.TextField_players, field_text)
    if field_text.place_holder == 'Player Name to Remove' then
        for i, v in pairs(participants) do
            if participants[i] ~= '' then
                if field_text.text == participants[i] then
                    table.remove(participants, i)
                    table.insert(participants, #participants + 1, '')
                    la.play(snd_remove)
                end
            else
                return
            end
        end
    end
end

function VersusPlanning:on_tbl_filled(value)
    for i = 1, #participants do
        if participants[i] == '' then
            participants[i] = value.text
            return
        end
    end
end

local prev_down = false
function VersusPlanning:update(dt)
    VersusPlanning.super.update(self, dt)

    local mx, my = love.mouse.getPosition() -- Gets the X and Y mouse coordonates
    local down = love.mouse.isDown(1) -- Returns true if left click else false

    if down and not prev_down then -- If left click was just pressed do stuff
        for _, item in pairs(inputs) do
            local index_offset = 10
            if U.point_in_rect({x = mx, y = my}, item:get_rect()) then
                item:set_focus(true)
            else
                item:set_focus(false)
            end
        end
    end
    prev_down = down
end

local function set_table_list(self, x, y, w, h, list)
    local offset = 0
    x = x
    y = y
    w = w
    h = h
    for _, participant in pairs(list) do
        list.label = Label(x, y + offset, 240, 40, participant, {1, 1, 1, 1}, 'center'):draw()
        offset = offset + 24
    end
end

function VersusPlanning:draw()
    VersusPlanning.super.draw(self)
    set_table_list(self, 770, 94, 240, 40, participants)
    --print(title)
    title = self.TextField_name.text
    if participants[10] ~= '' and title ~= '' and title ~= '|' then
        self.btn_start:create_outline({0, 2235294117647059, 0, 5803921568627451, 0, 0705882352941176, 1})
    end
end

return VersusPlanning
--
