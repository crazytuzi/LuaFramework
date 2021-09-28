

---@classdef record_compose_info
local record_compose_info = {}
  
record_compose_info.id = 0 --id  
record_compose_info.compose_level = 0 --合成等级  
record_compose_info.item_id = 0 --目标道具id  
record_compose_info.item_type = 0 --目标道具种类  
record_compose_info.item_size = 0 --目标道具数量  
record_compose_info.name = "" --名称  
record_compose_info.son_id = 0 --合成子道具id  
record_compose_info.son_type = 0 --合成子道具种类  
record_compose_info.son_size = 0 --合成所需子道具数量  
record_compose_info.compose_cost = 0 --合成费用  
record_compose_info.max_cost = 0 --合成最大费用  
record_compose_info.max_compose = 0 --合成最大个数


compose_info = {
   _data = {
    [1] = {1,65,13,11,1,"极品精炼石",10,11,10,1000,999999,99999,},
    [2] = {2,65,13,11,1,"极品精炼石",11,11,5,1000,999999,99999,},
    [3] = {3,65,13,11,1,"极品精炼石",12,11,2,1000,999999,99999,},
    [4] = {4,70,199,26,1,"中级战宠口粮",198,26,5,1000,999999,99999,},
    [5] = {5,70,200,26,1,"高级战宠口粮",199,26,2,1000,999999,99999,},
    [6] = {6,70,203,27,1,"高级神炼石",201,27,4,1000,999999,99999,},
    [7] = {7,70,203,27,1,"高级神炼石",202,27,2,1000,999999,99999,},
    [8] = {8,70,290,26,1,"特级战宠口粮",200,26,10,1000,999999,99999,},
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
    [8] = 8,

}

local __key_map = {
  id = 1,
  compose_level = 2,
  item_id = 3,
  item_type = 4,
  item_size = 5,
  name = 6,
  son_id = 7,
  son_type = 8,
  son_size = 9,
  compose_cost = 10,
  max_cost = 11,
  max_compose = 12,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_compose_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function compose_info.getLength()
    return #compose_info._data
end



function compose_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_compose_info
function compose_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = compose_info._data[index]}, m)
    
end

---
--@return @class record_compose_info
function compose_info.get(id)
    
    return compose_info.indexOf(__index_id[id])
        
end



function compose_info.set(id, key, value)
    local record = compose_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function compose_info.get_index_data()
    return __index_id
end