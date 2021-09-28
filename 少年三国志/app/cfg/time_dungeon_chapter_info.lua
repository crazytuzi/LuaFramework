

---@classdef record_time_dungeon_chapter_info
local record_time_dungeon_chapter_info = {}
  
record_time_dungeon_chapter_info.id = 0 --id  
record_time_dungeon_chapter_info.name = "" --副本名称  
record_time_dungeon_chapter_info.image = 0 --建筑形象  
record_time_dungeon_chapter_info.directions = "" --副本描述  
record_time_dungeon_chapter_info.item_type = 0 --奖励类型  
record_time_dungeon_chapter_info.item_value = 0 --物品ID


time_dungeon_chapter_info = {
   _data = {
    [1] = {1,"单刀赴会",1,"鲁肃邀关羽赴宴，商讨荆州归属，关羽持单刀赴会，最终压退东吴诸将，保住荆州。",1,0,},
    [2] = {2,"七擒孟获",2,"孟获率众叛乱，诸葛亮出兵平叛，将他七捉七放，最终使他真正服输，不再为敌。",3,14,},
    [3] = {3,"六出祁山",3,"蜀汉丞相诸葛亮为平定中原光复汉室，六次出兵北伐曹魏，却因为种种原因尽皆失败。",3,18,},
    [4] = {4,"空城计",4,"司马懿率兵进攻西城，诸葛亮无兵御敌却大开城门，并在城楼弹琴，最终吓退多疑的司马懿。",3,12,},
    [5] = {5,"合肥之战",1,"孙权率军进攻合肥，久攻不下之时。合肥别驾蒋济设计，让孙权以为有大军来救，于是退兵。",3,45,},
    [6] = {6,"渭水之战",2,"曹操率兵进攻凉州，马超、韩遂等起兵抵抗， 双方在关中大战，最终曹操以计取胜，压制关中。",3,60,},
    [7] = {7,"夷陵之战",3,"刘备出兵攻打东吴，孙权派陆逊迎敌，陆逊设计阻挡刘备大军攻势，并最终大败蜀汉军。",23,0,},
    [8] = {8,"姜维北伐",4,"姜维成为蜀汉大将军后，进行了十一次北伐，虽接连获胜，却未能攻破曹魏，反而损耗了蜀汉国力。",13,0,},
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

}

local __key_map = {
  id = 1,
  name = 2,
  image = 3,
  directions = 4,
  item_type = 5,
  item_value = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_time_dungeon_chapter_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function time_dungeon_chapter_info.getLength()
    return #time_dungeon_chapter_info._data
end



function time_dungeon_chapter_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_time_dungeon_chapter_info
function time_dungeon_chapter_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = time_dungeon_chapter_info._data[index]}, m)
    
end

---
--@return @class record_time_dungeon_chapter_info
function time_dungeon_chapter_info.get(id)
    
    return time_dungeon_chapter_info.indexOf(__index_id[id])
        
end



function time_dungeon_chapter_info.set(id, key, value)
    local record = time_dungeon_chapter_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function time_dungeon_chapter_info.get_index_data()
    return __index_id
end