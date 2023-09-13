-- Addon info
local name    = 'captain'
local author  = 'zach2good'
local version = '0.1'
local command = 'captain'

if addon then
    addon.name = name
    addon.author = author
    addon.version = version
    addon.command = command
elseif _addon then
    _addon.name = name
    _addon.author = author
    _addon.version = version
    _addon.command = command
end

-- Globals
backend = require('backend/backend')
utils = require('utils')

captain = {}
captain.isCapturing = false
captain.inFile = {}
captain.outFile = {}
captain.bothFile = {}

display = {}
display.playerInfo = {}
display.targetInfo = {}
display.inputPacket = {}
display.outputPacket = {}

local function StartCapture()
    local date = os.date('*t')
    local foldername = string.format('%d-%d-%d_%d_%d', date['year'], date['month'], date['day'], date['hour'], date['min'])
    local charname = backend.player_name()
    local baseDir = string.format('captures/%s/%s/', foldername, charname)

    backend.add_to_chat(1, 'starting capture at ' .. baseDir)

    captain.inFile = backend.fileOpen(baseDir .. 'packetviewer/incoming.log')
    captain.outFile = backend.fileOpen(baseDir .. 'packetviewer/outgoing.log')
    captain.bothFile = backend.fileOpen(baseDir .. 'packetviewer/full.log')
    captain.isCapturing = true
end

local function StopCapture()
    backend.add_to_chat(1, 'stopping capture')

    captain.isCapturing = false
    captain.inFile = {}
    captain.outFile = {}
    captain.bothFile = {}
end

local function ShowGui()
    display.playerInfo:show()
    display.targetInfo:show()
    display.inputPacket:show()
    display.outputPacket:show()
end

local function HideGui()
    display.playerInfo:hide()
    display.targetInfo:hide()
    display.inputPacket:hide()
    display.outputPacket:hide()
end

-- Hooks
backend.register_event_load(function()
    display.playerInfo = backend.textBox()
    display.targetInfo = backend.textBox()
    display.inputPacket = backend.textBox()
    display.outputPacket = backend.textBox()
end)

backend.register_event_unload(function()
end)

backend.register_command(function(args)
    if #args == 0 then
        return
    end

    if args[1] == 'help' then
        -- TODO
    elseif args[1] == 'start' then
        StartCapture()
    elseif args[1] == 'stop' then
        StopCapture()
    elseif args[1] == 'split' then
        StopCapture()
        StartCapture()
    elseif args[1] == 'show' then
        ShowGui()
    elseif args[1] == 'hide' then
        HideGui()
    end
end)

backend.register_event_incoming_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    if captain.isCapturing then
        backend.fileAppend(captain.inFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
        backend.fileAppend(captain.inFile, string.hexformat_file(data, size) .. '\n')
        backend.fileAppend(captain.bothFile, string.format('[%s] Incoming packet %s\n', timestr, hexidstr))
        backend.fileAppend(captain.bothFile, string.hexformat_file(data, size) .. '\n')
    end

    display.inputPacket:updateTitle(string.format('[%s] Incoming packet %s', timestr, hexidstr))
    display.inputPacket:updateText(string.hexformat_file(data, size))
end)

backend.register_event_outgoing_packet(function(id, data, size)
    local timestr = os.date('%Y-%m-%d %H:%M:%S')
    local hexidstr = string.format('0x%.3X', id)

    if captain.isCapturing then
        backend.fileAppend(captain.outFile, string.format('[%s] Packet %s\n', timestr, hexidstr))
        backend.fileAppend(captain.outFile, string.hexformat_file(data, size) .. '\n')
        backend.fileAppend(captain.bothFile, string.format('[%s] Outgoing packet %s\n', timestr, hexidstr))
        backend.fileAppend(captain.bothFile, string.hexformat_file(data, size) .. '\n')
    end

    display.outputPacket:updateTitle(string.format('[%s] Outgoing packet %s', timestr, hexidstr))
    display.outputPacket:updateText(string.hexformat_file(data, size))
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
