

---@classdef record_treasure_fragment_smelt_info
local record_treasure_fragment_smelt_info = {}
  
record_treasure_fragment_smelt_info.id = 0 --id  
record_treasure_fragment_smelt_info.type = 0 --类型  
record_treasure_fragment_smelt_info.fragment_id = 0 --宝物碎片ID  
record_treasure_fragment_smelt_info.smelt_price = 0 --熔炼消耗元宝  
record_treasure_fragment_smelt_info.treasure_quality = 0 --材料宝物品质


treasure_fragment_smelt_info = {
   _data = {
    [1] = {1,1,4011,250,5,},
    [2] = {2,1,4031,250,5,},
    [3] = {3,1,4021,250,5,},
    [4] = {4,1,4041,250,5,},
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
  type = 2,
  fragment_id = 3,
  smelt_price = 4,
  treasure_quality = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_fragment_smelt_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_fragment_smelt_info.getLength()
    return #treasure_fragment_smelt_info._data
end



function treasure_fragment_smelt_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_fragment_smelt_info
function treasure_fragment_smelt_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_fragment_smelt_info._data[index]}, m)
    
end

---
--@return @class record_treasure_fragment_smelt_info
function treasure_fragment_smelt_info.get(id)
    
    return treasure_fragment_smelt_info.indexOf(__index_id[id])
        
end



function treasure_fragment_smelt_info.set(id, key, value)
    local record = treasure_fragment_smelt_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_fragment_smelt_info.get_index_data()
    return __index_id
end