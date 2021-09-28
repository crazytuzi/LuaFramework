

---@classdef record_month_fund_small_info
local record_month_fund_small_info = {}
  
record_month_fund_small_info.id = 0 --id  
record_month_fund_small_info.day = 0 --领奖时间  
record_month_fund_small_info.type = 0 --奖励类型  
record_month_fund_small_info.value = 0 --奖励类型值  
record_month_fund_small_info.size = 0 --奖励数量  
record_month_fund_small_info.add_effect = 0 --是否加特效


month_fund_small_info = {
   _data = {
    [1] = {1,1,1,0,680000,0,},
    [2] = {2,2,1,0,880000,0,},
    [3] = {3,3,23,0,388,0,},
    [4] = {4,4,23,0,888,0,},
    [5] = {5,5,2,0,188,1,},
    [6] = {6,6,3,14,88,0,},
    [7] = {7,7,3,14,128,0,},
    [8] = {8,8,3,60,188,0,},
    [9] = {9,9,3,60,288,0,},
    [10] = {10,10,2,0,218,1,},
    [11] = {11,11,3,13,58,0,},
    [12] = {12,12,3,13,128,0,},
    [13] = {13,13,3,18,188,0,},
    [14] = {14,14,3,18,368,0,},
    [15] = {15,15,2,0,288,1,},
    [16] = {16,16,7,2,4,0,},
    [17] = {17,17,7,2,8,0,},
    [18] = {18,18,3,45,188,0,},
    [19] = {19,19,3,45,368,0,},
    [20] = {20,20,3,186,1,1,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
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
  day = 2,
  type = 3,
  value = 4,
  size = 5,
  add_effect = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_month_fund_small_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function month_fund_small_info.getLength()
    return #month_fund_small_info._data
end



function month_fund_small_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_month_fund_small_info
function month_fund_small_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = month_fund_small_info._data[index]}, m)
    
end

---
--@return @class record_month_fund_small_info
function month_fund_small_info.get(id)
    
    return month_fund_small_info.indexOf(__index_id[id])
        
end



function month_fund_small_info.set(id, key, value)
    local record = month_fund_small_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function month_fund_small_info.get_index_data()
    return __index_id
end