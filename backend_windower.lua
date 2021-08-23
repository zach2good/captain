local backend = {}

require('pack')
require('string')
local bit = require('bit')

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

return backend
