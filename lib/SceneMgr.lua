local Class = require('lib.Class')
local Scene = require('lib.Scene')
local SceneManager = Class:derive('SceneMgr')

function SceneManager:new(scene_dir, scenes)
    self.scenes = {}
    self.scene_dir = scene_dir

    if not scene_dir then
        scene_dir = ''
    end

    if scenes ~= nil then
        assert(type(scenes) == 'table', 'parameter scenes must be table!')
        for i = 1, #scenes do
            local M = require(scene_dir .. '.' .. scenes[i])
            assert(M:is(Scene), 'File: ' .. scene_dir .. '.' .. scenes[i] .. '.lua is not of type Scene!')
            self.scenes[scenes[i]] = M(self)
        end
    end

    self.prev_scene_name = nil
    self.current_scene_name = nil
    self.current = nil
end

function SceneManager:add(scene, scene_name)
    if scene then
        assert(scene_name ~= nil, 'parameter scene_name must be specified!')
        assert(type(scene_name) == 'string', 'parameter scene_name must be string!')
        assert(type(scene) == 'table', 'parameter scene must be table!')
        assert(scene:is(Scene), 'cannot add non-scene object to the scene manager!')
        self.scenes[scene_name] = scene
    end
end

function SceneManager:remove(scene_name)
    if scene_name then
        for k, v in pairs(self.scenes) do
            if k == scene_name then
                self.scenes[k]:destroy()
                self.scenes[k] = nil
                if scene_name == self.current_scene_name then
                    self.current = nil
                end
                break
            end
        end
    end
end

function SceneManager:switch(next_scene)
    if self.current then
        self.current:exit()
    end

    if next_scene then
        assert(self.scenes[next_scene] ~= nil, 'Unable to find scene:' .. next_scene)
        self.prev_scene_name = self.current_scene_name
        self.current_scene_name = next_scene
        self.current = self.scenes[next_scene]
        self.current:enter()
    end
end

function SceneManager:pop()
    if self.prev_scene_name then
        self:switch(self.prev_scene_name)
        self.prev_scene_name = nil
    end
end

function SceneManager:get_available_scenes()
    local scene_names = {}
    for k, v in pairs(self.scenes) do
        scene_names[#scene_names + 1] = k
    end
    return scene_names
end

function SceneManager:update(dt)
    if self.current then
        self.current:update(dt)
    end
end
function SceneManager:draw()
    if self.current then
        self.current:draw()
    end
end

return SceneManager
