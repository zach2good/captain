-- Docs:
-- https://github.com/AshitaXI/Ashita-v4beta/blob/main/plugins/sdk/Ashita.h
-- https://github.com/AshitaXI/Ashita-v4beta/tree/main/addons
-- https://github.com/AshitaXI/example/blob/main/example.lua

local backend = {}

require('common')
local chat = require('chat')
local imgui = require('imgui')

local WHITE = { 1.0,  1.0,  1.0, 1.0 }
local CORAL = { 1.0, 0.65, 0.26, 1.0 }

local gui = {}

--------------------------------
-- Event hooks
-- https://docs.ashitaxi.com/dev/addons/events/
--------------------------------
backend.register_event_load = function(func)
    ashita.events.register('load', 'load_cb', func)
end

backend.register_event_unload = function(func)
    ashita.events.register('unload', 'unload_cb', func)
end

backend.register_command = function(func)
    local addonCommand = string.format('/%s', addon.command)
    ashita.events.register('command', 'command_cb', function(e)
        local args = e.command:args()
        if #args < 1 or args[1] ~= addonCommand then
            return
        end

        local strippedArgs = { unpack(args, 2) }
        func(strippedArgs)
    end)
end

backend.register_event_incoming_packet = function(func)
    local adaptor = function(e)
        -- id, data, size
        func(e.id, e.data, e.size)
        return false
    end
    ashita.events.register('packet_in', 'packet_in_cb', adaptor)
end

backend.register_event_outgoing_packet = function(func)
    local adaptor = function(e)
        -- id, data, size
        func(e.id, e.data, e.size)
        return false
    end
    ashita.events.register('packet_out', 'packet_out_cb', adaptor)
end

backend.register_event_incoming_text = function(func)
    local adaptor = function(mode, message, modifiedmode, modifiedmessage, blocked)
        -- mode, text
        func(mode, message)
        return false
    end
    ashita.events.register('text_in', 'text_in_cb', adaptor)
end

backend.register_event_prerender = function(func)
    local adaptor = function()
        func()

        local flags = bit.bor(
            ImGuiWindowFlags_NoDecoration,
            ImGuiWindowFlags_AlwaysAutoResize,
            ImGuiWindowFlags_NoSavedSettings,
            ImGuiWindowFlags_NoFocusOnAppearing,
            ImGuiWindowFlags_NoNav)

        for _, box in pairs(gui) do
            imgui.SetNextWindowBgAlpha(0.6)
            imgui.SetNextWindowSize({ -1, -1, }, ImGuiCond_Always)
            imgui.SetNextWindowSizeConstraints({ -1, -1, }, { FLT_MAX, FLT_MAX, })

            if box.text ~= nil and box.visible and imgui.Begin(box.name, true, flags) then
                if box.title then
                    imgui.TextColored(CORAL, box.title)
                    imgui.Separator()
                end
                imgui.Text(box.text)
            end
        end
    end
    ashita.events.register('d3d_present', 'present_cb', adaptor)
end

-- backend.register_event_postrender = function(func)
--     ashita.events.register('d3d_beginscene', 'beginscene_cb', func)
-- end

--------------------------------
-- File IO
--------------------------------
backend.dir_exists = function(path)
    return ashita.fs.exists(path)
end

backend.file_exists = function(path)
    return ashita.fs.exists(path)
end

backend.create_dir = function(filename)
    ashita.fs.create_dir(filename)
end

--------------------------------
-- Text Display
--------------------------------
textBoxIdCounter = 0

backend.textBox = function()
    local box = {}
    box.name = '' .. textBoxIdCounter
    box.title = nil
    box.text = nil
    box.visible = true

    textBoxIdCounter = textBoxIdCounter + 1

    box.show = function(self)
        self.visible = true
    end

    box.hide = function(self)
        self.visible = false
    end

    box.updateTitle = function(self, str)
        self.title = str or ''
    end

    box.updateText = function(self, str)
        self.text = str or ''
    end

    table.insert(gui, box)

    return box
end

--------------------------------
-- Misc
--------------------------------
backend.script_path = function()
    local path = addon.path

    path = string.gsub(path, '\\', '/')
    path = string.gsub(path, '//', '/')

    return path
end

backend.add_to_chat = function(mode, msg)
    print(chat.header(addon.name):append(chat.message(msg)))
end

backend.player_name = function()
    local player = GetPlayerEntity()
    if player ~= nil then
        return player.Name
    end
    return nil
end

backend.target_index = function()
    return AshitaCore:GetDataManager():GetTarget():GetTargetIndex()
end

backend.target_name = function()
    return AshitaCore:GetDataManager():GetTarget():GetTargetName()
end

backend.target_hpp = function()
    return AshitaCore:GetDataManager():GetTarget():GetTargetHealthPercent()
end

backend.get_player_entity_data = function()
    local entity = AshitaCore:GetMemoryManager():GetEntity()
    local party = AshitaCore:GetMemoryManager():GetParty()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local index = party:GetMemberTargetIndex(0)

    local playerEntityData =
    {
        name = party:GetMemberName(0),
        serverId = party:GetMemberServerId(0),
        targIndex = index,
        x = string.format('%+08.03f', entity:GetLocalPositionX(index)),
        y = string.format('%+08.03f', entity:GetLocalPositionY(index)),
        z = string.format('%+08.03f', entity:GetLocalPositionZ(index)),
        r = utils.headingToByteRotation(entity:GetLocalPositionYaw(index)),
    }
    return playerEntityData
end

backend.get_target_entity_data = function()
    local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0))
    if target == nil then
        return nil
    end

    local index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0)
    local targetEntityData =
    {
        name =  AshitaCore:GetMemoryManager():GetEntity():GetName(index),
        serverId =  AshitaCore:GetMemoryManager():GetEntity():GetServerId(index),
        targIndex =  AshitaCore:GetMemoryManager():GetEntity():GetServerId(index),
        x = string.format('%+08.03f', AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionX(index)),
        y = string.format('%+08.03f', AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionY(index)),
        z = string.format('%+08.03f', AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionZ(index)),
        r = utils.headingToByteRotation(AshitaCore:GetMemoryManager():GetEntity():GetLocalPositionYaw(index)),
    }
    return targetEntityData
end

backend.schedule = function(func, delay)
    ashita.tasks.once(delay, func)
end

return backend
