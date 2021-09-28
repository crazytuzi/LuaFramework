

---@classdef record_login_reward_info_vip
local record_login_reward_info_vip = {}
  
record_login_reward_info_vip.id = 0 --id  
record_login_reward_info_vip.level = 0 --等级  
record_login_reward_info_vip.type_1 = 0 --物品类型1  
record_login_reward_info_vip.value_1 = 0 --类型值1  
record_login_reward_info_vip.size_1 = 0 --数量1  
record_login_reward_info_vip.type_2 = 0 --物品类型2  
record_login_reward_info_vip.value_2 = 0 --类型值2  
record_login_reward_info_vip.size_2 = 0 --数量2  
record_login_reward_info_vip.price = 0 --原价


login_reward_info_vip = {
   _data = {
    [1] = {1,1,13,0,100,3,15,10,300,},
    [2] = {2,30,1,0,100000,3,6,200,300,},
    [3] = {3,30,1,0,100000,3,9,66,300,},
    [4] = {4,30,1,0,100000,3,15,10,300,},
    [5] = {5,30,1,0,100000,3,18,40,300,},
    [6] = {6,30,1,0,100000,3,11,40,300,},
    [7] = {7,30,1,0,100000,3,21,2,300,},
    [8] = {8,30,1,0,100000,3,22,2,300,},
    [9] = {9,50,23,0,100,3,60,66,300,},
    [10] = {10,50,23,0,100,3,6,200,300,},
    [11] = {11,50,23,0,100,3,15,10,300,},
    [12] = {12,50,23,0,100,3,18,40,300,},
    [13] = {13,50,23,0,100,3,11,40,300,},
    [14] = {14,50,23,0,100,3,21,2,300,},
    [15] = {15,50,23,0,100,3,22,2,300,},
    [16] = {16,60,23,0,100,3,3,4,300,},
    [17] = {17,60,23,0,100,3,81,4,300,},
    [18] = {18,60,23,0,100,3,60,66,300,},
    [19] = {19,60,23,0,100,3,6,200,300,},
    [20] = {20,60,23,0,100,3,15,10,300,},
    [21] = {21,60,23,0,100,3,18,40,300,},
    [22] = {22,60,23,0,100,3,11,40,300,},
    [23] = {23,60,23,0,100,3,36,20,300,},
    [24] = {24,70,29,0,100,3,45,40,300,},
    [25] = {25,70,29,0,100,3,3,4,300,},
    [26] = {26,70,29,0,100,3,81,4,300,},
    [27] = {27,70,29,0,100,3,60,66,300,},
    [28] = {28,70,29,0,100,3,6,200,300,},
    [29] = {29,70,29,0,100,3,15,10,300,},
    [30] = {30,70,29,0,100,3,18,40,300,},
    [31] = {31,70,29,0,100,3,11,40,300,},
    [32] = {32,70,29,0,100,3,36,20,300,},
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
    [32] = 32,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  level = 2,
  type_1 = 3,
  value_1 = 4,
  size_1 = 5,
  type_2 = 6,
  value_2 = 7,
  size_2 = 8,
  price = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_login_reward_info_vip")
        
        
        return t._raw[__key_map[k]]
    end
}


function login_reward_info_vip.getLength()
    return #login_reward_info_vip._data
end



function login_reward_info_vip.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_login_reward_info_vip
function login_reward_info_vip.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = login_reward_info_vip._data[index]}, m)
    
end

---
--@return @class record_login_reward_info_vip
function login_reward_info_vip.get(id)
    
    return login_reward_info_vip.indexOf(__index_id[id])
        
end



function login_reward_info_vip.set(id, key, value)
    local record = login_reward_info_vip.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function login_reward_info_vip.get_index_data()
    return __index_id
end