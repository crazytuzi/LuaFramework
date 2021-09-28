

---@classdef record_corps_info
local record_corps_info = {}
  
record_corps_info.id = 0 --id  
record_corps_info.level = 0 --军团等级  
record_corps_info.exp = 0 --升到下级所需经验  
record_corps_info.number = 0 --成员数上限  
record_corps_info.plunder_exp = 0 --群英战抢夺经验  
record_corps_info.worship_value_1 = 0 --祭天进度1  
record_corps_info.item_type_1 = 0 --进度1物品类型  
record_corps_info.item_id_1 = 0 --进度1物品ID  
record_corps_info.item_size_1 = 0 --进度1物品数量  
record_corps_info.worship_value_2 = 0 --祭天进度2  
record_corps_info.item_type_2 = 0 --进度2物品类型  
record_corps_info.item_id_2 = 0 --进度2物品ID  
record_corps_info.item_size_2 = 0 --进度2物品数量  
record_corps_info.worship_value_3 = 0 --祭天进度3  
record_corps_info.item_type_3 = 0 --进度3物品类型  
record_corps_info.item_id_3 = 0 --进度3物品ID  
record_corps_info.item_size_3 = 0 --进度3物品数量  
record_corps_info.worship_value_4 = 0 --祭天进度4  
record_corps_info.item_type_4 = 0 --进度4物品类型  
record_corps_info.item_id_4 = 0 --进度4物品ID  
record_corps_info.item_size_4 = 0 --进度4物品数量


corps_info = {
   _data = {
    [1] = {1,1,5000,30,500,40,3,47,3,85,1,0,50000,110,2,0,50,135,20,0,500,},
    [2] = {2,2,15000,32,500,40,3,47,3,85,1,0,55000,110,2,0,55,135,20,0,550,},
    [3] = {3,3,50000,34,500,50,3,48,3,95,1,0,60000,125,2,0,60,155,20,0,600,},
    [4] = {4,4,100000,36,300,50,3,48,3,95,1,0,65000,125,2,0,65,155,20,0,650,},
    [5] = {5,5,300000,38,200,55,3,49,3,105,1,0,70000,140,2,0,70,170,20,0,700,},
    [6] = {6,6,600000,40,150,55,3,49,3,105,1,0,75000,140,2,0,75,170,20,0,750,},
    [7] = {7,7,900000,42,110,60,3,49,4,120,1,0,80000,155,2,0,80,190,20,0,800,},
    [8] = {8,8,1300000,44,80,60,3,49,4,120,1,0,85000,155,2,0,85,190,20,0,850,},
    [9] = {9,9,1800000,46,70,65,3,49,5,130,1,0,90000,165,2,0,90,210,20,0,900,},
    [10] = {10,10,0,48,70,65,3,49,5,130,1,0,100000,165,2,0,100,210,20,0,1000,},
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
  level = 2,
  exp = 3,
  number = 4,
  plunder_exp = 5,
  worship_value_1 = 6,
  item_type_1 = 7,
  item_id_1 = 8,
  item_size_1 = 9,
  worship_value_2 = 10,
  item_type_2 = 11,
  item_id_2 = 12,
  item_size_2 = 13,
  worship_value_3 = 14,
  item_type_3 = 15,
  item_id_3 = 16,
  item_size_3 = 17,
  worship_value_4 = 18,
  item_type_4 = 19,
  item_id_4 = 20,
  item_size_4 = 21,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_info.getLength()
    return #corps_info._data
end



function corps_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_info
function corps_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_info._data[index]}, m)
    
end

---
--@return @class record_corps_info
function corps_info.get(id)
    
    return corps_info.indexOf(__index_id[id])
        
end



function corps_info.set(id, key, value)
    local record = corps_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_info.get_index_data()
    return __index_id
end