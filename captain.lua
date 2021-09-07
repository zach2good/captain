-- Globals
backend = require('backend/backend')
utils = require('utils')

captain = {}
captain.file = {}

-- Addon info
_addon.name    = 'captain'
_addon.author  = 'zach2good'
_addon.version = '0.1'
_addon.command = 'captain'

-- Hooks
backend.register_event_load(function()
    local date = os.date('*t')
    local name = string.format('packets_%d_%d_%d_%d_%d_%d.log', date['year'], date['month'], date['day'], date['hour'], date['min'], date['sec'])
    local filename = 'captures/' .. name
    captain.file = backend.fileOpen(filename)
end)

backend.register_event_unload(function()
end)

backend.register_command(function(str)
end)

backend.register_event_incoming_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    backend.fileAppend(captain.file, string.format('[%s] Incoming packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.file, string.hexformat_file(data) .. '\n')
end)

backend.register_event_outgoing_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    backend.fileAppend(captain.file, string.format('[%s] Outgoing packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.file, string.hexformat_file(data) .. '\n')
end)

backend.register_event_incoming_text(function(mode, text)
end)
