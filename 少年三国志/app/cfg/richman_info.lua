

---@classdef record_richman_info
local record_richman_info = {}
  
record_richman_info.id = 0 --ID  
record_richman_info.square_type = 0 --格子类型  
record_richman_info.info = "" --格子信息  
record_richman_info.icon = "" --格子icon  
record_richman_info.effect = 0 --道具格特效  
record_richman_info.icon_effect = 0 --icon特效  
record_richman_info.type = 0 --奖励类型  
record_richman_info.value = 0 --奖励类型值  
record_richman_info.min_size = 0 --最小奖励数量  
record_richman_info.max_size = 0 --最大奖励数量  
record_richman_info.shop_type = 0 --商店类型


richman_info = {
   _data = {
    [1] = {1,1,"天降奇财！可获取#num1#~#num2#的银两！","ui/dafuweng/qizi_yinliang.png",0,0,1,0,5000,15000,0,},
    [2] = {2,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [3] = {3,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_gaojidaoju.png",3,1,3,3,1,1,0,},
    [4] = {4,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,15,1,1,0,},
    [5] = {5,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,13,1,1,0,},
    [6] = {6,5,"踩中后随机移动到附近的格子","ui/dafuweng/qizi_yidong.png",0,0,0,0,0,0,0,},
    [7] = {7,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,60,1,3,0,},
    [8] = {8,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [9] = {9,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,18,1,1,0,},
    [10] = {10,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,14,1,1,0,},
    [11] = {11,4,"红色时代主题商店，贩售红色武将精华和红色装备精华！","ui/dafuweng/qizi_daoju.png",0,0,0,0,0,0,1,},
    [12] = {12,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,23,0,5,15,0,},
    [13] = {13,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,11,1,3,0,},
    [14] = {14,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [15] = {15,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,4,1,1,0,},
    [16] = {16,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,9,1,3,0,},
    [17] = {17,4,"极限养成主题商店，贩售高级精炼石、宝物精炼石和刷新令！","ui/dafuweng/qizi_daoju.png",0,0,0,0,0,0,2,},
    [18] = {18,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,13,1,1,0,},
    [19] = {19,1,"天降奇财！可获取#num1#~#num2#的银两！","ui/dafuweng/qizi_yinliang.png",0,0,1,0,5000,15000,0,},
    [20] = {20,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [21] = {21,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_gaojidaoju.png",3,1,3,3,1,1,0,},
    [22] = {22,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,15,1,1,0,},
    [23] = {23,4,"神将觉醒主题商店，贩售觉醒丹、神魂和刷新令！","ui/dafuweng/qizi_daoju.png",0,0,0,0,0,0,3,},
    [24] = {24,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,4,1,1,0,},
    [25] = {25,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,60,1,3,0,},
    [26] = {26,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [27] = {27,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,18,1,3,0,},
    [28] = {28,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,14,1,1,0,},
    [29] = {29,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,23,0,5,15,0,},
    [30] = {30,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,11,1,3,0,},
    [31] = {31,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,87,1,1,0,},
    [32] = {32,3,"偶遇神将发生神秘事件！会随机获得各种奖励，甚至有红将礼包哦！","ui/dafuweng/qizi_shijian.png",0,0,0,0,0,0,0,},
    [33] = {33,2,"道具奖励！踩中该格可获取#num1#~#num2#个#name#！","ui/dafuweng/qizi_tong.png",1,0,3,9,1,3,0,},
    [34] = {34,5,"踩中后随机移动到附近的格子","ui/dafuweng/qizi_yidong.png",0,0,0,0,0,0,0,},
    [35] = {35,2,"道具奖励！踩中该格可获取#num1#个#name#！","ui/dafuweng/qizi_shenmishangdian.png",2,1,3,13,1,1,0,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  square_type = 2,
  info = 3,
  icon = 4,
  effect = 5,
  icon_effect = 6,
  type = 7,
  value = 8,
  min_size = 9,
  max_size = 10,
  shop_type = 11,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_richman_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function richman_info.getLength()
    return #richman_info._data
end



function richman_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_richman_info
function richman_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = richman_info._data[index]}, m)
    
end

---
--@return @class record_richman_info
function richman_info.get(id)
    
    return richman_info.indexOf(__index_id[id])
        
end



function richman_info.set(id, key, value)
    local record = richman_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function richman_info.get_index_data()
    return __index_id
end