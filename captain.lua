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
    local name = string.format('packets_%d_%d_%d_%d_%d_%d.log', date['year'], date['month'], date['day'], date['hour'], date['min'], date['sec'])

    captain.inFile = backend.fileOpen('captures/in_' .. name)
    captain.outFile = backend.fileOpen('captures/out_' .. name)
    captain.bothFile = backend.fileOpen('captures/both_' .. name)

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

    --backend.fileAppend(captain.inFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
    --backend.fileAppend(captain.inFile, string.hexformat_file(data) .. '\n')
    --backend.fileAppend(captain.bothFile, string.format('[%s] Incoming packet %s\n', timestr, hexidstr))
    --backend.fileAppend(captain.bothFile, string.hexformat_file(data) .. '\n')

    local outputStr = ''
    outputStr = outputStr .. string.format('[%s] Incoming packet %s\n', timestr, hexidstr) .. '\n'
    outputStr = outputStr .. string.hexformat_file(data) .. '\n'

    display.inputPacket:updateText(outputStr)
end)

backend.register_event_outgoing_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    --backend.fileAppend(captain.outFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
    --backend.fileAppend(captain.outFile, string.hexformat_file(data) .. '\n')
    --backend.fileAppend(captain.bothFile, string.format('[%s] Outgoing packet %s\n', timestr, hexidstr))
    --backend.fileAppend(captain.bothFile, string.hexformat_file(data) .. '\n')

    local outputStr = ''
    outputStr = outputStr .. string.format('[%s] Outgoing packet %s\n', timestr, hexidstr) .. '\n'
    outputStr = outputStr .. string.hexformat_file(data) .. '\n'

    display.outputPacket:updateText(outputStr)
end)

backend.register_event_incoming_text(function(mode, text)
end)

backend.register_event_prerender(function()
    local playerData = backend.get_player_entity_data()
    if playerData == nil then
        return
    end

    local playerOutputStr = 'Player:\n'
    playerOutputStr = playerOutputStr .. 'Name: ' .. playerData.name .. '\n'
    playerOutputStr = playerOutputStr .. 'serverId: ' .. playerData.serverId .. '\n'
    playerOutputStr = playerOutputStr .. 'targIndex: ' .. playerData.targIndex .. '\n'
    playerOutputStr = playerOutputStr .. 'X: ' .. playerData.x .. '\n'
    playerOutputStr = playerOutputStr .. 'Y: ' .. playerData.y .. '\n'
    playerOutputStr = playerOutputStr .. 'Z: ' .. playerData.z .. '\n'
    playerOutputStr = playerOutputStr .. 'R: ' .. playerData.r .. '\n'
    display.playerInfo:updateText(playerOutputStr)

    local targetData = backend.get_target_entity_data()
    if targetData then
        local targetOutputStr = 'Target:\n'
        targetOutputStr = targetOutputStr .. 'Name: ' .. targetData.name .. '\n'
        targetOutputStr = targetOutputStr .. 'serverId: ' .. targetData.serverId .. '\n'
        targetOutputStr = targetOutputStr .. 'targIndex: ' .. targetData.targIndex .. '\n'
        targetOutputStr = targetOutputStr .. 'X: ' .. targetData.x .. '\n'
        targetOutputStr = targetOutputStr .. 'Y: ' .. targetData.y .. '\n'
        targetOutputStr = targetOutputStr .. 'Z: ' .. targetData.z .. '\n'
        targetOutputStr = targetOutputStr .. 'R: ' .. targetData.r .. '\n'
        display.targetInfo:updateText(targetOutputStr)

        display.targetInfo:show()
    else
        display.targetInfo:hide()
    end
end)
