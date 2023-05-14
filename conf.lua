local love = require ('love')

function love.conf(t)
    t.title = 'Versus Maker'

    t.console = false
    t.window.icon = 'assets/gfx/icon.png'
    t.window.width = 1080
    t.window.height = 720
end
