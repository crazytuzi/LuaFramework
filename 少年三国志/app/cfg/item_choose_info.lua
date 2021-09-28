

---@classdef record_item_choose_info
local record_item_choose_info = {}
  
record_item_choose_info.id = 0 --id  
record_item_choose_info.switch_type = 0 --判断类型  
record_item_choose_info.switch_value = 0 --判断类型值  
record_item_choose_info.drop_true = 0 --掉落包真  
record_item_choose_info.drop_false = 0 --掉落包假


item_choose_info = {
   _data = {
    [1] = {1,1,301,49,53,},
    [2] = {2,1,401,50,54,},
    [3] = {3,1,201,51,55,},
    [4] = {4,1,501,52,56,},
    [5] = {5,1,601,120,121,},
    [6] = {6,1,602,122,123,},
    [7] = {7,1,701,704,708,},
    [8] = {8,1,702,705,709,},
    [9] = {9,1,703,706,710,},
    [10] = {10,1,704,707,711,},
	[11] = {11,1,705,707,267,},
	[12] = {12,1,706,707,268,},
	[13] = {13,1,707,707,269,},
	[14] = {14,1,708,707,270,},
    }
}



local __index_id = {
    [1] = 1,
	[11] = 11,
	[12] = 12,
	[13] = 13,
	[14] = 14,
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
  switch_type = 2,
  switch_value = 3,
  drop_true = 4,
  drop_false = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_item_choose_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function item_choose_info.getLength()
    return #item_choose_info._data
end



function item_choose_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_item_choose_info
function item_choose_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = item_choose_info._data[index]}, m)
    
end

---
--@return @class record_item_choose_info
function item_choose_info.get(id)
    
    return item_choose_info.indexOf(__index_id[id])
        
end



function item_choose_info.set(id, key, value)
    local record = item_choose_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function item_choose_info.get_index_data()
    return __index_id
end