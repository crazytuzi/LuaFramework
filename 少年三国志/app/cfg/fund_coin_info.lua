

---@classdef record_fund_coin_info
local record_fund_coin_info = {}
  
record_fund_coin_info.id = 0 --id  
record_fund_coin_info.level = 0 --玩家等级  
record_fund_coin_info.coin_number = 0 --元宝数量


fund_coin_info = {
   _data = {
    [1] = {1,10,1000,},
    [2] = {2,25,2000,},
    [3] = {3,35,3000,},
    [4] = {4,45,4000,},
    [5] = {5,55,5000,},
    [6] = {6,60,6000,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,

}

local __key_map = {
  id = 1,
  level = 2,
  coin_number = 3,

}



local m = { 
    __index = function(t, k) 
        if k == "toObject" then
            return function()  
                local o = {}
                for key, v in pairs (__key_map) do 
                    o[key] = t._raw[v]
                end
                return o
            end 
        end
        
        assert(__key_map[k], "cannot find " .. k .. " in record_fund_coin_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function fund_coin_info.getLength()
    return #fund_coin_info._data
end



function fund_coin_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_fund_coin_info
function fund_coin_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = fund_coin_info._data[index]}, m)
    
end

---
--@return @class record_fund_coin_info
function fund_coin_info.get(id)
    
    return fund_coin_info.indexOf(__index_id[id])
        
end



function fund_coin_info.set(id, key, value)
    local record = fund_coin_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function fund_coin_info.get_index_data()
    return __index_id
end