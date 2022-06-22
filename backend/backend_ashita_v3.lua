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
-- Text Display
--------------------------------
local default_config =
{
    font =
    {
        family      = 'Consolas',
        size        = 10,
        color       = 0xFFFFFFFF,
        position    = { 200, 200 },
        bgcolor     = 0x80000000,
        bgvisible   = true,
        padding     = 5,
    }
}

textBoxIdCounter = 0
backend.textBox = function()
    local box = {}

    box.impl = AshitaCore:GetFontManager():Create('' .. textBoxIdCounter)
    textBoxIdCounter = textBoxIdCounter + 1

    box.impl:SetPositionX(default_config.font.position[1])
    box.impl:SetPositionY(default_config.font.position[2])
    box.impl:SetColor(default_config.font.color)
    box.impl:SetFontFamily(default_config.font.family)
    box.impl:SetFontHeight(default_config.font.size)
    box.impl:SetBold(true)
    box.impl:GetBackground():SetColor(default_config.font.bgcolor)
    box.impl:GetBackground():SetVisibility(default_config.font.bgvisible)
    box.impl:SetPadding(default_config.font.padding)

    box.show = function(self)
        self.impl:SetVisibility(true)
    end

    box.hide = function(self)
        self.impl:SetVisibility(false)
    end

    box.updateText = function(self, str)
        self.text = str
        self.impl:SetText(self.text)
    end

    box:updateText('')
    box:show()

    return box
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
    local playerEntity = GetPlayerEntity()
    if playerEntity == nil then
        return nil
    end
    local playerEntityData =
    {
        name = playerEntity.Name,
        serverId = playerEntity.ServerId,
        targIndex = playerEntity.TargetIndex,
        x = string.format('%+08.03f', playerEntity.Movement.LocalPosition.X),
        y = string.format('%+08.03f', playerEntity.Movement.LocalPosition.Y),
        z = string.format('%+08.03f', playerEntity.Movement.LocalPosition.Z),
        r = utils.headingToByteRotation(playerEntity.Movement.LocalPosition.Yaw),
    }
    return playerEntityData
end

backend.get_target_entity_data = function()
    local target = AshitaCore:GetDataManager():GetTarget()
    local targetEntity = GetEntity(target:GetTargetIndex())
    if targetEntity == nil then
        return nil
    end
    local targetEntityData =
    {
        name = targetEntity.Name,
        serverId = targetEntity.ServerId,
        targIndex = targetEntity.TargetIndex,
        x = string.format('%+08.03f', targetEntity.Movement.LocalPosition.X),
        y = string.format('%+08.03f', targetEntity.Movement.LocalPosition.Y),
        z = string.format('%+08.03f', targetEntity.Movement.LocalPosition.Z),
        r = utils.headingToByteRotation(targetEntity.Movement.LocalPosition.Yaw),
    }
    return targetEntityData
end

backend.schedule = function(func, delay)
    ashita.timer.once(delay, func)
end

return backend
