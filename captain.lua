local backend = require('backend')
local utils = require('utils')

_addon.name    = 'captain'
_addon.author  = 'zach2good'
_addon.version = '0.1'
_addon.command = 'captain'

backend.register_event_load(function()
    if not backend.dir_exists('captures') then
        backend.create_dir('captures')
    end
end)

backend.register_event_unload(function()
    -- Flush any outstanding buffers
end)

backend.register_command(function(str)
end)

backend.register_event_incoming_packet(function(id, data, size)
    -- TODO: Use packetviewer format
    utils.log('[S->C] Id: %04X | Size: %d\n', id, size)
    utils.log(utils.hexdump(data, 16, 4))
end)

backend.register_event_outgoing_packet(function(id, data, size)
    -- TODO: Use packetviewer format
    utils.log('[C->S] Id: %04X | Size: %d\n', id, size)
    utils.log(utils.hexdump(data, 16, 4))
end)

backend.register_event_incoming_text(function(mode, text)
end)
