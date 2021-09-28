

---@classdef record_camp_drop_info
local record_camp_drop_info = {}
  
record_camp_drop_info.drop_num = 0 --抽卡次数  
record_camp_drop_info.cost = 0 --花费元宝  
record_camp_drop_info.oran_probability = 0 --橙将概率


camp_drop_info = {
   _data = {
    [1] = {1,80,1,},
    [2] = {2,120,2,},
    [3] = {3,180,3,},
    [4] = {4,240,4,},
    [5] = {5,300,5,},
    [6] = {6,360,10,},
    [7] = {7,440,15,},
    [8] = {8,520,20,},
    [9] = {9,600,25,},
    [10] = {10,680,30,},
    [11] = {11,760,40,},
    [12] = {12,840,50,},
    [13] = {13,900,60,},
    [14] = {14,950,80,},
    [15] = {15,1000,100,},
    }
}



local __index_drop_num = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
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
  drop_num = 1,
  cost = 2,
  oran_probability = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_camp_drop_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function camp_drop_info.getLength()
    return #camp_drop_info._data
end



function camp_drop_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_camp_drop_info
function camp_drop_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = camp_drop_info._data[index]}, m)
    
end

---
--@return @class record_camp_drop_info
function camp_drop_info.get(drop_num)
    
    return camp_drop_info.indexOf(__index_drop_num[drop_num])
        
end



function camp_drop_info.set(drop_num, key, value)
    local record = camp_drop_info.get(drop_num)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function camp_drop_info.get_index_data()
    return __index_drop_num
end