

---@classdef record_pet_compose_info
local record_pet_compose_info = {}
  
record_pet_compose_info.id = 0 --id  
record_pet_compose_info.name = "" --名字  
record_pet_compose_info.pet_1 = 0 --宠物1  
record_pet_compose_info.pet_2 = 0 --宠物2  
record_pet_compose_info.pet_3 = 0 --宠物3  
record_pet_compose_info.attribute_type_1 = 0 --属性1类型  
record_pet_compose_info.attribute_value_1 = 0 --属性1值  
record_pet_compose_info.attribute_type_2 = 0 --属性2类型  
record_pet_compose_info.attribute_value_2 = 0 --属性2值  
record_pet_compose_info.attribute_type_3 = 0 --属性3类型  
record_pet_compose_info.attribute_value_3 = 0 --属性3值  
record_pet_compose_info.attribute_type_4 = 0 --属性4类型  
record_pet_compose_info.attribute_value_4 = 0 --属性4值


pet_compose_info = {
   _data = {
    [1] = {101,"电光火石",50000,50300,50400,6,1600,5,10000,0,0,0,0,},
    [2] = {102,"铜甲甘霖",50100,50200,0,21,1000,5,10000,0,0,0,0,},
    [3] = {103,"天崩地裂",50500,50600,0,11,100,24,100,0,0,0,0,},
    [4] = {104,"龙影随凤",50900,51000,0,5,50000,6,2000,21,2000,0,0,},
	[5] = {105,"风火弥天",51100,51200,0,17,100,18,100,0,0,0,0,},
	[6] = {106,"功夫之王",51300,50800,0,5,30000,6,1200,21,1200,0,0,},
	[7] = {107,"美人驭兽",51400,51500,0,17,200,18,200,0,0,0,0,},
	[8] = {108,"水火之巅",51600,51700,0,17,250,5,70000,21,3000,0,0,},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
	[105] = 5,
	[106] = 6,
	[107] = 7,
	[107] = 8,

}

local __key_map = {
  id = 1,
  name = 2,
  pet_1 = 3,
  pet_2 = 4,
  pet_3 = 5,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_pet_compose_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function pet_compose_info.getLength()
    return #pet_compose_info._data
end



function pet_compose_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_pet_compose_info
function pet_compose_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = pet_compose_info._data[index]}, m)
    
end

---
--@return @class record_pet_compose_info
function pet_compose_info.get(id)
    
    return pet_compose_info.indexOf(__index_id[id])
        
end



function pet_compose_info.set(id, key, value)
    local record = pet_compose_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function pet_compose_info.get_index_data()
    return __index_id
end