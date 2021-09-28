

---@classdef record_shop_auction_info
local record_shop_auction_info = {}
  
record_shop_auction_info.id = 0 --id  
record_shop_auction_info.open_cycle = 0 --开启周期  
record_shop_auction_info.last_time = 0 --持续时间  
record_shop_auction_info.price_type = 0 --初始价格类型  
record_shop_auction_info.price = 0 --初始价格类型值  
record_shop_auction_info.price_add = 0 --竞价步长


shop_auction_info = {
   _data = {
    [1] = {1,2,120,3,10,5,},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  open_cycle = 2,
  last_time = 3,
  price_type = 4,
  price = 5,
  price_add = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_shop_auction_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function shop_auction_info.getLength()
    return #shop_auction_info._data
end



function shop_auction_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_shop_auction_info
function shop_auction_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = shop_auction_info._data[index]}, m)
    
end

---
--@return @class record_shop_auction_info
function shop_auction_info.get(id)
    
    return shop_auction_info.indexOf(__index_id[id])
        
end



function shop_auction_info.set(id, key, value)
    local record = shop_auction_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function shop_auction_info.get_index_data()
    return __index_id
end