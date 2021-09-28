

---@classdef record_days7_sell_info
local record_days7_sell_info = {}
  
record_days7_sell_info.id = 0 --货物id  
record_days7_sell_info.time = 0 --货物时间  
record_days7_sell_info.name = "" --货物名称  
record_days7_sell_info.type = 0 --货物类型  
record_days7_sell_info.value = 0 --货物类型值  
record_days7_sell_info.size = 0 --货物数量  
record_days7_sell_info.price_type = 0 --购买货币类型  
record_days7_sell_info.pre_price = 0 --货物原价  
record_days7_sell_info.price = 0 --货物现价  
record_days7_sell_info.num = 0 --限购次数


days7_sell_info = {
   _data = {
    [1] = {1,1,"飞雪装备全套",3,2,1,2,800,400,6000,},
    [2] = {2,2,"橙色宝物箱子*10",3,22,10,2,1200,600,5000,},
    [3] = {3,3,"极品精炼石*100",3,13,100,2,2000,1000,4000,},
    [4] = {4,4,"天命石*500(3折)",3,14,500,2,7500,2500,3000,},
    [5] = {5,5,"将魂*2000",13,0,2000,2,2000,1000,2500,},
    [6] = {6,6,"宝物精炼石*1000",3,18,1000,2,5000,2500,2000,},
    [7] = {7,7,"银两*500万",1,0,5000000,2,5000,2500,1500,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,

}

local __key_map = {
  id = 1,
  time = 2,
  name = 3,
  type = 4,
  value = 5,
  size = 6,
  price_type = 7,
  pre_price = 8,
  price = 9,
  num = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_days7_sell_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function days7_sell_info.getLength()
    return #days7_sell_info._data
end



function days7_sell_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_days7_sell_info
function days7_sell_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = days7_sell_info._data[index]}, m)
    
end

---
--@return @class record_days7_sell_info
function days7_sell_info.get(id)
    
    return days7_sell_info.indexOf(__index_id[id])
        
end



function days7_sell_info.set(id, key, value)
    local record = days7_sell_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function days7_sell_info.get_index_data()
    return __index_id
end