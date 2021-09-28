

---@classdef record_richman_shop_info
local record_richman_shop_info = {}
  
record_richman_shop_info.id = 0 --商店编号  
record_richman_shop_info.shop_type = "" --商店类型  
record_richman_shop_info.type = 0 --道具类型  
record_richman_shop_info.value = 0 --道具类型值  
record_richman_shop_info.size = 0 --道具数量  
record_richman_shop_info.cost_type = 0 --消耗货币类型  
record_richman_shop_info.cost_size = 0 --消耗货币数量  
record_richman_shop_info.limit = 0 --限购次数  
record_richman_shop_info.score = 0 --获得积分  
record_richman_shop_info.discount = "" --折扣


richman_shop_info = {
   _data = {
    [1] = {101,1,1,0,1000000,2,400,1,40,40,},
    [2] = {102,1,3,81,5,2,175,1,18,70,},
    [3] = {103,1,3,3,1,2,50,5,5,0,},
    [4] = {104,1,3,81,1,2,50,5,5,0,},
    [5] = {105,1,3,189,1,2,1200,1,120,0,},
    [6] = {106,1,3,275,1,2,888,2,88,80,},
    [7] = {201,2,1,0,1000000,2,400,1,40,40,},
    [8] = {202,2,3,13,50,2,600,1,60,60,},
    [9] = {203,2,3,12,10,2,90,3,9,90,},
    [10] = {204,2,3,18,20,2,90,3,9,90,},
    [11] = {205,2,3,13,20,2,360,4,36,90,},
    [12] = {206,2,3,275,1,2,888,2,88,80,},
    [13] = {301,3,1,0,1000000,2,400,1,40,40,},
    [14] = {302,3,3,60,200,2,360,1,36,60,},
    [15] = {303,3,3,60,30,2,90,3,9,0,},
    [16] = {304,3,23,0,100,2,100,3,10,0,},
    [17] = {305,3,3,74,1,2,620,2,62,0,},
    [18] = {306,3,3,275,1,2,888,2,88,80,},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [105] = 5,
    [106] = 6,
    [201] = 7,
    [202] = 8,
    [203] = 9,
    [204] = 10,
    [205] = 11,
    [206] = 12,
    [301] = 13,
    [302] = 14,
    [303] = 15,
    [304] = 16,
    [305] = 17,
    [306] = 18,

}

local __key_map = {
  id = 1,
  shop_type = 2,
  type = 3,
  value = 4,
  size = 5,
  cost_type = 6,
  cost_size = 7,
  limit = 8,
  score = 9,
  discount = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_richman_shop_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function richman_shop_info.getLength()
    return #richman_shop_info._data
end



function richman_shop_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_richman_shop_info
function richman_shop_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = richman_shop_info._data[index]}, m)
    
end

---
--@return @class record_richman_shop_info
function richman_shop_info.get(id)
    
    return richman_shop_info.indexOf(__index_id[id])
        
end



function richman_shop_info.set(id, key, value)
    local record = richman_shop_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function richman_shop_info.get_index_data()
    return __index_id
end