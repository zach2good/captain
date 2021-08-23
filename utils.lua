local backend = require('backend')

local utils = {}

 -- Create a file name based on the current date and time
local date = os.date('*t')
local name = string.format('packets_%d_%d_%d_%d_%d_%d.txt', date['year'], date['month'], date['day'], date['hour'], date['min'], date['sec'])
local filename = backend.script_path() .. 'captures/' .. name

utils.log = function(str, ...)
    backend.file_append(filename, str)
end

utils.hexdump = function(str, align, indent)
    local ret = ''
    
    -- Loop the data string in steps..
    for x = 1, #str, align do
        local data = str:sub(x, x + 15)
        ret = ret .. string.rep(' ', indent)
        ret = ret .. data:gsub('.', function(c) return string.format('%02X ', string.byte(c)) end)
        ret = ret .. string.rep(' ', 3 * (16 - #data))
        ret = ret .. ' ' .. data:gsub('%c', '.')
        ret = ret .. '\n'
    end
    
    -- Fix percents from breaking string.format..
    ret = string.gsub(ret, '%%', '%%%%')
    ret = ret .. '\n'
    
    return ret
end

return utils
