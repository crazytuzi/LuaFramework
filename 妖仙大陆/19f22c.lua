








local base = _G
local ltn12 = require("ltn12")
local mime = require("mime.core")
local io = require("io")
local string = require("string")
local _M = mime


local encodet, decodet, wrapt = {},{},{}

_M.encodet = encodet
_M.decodet = decodet
_M.wrapt   = wrapt  


local function choose(table)
    return function(name, opt1, opt2)
        if base.type(name) ~= "string" then
            name, opt1, opt2 = "default", name, opt1
        end
        local f = table[name or "nil"]
        if not f then 
            base.error("unknown key (" .. base.tostring(name) .. ")", 3)
        else return f(opt1, opt2) end
    end
end


encodet['base64'] = function()
    return ltn12.filter.cycle(_M.b64, "")
end

encodet['quoted-printable'] = function(mode)
    return ltn12.filter.cycle(_M.qp, "",
        (mode == "binary") and "=0D=0A" or "\r\n")
end


decodet['base64'] = function()
    return ltn12.filter.cycle(_M.unb64, "")
end

decodet['quoted-printable'] = function()
    return ltn12.filter.cycle(_M.unqp, "")
end

local function format(chunk)
    if chunk then
        if chunk == "" then return "''"
        else return string.len(chunk) end
    else return "nil" end
end


wrapt['text'] = function(length)
    length = length or 76
    return ltn12.filter.cycle(_M.wrp, length, length)
end
wrapt['base64'] = wrapt['text']
wrapt['default'] = wrapt['text']

wrapt['quoted-printable'] = function()
    return ltn12.filter.cycle(_M.qpwrp, 76, 76)
end


_M.encode = choose(encodet)
_M.decode = choose(decodet)
_M.wrap = choose(wrapt)


function _M.normalize(marker)
    return ltn12.filter.cycle(_M.eol, 0, marker)
end


function _M.stuff()
    return ltn12.filter.cycle(_M.dot, 2)
end

return _M
