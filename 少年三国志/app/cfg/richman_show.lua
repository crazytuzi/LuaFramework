

---@classdef record_richman_show
local record_richman_show = {}
  
record_richman_show.type = 0 --格子类型  
record_richman_show.time = 0 --出现时间  
record_richman_show.face = 0 --表情id  
record_richman_show.chat = "" --气泡对话


richman_show = {
   _data = {
    [1] = {1,1,10,"噢耶！钱钱钱~噢嘛呢够麦厚~",},
    [2] = {2,1,5,"艾玛~赚到了个宝贝大箱子！",},
    [3] = {3,1,18,"咦~？发生了什么好事？",},
    [4] = {4,1,11,"神秘商店我来喽~逛逛逛~买买买~",},
    [5] = {5,2,26,"神马！难道不是停在这里？！",},
    [6] = {6,2,53,"第#num#圈巡回完成，纪念一下！",},
    [7] = {7,2,20,"俺要寻宝，快摇骰，快摇骰~",},
    }
}



local __index_type = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,

}

local __key_map = {
  type = 1,
  time = 2,
  face = 3,
  chat = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_richman_show")
        
        
        return t._raw[__key_map[k]]
    end
}


function richman_show.getLength()
    return #richman_show._data
end



function richman_show.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_richman_show
function richman_show.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = richman_show._data[index]}, m)
    
end

---
--@return @class record_richman_show
function richman_show.get(type)
    
    return richman_show.indexOf(__index_type[type])
        
end



function richman_show.set(type, key, value)
    local record = richman_show.get(type)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function richman_show.get_index_data()
    return __index_type
end