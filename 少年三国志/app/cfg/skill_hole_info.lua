

---@classdef record_skill_hole_info
local record_skill_hole_info = {}
  
record_skill_hole_info.id = 0 --技能孔编号  
record_skill_hole_info.open_level = 0 --开启等级  
record_skill_hole_info.super_num = 0 --开启必杀


skill_hole_info = {
   _data = {
    [1] = {1,1,0,},
    [2] = {2,1,0,},
    [3] = {3,24,1,},
    [4] = {4,33,2,},
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
  open_level = 2,
  super_num = 3,

}



local m = { 
    __index = function(t, k) 
        assert(__key_map[k], "cannot find " .. k .. " in record_skill_hole_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function skill_hole_info.getLength()
    return #skill_hole_info._data
end

---
--@return @class record_skill_hole_info
function skill_hole_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = skill_hole_info._data[index]}, m)
    
end

---
--@return @class record_skill_hole_info
function skill_hole_info.get(id)
    
    return skill_hole_info.indexOf(__index_id[id])
        
end
