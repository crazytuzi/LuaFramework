

---@classdef record_skilltree_info
local record_skilltree_info = {}
  
record_skilltree_info.id = 0 --编号  
record_skilltree_info.skill_id = 0 --对应技能  
record_skilltree_info.skill_name = "" --技能名称  
record_skilltree_info.learn_point = 0 --学习消耗  
record_skilltree_info.front_skill = "" --前置技能  
record_skilltree_info.initialupgrade_cost = 0 --初始升级消耗   
record_skilltree_info.upgradecost_growth = 0 --升级消耗点数增长  
record_skilltree_info.learn_cost_item = 0 --学习消耗道具  
record_skilltree_info.max_level = 0 --技能满级  
record_skilltree_info.comment = "" --技能说明


skilltree_info = {
   _data = {
    [1] = {1,201,"猛击",15,0,10,5,0,5,"猛击对位的敌人，造成500点伤害",},
    [2] = {2,202,"突刺",30,201,20,8,0,8,"对对位的一列敌人造成400点伤害",},
    [3] = {3,203,"横扫",30,202,20,8,0,8,"对前排敌人造成350点伤害",},
    [4] = {4,204,"乱击",30,203,20,8,20,8,"对随机三明敌人均造成320点伤害",},
    [5] = {5,205,"纵横",30,0,20,8,20,8,"对对位敌人造成400点伤害，并对其相邻敌人造成150点伤害",},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,

}

local __key_map = {
  id = 1,
  skill_id = 2,
  skill_name = 3,
  learn_point = 4,
  front_skill = 5,
  initialupgrade_cost = 6,
  upgradecost_growth = 7,
  learn_cost_item = 8,
  max_level = 9,
  comment = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_skilltree_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function skilltree_info.getLength()
    return #skilltree_info._data
end



function skilltree_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_skilltree_info
function skilltree_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = skilltree_info._data[index]}, m)
    
end

---
--@return @class record_skilltree_info
function skilltree_info.get(id)
    
    return skilltree_info.indexOf(__index_id[id])
        
end



function skilltree_info.set(id, key, value)
    local record = skilltree_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function skilltree_info.get_index_data()
    return __index_id
end