

---@classdef record_vip_discount_store
local record_vip_discount_store = {}
  
record_vip_discount_store.id = 0 --礼包ID  
record_vip_discount_store.vip_level = 0 --可购买VIP等级  
record_vip_discount_store.res_id = 0 --销售NPC  
record_vip_discount_store.original_cost = "" --原价  
record_vip_discount_store.current_cost = "" --现价  
record_vip_discount_store.item_1_type = 0 --礼包物品1类型  
record_vip_discount_store.item_1_value = 0 --礼包物品1类型值  
record_vip_discount_store.item_1_size = 0 --礼包物品1数量  
record_vip_discount_store.item_2_type = 0 --礼包物品2类型  
record_vip_discount_store.item_2_value = 0 --礼包物品2类型值  
record_vip_discount_store.item_2_size = 0 --礼包物品2数量  
record_vip_discount_store.item_3_type = 0 --礼包物品3类型  
record_vip_discount_store.item_3_value = 0 --礼包物品3类型值  
record_vip_discount_store.item_3_size = 0 --礼包物品3数量  
record_vip_discount_store.item_4_type = 0 --礼包物品4类型  
record_vip_discount_store.item_4_value = 0 --礼包物品4类型值  
record_vip_discount_store.item_4_size = 0 --礼包物品4数量  
record_vip_discount_store.talk_1 = "" --NPC对话  
record_vip_discount_store.talk_2 = "" --NPC对话  
record_vip_discount_store.talk_3 = "" --NPC对话


vip_discount_store = {
   _data = {
    [1] = {1,0,13013,500,250,1,0,500000,0,0,0,0,0,0,0,0,0,"钱不是万能的，没有钱是万万不能的~","将军装备还没强化满吧？没有银两可不行哦~","少年，你真懂行，给你点个赞！",},
    [2] = {2,1,12032,250,125,3,5,10,0,0,0,0,0,0,0,0,0,"少年将军，买点体力丹呗~比吃鸡腿还管用~","有了体力，就可以继续扫荡各种副本啦~","谢谢少年，我又有钱买鸡腿啦~",},
    [3] = {3,2,11043,250,125,3,4,10,0,0,0,0,0,0,0,0,0,"精力丹跳楼价了啊，夺宝必备，不买您吃亏~","有了精力丹，夺宝，竞技，巡逻都不成问题啦！","谢谢少年惠顾~玩的开心哟！",},
    [4] = {4,3,11033,600,300,3,22,5,0,0,0,0,0,0,0,0,0,"宝物箱子清仓卖，血本无归，只求出货~","老板娘跑了，老板无心经营，唉~少年你懂的~","少年豪爽，祝您多开几个橙色宝物！",},
    [5] = {5,4,12014,600,300,3,21,5,0,0,0,0,0,0,0,0,0,"人靠衣装，佛靠金装，打怪靠橙装~","橙装箱子大甩卖，绝对跳楼价，一周就一次~","谢谢少年帮衬，祝您多开几个橙装！",},
    [6] = {6,5,14008,1000,500,13,0,1000,0,0,0,0,0,0,0,0,0,"将魂大甩卖，每天刷神将商店，刷将必备~","这些将魂量足价低，全网最划算没有之一哦！","谢谢少年，加油，早日突破+10！",},
    [7] = {7,6,12015,1000,500,3,15,50,0,0,0,0,0,0,0,0,0,"刷新令跳楼价打包卖，足足五折哦！","少年，这可比元宝刷神将商店划算多了~","祝将军每日神将商店，要咩有咩！",},
    [8] = {8,7,12002,1000,500,3,12,100,0,0,0,0,0,0,0,0,0,"我这里有大量的高级精炼石，便宜甩卖啦！","装备不精练，战力可上不去哦~","少年加油，早日炼成神兵利器，所向披靡！",},
    [9] = {9,8,13014,2500,1250,3,18,500,0,0,0,0,0,0,0,0,0,"亏本含泪甩卖宝物精炼石啦！","宝物精炼之后，战力飞升！不信您去试！","卖完啦，收工！谢谢少年！",},
    [10] = {10,9,110112,3000,1500,3,60,1000,0,0,0,0,0,0,0,0,0,"夭寿啦~觉醒丹都打折啦~","这个价格一周就一次，不买您吃亏~","谢谢惠顾，祝少年战力一路高升哦~",},
    [11] = {11,10,13001,2000,1000,3,13,100,0,0,0,0,0,0,0,0,0,"极品精炼石，亏本清仓出售！","装备精炼，战力提升看得见！","谢谢少年，祝战力飞升，早日一统三国！",},
    [12] = {12,11,12009,5000,2500,3,18,1000,0,0,0,0,0,0,0,0,0,"宝物不精练等于废物。","宝物精炼后，战力飞一般的感觉，不信您去试！","少年加油，一统三国这个任务就交个你了！",},
    [13] = {13,12,14007,7500,3750,3,60,2500,0,0,0,0,0,0,0,0,0,"觉醒生一，一生二，二生三，三生万物！","有了这些觉醒丹，腰不酸了，腿不疼了！","谢谢少年，一统三国指日可待！",},
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
  res_id = 3,
  original_cost = 4,
  current_cost = 5,
  item_1_type = 6,
  item_1_value = 7,
  item_1_size = 8,
  item_2_type = 9,
  item_2_value = 10,
  item_2_size = 11,
  item_3_type = 12,
  item_3_value = 13,
  item_3_size = 14,
  item_4_type = 15,
  item_4_value = 16,
  item_4_size = 17,
  talk_1 = 18,
  talk_2 = 19,
  talk_3 = 20,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_vip_discount_store")
        
        
        return t._raw[__key_map[k]]
    end
}


function vip_discount_store.getLength()
    return #vip_discount_store._data
end



function vip_discount_store.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_vip_discount_store
function vip_discount_store.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = vip_discount_store._data[index]}, m)
    
end

---
--@return @class record_vip_discount_store
function vip_discount_store.get(id)
    
    return vip_discount_store.indexOf(__index_id[id])
        
end



function vip_discount_store.set(id, key, value)
    local record = vip_discount_store.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function vip_discount_store.get_index_data()
    return __index_id
end