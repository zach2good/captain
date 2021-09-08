-- Addon info
_addon.name    = 'captain'
_addon.author  = 'zach2good'
_addon.version = '0.1'
_addon.command = 'captain'

-- Globals
backend = require('backend/backend')
utils = require('utils')

captain = {}
captain.inFile = {}
captain.outFile = {}
captain.bothFile = {}

display = {}
display.playerInfo = {}
display.targetInfo = {}
display.inputPacket = {}
display.outputPacket = {}

-- Hooks
backend.register_event_load(function()
    local date = os.date('*t')
    local foldername = string.format('%d-%d-%d_%d_%d', date['year'], date['month'], date['day'], date['hour'], date['min'])
    local charname = backend.player_name()

    captain.inFile = backend.fileOpen('captures/' .. foldername .. '/' .. charname .. '/packetviewer/incoming.log')
    captain.outFile = backend.fileOpen('captures/' .. foldername .. '/' .. charname .. '/packetviewer/outgoing.log')
    captain.bothFile = backend.fileOpen('captures/' .. foldername .. '/' .. charname .. '/packetviewer/full.log')

    display.playerInfo = backend.textBox()
    display.targetInfo = backend.textBox()
    display.inputPacket = backend.textBox()
    display.outputPacket = backend.textBox()
end)

backend.register_event_unload(function()
end)

backend.register_command(function(str)
end)

backend.register_event_incoming_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    backend.fileAppend(captain.inFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.inFile, string.hexformat_file(data) .. '\n')
    backend.fileAppend(captain.bothFile, string.format('[%s] Incoming packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.bothFile, string.hexformat_file(data) .. '\n')

    local outputStr = string.format('[%s] Incoming packet %s\n', timestr, hexidstr) .. '\n' ..
    string.hexformat_file(data) .. '\n'

    --display.inputPacket:updateText(outputStr)
end)

backend.register_event_outgoing_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    backend.fileAppend(captain.outFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.outFile, string.hexformat_file(data) .. '\n')
    backend.fileAppend(captain.bothFile, string.format('[%s] Outgoing packet %s\n', timestr, hexidstr))
    backend.fileAppend(captain.bothFile, string.hexformat_file(data) .. '\n')

    local outputStr = string.format('[%s] Outgoing packet %s\n', timestr, hexidstr) .. '\n' ..
    string.hexformat_file(data) .. '\n'

    --display.outputPacket:updateText(outputStr)
end)

backend.register_event_incoming_text(function(mode, text)
end)

backend.register_event_prerender(function()
    local playerData = backend.get_player_entity_data()
    if playerData == nil then
        return
    end

    local playerOutputStr = 'Player: ' ..
    playerData.name .. ' ' ..
    '(99NIN/49WAR) ' .. -- TODO
    'ID: ' .. playerData.serverId .. ' ' ..
    'IDX: ' .. playerData.targIndex .. ' ' ..
    'X: ' .. playerData.x .. ' ' ..
    'Y: ' .. playerData.y .. ' ' ..
    'Z: ' .. playerData.z .. ' ' ..
    'R: ' .. playerData.r .. ' ' ..
    'Zone: 000 (Zone Name)'
    display.playerInfo:updateText(playerOutputStr)

    local targetData = backend.get_target_entity_data()
    local targetOutputStr = ''
    if targetData then
        targetOutputStr = 'Target: ' ..
        targetData.name .. ' ' ..
        'LVL: (' .. 0 .. ')/(' .. 0 .. ') ' .. -- TODO
        'ID: ' .. targetData.serverId .. ' ' ..
        'IDX: ' .. targetData.targIndex .. ' ' ..
        'X: ' .. targetData.x .. ' ' ..
        'Y: ' .. targetData.y .. ' ' ..
        'Z: ' .. targetData.z .. ' ' ..
        'R: ' .. targetData.r
        display.targetInfo:updateText(targetOutputStr)
    else
        targetOutputStr = 'Target: ' ..
        '-None- ' ..
        'ID: ? ' ..
        'IDX: ? ' ..
        'LVL: (?)/(?) ' ..
        'X: ? ' ..
        'Y: ? ' ..
        'Z: ? ' ..
        'R: ?'
    end
    display.targetInfo:updateText(targetOutputStr)
end)
