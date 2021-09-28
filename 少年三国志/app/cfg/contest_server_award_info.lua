

---@classdef record_contest_server_award_info
local record_contest_server_award_info = {}
  
record_contest_server_award_info.id = 0 --id  
record_contest_server_award_info.name = "" --名称  
record_contest_server_award_info.rank = 0 --达成名次  
record_contest_server_award_info.item_type = 0 --物品类型  
record_contest_server_award_info.item_value = 0 --物品ID  
record_contest_server_award_info.item_size = 0 --物品数量


contest_server_award_info = {
   _data = {
    [1] = {1,"第1名",1,3,139,1,},
    [2] = {2,"第2名",2,3,140,1,},
    [3] = {3,"第3名",3,3,141,1,},
    [4] = {4,"第4名",4,3,142,1,},
    [5] = {5,"第5名",5,3,143,1,},
    [6] = {6,"第6名",6,3,144,1,},
    [7] = {7,"第7名",7,3,145,1,},
    [8] = {8,"第8名",8,3,146,1,},
    [9] = {9,"第9名",9,3,147,1,},
    [10] = {10,"第10名",10,3,148,1,},
    }
}



local __index_id = {
    [1] = 1,
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
  name = 2,
  rank = 3,
  item_type = 4,
  item_value = 5,
  item_size = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_server_award_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_server_award_info.getLength()
    return #contest_server_award_info._data
end



function contest_server_award_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_server_award_info
function contest_server_award_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_server_award_info._data[index]}, m)
    
end

---
--@return @class record_contest_server_award_info
function contest_server_award_info.get(id)
    
    return contest_server_award_info.indexOf(__index_id[id])
        
end



function contest_server_award_info.set(id, key, value)
    local record = contest_server_award_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_server_award_info.get_index_data()
    return __index_id
end