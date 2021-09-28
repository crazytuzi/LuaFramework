

---@classdef record_battlefield_info
local record_battlefield_info = {}
  
record_battlefield_info.id = 0 --关卡ID  
record_battlefield_info.ratio = 0 --挑战奖励系数  
record_battlefield_info.award_type = 0 --关卡宝箱ID  
record_battlefield_info.image = 0 --据点形象  
record_battlefield_info.price_type = 0 --开宝箱花费  
record_battlefield_info.drop_award = 0 --掉落奖励  
record_battlefield_info.award_type = 0 --掉落奖励类型  
record_battlefield_info.award_value = 0 --掉落奖励类型值  
record_battlefield_info.award_size = 0 --掉落奖励数量  
record_battlefield_info.award_name = "" --宝藏名称  
record_battlefield_info.tips = "" --气泡描述  
record_battlefield_info.buff_id1 = 0 --buff_id1  
record_battlefield_info.buff_id2 = 0 --buff_id2


battlefield_info = {
   _data = {
    [1] = {1,0,1,1,25,1001,3,198,1,"第一关宝藏","0",0,0,},
    [2] = {2,50,2,2,26,1002,3,198,2,"第二关宝藏","这是战场第2关，战胜我可以获得额外兽魂",0,0,},
    [3] = {3,100,3,3,27,1003,3,198,3,"第三关宝藏","这是战场第3关，战胜我可以获得额外兽魂",0,0,},
    [4] = {4,150,4,4,28,1004,3,198,4,"第四关宝藏","这是战场第4关，战胜我可以获得额外兽魂",0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,

}

local __key_map = {
  id = 1,
  ratio = 2,
  award_type = 3,
  image = 4,
  price_type = 5,
  drop_award = 6,
  award_type = 7,
  award_value = 8,
  award_size = 9,
  award_name = 10,
  tips = 11,
  buff_id1 = 12,
  buff_id2 = 13,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_battlefield_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function battlefield_info.getLength()
    return #battlefield_info._data
end



function battlefield_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_battlefield_info
function battlefield_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = battlefield_info._data[index]}, m)
    
end

---
--@return @class record_battlefield_info
function battlefield_info.get(id)
    
    return battlefield_info.indexOf(__index_id[id])
        
end



function battlefield_info.set(id, key, value)
    local record = battlefield_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function battlefield_info.get_index_data()
    return __index_id
end