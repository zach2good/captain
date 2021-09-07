local backend = nil

--------------------------------
-- Load platform specific backends
--------------------------------
if windower ~= nil then
    backend = require('backend/backend_windower')
elseif ashita ~= nil then
    backend = require('backend/backend_ashita')
elseif windower == nil and string == nil then
    -- Windower v5
else
    print('Captain: COULD NOT FIND RELEVANT BACKEND!')
end

--------------------------------
-- Add additional _platform agnostic_ functions to supplement backends
--------------------------------
local files = require('backend/files')

--------------------------------
-- Handles opening, or creating, a file object. Returns it.
--------------------------------
backend.fileOpen = function(path)
    local file = {
        path = backend.script_path() .. path,
        stream = files.new(path, true),
        locked = false,
        scheduled = false,
        buffer = ''
    }
    return file
end

--------------------------------
-- Handles writing to a file (gently)
--------------------------------
backend.fileAppend = function(file, text)
    if not file.locked then
        file.buffer = file.buffer .. text
        if not file.scheduled then
            file.scheduled = true
            backend.schedule(function() backend.fileWrite(file) end, 0.5)
        end
    else
        backend.schedule(function() backend.fileAppend(file, text) end, 0.1)
    end
end

--------------------------------
-- Writes to a file and empties the buffer
--------------------------------
backend.fileWrite = function(file)
    file.locked = true
    local to_write = file.buffer
    file.buffer = ''
    file.scheduled = false
    file.stream:append(to_write)
    file.locked = false
end

return backend
