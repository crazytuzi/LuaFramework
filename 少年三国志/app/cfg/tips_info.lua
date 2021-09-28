

---@classdef record_tips_info
local record_tips_info = {}
  
record_tips_info.id = 0 --id  
record_tips_info.title = "" --条目标题  
record_tips_info.icon = "" --标题icon  
record_tips_info.premise_id = 0 --前置条目id  
record_tips_info.comment = "" --条目内容  
record_tips_info.stage_id = 0 --界面id


tips_info = {
   _data = {
    [1] = {1001,"如何搭配阵容？","icon/tips_icon/1.png",0,"搭配阵容",0,},
    [2] = {1002,"如何获取武将？","icon/tips_icon/6.png",0,"获取武将",0,},
    [3] = {1003,"如何获取银两？","icon/basic/1.png",0,"获取银两",0,},
    [4] = {1004,"如何获取经验？","icon/basic/4.png",0,"获取经验",0,},
    [5] = {1005,"如何获取装备和宝物？","icon/tips_icon/12.png",0,"获取装备和宝物",0,},
    [6] = {1006,"如何获取经验宝宝？","icon/tips_icon/2.png",0,"获取经验宝宝",0,},
    [7] = {1007,"如何获取突破石？","icon/tips_icon/9.png",0,"获取突破石",0,},
    [8] = {1008,"如何获取培养丹？","icon/tips_icon/10.png",0,"获取培养丹",0,},
    [9] = {1009,"如何获取天命石？","icon/tips_icon/11.png",0,"获取天命石",0,},
    [10] = {1010,"如何获取精炼石？","icon/item/40012.png",0,"获取精炼石",0,},
    [11] = {1011,"如何获取三国志残卷？","icon/item/9999.png",0,"获取三国志残卷",0,},
    [12] = {2001,"配合击","ui/mainpage/icon-zhenrong.png",1001,"有些武将之间有超强合击技能，同时上阵可大大提升我方战力！",14,},
    [13] = {2002,"缘分搭配","ui/mainpage/icon-zhenrong.png",1001,"武将可以靠上阵指定队友激活缘分，从而带来极大的实力提升。",14,},
    [14] = {2003,"技能配合","ui/mainpage/icon-zhenrong.png",1001,"不同武将的打击面不同，要根据敌方阵容灵活组合。",14,},
    [15] = {2011,"招募","ui/mainpage/icon-shangcheng.png",1002,"进行神将招募有概率获得强力的武将，急缺武将就去招募吧。",11,},
    [16] = {2012,"神将商店","ui/mainpage/icon-shenmishangdian.png",1002,"神将商店里会出售强力武将的碎片，并可能出售整张武将。",9,},
    [17] = {2013,"主线副本","ui/mainpage/icon-zhuxian.png",1002,"攻打主线精英关卡可能会掉落武将碎片。",1,},
    [18] = {2021,"主线副本","ui/mainpage/icon-zhuxian.png",1003,"在副本战斗或开启宝箱，均可获得大量银两奖励。",1,},
    [19] = {2022,"日常副本","ui/mainpage/icon-zhuxian.png",1003,"攻打银两副本可以稳定获取大量银两。",2,},
    [20] = {2023,"商城","ui/mainpage/icon-shangcheng.png",1003,"在商城可快速购买大量银两。",4,},
    [21] = {2024,"竞技场","ui/mainpage/icon-wanfa.png",1003,"在竞技场和玩家战斗，可以获得银两奖励。",5,},
    [22] = {2025,"叛军","ui/mainpage/icon-wanfa.png",1003,"叛军功勋达到一定数目时，可以获得丰厚银两奖励。",8,},
    [23] = {2031,"主线副本","ui/mainpage/icon-zhuxian.png",1004,"攻打主线副本关卡是最主要的获取经验的方式。",1,},
    [24] = {2032,"竞技场","ui/mainpage/icon-wanfa.png",1004,"在竞技场和玩家战斗，可获得经验奖励。",5,},
    [25] = {2033,"夺宝","ui/mainpage/icon-wanfa.png",1004,"夺宝战斗胜利后可以获得经验奖励。",6,},
    [26] = {2041,"三国无双","ui/mainpage/icon-wanfa.png",1005,"过关三国无双可获得威名，用威名可在神兵商店兑换高品质碎片。",7,},
    [27] = {2042,"主线副本","ui/mainpage/icon-zhuxian.png",1005,"攻打主线精英关卡可能会掉落装备和装备碎片。",1,},
    [28] = {2043,"夺宝","ui/mainpage/icon-wanfa.png",1005,"在夺宝中可以从其他玩家和npc处抢夺指定的宝物碎片。",6,},
    [29] = {2044,"商城","ui/mainpage/icon-shangcheng.png",1005,"在商城购买橙色宝箱，可以从中开出珍贵的装备或宝物碎片。",4,},
    [30] = {2051,"商城","ui/mainpage/icon-shangcheng.png",1006,"在商城可快速购买大量金龙宝宝。",4,},
    [31] = {2052,"日常副本","ui/mainpage/icon-zhuxian.png",1006,"攻打铜龙宝宝副本可以稳定获取铜龙宝宝。",2,},
    [32] = {2053,"神将商店","ui/mainpage/icon-shenmishangdian.png",1006,"神将商店里可能会出售各类经验宝宝。",9,},
    [33] = {2054,"叛军","ui/mainpage/icon-wanfa.png",1006,"叛军功勋达到一定数目时，可以领取金龙宝宝的奖励。",8,},
    [34] = {2061,"主线副本","ui/mainpage/icon-zhuxian.png",1007,"开启主线副本的星数宝箱，可以获得大量突破石。",1,},
    [35] = {2062,"竞技场","ui/mainpage/icon-wanfa.png",1007,"在竞技场积累声望值后，可以在声望商店购买突破石。",5,},
    [36] = {2063,"日常副本","ui/mainpage/icon-zhuxian.png",1007,"攻打突破石副本可以稳定获取突破石。",2,},
    [37] = {2064,"神将商店","ui/mainpage/icon-shenmishangdian.png",1007,"神将商店里可能会出售突破石。",9,},
    [38] = {2071,"竞技场","ui/mainpage/icon-wanfa.png",1008,"在竞技场积累声望值后，可以在声望商店购买培养丹。",5,},
    [39] = {2072,"日常副本","ui/mainpage/icon-zhuxian.png",1008,"攻打培养丹副本可以稳定获取培养丹。",2,},
    [40] = {2073,"神将商店","ui/mainpage/icon-shenmishangdian.png",1008,"神将商店里可能会出售培养丹。",9,},
    [41] = {2081,"叛军","ui/mainpage/icon-wanfa.png",1009,"攻打叛军会积累功勋，可以在功勋商店购买大量天命石。",8,},
    [42] = {2082,"商城","ui/mainpage/icon-shangcheng.png",1009,"在商城可以快速购买大量天命石。",4,},
    [43] = {2083,"日常副本","ui/mainpage/icon-zhuxian.png",1009,"攻打天命石副本可以稳定获取天命石。",2,},
    [44] = {2084,"神将商店","ui/mainpage/icon-shenmishangdian.png",1009,"神将商店里可能会出售天命石。",9,},
    [45] = {2091,"三国无双","ui/mainpage/icon-wanfa.png",1010,"过关三国无双可获得威名，能在神兵商店购买装备或宝物精炼石。",7,},
    [46] = {2092,"日常副本","ui/mainpage/icon-zhuxian.png",1010,"攻打不同的精炼石副本，可以稳定获取各种精炼石。",2,},
    [47] = {2101,"主线副本","ui/mainpage/icon-zhuxian.png",1011,"每完成一章主线副本，都可以获得三国志残卷。",1,},
    [48] = {2102,"名将副本","ui/mainpage/icon-zhuxian.png",1011,"完成“史诗战役”后，可以获得大量残卷奖励。",3,},
    }
}



local __index_id = {
    [1001] = 1,
    [1002] = 2,
    [1003] = 3,
    [1004] = 4,
    [1005] = 5,
    [1006] = 6,
    [1007] = 7,
    [1008] = 8,
    [1009] = 9,
    [1010] = 10,
    [1011] = 11,
    [2001] = 12,
    [2002] = 13,
    [2003] = 14,
    [2011] = 15,
    [2012] = 16,
    [2013] = 17,
    [2021] = 18,
    [2022] = 19,
    [2023] = 20,
    [2024] = 21,
    [2025] = 22,
    [2031] = 23,
    [2032] = 24,
    [2033] = 25,
    [2041] = 26,
    [2042] = 27,
    [2043] = 28,
    [2044] = 29,
    [2051] = 30,
    [2052] = 31,
    [2053] = 32,
    [2054] = 33,
    [2061] = 34,
    [2062] = 35,
    [2063] = 36,
    [2064] = 37,
    [2071] = 38,
    [2072] = 39,
    [2073] = 40,
    [2081] = 41,
    [2082] = 42,
    [2083] = 43,
    [2084] = 44,
    [2091] = 45,
    [2092] = 46,
    [2101] = 47,
    [2102] = 48,

}

local __key_map = {
  id = 1,
  title = 2,
  icon = 3,
  premise_id = 4,
  comment = 5,
  stage_id = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_tips_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function tips_info.getLength()
    return #tips_info._data
end



function tips_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_tips_info
function tips_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = tips_info._data[index]}, m)
    
end

---
--@return @class record_tips_info
function tips_info.get(id)
    
    return tips_info.indexOf(__index_id[id])
        
end



function tips_info.set(id, key, value)
    local record = tips_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function tips_info.get_index_data()
    return __index_id
end