

---@classdef record_vip_daily_boon
local record_vip_daily_boon = {}
  
record_vip_daily_boon.id = 0 --礼包ID  
record_vip_daily_boon.vip_level = 0 --可购买VIP等级  
record_vip_daily_boon.res_id_1 = 0 --销售NPC  
record_vip_daily_boon.talk_1 = "" --NPC对话  
record_vip_daily_boon.res_id_2 = 0 --推广NPC  
record_vip_daily_boon.talk_2 = "" --NPC对话  
record_vip_daily_boon.item_1_type = 0 --礼包物品1类型  
record_vip_daily_boon.item_1_value = 0 --礼包物品1类型值  
record_vip_daily_boon.item_1_size = 0 --礼包物品1数量  
record_vip_daily_boon.item_2_type = 0 --礼包物品2类型  
record_vip_daily_boon.item_2_value = 0 --礼包物品2类型值  
record_vip_daily_boon.item_2_size = 0 --礼包物品2数量  
record_vip_daily_boon.item_3_type = 0 --礼包物品3类型  
record_vip_daily_boon.item_3_value = 0 --礼包物品3类型值  
record_vip_daily_boon.item_3_size = 0 --礼包物品3数量  
record_vip_daily_boon.item_4_type = 0 --礼包物品4类型  
record_vip_daily_boon.item_4_value = 0 --礼包物品4类型值  
record_vip_daily_boon.item_4_size = 0 --礼包物品4数量  
record_vip_daily_boon.item_5_type = 0 --礼包物品5类型  
record_vip_daily_boon.item_5_value = 0 --礼包物品5类型值  
record_vip_daily_boon.item_5_size = 0 --礼包物品5数量


vip_daily_boon = {
   _data = {
    [1] = {1,0,13013,"不充钱也能嗨，别忘了每天来领VIP福利哦！",12032,"只要一个鸡腿的钱，V0福利就可以升级到V1啦！",1,0,90000,0,0,0,0,0,0,0,0,0,0,0,0,},
    [2] = {2,1,12032,"我每天都在这里发V1福利，感觉自己萌萌哒~",11043,"少年，要不要包月呀~包月就可以升级到V2啦！",1,0,180000,0,0,0,0,0,0,0,0,0,0,0,0,},
    [3] = {3,2,11043,"少年三国志，每天都可以拿福利，好开心！",11033,"我听少年们说，V3是最具性价比的~双月卡包邮~",1,0,270000,0,0,0,0,0,0,0,0,0,0,0,0,},
    [4] = {4,3,11033,"少年每天都来领VIP福利，我才不会失业哦~",12014,"少年，V4福利所有V3福利内容，还有多多哦",1,0,360000,3,14,15,0,0,0,0,0,0,0,0,0,},
    [5] = {5,4,12014,"少年每天都来领VIP福利，我才不会失业哦~",14008,"少年，V5福利所有V4福利内容，还有多多哦",1,0,450000,3,14,30,0,0,0,0,0,0,0,0,0,},
    [6] = {6,5,14008,"少年每天都来领VIP福利，我才不会失业哦~",12015,"少年，V6福利所有V5福利内容，还有多多哦",1,0,540000,3,14,45,3,13,15,0,0,0,0,0,0,},
    [7] = {7,6,12015,"少年每天都来领VIP福利，我才不会失业哦~",12002,"少年，V7福利所有V6福利内容，还有多多哦",1,0,630000,3,14,60,3,13,30,3,18,60,0,0,0,},
    [8] = {8,7,12002,"少年每天都来领VIP福利，我才不会失业哦~",13014,"少年，V8福利所有V7福利内容，还有多多哦",1,0,720000,3,14,75,3,13,45,3,18,90,0,0,0,},
    [9] = {9,8,13014,"少年每天都来领VIP福利，我才不会失业哦~",110112,"少年，V9福利所有V8福利内容，还有多多哦",1,0,810000,3,14,90,3,13,60,3,18,120,3,60,150,},
    [10] = {10,9,110112,"少年每天都来领VIP福利，我才不会失业哦~",13001,"少年，V10福利所有V9福利内容，还有多多哦",1,0,900000,3,14,105,3,13,75,3,18,150,3,60,300,},
    [11] = {11,10,13001,"少年每天都来领VIP福利，我才不会失业哦~",12009,"少年，V11福利所有V10福利内容，还有多多哦",1,0,990000,3,14,120,3,13,90,3,18,180,3,60,450,},
    [12] = {12,11,12009,"少年每天都来领VIP福利，我才不会失业哦~",14007,"少年，V12福利所有V11福利内容，还有多多哦",1,0,1080000,3,14,135,3,13,105,3,18,210,3,60,600,},
    [13] = {13,12,14007,"少年每天都来领VIP福利，我才不会失业哦~",0,"0",1,0,1200000,3,14,150,3,13,130,3,18,240,3,60,900,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
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
  vip_level = 2,
  res_id_1 = 3,
  talk_1 = 4,
  res_id_2 = 5,
  talk_2 = 6,
  item_1_type = 7,
  item_1_value = 8,
  item_1_size = 9,
  item_2_type = 10,
  item_2_value = 11,
  item_2_size = 12,
  item_3_type = 13,
  item_3_value = 14,
  item_3_size = 15,
  item_4_type = 16,
  item_4_value = 17,
  item_4_size = 18,
  item_5_type = 19,
  item_5_value = 20,
  item_5_size = 21,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_vip_daily_boon")
        
        
        return t._raw[__key_map[k]]
    end
}


function vip_daily_boon.getLength()
    return #vip_daily_boon._data
end



function vip_daily_boon.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_vip_daily_boon
function vip_daily_boon.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = vip_daily_boon._data[index]}, m)
    
end

---
--@return @class record_vip_daily_boon
function vip_daily_boon.get(id)
    
    return vip_daily_boon.indexOf(__index_id[id])
        
end



function vip_daily_boon.set(id, key, value)
    local record = vip_daily_boon.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function vip_daily_boon.get_index_data()
    return __index_id
end