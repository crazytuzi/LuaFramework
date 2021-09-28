

---@classdef record_item_box_info
local record_item_box_info = {}
  
record_item_box_info.id = 0 --选择库id  
record_item_box_info.item_id = 0 --道具id  
record_item_box_info.num = 0 --道具数量  
record_item_box_info.choice_type_1 = 0 --选择1类型  
record_item_box_info.choice_value_1 = 0 --选择1类型值  
record_item_box_info.choice_size_1 = 0 --选择1数量  
record_item_box_info.choice_type_2 = 0 --选择2类型  
record_item_box_info.choice_value_2 = 0 --选择2类型值  
record_item_box_info.choice_size_2 = 0 --选择2数量  
record_item_box_info.choice_type_3 = 0 --选择3类型  
record_item_box_info.choice_value_3 = 0 --选择3类型值  
record_item_box_info.choice_size_3 = 0 --选择3数量  
record_item_box_info.choice_type_4 = 0 --选择4类型  
record_item_box_info.choice_value_4 = 0 --选择4类型值  
record_item_box_info.choice_size_4 = 0 --选择4数量


item_box_info = {
   _data = {
    [1] = {1,55,2,3,55,1,3,187,1,0,0,0,0,0,0,},
    [2] = {2,67,4,4,10111,1,4,20089,1,4,30067,1,4,40133,1,},
    [3] = {3,86,4,3,82,1,3,83,1,3,84,1,3,85,1,},
    [4] = {4,103,4,5,5001,1,5,5002,1,5,5003,1,5,5004,1,},
    [5] = {5,156,4,4,10122,1,4,20045,1,4,30012,1,4,40056,1,},
    [6] = {6,157,4,4,10067,1,4,20067,1,4,30144,1,4,40177,1,},
    [7] = {7,158,4,4,10089,1,4,20155,1,4,30078,1,4,40166,1,},
    [8] = {8,159,4,4,10144,1,4,20012,1,4,30133,1,4,40012,1,},
    [9] = {9,160,4,4,10045,1,4,20023,1,4,30034,1,4,40188,1,},
    [10] = {10,161,3,5,4001,1,5,4011,1,5,4021,1,0,0,0,},
    [11] = {11,162,3,5,4002,1,5,4012,1,5,4022,1,0,0,0,},
    [12] = {12,163,3,5,4004,1,5,4014,1,5,4024,1,0,0,0,},
    [13] = {13,164,3,5,4003,1,5,4013,1,5,4023,1,0,0,0,},
    [14] = {14,186,4,4,10001,1,4,20001,1,4,30045,1,4,40045,1,},
    [15] = {15,187,4,4,10056,1,4,20078,1,4,30001,1,4,40001,1,},
    [16] = {16,188,4,7,301,1,7,302,1,7,303,1,7,304,1,},
    [17] = {17,189,4,7,401,1,7,402,1,7,403,1,7,404,1,},
    [18] = {18,194,4,3,190,1,3,191,1,3,192,1,3,193,1,},
    [19] = {19,216,4,6,5001,1,6,5002,1,6,5003,1,6,5004,1,},
    [20] = {20,289,4,6,50004,1,6,50005,1,6,50006,1,6,50008,1,},
    [21] = {21,300,2,3,301,1,3,302,1,0,0,0,0,0,0,},
    [22] = {22,301,4,6,10001,1,6,10025,1,6,10052,1,6,10075,1,},
    [23] = {23,302,4,6,10006,1,6,10032,1,6,10048,1,6,10071,1,},
    [24] = {24,358,4,3,354,1,3,355,1,3,356,1,3,357,1,},
    [25] = {25,358,2,3,358,1,3,194,1,0,0,0,0,0,0,},
	[26] = {26,369,4,5,6001,1,5,6002,1,5,6003,1,5,6004,1,},
	[27] = {27,370,4,5,7001,1,5,7002,1,5,7003,1,5,7004,1,},
	[28] = {28,371,4,5,7011,1,5,7012,1,5,7013,1,5,7014,1,},
	[29] = {29,372,4,5,7021,1,5,7022,1,5,7023,1,5,7024,1,},
	[30] = {30,373,4,5,7031,1,5,7032,1,5,7033,1,5,7034,1,},
	[31] = {31,374,4,5,7041,1,5,7042,1,5,7043,1,5,7044,1,},
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
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
	[26] = 26,
	[27] = 27,
	[28] = 28,
	[29] = 29,
    [3] = 3,
	[30] = 30,
	[31] = 31,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  item_id = 2,
  num = 3,
  choice_type_1 = 4,
  choice_value_1 = 5,
  choice_size_1 = 6,
  choice_type_2 = 7,
  choice_value_2 = 8,
  choice_size_2 = 9,
  choice_type_3 = 10,
  choice_value_3 = 11,
  choice_size_3 = 12,
  choice_type_4 = 13,
  choice_value_4 = 14,
  choice_size_4 = 15,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_item_box_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function item_box_info.getLength()
    return #item_box_info._data
end



function item_box_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_item_box_info
function item_box_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = item_box_info._data[index]}, m)
    
end

---
--@return @class record_item_box_info
function item_box_info.get(id)
    
    return item_box_info.indexOf(__index_id[id])
        
end



function item_box_info.set(id, key, value)
    local record = item_box_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function item_box_info.get_index_data()
    return __index_id
end