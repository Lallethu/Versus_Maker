local Utils = {}

function Utils.color(r, g, b, a)
    return {r, g or r, b or r, a or 1}
end

function Utils.gray(level, alpha)
    return {level, level, level, alpha or 255}
end

function Utils.point_in_rect(point, rect)
    return not (point.x < rect.x or point.x > rect.x + rect.w or point.y < rect.y or point.y > rect.y + rect.h)
end

function Utils.mouse_in_rect(mx, my, rx, ry, rw, rh)
    return not (mx < rx or mx > rx + rw or my < ry or my > ry + rh)
end

function Utils.contains(list, item)
    for val in pairs(list) do
        if val == item then
            return true
        end
    end
    return false
end

function Utils.index_of(list, item)
    for i, val in ipairs(list) do
        if val == item then
            return i
        end
    end
    return -1
end

return Utils
