local love = require('love')
local Dependencies = require('dependencies')
local SceneManager
local Events

local lg = love.graphics
local la = love.audio
local font = lg.newFont('assets/fonts/Sono-Medium.ttf', 20)
local logo = lg.newImage('assets/gfx/icon.png')
local VERSION = '--Release[v.1.0.0]--'

function love.load()
    la.setVolume(0.37687)
    lg.setFont(font)
    Key:hook_love_events()
    
    Events = Dependencies.Event
    _G.events = Events(false)

    SceneManager = Dependencies.SceneManager
    SceneManager:new('scenes', {'Main_Menu', 'Versus_Planification', 'Versus_Tree'})
    SceneManager:switch('Main_Menu')
end

function love.update(dt)
    SceneManager:update(dt)
    Key:update(dt)
end

function love.draw()
    SceneManager:draw()
    lg.draw(logo, 64, 64)
    lg.print(VERSION, 44, 664)
    lg.setBackgroundColor(0.141, 0.152, 0.184)
end
