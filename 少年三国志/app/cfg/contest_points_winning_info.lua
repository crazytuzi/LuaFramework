

---@classdef record_contest_points_winning_info
local record_contest_points_winning_info = {}
  
record_contest_points_winning_info.id = 0 --id  
record_contest_points_winning_info.name = "" --连胜名称  
record_contest_points_winning_info.winning_number = 0 --连胜场数  
record_contest_points_winning_info.item_type = 0 --物品类型  
record_contest_points_winning_info.item_value = 0 --物品ID  
record_contest_points_winning_info.item_size = 0 --物品数量


contest_points_winning_info = {
   _data = {
    [1] = {1,"胜利3场",3,25,0,150,},
    [2] = {2,"胜利5场",5,25,0,200,},
    [3] = {3,"胜利10场",10,25,0,300,},
    [4] = {4,"胜利15场",15,25,0,450,},
    [5] = {5,"胜利20场",20,25,0,600,},
    [6] = {6,"胜利25场",25,25,0,800,},
    [7] = {7,"胜利30场",30,25,0,1000,},
    [8] = {8,"胜利40场",40,25,0,1200,},
    [9] = {9,"胜利50场",50,25,0,1500,},
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
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  name = 2,
  winning_number = 3,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_points_winning_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_points_winning_info.getLength()
    return #contest_points_winning_info._data
end



function contest_points_winning_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_points_winning_info
function contest_points_winning_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_points_winning_info._data[index]}, m)
    
end

---
--@return @class record_contest_points_winning_info
function contest_points_winning_info.get(id)
    
    return contest_points_winning_info.indexOf(__index_id[id])
        
end



function contest_points_winning_info.set(id, key, value)
    local record = contest_points_winning_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_points_winning_info.get_index_data()
    return __index_id
end