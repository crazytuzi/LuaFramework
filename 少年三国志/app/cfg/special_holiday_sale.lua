

---@classdef record_special_holiday_sale
local record_special_holiday_sale = {}
  
record_special_holiday_sale.id = 0 --编号  
record_special_holiday_sale.tags = 0 --任务页签  
record_special_holiday_sale.start_time = 0 --开始时间  
record_special_holiday_sale.end_time = 0 --结束时间  
record_special_holiday_sale.limit_time = "" --任务时间  
record_special_holiday_sale.type = 0 --货物类型  
record_special_holiday_sale.value = 0 --货物类型值  
record_special_holiday_sale.size = 0 --货物数量  
record_special_holiday_sale.price_type = 0 --购买货币类型  
record_special_holiday_sale.price = 0 --购买价格  
record_special_holiday_sale.extra_type = 0 --其他消耗类型  
record_special_holiday_sale.extra_value = 0 --其他消耗类型值  
record_special_holiday_sale.extra_size = 0 --其他消耗数量  
record_special_holiday_sale.extra_type2 = 0 --其他消耗类型2  
record_special_holiday_sale.extra_value2 = 0 --其他消耗类型值2  
record_special_holiday_sale.extra_size2 = 0 --其他消耗数量2  
record_special_holiday_sale.discount = 0 --折扣  
record_special_holiday_sale.arrange = 0 --显示顺序  
record_special_holiday_sale.level_min = 0 --等级下限（闭区间）  
record_special_holiday_sale.level_max = 0 --等级上限（闭区间）  
record_special_holiday_sale.time_self = 0 --活动内单人可兑换次数


special_holiday_sale = {
   _data = {
    [1] = {57,1,1449763200,1450022400,"1",1,0,1000000,2,468,0,0,0,0,0,0,45,17,1,150,30,},
    [2] = {58,1,1449763200,1450022400,"1",1,0,20000000,2,6188,0,0,0,0,0,0,30,18,1,150,3,},
    [3] = {59,1,1449763200,1450022400,"1",3,204,300,2,568,0,0,0,0,0,0,90,19,1,150,10,},
    [4] = {60,1,1449763200,1450022400,"1",3,204,3000,2,4888,0,0,0,0,0,0,80,20,1,150,1,},
    [5] = {61,1,1449763200,1450022400,"1",23,0,1000,2,498,0,0,0,0,0,0,50,21,1,150,10,},
    [6] = {62,1,1449763200,1450022400,"1",23,0,10000,2,4688,0,0,0,0,0,0,45,22,1,150,1,},
    [7] = {63,1,1449763200,1450022400,"1",3,3,10,2,398,0,0,0,0,0,0,80,23,1,150,10,},
    [8] = {64,1,1449763200,1450022400,"1",3,3,100,2,3488,0,0,0,0,0,0,70,24,1,150,1,},
    [9] = {65,1,1449763200,1450022400,"1",6,50010,10,2,2500,0,0,0,0,0,0,0,25,1,150,20,},
    [10] = {66,1,1449763200,1450022400,"1",6,50009,10,2,2500,0,0,0,0,0,0,0,26,1,150,20,},
    [11] = {67,1,1449763200,1450022400,"1",3,305,1,2,300,0,0,0,0,0,0,60,27,1,150,30,},
    [12] = {68,1,1449763200,1450022400,"1",3,275,1,2,800,0,0,0,0,0,0,80,28,1,150,15,},
    [13] = {69,2,1449763200,1450022400,"1",3,303,5,0,0,3,304,1,0,0,0,0,29,1,150,0,},
    [14] = {70,2,1449763200,1450022400,"1",1,0,50000,0,0,3,303,1,0,0,0,0,30,1,150,0,},
    [15] = {71,2,1449763200,1450022400,"1",13,0,100,0,0,3,303,2,0,0,0,0,31,1,150,200,},
    [16] = {72,2,1449763200,1450022400,"1",29,0,100,0,0,3,303,2,0,0,0,0,32,1,150,200,},
    [17] = {73,2,1449763200,1450022400,"1",6,50010,1,0,0,3,304,1,0,0,0,0,34,1,150,200,},
    [18] = {74,2,1449763200,1450022400,"1",6,50009,1,0,0,3,304,1,0,0,0,0,35,1,150,200,},
    [19] = {75,2,1449763200,1450022400,"1",3,275,1,0,0,3,303,20,0,0,0,0,36,1,150,15,},
    }
}



local __index_id = {
    [57] = 1,
    [58] = 2,
    [59] = 3,
    [60] = 4,
    [61] = 5,
    [62] = 6,
    [63] = 7,
    [64] = 8,
    [65] = 9,
    [66] = 10,
    [67] = 11,
    [68] = 12,
    [69] = 13,
    [70] = 14,
    [71] = 15,
    [72] = 16,
    [73] = 17,
    [74] = 18,
    [75] = 19,

}

local __key_map = {
  id = 1,
  tags = 2,
  start_time = 3,
  end_time = 4,
  limit_time = 5,
  type = 6,
  value = 7,
  size = 8,
  price_type = 9,
  price = 10,
  extra_type = 11,
  extra_value = 12,
  extra_size = 13,
  extra_type2 = 14,
  extra_value2 = 15,
  extra_size2 = 16,
  discount = 17,
  arrange = 18,
  level_min = 19,
  level_max = 20,
  time_self = 21,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_special_holiday_sale")
        
        
        return t._raw[__key_map[k]]
    end
}


function special_holiday_sale.getLength()
    return #special_holiday_sale._data
end



function special_holiday_sale.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_special_holiday_sale
function special_holiday_sale.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = special_holiday_sale._data[index]}, m)
    
end

---
--@return @class record_special_holiday_sale
function special_holiday_sale.get(id)
    
    return special_holiday_sale.indexOf(__index_id[id])
        
end



function special_holiday_sale.set(id, key, value)
    local record = special_holiday_sale.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function special_holiday_sale.get_index_data()
    return __index_id
end