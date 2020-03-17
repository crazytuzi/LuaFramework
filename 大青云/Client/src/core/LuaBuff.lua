_G.classlist['luabuff'] = 'luabuff' 
_G.luabuff = {}
_G.luabuff.objName = 'luabuff'
luabuff.__index = luabuff

function luabuff:new(string_array)
    local temp = {}
    if string_array then 
        temp.string = string_array:tostr()
    else
        temp.string = ""
    end
    setmetatable(temp, luabuff)
    return temp
end

function luabuff:char32(input)
    local maxsize = 32
    local size = input:len()
    local result = input
    local pad = maxsize - size
    if pad > 0 then
        for i = 1, pad do
            result = result .. '\0'
        end
    else
        result = result:sub(1, maxsize)
    end
    return result
end

function luabuff:writeString(_string)
    self.string = self.string .. luabuff:char32(_string)
end

function luabuff:readString()
    local temp = string.sub(self.string, 1, 32)
    self.string = string.sub(self.string, 33)
    return temp
end

function luabuff:writeInt(_int)
    self.string = self.string .. string.from32l(_int)
end

function luabuff:readInt()
    local temp = self.string:to32l(1, true)
    self.string = string.sub(self.string, 5)
    return temp
end

function luabuff:writeShort(_short)
    self.string = self.string .. string.from16l(_short)
end

function luabuff:readShort()
    local temp = self.string:to16l(1, true)
    self.string = string.sub(self.string, 3)
    return temp
end

function luabuff:writeByte(_byte)
    stringelf.string = self.string .. string.char(_byte)
end

function luabuff:readByte()
    local temp = string.byte(string.sub(self.string, 1, 2))
    self.string = string.sub(self.string, 2)
    return temp
end

function luabuff:writeNumber(_number)
    self.string = self.string .. string.fromDl(_number)
end

function luabuff:readNumber()
    local temp = self.string:toDl(1, true)
    self.string = string.sub(self.string, 9)
    return temp
end

function luabuff:readInt64()
    local temp = self.string:to64l(1, true)
    self.string = string.sub(self.string, 9)
    return temp
end

function luabuff:writeInt64(_int64)
    self.string = self.string .. string.from64l(_int64)
end