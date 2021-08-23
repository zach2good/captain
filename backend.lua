local backend = nil

--------------------------------
-- Load platform specific backends
--------------------------------
if windower ~= nil then
    backend = require('backend_windower')
elseif ashita ~= nil then
    backend = require('backend_ashita')
else
    print('Captain: COULD NOT FIND RELEVANT BACKEND!')
end

--------------------------------
-- Add additional _platform agnostic_ functions to supplement backends
--------------------------------
backend.file_append = function(filename, content)
    -- TODO: Keep file handles alive and write to them using coros
    local file = nil
    if not backend.file_exists(filename) then
        file = io.open(filename, "w")
    else
        file = io.open(filename, "a")
    end

    if file then
        file:write(content)
        file:close()
    else
        print('Could not open file:', filename)
    end
end

return backend
