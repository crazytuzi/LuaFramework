

---@classdef record_group_buy_goods_info
local record_group_buy_goods_info = {}
  
record_group_buy_goods_info.id = 0 --编号  
record_group_buy_goods_info.type = 0 --货物类型  
record_group_buy_goods_info.value = 0 --货物ID  
record_group_buy_goods_info.size = 0 --货物数量  
record_group_buy_goods_info.initial_price = 0 --初始价格  
record_group_buy_goods_info.initial_off = 0 --初始折扣  
record_group_buy_goods_info.coupon_use_percent = 0 --可使用团购券%  
record_group_buy_goods_info.buyer_num_1 = 0 --购买玩家数1  
record_group_buy_goods_info.off_price_1 = 0 --折扣价格1  
record_group_buy_goods_info.buyer_num_2 = 0 --购买玩家数2  
record_group_buy_goods_info.off_price_2 = 0 --折扣价格2  
record_group_buy_goods_info.buyer_num_3 = 0 --购买玩家数3  
record_group_buy_goods_info.off_price_3 = 0 --折扣价格3  
record_group_buy_goods_info.buyer_num_4 = 0 --购买玩家数4  
record_group_buy_goods_info.off_price_4 = 0 --折扣价格4  
record_group_buy_goods_info.buy_max_day = 0 --玩家单日购买上限  
record_group_buy_goods_info.coupon_give_percent = 0 --团购券返还比例  
record_group_buy_goods_info.level = 0 --玩家可购买/可见等级限制  
record_group_buy_goods_info.vip_level = 0 --玩家可购买/可见VIP限制


group_buy_goods_info = {
   _data = {
    [1] = {1,1,0,5000000,5000,500,50,40,450,80,400,120,350,160,300,2,50,0,0,},
    [2] = {2,3,298,1,600,800,50,100,750,200,700,300,650,400,600,2,50,0,0,},
    [3] = {3,3,299,1,4000,800,50,100,750,200,700,300,650,400,600,1,50,0,0,},
    [4] = {4,6,50006,10,2000,800,50,100,750,200,700,300,650,400,600,2,50,0,0,},
    [5] = {5,6,50008,10,2000,800,50,100,750,200,700,300,650,400,600,2,50,0,0,},
    [6] = {6,6,50004,10,2000,800,50,100,750,200,700,300,650,400,600,2,50,0,0,},
    [7] = {7,6,50002,10,1500,800,50,100,750,200,700,300,650,400,600,3,50,0,0,},
    [8] = {8,6,50003,10,1500,800,50,100,750,200,700,300,650,400,600,3,50,0,0,},
    [9] = {9,3,186,1,5000,800,50,40,750,80,700,120,650,160,600,2,50,0,0,},
    [10] = {10,6,5001,6,1500,800,50,100,750,200,700,300,650,400,600,10,50,0,0,},
    [11] = {11,6,5002,6,1500,800,50,100,750,200,700,300,650,400,600,10,50,0,0,},
    [12] = {12,6,5003,6,1500,800,50,100,750,200,700,300,650,400,600,10,50,0,0,},
    [13] = {13,6,5004,6,1500,800,50,100,750,200,700,300,650,400,600,10,50,0,0,},
    [14] = {14,3,189,1,1750,800,50,100,750,200,700,300,650,400,600,10,50,0,0,},
    [15] = {15,3,116,1,2250,350,50,100,300,200,250,300,200,400,150,10,50,0,0,},
    [16] = {16,3,184,1,2500,750,100,60,700,120,650,180,600,240,550,3,50,0,0,},
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
  type = 2,
  value = 3,
  size = 4,
  initial_price = 5,
  initial_off = 6,
  coupon_use_percent = 7,
  buyer_num_1 = 8,
  off_price_1 = 9,
  buyer_num_2 = 10,
  off_price_2 = 11,
  buyer_num_3 = 12,
  off_price_3 = 13,
  buyer_num_4 = 14,
  off_price_4 = 15,
  buy_max_day = 16,
  coupon_give_percent = 17,
  level = 18,
  vip_level = 19,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_group_buy_goods_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function group_buy_goods_info.getLength()
    return #group_buy_goods_info._data
end



function group_buy_goods_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_group_buy_goods_info
function group_buy_goods_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = group_buy_goods_info._data[index]}, m)
    
end

---
--@return @class record_group_buy_goods_info
function group_buy_goods_info.get(id)
    
    return group_buy_goods_info.indexOf(__index_id[id])
        
end



function group_buy_goods_info.set(id, key, value)
    local record = group_buy_goods_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function group_buy_goods_info.get_index_data()
    return __index_id
end