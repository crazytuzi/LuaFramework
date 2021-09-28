

---@classdef record_scene_effect_info
local record_scene_effect_info = {}
  
record_scene_effect_info.scene_type = 0 --场景类型  
record_scene_effect_info.scene_id = "" --场景文件  
record_scene_effect_info.effect_1 = "" --引用特效1  
record_scene_effect_info.effect_btype_1 = 0 --引用特效1大类型  
record_scene_effect_info.effect_type_1 = 0 --特效1层级  
record_scene_effect_info.effect_position_type_1 = 0 --特效1位置  
record_scene_effect_info.effect_2 = "" --引用特效2  
record_scene_effect_info.effect_btype_2 = 0 --引用特效2大类型  
record_scene_effect_info.effect_type_2 = 0 --特效2层级  
record_scene_effect_info.effect_position_type_2 = 0 --特效2位置  
record_scene_effect_info.effect_3 = "" --引用特效3  
record_scene_effect_info.effect_btype_3 = 0 --引用特效3大类型  
record_scene_effect_info.effect_type_3 = 0 --特效3层级  
record_scene_effect_info.effect_position_type_3 = 0 --特效3位置  
record_scene_effect_info.effect_4 = "" --引用特效4  
record_scene_effect_info.effect_btype_4 = 0 --引用特效4大类型  
record_scene_effect_info.effect_type_4 = 0 --特效4层级  
record_scene_effect_info.effect_position_type_4 = 0 --特效4位置  
record_scene_effect_info.effect_5 = "" --引用特效5  
record_scene_effect_info.effect_btype_5 = 0 --引用特效5大类型  
record_scene_effect_info.effect_type_5 = 0 --特效5层级  
record_scene_effect_info.effect_position_type_5 = 0 --特效5位置


scene_effect_info = {
   _data = {
    [1] = {1,"5","effect_boat",1,1,0,"effect_butterfly",1,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [2] = {2,"pic/dungeonbattle_map/31007.png","effect_zdhy",1,0,0,"0",0,0,0,"Sakura",2,0,3,"Sakura",2,0,6,"0",0,0,0,},
    [3] = {1,"3","effect_fieldscene",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [4] = {1,"4","effect_waterfield",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [5] = {1,"6","effect_city",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [6] = {2,"pic/dungeonbattle_map/31008.png","effect_csgc",1,1,0,"effect_csgc_sunshine",1,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [7] = {1,"8","rain",2,0,2,"effect_shuiy",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [8] = {2,"pic/dungeonbattle_map/31010.png","effect_shangu",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [9] = {2,"pic/dungeonbattle_map/31012.png","effect_chenglou",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [10] = {2,"pic/dungeonbattle_map/4.png","effect_light_gt",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [11] = {2,"pic/dungeonbattle_map/31003.png","effect_fire_cz",1,1,0,"firefly",2,0,8,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [12] = {2,"pic/dungeonbattle_map/31011.png","effect_bird_hb",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [13] = {1,"7","effect_bird_hg",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [14] = {2,"pic/dungeonbattle_map/31013.png","effect_sunshine_gs",1,0,0,"effect_cloud_gs",1,1,0,"leaf",2,0,3,"leaf2",2,0,3,"0",0,0,0,},
    [15] = {2,"pic/dungeonbattle_map/31001.png","effect_flag_hs",1,1,0,"spark",2,0,8,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [16] = {1,"11","effect_cq",1,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [17] = {1,"1","effect_yxt",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [18] = {1,"12","effect_mq",1,2,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [19] = {1,"13","effect_wc",1,0,0,"leaf",2,0,3,"leaf2",2,0,3,"leaf",2,0,6,"leaf2",2,0,6,},
    [20] = {1,"9","effect_csgc",1,1,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [21] = {2,"pic/dungeonbattle_map/31000.png","spark",2,0,8,"spark",2,0,5,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    [22] = {1,"10","effect_cmw",1,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,"0",0,0,0,},
    }
}



local __index_scene_type_scene_id = {
    ["1_1"] = 17,
    ["1_10"] = 22,
    ["1_11"] = 16,
    ["1_12"] = 18,
    ["1_13"] = 19,
    ["1_3"] = 3,
    ["1_4"] = 4,
    ["1_5"] = 1,
    ["1_6"] = 5,
    ["1_7"] = 13,
    ["1_8"] = 7,
    ["1_9"] = 20,
    ["2_pic/dungeonbattle_map/31000.png"] = 21,
    ["2_pic/dungeonbattle_map/31001.png"] = 15,
    ["2_pic/dungeonbattle_map/31003.png"] = 11,
    ["2_pic/dungeonbattle_map/31007.png"] = 2,
    ["2_pic/dungeonbattle_map/31008.png"] = 6,
    ["2_pic/dungeonbattle_map/31010.png"] = 8,
    ["2_pic/dungeonbattle_map/31011.png"] = 12,
    ["2_pic/dungeonbattle_map/31012.png"] = 9,
    ["2_pic/dungeonbattle_map/31013.png"] = 14,
    ["2_pic/dungeonbattle_map/4.png"] = 10,

}

local __key_map = {
  scene_type = 1,
  scene_id = 2,
  effect_1 = 3,
  effect_btype_1 = 4,
  effect_type_1 = 5,
  effect_position_type_1 = 6,
  effect_2 = 7,
  effect_btype_2 = 8,
  effect_type_2 = 9,
  effect_position_type_2 = 10,
  effect_3 = 11,
  effect_btype_3 = 12,
  effect_type_3 = 13,
  effect_position_type_3 = 14,
  effect_4 = 15,
  effect_btype_4 = 16,
  effect_type_4 = 17,
  effect_position_type_4 = 18,
  effect_5 = 19,
  effect_btype_5 = 20,
  effect_type_5 = 21,
  effect_position_type_5 = 22,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_scene_effect_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function scene_effect_info.getLength()
    return #scene_effect_info._data
end



function scene_effect_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_scene_effect_info
function scene_effect_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = scene_effect_info._data[index]}, m)
    
end

---
--@return @class record_scene_effect_info
function scene_effect_info.get(scene_type,scene_id)
    
    local k = scene_type .. '_' .. scene_id
    return scene_effect_info.indexOf(__index_scene_type_scene_id[k])
        
end



function scene_effect_info.set(scene_type,scene_id, key, value)
    local record = scene_effect_info.get(scene_type,scene_id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function scene_effect_info.get_index_data()
    return __index_scene_type_scene_id
end