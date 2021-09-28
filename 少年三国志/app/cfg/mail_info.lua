

---@classdef record_mail_info
local record_mail_info = {}
  
record_mail_info.id = 0 --ID  
record_mail_info.type = 0 --邮件类型  
record_mail_info.value = 0 --系统分类  
record_mail_info.title = "" --标题  
record_mail_info.comment = "" --描述  
record_mail_info.tag = 0 --客户端标签


mail_info = {
   _data = {
    [1] = {1,1,1,"夺宝信息","<prefix><text value='您的' color='5258818'/><text value='#treasure_fragment_info|name|id#' color='12922112'/><text value='被玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='无情的抢夺了！' color='5258818'/></prefix>",2,},
    [2] = {2,1,7,"竞技场奖励","<prefix><text value='恭喜你在竞技场中位列' color='5258818'/><text value='#rank#' color='12922112'/><text value='名，鉴于神勇表现，特发以上奖励。' color='5258818'/></prefix>",2,},
    [3] = {3,2,7,"叛军功勋排名奖励","<prefix><text value='您在昨天的围剿叛军活动中表现卓越，功勋排名第' color='5258818'/><text value='#rank#' color='12922112'/><text value='，获得以上奖励。' color='5258818'/></prefix>",1,},
    [4] = {4,2,7,"叛军伤害排名奖励","<prefix><text value='您在昨天的围剿叛军活动中表现卓越，伤害排名第' color='5258818'/><text value='#rank#' color='12922112'/><text value='，获得以上奖励。' color='5258818'/></prefix>",1,},
    [5] = {5,2,7,"三国无双扫荡","这是您在三国无双，由于背包已满，而无法领取的奖励。",1,},
    [6] = {6,1,3,"废弃的配置","废弃的配置",3,},
    [7] = {7,2,7,"系统补偿","#comment#",1,},
    [8] = {8,1,3,"私人邮件","玩家#name#对你说：#comment#",3,},
    [9] = {9,1,3,"系统邮件","#comment#",3,},
    [10] = {10,1,3,"好友信息","<prefix><text value='玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='要与你义结金兰，共闯天下。' color='5258818'/></prefix>",3,},
    [11] = {11,1,3,"好友信息","<prefix><text value='玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='同意了你的好友申请，快和他聊聊天吧。' color='5258818'/></prefix>",3,},
    [12] = {12,2,7,"发现的叛军被击杀","<prefix><text value='您发现的叛军' color='5258818'/><text value='【#rebel_info|name|rebel#】' color='12922112'/><text value='被众将合力击败，最后击杀的是' color='5258818'/><text value='#name#' color='3509514'/><text value='，您获得了发现奖励。' color='5258818'/></prefix>",1,},
    [13] = {13,2,7,"击杀叛军","<prefix><text value='一举成名！叛军' color='5258818'/><text value='【#rebel_info|name|rebel#】' color='12922112'/><text value='被您击杀，您获得了击杀奖励。' color='5258818'/></prefix>",1,},
    [14] = {14,1,6,"充值成功","<prefix><text value='您成功充值' color='5258818'/><text value='#money#元' color='12922112'/><text value='！获得元宝#money2#，额外赠送元宝#money3#，再次感谢您的支持。' color='5258818'/></prefix>",1,},
    [15] = {15,1,6,"充值成功","<prefix><text value='感谢您充值' color='5258818'/><text value='#money#元' color='12922112'/><text value='购买月卡，获得元宝#money2#，之后每天可以在月卡界面领取#money3#元宝，持续' color='5258818'/><text value='#day#天' color='12922112'/><text value='，再次感谢您的支持。' color='5258818'/></prefix>",1,},
    [16] = {16,2,7,"礼品码领奖","礼品码兑换成功，以下为您的奖励！",1,},
    [17] = {17,1,2,"竞技场防守失败","<prefix><text value='玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='在竞技场中轻松击败了你，你的竞技场排名降至' color='5258818'/><text value='#rank#。' color='12922112'/></prefix>",2,},
    [18] = {18,1,2,"竞技场防守成功","<prefix><text value='玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='在竞技场中挑战了你，被你轻松击败。' color='5258818'/></prefix>",2,},
    [19] = {19,1,2,"竞技场防守失败","<prefix><text value='玩家' color='5258818'/><text value='#name#' color='3509514'/><text value='在竞技场中轻松击败了你，由于对方排名比你高，你的排名不变' color='5258818'/></prefix>",2,},
    [20] = {20,1,4,"军团通知","<prefix><text value='你的入团申请已被通过，恭喜你加入' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='大家庭，快向大家打招呼吧！' color='5258818'/></prefix>",3,},
    [21] = {21,1,4,"军团通知","<prefix><text value='你被移除出' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团。' color='5258818'/></prefix>",3,},
    [22] = {22,1,4,"军团解散","<prefix><text value='悲剧啊，你所在的' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团已被军团长解散了。' color='5258818'/></prefix>",3,},
    [23] = {23,1,4,"军团解散","<prefix><text value='你所在' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团，因为7天内，军团等级依旧停留在1级并且成员数不足3人，已被自动解散。' color='5258818'/></prefix>",3,},
    [24] = {24,2,4,"全服最高伤害排名","<prefix><text value='将军威武，在昨日军团副本中攻击力爆表，最高伤害排名第' color='5258818'/><text value='#rank#' color='3509514'/><text value='名 ，获得以上奖励。' color='5258818'/></prefix>",1,},
    [25] = {25,1,4,"军团通知","<prefix><text value='很遗憾，你加入' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='的请求被拒绝。' color='5258818'/></prefix>",3,},
    [26] = {26,1,4,"军团通知","<prefix><text value='恭喜将军，在' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团中，被任命为副军团长，可喜可贺！' color='5258818'/></prefix>",3,},
    [27] = {27,1,4,"军团通知","<prefix><text value='很遗憾，你在' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团中的副军团长职务被罢免了。' color='5258818'/></prefix>",3,},
    [28] = {28,1,4,"军团通知","<prefix><text value='恭喜将军，成为' color='5258818'/><text value='[#corps_name#]' color='3509514'/><text value='军团中万人之上的军团长，可喜可贺！' color='5258818'/></prefix>",3,},
    [29] = {29,1,6,"封测充值返还","<prefix><text value='您在封测期间充值' color='5258818'/><text value='#money#' color='3509514'/><text value='元，已经为您返还了' color='5258818'/><text value='#gold#' color='3509514'/><text value='元宝和' color='5258818'/><text value='#exp#' color='3509514'/><text value='VIP经验。' color='5258818'/></prefix>",1,},
    [30] = {30,2,7,"转盘","这是您在幸运转盘排名，由于背包已满，而无法领取的奖励。",1,},
    [31] = {31,2,4,"群英战","你在群英战中，挑战后离线，以上是由于离线而未获得的军团贡献",1,},
    [32] = {32,2,7,"领奖成功","欢迎进入少年三国志腾讯专服，祝您游戏愉快！",1,},
    [33] = {33,2,7,"巡游","这是您在巡游探宝排名，由于背包已满，而无法领取的奖励。",1,},
    [34] = {34,2,7,"巡游","这是您在巡回奖励，由于背包已满，而无法领取的奖励。",1,},
    [35] = {35,2,7,"积分赛排名奖励","<prefix><text value='你在跨服演武-积分赛' color='5258818'/><text value='（魏国分组）' color='12922112'/><text value='中，获得了第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励' color='5258818'/></prefix>",1,},
    [36] = {36,2,7,"积分赛排名奖励","<prefix><text value='你在跨服演武-积分赛' color='5258818'/><text value='（蜀国分组）' color='12922112'/><text value='中，获得了第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励' color='5258818'/></prefix>",1,},
    [37] = {37,2,7,"积分赛排名奖励","<prefix><text value='你在跨服演武-积分赛' color='5258818'/><text value='（吴国分组）' color='12922112'/><text value='中，获得了第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励' color='5258818'/></prefix>",1,},
    [38] = {38,2,7,"积分赛排名奖励","<prefix><text value='你在跨服演武-积分赛' color='5258818'/><text value='（群雄分组）' color='12922112'/><text value='中，获得了第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励' color='5258818'/></prefix>",1,},
    [39] = {39,2,7,"巡游","这是您在巡游探宝，由于背包已满，而无法领取的奖励。",1,},
    [40] = {40,2,7,"争霸赛排名奖励","<prefix><text value='你在跨服演武-争霸赛中，获得第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [41] = {41,2,7,"叛军BOSS伤害排名奖励","<prefix><text value='你在叛军BOSS（魏国分组）中，最高伤害排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [42] = {42,2,7,"叛军BOSS伤害排名奖励","<prefix><text value='你在叛军BOSS（蜀国分组）中，最高伤害排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [43] = {43,2,7,"叛军BOSS伤害排名奖励","<prefix><text value='你在叛军BOSS（吴国分组）中，最高伤害排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [44] = {44,2,7,"叛军BOSS伤害排名奖励","<prefix><text value='你在叛军BOSS（群雄分组）中，最高伤害排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [45] = {45,2,7,"叛军BOSS荣誉排名奖励","<prefix><text value='你在叛军BOSS（魏国分组）中，累计荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [46] = {46,2,7,"叛军BOSS荣誉排名奖励","<prefix><text value='你在叛军BOSS（蜀国分组）中，累计荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [47] = {47,2,7,"叛军BOSS荣誉排名奖励","<prefix><text value='你在叛军BOSS（吴国分组）中，累计荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [48] = {48,2,7,"叛军BOSS荣誉排名奖励","<prefix><text value='你在叛军BOSS（群雄分组）中，累计荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [49] = {49,2,7,"叛军BOSS幸运一击","<prefix><text value='恭喜你在攻打叛军BOSS活动中，对' color='5258818'/><text value='#rebel_boss_info|name|name#(#level#级)' color='12922112'/><text value='造成幸运一击，获得以上奖励。' color='5258818'/></prefix>",1,},
    [50] = {50,2,7,"击杀叛军BOSS","<prefix><text value='恭喜你终结了BOSS' color='5258818'/><text value='#rebel_boss_info|name|name#(#level#级)' color='12922112'/><text value='，获得了以上击杀奖励。' color='5258818'/></prefix>",1,},
    [51] = {51,1,2,"争霸赛防守失败","<prefix><text value='玩家' color='5258818'/><text value='[#sname#]#name#' color='3509514'/><text value='在争霸赛中轻松击败了你，你的争霸赛排名降至' color='5258818'/><text value='#rank#。' color='12922112'/></prefix>",1,},
    [52] = {52,1,2,"争霸赛防守成功","<prefix><text value='玩家' color='5258818'/><text value='[#sname#]#name#' color='3509514'/><text value='在争霸赛中挑战了你，被你轻松击败。' color='5258818'/></prefix>",1,},
    [53] = {53,1,6,"充值成功","<prefix><text value='您成功充值' color='5258818'/><text value='#money#元' color='12922112'/><text value='！获得元宝#money2#，额外赠送元宝#money3#（包括#money4#元宝充值优惠），再次感谢您的支持。' color='5258818'/></prefix>",1,},
    [54] = {54,2,7,"押注异常","由于争霸赛押注异常，您押注的鲜花已被扣除，却未增加押注注数，这是返还给您的鲜花。",1,},
    [55] = {55,2,7,"叛军BOSS军团排名奖励","<prefix><text value='你所在的军团[#corps_name#]，军团荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [56] = {56,2,7,"奇门八卦奖励","这是您在奇门八卦排行榜中，由于背包已满而无法领取的奖励。",1,},
    [57] = {57,2,7,"决战赤壁晋级奖励","这是您在决战赤壁中的晋级奖励，由于领奖异常，而补发的奖励",1,},
    [58] = {58,2,7,"决战赤壁鲜花投注奖励","这是您在决战赤壁中的鲜花投注奖励，由于领奖异常，而补发的奖励",1,},
    [59] = {59,2,7,"决战赤壁鸡蛋投注奖励","这是您在决战赤壁中的鸡蛋投注奖励，由于领奖异常，而补发的奖励",1,},
    [60] = {60,2,6,"充值成功","<prefix><text value='您成功充值' color='5258818'/><text value='#money#元' color='12922112'/><text value='！首次充值额外获得#item_info|name|id#×#size#，再次感谢您的支持。' color='5258818'/></prefix>",1,},
    [61] = {61,2,7,"虎牢关排行奖励","<prefix><text value='你在激战虎牢关中，累计荣誉排名第' color='5258818'/><text value='#rank#名' color='12922112'/><text value='，以上是你的奖励。' color='5258818'/></prefix>",1,},
    [62] = {62,1,3,"好友改名","<prefix><text value='您的好友' color='5258818'/><text value='#old#' color='3509514'/><text value='已经改名为 ' color='5258818'/><text value='#new#，' color='3509514'/><text value='请继续保持友好关系哦。' color='5258818'/></prefix>",3,},
    [63] = {63,1,4,"军团成员改名","<prefix><text value='军团成员' color='5258818'/><text value='#old#' color='3509514'/><text value='已经改名为 ' color='5258818'/><text value='#new#，' color='3509514'/><text value='请大家知悉。' color='5258818'/></prefix>",3,},
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
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [49] = 49,
    [5] = 5,
    [50] = 50,
    [51] = 51,
    [52] = 52,
    [53] = 53,
    [54] = 54,
    [55] = 55,
    [56] = 56,
    [57] = 57,
    [58] = 58,
    [59] = 59,
    [6] = 6,
    [60] = 60,
    [61] = 61,
    [62] = 62,
    [63] = 63,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  type = 2,
  value = 3,
  title = 4,
  comment = 5,
  tag = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_mail_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function mail_info.getLength()
    return #mail_info._data
end



function mail_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_mail_info
function mail_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = mail_info._data[index]}, m)
    
end

---
--@return @class record_mail_info
function mail_info.get(id)
    
    return mail_info.indexOf(__index_id[id])
        
end



function mail_info.set(id, key, value)
    local record = mail_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function mail_info.get_index_data()
    return __index_id
end