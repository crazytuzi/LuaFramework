

---@classdef record_month_card_info
local record_month_card_info = {}
  
record_month_card_info.id = 0 --id  
record_month_card_info.app_id = "" --版本  
record_month_card_info.product_id = "" --商品编号  
record_month_card_info.name = "" --商品名称  
record_month_card_info.size = 0 --充值金额  
record_month_card_info.recharge_gold = 0 --元宝兑换数量  
record_month_card_info.gold_back = 0 --每日返还元宝  
record_month_card_info.last_day = 0 --持续天数  
record_month_card_info.res_id = 0 --商品名称


month_card_info = {
   _data = {
    [1] = {1,"1","smc2","50元月卡",50,10000,30000,30,999,},
    [2] = {2,"1","smc1","25元月卡",25,5000,20000,30,998,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  app_id = 2,
  product_id = 3,
  name = 4,
  size = 5,
  recharge_gold = 6,
  gold_back = 7,
  last_day = 8,
  res_id = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_month_card_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function month_card_info.getLength()
    return #month_card_info._data
end



function month_card_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_month_card_info
function month_card_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = month_card_info._data[index]}, m)
    
end

---
--@return @class record_month_card_info
function month_card_info.get(id)
    
    return month_card_info.indexOf(__index_id[id])
        
end



function month_card_info.set(id, key, value)
    local record = month_card_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function month_card_info.get_index_data()
    return __index_id
end