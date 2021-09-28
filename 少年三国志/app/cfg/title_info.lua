

---@classdef record_title_info
local record_title_info = {}
  
record_title_info.id = 0 --称号ID  
record_title_info.name = "" --称号名称  
record_title_info.picture = "" --水印图标ID  
record_title_info.picture2 = "" --聊天图标  
record_title_info.type1 = 0 --赛局栏目  
record_title_info.quality = 0 -- 品质  
record_title_info.type2 = 0 --种类  
record_title_info.directions = "" --称号描述  
record_title_info.directions2 = "" --称号描述详细  
record_title_info.effect_time = 0 --称号时效  
record_title_info.strength_type_1 = 0 --增加属性1类型  
record_title_info.strength_value_1 = 0 --增加属性1类型值  
record_title_info.strength_type_2 = 0 --增加属性2类型  
record_title_info.strength_value_2 = 0 --增加属性2类型值


title_info = {
   _data = {
    [1] = {101,"血腥杀戮","icon/title/1.png","icon/title/101.png",2,3,2,"高级勋章兑换称号","在演武商店中用演武币兑换的高级称号",604800,5,6000,21,300,},
    [2] = {102,"长枪如龙","icon/title/2.png","icon/title/102.png",2,2,2,"中级勋章兑换称号","在演武商店中用演武币兑换的中级称号",604800,5,2000,21,100,},
    [3] = {201,"无敌将军","icon/title/3.png","icon/title/103.png",1,6,2,"积分赛第1名","威武霸气！本赛季积分排名第一",604800,5,20000,6,1650,},
    [4] = {202,"万夫莫敌","icon/title/4.png","icon/title/104.png",1,5,2,"积分赛第2名","本赛季积分排名第二",604800,5,16000,6,1320,},
    [5] = {203,"征战四方","icon/title/5.png","icon/title/105.png",1,5,2,"积分赛第3名","本赛季积分排名第三",604800,5,14000,6,1150,},
    [6] = {204,"斩将狂人","icon/title/6.png","icon/title/106.png",1,4,2,"积分赛4-10名","本赛季积分排名前十",604800,5,11000,6,900,},
    [7] = {205,"百战名将","icon/title/7.png","icon/title/107.png",1,4,2,"积分赛11-25名","本赛季积分排名前二十五",604800,5,10000,6,820,},
    [8] = {206,"铁血战将","icon/title/8.png","icon/title/108.png",1,3,2,"积分赛26-50名","本赛季积分排名前五十",604800,5,9000,6,740,},
    [9] = {207,"沙场老兵","icon/title/9.png","icon/title/109.png",1,3,2,"积分赛51-100名","本赛季积分排名前一百",604800,5,8000,6,660,},
    [10] = {301,"三国至尊","icon/title/10.png","icon/title/110.png",3,7,2,"争霸赛第1名","称霸三国！跨服演武争霸赛第一名",604800,5,50000,17,600,},
    [11] = {302,"上将无双","icon/title/11.png","icon/title/111.png",3,6,2,"争霸赛第2名","本赛季争霸赛排名第二",604800,5,45000,17,500,},
    [12] = {303,"常胜将军","icon/title/12.png","icon/title/112.png",3,5,2,"争霸赛第3名","本赛季争霸赛排名第三",604800,5,40000,17,400,},
    [13] = {304,"一骑当千","icon/title/13.png","icon/title/113.png",3,4,2,"争霸赛4-10名","本赛季争霸赛排名前十",604800,5,35000,17,300,},
    [14] = {305,"骁勇虎卫","icon/title/14.png","icon/title/114.png",3,3,2,"争霸赛11-25名","本赛季争霸赛排名前二十五",604800,5,30000,17,200,},
    [15] = {306,"浑身是胆","icon/title/15.png","icon/title/115.png",3,2,2,"争霸赛26-50名","本赛季争霸赛排名前五十",604800,5,25000,17,100,},
    [16] = {307,"血气方刚","icon/title/16.png","icon/title/116.png",3,2,2,"争霸赛51-100名","本赛季争霸赛排名前一百",604800,5,20000,17,80,},
    [17] = {404,"至尊战神","icon/title/11.png","icon/title/123.png",5,6,2,"至尊战场4强","决战赤壁至尊战场，4强赛晋级奖励",2592000,26,350,20,1,},
    [18] = {403,"高级战神","icon/title/11.png","icon/title/122.png",5,6,2,"高级战场4强","决战赤壁高级战场，4强赛晋级奖励",2592000,26,250,20,1,},
    [19] = {402,"中级战神","icon/title/11.png","icon/title/121.png",5,6,2,"中级战场4强","决战赤壁中级战场，4强赛晋级奖励",2592000,26,150,20,1,},
    [20] = {401,"初级战神","icon/title/11.png","icon/title/120.png",5,6,2,"初级战场4强","决战赤壁初级战场，4强赛晋级奖励",2592000,26,50,20,1,},
    [21] = {408,"至尊霸主","icon/title/10.png","icon/title/127.png",5,7,2,"至尊战场冠军","决战赤壁至尊战场，决赛冠军奖励",2592000,26,400,20,1,},
    [22] = {407,"高级霸主","icon/title/10.png","icon/title/126.png",5,7,2,"高级战场冠军","决战赤壁高级战场，决赛冠军奖励",2592000,26,300,20,1,},
    [23] = {406,"中级霸主","icon/title/10.png","icon/title/125.png",5,7,2,"中级战场冠军","决战赤壁中级战场，决赛冠军奖励",2592000,26,200,20,1,},
    [24] = {405,"初级霸主","icon/title/10.png","icon/title/124.png",5,7,2,"初级战场冠军","决战赤壁初级战场，决赛冠军奖励",2592000,26,100,20,1,},
    [25] = {1001,"粽叶飘香","icon/title/16.png","icon/title/117.png",4,2,2,"端午节活动","端午节活动的绝版称号",2592000,11,300,20,1,},
    [26] = {1002,"金风玉露","icon/title/13.png","icon/title/119.png",4,5,2,"七夕节活动","七夕节活动的绝版称号",2592000,24,300,20,1,},
    [27] = {1003,"登高远眺","icon/title/12.png","icon/title/128.png",4,6,2,"重阳节活动","重阳节活动的绝版称号",2592000,12,300,20,1,},
    [28] = {1004,"恩德如山","icon/title/16.png","icon/title/129.png",4,2,2,"感恩节活动","感恩节活动的绝版称号",604800,26,200,20,1,},
    }
}



local __index_id = {
    [1001] = 25,
    [1002] = 26,
    [1003] = 27,
    [1004] = 28,
    [101] = 1,
    [102] = 2,
    [201] = 3,
    [202] = 4,
    [203] = 5,
    [204] = 6,
    [205] = 7,
    [206] = 8,
    [207] = 9,
    [301] = 10,
    [302] = 11,
    [303] = 12,
    [304] = 13,
    [305] = 14,
    [306] = 15,
    [307] = 16,
    [401] = 20,
    [402] = 19,
    [403] = 18,
    [404] = 17,
    [405] = 24,
    [406] = 23,
    [407] = 22,
    [408] = 21,

}

local __key_map = {
  id = 1,
  name = 2,
  picture = 3,
  picture2 = 4,
  type1 = 5,
  quality = 6,
  type2 = 7,
  directions = 8,
  directions2 = 9,
  effect_time = 10,
  strength_type_1 = 11,
  strength_value_1 = 12,
  strength_type_2 = 13,
  strength_value_2 = 14,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_title_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function title_info.getLength()
    return #title_info._data
end



function title_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_title_info
function title_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = title_info._data[index]}, m)
    
end

---
--@return @class record_title_info
function title_info.get(id)
    
    return title_info.indexOf(__index_id[id])
        
end



function title_info.set(id, key, value)
    local record = title_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function title_info.get_index_data()
    return __index_id
end