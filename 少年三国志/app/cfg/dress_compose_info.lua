

---@classdef record_dress_compose_info
local record_dress_compose_info = {}
  
record_dress_compose_info.id = 0 --id  
record_dress_compose_info.name = "" --名字  
record_dress_compose_info.dress_1 = 0 --时装1  
record_dress_compose_info.dress_2 = 0 --时装2  
record_dress_compose_info.dress_3 = 0 --时装3  
record_dress_compose_info.attribute_type_1 = 0 --属性1类型  
record_dress_compose_info.attribute_value_1 = 0 --属性1值  
record_dress_compose_info.attribute_type_2 = 0 --属性2类型  
record_dress_compose_info.attribute_value_2 = 0 --属性2值  
record_dress_compose_info.attribute_type_3 = 0 --属性3类型  
record_dress_compose_info.attribute_value_3 = 0 --属性3值  
record_dress_compose_info.attribute_type_4 = 0 --属性4类型  
record_dress_compose_info.attribute_value_4 = 0 --属性4值


dress_compose_info = {
   _data = {
    [1] = {1,"蛮族领袖",101,102,0,21,300,0,0,0,0,0,0,},
    [2] = {2,"凌云之志",201,202,0,22,100,23,100,0,0,0,0,},
    [3] = {3,"巧变破军",301,302,0,22,100,23,100,0,0,0,0,},
    [4] = {4,"勇冠千军",401,402,0,22,100,23,100,0,0,0,0,},
    [5] = {5,"太平道",501,502,0,22,100,23,100,0,0,0,0,},
    [6] = {6,"兰心蕙质",601,602,0,5,10000,0,0,0,0,0,0,},
    [7] = {7,"智谋无双",701,702,0,5,50000,23,200,0,0,0,0,},
    [8] = {8,"勇武无双",703,704,0,6,5000,22,200,0,0,0,0,},
	[9] = {9,"华容圣雄",705,706,0,6,5000,22,200,0,0,0,0,},
	[10] = {10,"名士风流",707,708,0,5,50000,22,200,0,0,0,0,},
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
	[10] = 10,

}

local __key_map = {
  id = 1,
  name = 2,
  dress_1 = 3,
  dress_2 = 4,
  dress_3 = 5,
  attribute_type_1 = 6,
  attribute_value_1 = 7,
  attribute_type_2 = 8,
  attribute_value_2 = 9,
  attribute_type_3 = 10,
  attribute_value_3 = 11,
  attribute_type_4 = 12,
  attribute_value_4 = 13,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dress_compose_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dress_compose_info.getLength()
    return #dress_compose_info._data
end



function dress_compose_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dress_compose_info
function dress_compose_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dress_compose_info._data[index]}, m)
    
end

---
--@return @class record_dress_compose_info
function dress_compose_info.get(id)
    
    return dress_compose_info.indexOf(__index_id[id])
        
end



function dress_compose_info.set(id, key, value)
    local record = dress_compose_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dress_compose_info.get_index_data()
    return __index_id
end