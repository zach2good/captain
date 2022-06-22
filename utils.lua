local backend = require('backend/backend')

colors = {}
colors['hexborder'] =   '\\cs(0,255,0)'
colors['gray'] =        '\\cs(102,102,102)'
colors[0] =             '\\cs(204,204,0)'
colors[1] =             '\\cs(51,153,255)'
colors[2] =             '\\cs(51,255,153)'
colors[3] =             '\\cs(153,51,255)'
colors[4] =             '\\cs(255,51,153)'
colors[5] =             '\\cs(153,255,51)'
colors[6] =             '\\cs(255,153,51)'
colors[7] =             '\\cs(255,255,102)'
colors[8] =             '\\cs(255,102,255)'
colors[9] =             '\\cs(102,255,255)'
colors[10] =            '\\cs(102,102,255)'
colors[11] =            '\\cs(102,255,102)'
colors[12] =            '\\cs(255,102,102)'
colors[13] =            '\\cs(255,204,153)'
colors[14] =            '\\cs(204,255,153)'
colors[15] =            '\\cs(255,153,204)'
colors[16] =            '\\cs(153,204,255)'
colors[17] =            '\\cs(204,153,255)'
colors[18] =            '\\cs(153,255,204)'

byte_colors = { colors.gray, colors.gray, colors.gray, colors.gray }

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

do
    -- Precompute hex string tables for lookups, instead of constant computation.
    local top_row = '        |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F      | 0123456789ABCDEF\n    ' .. string.rep('-', (16+1)*3 + 2) .. '  ' .. string.rep('-', 16 + 6) .. '\n'

    local chars = {}
    for i = 0x00, 0xFF do
        if i >= 0x20 and i < 0x7F then
            chars[i] = string.char(i)
        else
            chars[i] = '.'
        end
    end
    chars[0x5C] = '\\\\'
    chars[0x25] = '%%'

    local line_replace = {}
    for i = 0x01, 0x10 do
        line_replace[i] = '    %%%%3X |' .. string.rep(' %.2X', i) .. string.rep(' --', 0x10 - i) .. '  %%%%3X | ' .. '%%s\n'
    end
    local short_replace = {}
    for i = 0x01, 0x10 do
        short_replace[i] = string.rep('%s', i) .. string.rep('-', 0x10 - i)
    end

    -- Receives a byte string and returns a table-formatted string with 16 columns.
    string.hexformat_file = function(str, size, byte_colors)
        local length = size
        local str_table = {}
        local from = 1
        local to = 16
        for i = 0, math.floor((length - 1)/0x10) do
            local partial_str = {str:byte(from, to)}
            local char_table = {
                [0x01] = chars[partial_str[0x01]],
                [0x02] = chars[partial_str[0x02]],
                [0x03] = chars[partial_str[0x03]],
                [0x04] = chars[partial_str[0x04]],
                [0x05] = chars[partial_str[0x05]],
                [0x06] = chars[partial_str[0x06]],
                [0x07] = chars[partial_str[0x07]],
                [0x08] = chars[partial_str[0x08]],
                [0x09] = chars[partial_str[0x09]],
                [0x0A] = chars[partial_str[0x0A]],
                [0x0B] = chars[partial_str[0x0B]],
                [0x0C] = chars[partial_str[0x0C]],
                [0x0D] = chars[partial_str[0x0D]],
                [0x0E] = chars[partial_str[0x0E]],
                [0x0F] = chars[partial_str[0x0F]],
                [0x10] = chars[partial_str[0x10]],
            }
            local bytes = math.min(length - from + 1, 16)
            str_table[i + 1] = line_replace[bytes]
                :format(unpack(partial_str))
                :format(short_replace[bytes]:format(unpack(char_table)))
                :format(i, i)
            from = to + 1
            to = to + 0x10
        end
        return string.format('%s%s', top_row, table.concat(str_table))
    end
end

-- Rounds to prec decimal digits. Accepts negative numbers for precision.
function math.round(num, prec)
    local mult = 10^(prec or 0)
    return math.floor(num * mult + 0.5) / mult
end
utils.round = math.round

utils.headingToByteRotation = function(oldHeading)
    local newHeading = oldHeading
    if newHeading < 0 then
        newHeading = (math.pi * 2) - (newHeading * -1)
    end
    return math.round((newHeading / (math.pi * 2)) * 256)
end

function string.fromhex(str)
    if str == nil then return "" end
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    if str == nil then return "" end
    return (str:gsub('.', function (c)
        return string.format('%02X ', string.byte(c))
    end))
end

local function getTableKeys(tab)
    local keyset = {}
    for k,v in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end

utils.dumpTableToString = nil
utils.dumpTableToString = function(table, depth)
    if table == nil then table = {} end
    if depth == nil then depth = 0 end

    local outputString = ""
    for _, key in ipairs(getTableKeys(table)) do
        local value = table[key]
        if type(value) == "table" then
            local keyStr = tostring(key)
            local indent = ""
            for i = 1, depth do indent = indent .. "    " end
            outputString = outputString .. indent .. keyStr .. " : {\n"
            outputString = outputString .. dumpTableToString(value, depth + 1)
            outputString = outputString .. indent .. "}\n"
        else
            local keyStr = tostring(key)
            local valueStr = tostring(value)
            local indent = ""
            for i = 1, depth do indent = indent .. "    " end
            outputString = outputString .. indent .. keyStr .. " : " .. valueStr .. "\n"
        end
    end
    return outputString
end

return utils
