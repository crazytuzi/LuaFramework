

---@classdef record_city_knight_text
local record_city_knight_text = {}
  
record_city_knight_text.id = 0 --id  
record_city_knight_text.city_id = "" --城市  
record_city_knight_text.text = "" --巡逻语言


city_knight_text = {
   _data = {
    [1] = {1,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [2] = {2,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [3] = {3,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [4] = {4,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [5] = {5,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [6] = {6,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [7] = {7,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [8] = {8,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [9] = {9,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    [10] = {10,"0","主公，你放心去刷副本夺宝吧，这里的安危就交给我啦！",},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  city_id = 2,
  text = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_city_knight_text")
        
        
        return t._raw[__key_map[k]]
    end
}


function city_knight_text.getLength()
    return #city_knight_text._data
end



function city_knight_text.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_city_knight_text
function city_knight_text.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = city_knight_text._data[index]}, m)
    
end

---
--@return @class record_city_knight_text
function city_knight_text.get(id)
    
    return city_knight_text.indexOf(__index_id[id])
        
end



function city_knight_text.set(id, key, value)
    local record = city_knight_text.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function city_knight_text.get_index_data()
    return __index_id
end