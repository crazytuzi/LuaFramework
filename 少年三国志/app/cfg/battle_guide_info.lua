

---@classdef record_battle_guide_info
local record_battle_guide_info = {}
  
record_battle_guide_info.id = 0 --编号  
record_battle_guide_info.level_min = 0 --等级下限  
record_battle_guide_info.level_max = 0 --等级上限  
record_battle_guide_info.type_1 = 0 --功能类型1  
record_battle_guide_info.res_id_1 = 0 --功能图标id  
record_battle_guide_info.txt_id_1 = "" --txt图片id  
record_battle_guide_info.type_2 = 0 --功能类型2  
record_battle_guide_info.res_id_2 = 0 --功能图标id  
record_battle_guide_info.txt_id_2 = "" --txt图片id  
record_battle_guide_info.type_3 = 0 --功能类型3  
record_battle_guide_info.res_id_3 = 0 --功能图标id  
record_battle_guide_info.txt_id_3 = "" --txt图片id


battle_guide_info = {
   _data = {
    [1] = {1,1,10,4,105,"txt_wujiangshengji",5,105,"txt_wujiangtupo",8,106,"txt_zhuangbeiqianghua",},
    [2] = {2,11,15,4,105,"txt_wujiangshengji",5,105,"txt_wujiangtupo",8,106,"txt_zhuangbeiqianghua",},
    [3] = {3,16,20,4,105,"txt_wujiangshengji",5,105,"txt_wujiangtupo",12,131,"txt_qianghuadashi",},
    [4] = {4,21,25,6,105,"txt_wujiangpeiyang",10,109,"txt_baowuqianghua",12,131,"txt_qianghuadashi",},
    [5] = {5,26,30,6,105,"txt_wujiangpeiyang",5,105,"txt_wujiangtupo",12,131,"txt_qianghuadashi",},
    [6] = {6,31,34,1,121,"txt_zhaoxiannashi",2,105,"txt_yangchengwujiang",3,106,"txt_yangchengzhuangbei",},
    [7] = {7,35,80,1,121,"txt_zhaoxiannashi",2,105,"txt_yangchengwujiang",3,106,"txt_yangchengzhuangbei",},
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
  level_min = 2,
  level_max = 3,
  type_1 = 4,
  res_id_1 = 5,
  txt_id_1 = 6,
  type_2 = 7,
  res_id_2 = 8,
  txt_id_2 = 9,
  type_3 = 10,
  res_id_3 = 11,
  txt_id_3 = 12,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_battle_guide_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function battle_guide_info.getLength()
    return #battle_guide_info._data
end



function battle_guide_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_battle_guide_info
function battle_guide_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = battle_guide_info._data[index]}, m)
    
end

---
--@return @class record_battle_guide_info
function battle_guide_info.get(id)
    
    return battle_guide_info.indexOf(__index_id[id])
        
end



function battle_guide_info.set(id, key, value)
    local record = battle_guide_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function battle_guide_info.get_index_data()
    return __index_id
end