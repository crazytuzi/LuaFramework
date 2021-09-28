

---@classdef record_shop_time_recharge_info
local record_shop_time_recharge_info = {}
  
record_shop_time_recharge_info.id = 0 --id  
record_shop_time_recharge_info.vip_level = 0 --VIP等级  
record_shop_time_recharge_info.prob = 0 --概率  
record_shop_time_recharge_info.recharge_size = 0 --充值金额  
record_shop_time_recharge_info.gift_gold_extra_min = 0 --额外赠送元宝min  
record_shop_time_recharge_info.gift_gold_extra_max = 0 --额外赠送元宝max  
record_shop_time_recharge_info.time = 0 --限制时长


shop_time_recharge_info = {
   _data = {
    [1] = {1,0,500,6,60,60,43200,},
    [2] = {2,0,300,6,60,60,43200,},
    [3] = {3,0,200,6,60,60,43200,},
    [4] = {4,1,500,30,90,180,43200,},
    [5] = {5,1,300,6,60,60,43200,},
    [6] = {6,1,200,6,60,60,43200,},
    [7] = {7,2,500,30,90,180,43200,},
    [8] = {8,2,300,6,60,60,43200,},
    [9] = {9,2,200,30,90,180,43200,},
    [10] = {10,3,500,6,60,60,43200,},
    [11] = {11,3,300,30,90,180,43200,},
    [12] = {12,3,200,30,90,180,43200,},
    [13] = {13,4,500,30,90,180,43200,},
    [14] = {14,4,300,30,90,180,43200,},
    [15] = {15,4,200,30,90,180,43200,},
    [16] = {16,5,500,30,90,180,43200,},
    [17] = {17,5,300,50,100,200,43200,},
    [18] = {18,5,200,50,100,200,43200,},
    [19] = {19,6,500,50,100,200,43200,},
    [20] = {20,6,300,128,192,384,43200,},
    [21] = {21,6,200,50,100,200,43200,},
    [22] = {22,7,500,50,100,200,43200,},
    [23] = {23,7,300,288,432,864,43200,},
    [24] = {24,7,200,128,192,384,43200,},
    [25] = {25,8,500,128,192,384,43200,},
    [26] = {26,8,300,548,548,1096,43200,},
    [27] = {27,8,200,288,432,864,43200,},
    [28] = {28,9,500,288,432,864,43200,},
    [29] = {29,9,300,548,548,1096,43200,},
    [30] = {30,9,200,548,548,1096,43200,},
    [31] = {31,10,500,548,548,1096,43200,},
    [32] = {32,10,300,548,548,1096,43200,},
    [33] = {33,10,200,648,648,1296,43200,},
    [34] = {34,11,500,648,648,1296,43200,},
    [35] = {35,11,300,648,648,1296,43200,},
    [36] = {36,11,200,648,648,1296,43200,},
    [37] = {37,12,500,648,648,1296,43200,},
    [38] = {38,12,300,648,648,1296,43200,},
    [39] = {39,12,200,648,648,1296,43200,},
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
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  vip_level = 2,
  prob = 3,
  recharge_size = 4,
  gift_gold_extra_min = 5,
  gift_gold_extra_max = 6,
  time = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_shop_time_recharge_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function shop_time_recharge_info.getLength()
    return #shop_time_recharge_info._data
end



function shop_time_recharge_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_shop_time_recharge_info
function shop_time_recharge_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = shop_time_recharge_info._data[index]}, m)
    
end

---
--@return @class record_shop_time_recharge_info
function shop_time_recharge_info.get(id)
    
    return shop_time_recharge_info.indexOf(__index_id[id])
        
end



function shop_time_recharge_info.set(id, key, value)
    local record = shop_time_recharge_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function shop_time_recharge_info.get_index_data()
    return __index_id
end