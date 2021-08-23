local backend = {}

require('common')

--------------------------------
-- Event hooks
-- https://docs.ashitaxi.com/dev/addons/events/
--------------------------------
backend.register_event_load = function(func)
    ashita.register_event('load', func)
end

backend.register_event_unload = function(func)
    ashita.register_event('unload', func)
end

backend.register_command = function(str)
    -- TODO
end

backend.register_event_incoming_packet = function(func)
    -- ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
    local adaptor = function(id, size, packet, packet_modified, blocked)
        -- id, data, size
        func(id, packet, size)
        return false
    end
    ashita.register_event('incoming_packet', adaptor)
end

backend.register_event_outgoing_packet = function(func)
    -- ashita.register_event('outgoing_packet', function(id, size, packet, packet_modified, blocked)
    local adaptor = function(id, size, packet, packet_modified, blocked)
        -- id, data, size
        func(id, packet, size)
        return false
    end
    ashita.register_event('outgoing_packet', adaptor)
end

backend.register_event_incoming_text = function(func)
    -- ashita.register_event('incoming_text', function(mode, message, modifiedmode, modifiedmessage, blocked)
    local adaptor = function(mode, message, modifiedmode, modifiedmessage, blocked)
        -- mode, text
        func(mode, message)
        return false
    end
    ashita.register_event('incoming_text', adaptor)
end

backend.register_event_prerender = function(func)
    ashita.register_event('prerender', func)
end

backend.register_event_postrender = function(func)
    ashita.register_event('render', func)
end

--------------------------------
-- File IO
--------------------------------
backend.dir_exists = function(path)
    return ashita.file.dir_exists(path)
end

backend.file_exists = function(path)
    return ashita.file.file_exists(path)
end

backend.create_dir = function(filename)
    ashita.file.create_dir(filename)
end

--------------------------------
-- Misc
--------------------------------
backend.script_path = function()
    local path = _addon.path

    path = string.gsub(path, '\\', '/')
    path = string.gsub(path, '//', '/')

    return path
end

backend.add_to_chat = function(mode, msg)
    -- TODO
    print(msg)
end

backend.player_name = function()
    local player = GetPlayerEntity()
    if player ~= nil then
        return player.Name
    end
    return nil
end

return backend
