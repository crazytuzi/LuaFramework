

---@classdef record_return_level_gift_info
local record_return_level_gift_info = {}
  
record_return_level_gift_info.id = 0 --id  
record_return_level_gift_info.type = 0 --活动类型  
record_return_level_gift_info.level = 0 --等级  
record_return_level_gift_info.type_1 = 0 --奖励类型1  
record_return_level_gift_info.value_1 = 0 --类型值1  
record_return_level_gift_info.size_1 = 0 --数量1  
record_return_level_gift_info.type_2 = 0 --奖励类型2  
record_return_level_gift_info.value_2 = 0 --类型值2  
record_return_level_gift_info.size_2 = 0 --数量2  
record_return_level_gift_info.type_3 = 0 --奖励类型3  
record_return_level_gift_info.value_3 = 0 --类型值3  
record_return_level_gift_info.size_3 = 0 --数量3  
record_return_level_gift_info.type_4 = 0 --奖励类型4  
record_return_level_gift_info.value_4 = 0 --类型值4  
record_return_level_gift_info.size_4 = 0 --数量4


return_level_gift_info = {
   _data = {
    [1] = {1,1,30,2,0,1000,1,0,500000,0,0,0,0,0,0,},
    [2] = {2,1,50,3,60,500,3,14,200,0,0,0,0,0,0,},
    [3] = {3,1,65,3,55,1,3,189,1,0,0,0,0,0,0,},
    [4] = {4,1,75,28,50300,1,3,198,50,3,201,50,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,

}

local __key_map = {
  id = 1,
  type = 2,
  level = 3,
  type_1 = 4,
  value_1 = 5,
  size_1 = 6,
  type_2 = 7,
  value_2 = 8,
  size_2 = 9,
  type_3 = 10,
  value_3 = 11,
  size_3 = 12,
  type_4 = 13,
  value_4 = 14,
  size_4 = 15,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_return_level_gift_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function return_level_gift_info.getLength()
    return #return_level_gift_info._data
end



function return_level_gift_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_return_level_gift_info
function return_level_gift_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = return_level_gift_info._data[index]}, m)
    
end

---
--@return @class record_return_level_gift_info
function return_level_gift_info.get(id)
    
    return return_level_gift_info.indexOf(__index_id[id])
        
end



function return_level_gift_info.set(id, key, value)
    local record = return_level_gift_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function return_level_gift_info.get_index_data()
    return __index_id
end