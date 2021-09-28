

---@classdef record_city_npc_info
local record_city_npc_info = {}
  
record_city_npc_info.id = 0 --NPC编号  
record_city_npc_info.name = "" --NPC名称  
record_city_npc_info.res_id = 0 --引用资源ID  
record_city_npc_info.disable_city_id = "" --不出现城池  
record_city_npc_info.text_1 = "" --NPC对话1  
record_city_npc_info.face_1 = 0 --NPC表情1  
record_city_npc_info.text_2 = "" --NPC对话2  
record_city_npc_info.face_2 = 0 --NPC表情2  
record_city_npc_info.text_3 = "" --NPC对话3  
record_city_npc_info.face_3 = 0 --NPC表情3


city_npc_info = {
   _data = {
    [1] = {1,"算命先生",11026,"0","少年，来算上一卦？",49,"生死有命，富贵在天。",25,"卜前程，问吉凶。",48,},
    [2] = {2,"江湖郎中",14044,"0","祖传秘方，包治百病。",48,"华佗夸我医术高~",45,"医不好不收钱~",53,},
    [3] = {3,"店小二",12033,"0","新到美酒，来尝尝吗？",44,"张飞牛肉，本店一绝！",5,"客官住店吗？",8,},
    [4] = {4,"舞娘",11043,"0","这位少年，一起玩吗？",52,"要不要妾身舞一曲~",3,"人家只卖艺，不卖身~",52,},
    [5] = {5,"债主",12045,"0","欠债还钱，天经地义！",49,"愿赌就要服输~",19,"再不还钱，打断腿！",29,},
    [6] = {6,"暴动士兵",12041,"0","0",27,"0",27,"0",27,},
    [7] = {7,"老者1",11029,"0","今天天气真好~",31,"少年，我看你骨骼清奇~",45,"一看你就是体面的人~",5,},
    [8] = {8,"少年1",12017,"0","关羽将军重情义~",30,"关将军是我的偶像~",9,"我在cosplay关将军~",17,},
    [9] = {9,"少年2",11031,"0","我的枪法不输赵云~",8,"少年，来比划比划？",5,"来吧~跟我一决高下",9,},
    [10] = {10,"街头艺人",12021,"1,5","有钱的捧个钱场~",10,"没钱的回去取钱~",5,"看什么看，没钱还看？",19,},
    [11] = {11,"少女1",11045,"1,5","我抚琴故意错音~",52,"就想周郎能看我一眼~",3,"只想嫁公瑾这样的男子",39,},
    [12] = {12,"少女2",12022,"0","看什么看？",19,"没见过美女玩刀吗？",22,"再看小心砍死你哦~",28,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
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
  res_id = 3,
  disable_city_id = 4,
  text_1 = 5,
  face_1 = 6,
  text_2 = 7,
  face_2 = 8,
  text_3 = 9,
  face_3 = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_city_npc_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function city_npc_info.getLength()
    return #city_npc_info._data
end



function city_npc_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_city_npc_info
function city_npc_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = city_npc_info._data[index]}, m)
    
end

---
--@return @class record_city_npc_info
function city_npc_info.get(id)
    
    return city_npc_info.indexOf(__index_id[id])
        
end



function city_npc_info.set(id, key, value)
    local record = city_npc_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function city_npc_info.get_index_data()
    return __index_id
end