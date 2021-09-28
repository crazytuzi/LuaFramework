

---@classdef record_ticket_price_info
local record_ticket_price_info = {}
  
record_ticket_price_info.num = 0 --已购张数  
record_ticket_price_info.origin_price = "" --初始价格  
record_ticket_price_info.increase = 0 --涨幅  
record_ticket_price_info.pace = 0 --步长


ticket_price_info = {
   _data = {
    [1] = {0,"1",1,4,},
    [2] = {20,"6",1,6,},
    [3] = {50,"11",1,8,},
    [4] = {90,"16",1,10,},
    [5] = {140,"21",1,12,},
    [6] = {200,"26",1,20,},
    [7] = {300,"40",10,100,},
    [8] = {400,"50",0,1,},
    }
}



local __index_num = {
    [0] = 1,
    [140] = 5,
    [20] = 2,
    [200] = 6,
    [300] = 7,
    [400] = 8,
    [50] = 3,
    [90] = 4,

}

local __key_map = {
  num = 1,
  origin_price = 2,
  increase = 3,
  pace = 4,

}



local m = { 
    __index = function(t, k) 
        assert(__key_map[k], "cannot find " .. k .. " in record_ticket_price_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function ticket_price_info.getLength()
    return #ticket_price_info._data
end



function ticket_price_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_ticket_price_info
function ticket_price_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = ticket_price_info._data[index]}, m)
    
end

---
--@return @class record_ticket_price_info
function ticket_price_info.get(num)
    
    return ticket_price_info.indexOf(__index_num[num])
        
end



function ticket_price_info.set(num, key, value)
    local record = ticket_price_info.get(num)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end