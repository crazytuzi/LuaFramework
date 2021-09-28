

---@classdef record_corps_dungeon_tips_info
local record_corps_dungeon_tips_info = {}
  
record_corps_dungeon_tips_info.id = 0 --克制类型id  
record_corps_dungeon_tips_info.icon = 0 --克制icon  
record_corps_dungeon_tips_info.group = 0 --阵营  
record_corps_dungeon_tips_info.tips = "" --克制描述


corps_dungeon_tips_info = {
   _data = {
    [1] = {1,1,1,"上阵魏将，可额外造成50%伤害",},
    [2] = {2,2,2,"上阵蜀将，可额外造成50%伤害",},
    [3] = {3,3,3,"上阵吴将，可额外造成50%伤害",},
    [4] = {4,4,4,"上阵群雄，可额外造成50%伤害",},
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
  icon = 2,
  group = 3,
  tips = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_dungeon_tips_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_dungeon_tips_info.getLength()
    return #corps_dungeon_tips_info._data
end



function corps_dungeon_tips_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_dungeon_tips_info
function corps_dungeon_tips_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_dungeon_tips_info._data[index]}, m)
    
end

---
--@return @class record_corps_dungeon_tips_info
function corps_dungeon_tips_info.get(id)
    
    return corps_dungeon_tips_info.indexOf(__index_id[id])
        
end



function corps_dungeon_tips_info.set(id, key, value)
    local record = corps_dungeon_tips_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_dungeon_tips_info.get_index_data()
    return __index_id
end