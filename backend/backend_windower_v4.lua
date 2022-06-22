local backend = {}

local pack = require('pack')
local string = require('string')
local bit = require('bit')
local texts = require('texts')
local tables = require('tables')

--------------------------------
-- Event hooks
-- https://github.com/Windower/Lua/wiki/Events
--------------------------------
backend.register_event_load = function(func)
    windower.register_event('load', func)
end

backend.register_event_unload = function(func)
    windower.register_event('unload', func)
end

backend.register_command = function(str)
    -- TODO
end

backend.register_event_incoming_packet = function(func)
    -- windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    local adaptor = function(id, original, modified, injected, blocked)
        -- id, data, size
        func(id, original, string.len(original))
    end
    windower.register_event('incoming chunk', adaptor)
end

backend.register_event_outgoing_packet = function(func)
    -- windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
    local adaptor = function(id, original, modified, injected, blocked)
        func(id, original, string.len(original))
    end
    windower.register_event('outgoing chunk', adaptor)
end

backend.register_event_incoming_text = function(func)
    -- windower.register_event('incoming text', function(original, modified, original_mode, modified_mode)
    local adaptor = function(original, modified, original_mode, modified_mode)
        -- mode, text
        func(original_mode, original)
    end
    windower.register_event('incoming text', adaptor)
end

backend.register_event_prerender = function(func)
    windower.register_event('prerender', func)
end

backend.register_event_postrender = function(func)
    windower.register_event('postrender', func)
end

--------------------------------
-- File IO
--------------------------------
backend.dir_exists = function(path)
    return windower.dir_exists(path)
end

backend.file_exists = function(path)
    return windower.file_exists(path)
end

backend.create_dir = function(filename)
    windower.create_dir(backend.script_path() .. filename)
end

--------------------------------
-- Text Display
--------------------------------

-- Override texts.new and texts.destroy to enable
-- movement only on shift+click
local texts_settings = T{}
texts.oldnew = texts.new
texts.new = function(str, settings, root_settings)
    settings = settings or { flags = { draggable = false } }
    settings.flags = settings.flags or { draggable = false }
    settings.flags.draggable = false
    local ret = texts.oldnew(str, settings, root_settings)
    texts_settings[ret._name]=  settings
    return ret
end

texts.destroy = function(t)
    texts_settings[t._name] = nil
end

windower.register_event('keyboard', function(dik, pressed, flags, blocked)
    if dik == 42 and not blocked then
        if pressed then
            texts_settings:map(function(settings)
                settings.flags = settings.flags or { draggable = true }
                settings.flags.draggable = true
            end)
        else
            texts_settings:map(function(settings)
                settings.flags = settings.flags or { draggable = false }
                settings.flags.draggable = false
            end)
        end
    end
end)

-- Resume normal usage
displaySettings = {}
displaySettings.pos = {}
displaySettings.pos.x = 200
displaySettings.pos.y = 200
displaySettings.text = {}
displaySettings.text.font = 'Consolas'
displaySettings.text.size = 14
displaySettings.text.alpha = 255
displaySettings.text.red = 255
displaySettings.text.green = 255
displaySettings.text.blue = 255
displaySettings.bg = {}
displaySettings.bg.alpha = 128
displaySettings.bg.red = 0
displaySettings.bg.green = 0
displaySettings.bg.blue = 0
displaySettings.padding = 5

backend.textBox = function()
    local box = {}
    box.impl = texts.new('', displaySettings)

    box.show = function(self)
        self.impl:show()
    end

    box.hide = function(self)
        self.impl:hide()
    end

    box.updateText = function(self, str)
        self.text = str
        texts.text(self.impl, self.text)
    end

    box:updateText('')
    box:show()

    return box
end

--------------------------------
-- Misc
--------------------------------
backend.script_path = function()
    local path = windower.addon_path

    path = string.gsub(path, '\\', '/')
    path = string.gsub(path, '//', '/')

    return path
end

backend.add_to_chat = function(mode, msg)
    windower.add_to_chat(mode, msg)
end

backend.player_name = function()
    local player = windower.ffxi.get_player()
    if player ~= nil then
        return player.name
    end
    return nil
end

backend.target_index = function()
    local player = windower.ffxi.get_player()
    if not player then
        return nil
    end

    if not player.target_index then
        return nil
    end

    return player.target_index
end

backend.target_name = function()
    local index = backend.target_index()
    if not index then
        return nil
    end

    local mob = windower.ffxi.get_mob_by_index(index)
    if not mob then
        return nil
    end

    return mob.name
end

backend.target_hpp = function()
    local index = backend.target_index()
    if not index then
        return nil
    end

    local mob = windower.ffxi.get_mob_by_index(index)
    if not mob then
        return nil
    end

    return mob.hpp
end

backend.get_player_entity_data = function()
    local playerEntity = windower.ffxi.get_mob_by_target('me')
    if playerEntity == nil then
        return nil
    end
    local playerEntityData =
    {
        name = playerEntity.name,
        serverId = playerEntity.id,
        targIndex = playerEntity.index,
        x = string.format('%+08.03f', playerEntity.x),
        y = string.format('%+08.03f', playerEntity.z),
        z = string.format('%+08.03f', playerEntity.y),
        r = utils.headingToByteRotation(playerEntity.heading),
    }
    return playerEntityData
end

backend.get_target_entity_data = function()
    local targetEntity = windower.ffxi.get_mob_by_target('t')
    if targetEntity == nil then
        return nil
    end
    local targetEntityData =
    {
        name = targetEntity.name,
        serverId = targetEntity.id,
        targIndex = targetEntity.index,
        x = string.format('%+08.03f', targetEntity.x),
        y = string.format('%+08.03f', targetEntity.z),
        z = string.format('%+08.03f', targetEntity.y),
        r = utils.headingToByteRotation(targetEntity.heading),
    }
    return targetEntityData
end

backend.schedule = function(func, delay)
    coroutine.schedule(func, delay)
end

return backend
