

---@classdef record_task_info
local record_task_info = {}
  
record_task_info.id = 0 --任务id  
record_task_info.comment = "" --任务描述  
record_task_info.background = "" --活动背景


task_info = {
   _data = {
    [1] = {101,"主线副本战斗胜利#num#次","ui/background/back_zrbt.png",},
    [2] = {102,"名将副本战斗胜利#num#次","ui/background/back_zrbt.png",},
    [3] = {103,"三国无双挑战#num#次","ui/background/xingkong.png",},
    [4] = {104,"竞技场胜利#num#次","ui/background/bg_wujiang_info.png",},
    [5] = {105,"夺宝#num#次","ui/background/duobao.png",},
    [6] = {106,"活动期间获取#name##num#个","ui/background/zhuangbeifenjie_bg1.png",},
    [7] = {107,"击毙叛军#num#名","ui/background/panjun.png",},
    [8] = {108,"攻打叛军#num#次","ui/background/panjun.png",},
    [9] = {109,"累计登陆#num#天","ui/background/bg_common.png",},
    [10] = {110,"精英副本战斗胜利#num#次","ui/background/back_zrbt.png",},
    [11] = {111,"幸运轮盘总积分达到#num#","ui/background/bg_common.png",},
    [12] = {112,"神将招募#num#次","ui/background/bg_common.png",},
    [13] = {113,"巡游探宝总积分达到#num#","ui/background/bg_common.png",},
    [14] = {114,"奇门八卦总积分达到#num#","ui/background/bg_common.png",},
    [15] = {115,"累计点将#num#次","ui/background/bg_common.png",},
    [16] = {201,"","ui/background/back_zrbt.png",},
    [17] = {202,"","ui/background/back_zrbt.png",},
    [18] = {203,"","ui/background/back_mainbt.png",},
    [19] = {204,"","ui/background/bg_wujiang_info.png",},
    [20] = {205,"","ui/background/xingkong.png",},
    [21] = {206,"","ui/background/bg_taofa.png",},
    [22] = {207,"","ui/background/panjun.png",},
    [23] = {208,"","ui/background/panjun.png",},
    [24] = {209,"","ui/background/bg_common.png",},
    [25] = {210,"","ui/background/bg_common.png",},
    [26] = {211,"","ui/background/bg_common.png",},
    [27] = {212,"","ui/background/bg_common.png",},
    [28] = {301,"本日充值#num#元","ui/background/bg_common.png",},
    [29] = {302,"活动期间总共充值#num#元","ui/background/bg_common.png",},
    [30] = {303,"单笔充值#num#元","ui/background/bg_common.png",},
    [31] = {304,"本日消耗元宝#num#","ui/background/bg_common.png",},
    [32] = {305,"活动期间总共消耗#num#元宝","ui/background/bg_common.png",},
    [33] = {306,"单笔充值#num1#～#num2#元","ui/background/bg_common.png",},
    [34] = {401,"","ui/background/bg_common.png",},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [105] = 5,
    [106] = 6,
    [107] = 7,
    [108] = 8,
    [109] = 9,
    [110] = 10,
    [111] = 11,
    [112] = 12,
    [113] = 13,
    [114] = 14,
    [115] = 15,
    [201] = 16,
    [202] = 17,
    [203] = 18,
    [204] = 19,
    [205] = 20,
    [206] = 21,
    [207] = 22,
    [208] = 23,
    [209] = 24,
    [210] = 25,
    [211] = 26,
    [212] = 27,
    [301] = 28,
    [302] = 29,
    [303] = 30,
    [304] = 31,
    [305] = 32,
    [306] = 33,
    [401] = 34,

}

local __key_map = {
  id = 1,
  comment = 2,
  background = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_task_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function task_info.getLength()
    return #task_info._data
end



function task_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_task_info
function task_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = task_info._data[index]}, m)
    
end

---
--@return @class record_task_info
function task_info.get(id)
    
    return task_info.indexOf(__index_id[id])
        
end



function task_info.set(id, key, value)
    local record = task_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function task_info.get_index_data()
    return __index_id
end