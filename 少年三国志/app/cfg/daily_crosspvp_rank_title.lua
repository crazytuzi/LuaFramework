

---@classdef record_daily_crosspvp_rank_title
local record_daily_crosspvp_rank_title = {}
  
record_daily_crosspvp_rank_title.id = 0 --称号id  
record_daily_crosspvp_rank_title.low_rank = 0 --最低排名  
record_daily_crosspvp_rank_title.low_value = 0 --最低荣誉值  
record_daily_crosspvp_rank_title.text = "" --称号  
record_daily_crosspvp_rank_title.quality = 0 --称号颜色  
record_daily_crosspvp_rank_title.add_type1 = 0 --属性加成类型1  
record_daily_crosspvp_rank_title.add_value1 = 0 --属性加成值1  
record_daily_crosspvp_rank_title.add_type2 = 0 --属性加成类型2  
record_daily_crosspvp_rank_title.add_value2 = 0 --属性加成值2


daily_crosspvp_rank_title = {
   _data = {
    [1] = {1,10,4800,"国士无双",7,22,150,23,150,},
    [2] = {2,100,4000,"万人敌",6,22,120,23,120,},
    [3] = {3,300,3000,"一骑当千",5,22,100,23,100,},
    [4] = {4,0,3000,"黄沙百战",4,22,80,23,80,},
    [5] = {5,0,1000,"十战精兵",3,22,50,23,50,},
    [6] = {6,0,500,"初出茅庐",2,22,30,23,30,},
    [7] = {7,0,0,"一介武夫",1,0,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,

}

local __key_map = {
  id = 1,
  low_rank = 2,
  low_value = 3,
  text = 4,
  quality = 5,
  add_type1 = 6,
  add_value1 = 7,
  add_type2 = 8,
  add_value2 = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_daily_crosspvp_rank_title")
        
        
        return t._raw[__key_map[k]]
    end
}


function daily_crosspvp_rank_title.getLength()
    return #daily_crosspvp_rank_title._data
end



function daily_crosspvp_rank_title.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_daily_crosspvp_rank_title
function daily_crosspvp_rank_title.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = daily_crosspvp_rank_title._data[index]}, m)
    
end

---
--@return @class record_daily_crosspvp_rank_title
function daily_crosspvp_rank_title.get(id)
    
    return daily_crosspvp_rank_title.indexOf(__index_id[id])
        
end



function daily_crosspvp_rank_title.set(id, key, value)
    local record = daily_crosspvp_rank_title.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function daily_crosspvp_rank_title.get_index_data()
    return __index_id
end