--REQUIRES
local love = require('love')
local utf8 = require('utf8')
local Scene = require('lib.Scene')
local Button = require('lib.ui.Button')
local Label = require('lib.ui.Label')
local TextField = require('lib.ui.TextField')
local U = require('lib.Utils')
--

--Locals
local lg = love.graphics
local ls = love.system
local sw = lg.getWidth()
local sh = lg.getHeight()
local img = lg.newImage('assets/gfx/redraw-team.png')
local vs_title = ''
local team_1 = {}
local team_2 = {}
local buffer_1 = ''
local buffer_2 = ''
--

--VsTree
local VersusTree = Scene:derive('Tree')

local function randomiseTable(tbl, count)
    local n = #tbl
    for k = 1, count do
        for i = n - 5, n, 1 do
            local j = math.random(1, 10)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end
end

function VersusTree:new(scene_mgr)
    VersusTree.super.new(self, scene_mgr)

    for i = 1, 5, 1 do
        team_1[i] = ''
        team_2[i] = ''
    end

    self.btn_redraw = Button(sw / 2, sh / 2 + 130, 60, 60, 'Redraw')
    self.btn_redraw:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})
    self.btn_redraw.render = false

    local btn_back = Button(sw / 2, sh / 2 + 230, 140, 40, 'Back to Menu')
    btn_back:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})

    self.btn_copy = Button(sw / 2 + 360, sh / 2 + 120, 140, 50, 'Copy to Clipboard')
    self.btn_copy:colors({0.4, 0.4, 0.4, 1}, {0.28, 0.28, 0.28, 1}, {0.21, 0.21, 0.21, 1})
    self.btn_copy.color = self.btn_copy.disabled
    self.btn_copy.interactible = false

    self.label_name = Label(sw / 2 - 260 / 2, 105, 260, 50, '', {1, 1, 1, 1}, 'center')
    self.label_team1 = Label(76, 185, 260, 50, 'Team 1 :', {1, 1, 1, 1}, 'center')
    self.label_team2 = Label(780, 185, 260, 50, 'Team 2 :', {1, 1, 1, 1}, 'center')

    self.players_list_team_1_back_rect = TextField(85, 185, 240, 275, '', '', {1, 1, 1}, 'left', true, false)
    self.players_list_team_2_back_rect = TextField(785, 185, 240, 275, '', '', {1, 1, 1}, 'left', true, false)

    self.em:add(self.label_name)
    self.em:add(self.players_list_team_1_back_rect)
    self.em:add(self.label_team1)
    self.em:add(self.players_list_team_2_back_rect)
    self.em:add(self.label_team2)
    self.em:add(self.btn_copy)
    self.em:add(btn_back)
    self.em:add(self.btn_redraw)
    self.click = function(btn)
        self:on_click(btn)
    end
end

function VersusTree:remove_end_chars(num, b1, b2)
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset_1 = utf8.offset(b1, -num)
    local byteoffset_2 = utf8.offset(b2, -num)
    if byteoffset_1 then
        b1 = string.sub(b1, 1, byteoffset_1 - 1)
    end
    if byteoffset_2 then
        b2 = string.sub(b2, 1, byteoffset_2 - 1)
    end
end

function VersusTree:copyToClipBoard()
    ls.setClipboardText('')
    buffer_1 = ''
    buffer_2 = ''
    for i = 1, #team_1 do
        buffer_1 = buffer_1 .. team_1[i] .. ', '
        if i == #team_1 then
            self:remove_end_chars(2, buffer_1, '')
        end
    end
    for k = 6, #team_2 do
        buffer_2 = buffer_2 .. team_2[k] .. ', '
        if k == #team_2 then
            self:remove_end_chars(1, '', buffer_2)
        end
    end
    ls.setClipboardText('Team 1 : ' .. buffer_1 .. '\n' .. 'Team 2 : ' .. buffer_2)
end

function VersusTree:enter()
    VersusTree.super.enter(self)
    _G.events:hook('onBtnClick', self.click)
end

function VersusTree:exit()
    VersusTree.super.exit(self)
    _G.events:unhook('onBtnClick', self.click)
end

function VersusTree:on_click(btn)
    if btn.text == 'Back to Menu' then
        self.scene_mgr:switch('Main_Menu')
        for i = 1, 10 do
            participants[i] = ''
        end
        for i = 1, 10 do
            team_1[i] = ''
            team_2[i] = ''
        end

        buffer_1 = ''
        buffer_2 = ''
    end

    if btn.text == 'Redraw' then
        randomiseTable(participants, 10)
        for i = 1, 5 do
            team_1[i] = participants[i]
        end
        for j = 6, 10 do
            team_2[j] = participants[j]
        end
        self.btn_copy.interactible = true
        self.btn_copy.color = self.btn_copy.normal
        buffer_1 = ''
        buffer_2 = ''
    end

    if btn.text == 'Copy to Clipboard' then
        self:copyToClipBoard()
    end
end

function VersusTree:update(dt)
    self.super.update(self, dt)
end

local function set_table_list(x, y, w, h, list)
    local offset = 0
    x = x
    y = y
    w = w
    h = h
    for _, participant in pairs(list) do
        list.label = Label(x, y + offset, w, h, participant, {1, 1, 1, 1}, 'center'):draw()
        offset = offset + 28
    end
end

function VersusTree:draw()
    self.super.draw(self)
    self.label_name.text = 'Original Player Pool for : ' .. title
    set_table_list(sw / 2 - 240 / 2, 180, 240, 40, participants)
    set_table_list(76, 238, 240, 275, team_1)
    set_table_list(785, 98, 240, 275, team_2)
    lg.draw(img, self.btn_redraw.pos.x - 48 / 2, self.btn_redraw.pos.y - 48 / 2)
end

return VersusTree
