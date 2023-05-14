local Class = require('lib.Class')

local Vector2 = Class:derive('Vector2')

function Vector2:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

return Vector2
