
local storage = require("app.storage.storage")

--可配置活动
--[[
    接收可配置活动信息 
    1,推进
    2，限时
    3，限时贩售&物品兑换
    4，累冲/单冲
]]
local ActivityDataCustom = class("ActivityDataCustom")
function ActivityDataCustom:ctor( ... )
    self.customList = {}
    self.isInit = false
    self:initData()
    self._data = nil

    -- 记录玩家有没有查看过新活动
    self._actStateStorgePath = "activityState.data"

end

function ActivityDataCustom:initData()
    self.itemList = {}   --打折道具列表
    
    --self.secret = {activte = false,discount=0,end_time=0,start_time=0,vip=0}     -- 神秘商店打折
    self.secretList = {}
    
    --self.drop = {activte = false,discount=0,end_time=0,start_time=0,vip=0}  --抽卡打折
    self.dropList = {}
    
    --self.dungeon ={activte = false,end_time=0,start_time=0,vip=0} --主线副本掉落翻倍
    self.dungeonList = {}

    --self.storyDungeon = {activte = false,end_time=0,start_time=0,vip=0} --名将副本掉落翻倍
    self.storyDungeonList = {}
    
    --self.dailyDungeon = {activte = false,end_time=0,start_time=0,vip=0} --日常副本掉落翻倍
    self.dailyDungeonList = {}

    --self.arena = {activte = false,end_time=0,start_time=0,vip=0} --竞技场声望翻倍
    self.arenaList = {}

    --self.wush = {activte = false,end_time=0,start_time=0,vip=0} --三国无双威名翻倍
    self.wushList = {}

    --self.gongxun={activte = false,end_time=0,start_time=0,vip=0} --叛军功勋翻倍
    self.gongxunList = {}

    --self.zhenaoling={activte = false,end_time=0,start_time=0,vip=0} --叛军征讨令减半
    self.zhentaolingList = {}

    self.heroSoulList = {}
end
--[[
    data有可能为空,每次进活动都调用此方法
]]
function ActivityDataCustom:initActivity(data)
    self.customList = {}  --以act_id 做key
    if data == nil then
        self.isInit = false
        return
    end
    --初始化过
    self._date = G_ServerTime:getDate()
    self.isInit = true
    if rawget(data,"activity") ~= nil then
        for _,v in ipairs(data.activity) do

            local item = {act=v}
            if item["questList"] == nil then
                item.questList = {}
            end
            if rawget(data,"quest") then
                for _,u in ipairs(data.quest) do
                    if u.act_id == v.act_id then
                        item.questList[u.quest_id] = u
                    end
                end
            end
            if item["currentQuestList"] == nil then
                item.currentQuestList = {}
            end
            if rawget(data,"user_quest") then
                for _,u in ipairs(data.user_quest) do
                    if u.act_id == v.act_id then
                        item.currentQuestList[u.quest_id] = u
                    end 
                end
            end
            self.customList[v.act_id] = item
        end
    end
    --初始化福利类活动信息
    self:_initWelfareAct()
end


--是否为新活动
function ActivityDataCustom:isNewActivity( act_id )
    if not act_id or type(act_id) ~= "number" then return false end

    -- 读取本地数据
    local _szStorgePath = self._actStateStorgePath

    local tLocalData = storage.load(storage.rolePath(_szStorgePath))

    if tLocalData == nil then
        tLocalData = {}
        tLocalData[tostring(act_id)] = 0
        storage.save(storage.rolePath(_szStorgePath), tLocalData)
        return true
    end

    --dump(tLocalData)

    if not tLocalData[tostring(act_id)] then
        tLocalData[tostring(act_id)] = 0
        storage.save(storage.rolePath(_szStorgePath), tLocalData)
        return true
    else
        return tLocalData[tostring(act_id)] == 0
    end
end

--设置活动状态
function ActivityDataCustom:setActivityEntered( act_id )

    if not act_id or type(act_id) ~= "number" then return false end

    -- 读取本地数据
    local _szStorgePath = self._actStateStorgePath
    local tLocalData = storage.load(storage.rolePath(_szStorgePath))

    if tLocalData == nil then
        tLocalData = {}
    end

    --避免多次写数据
    if not tLocalData[tostring(act_id)] or tLocalData[tostring(act_id)] == 0 then 
        tLocalData[tostring(act_id)] = act_id
        storage.save(storage.rolePath(_szStorgePath), tLocalData)
        return true
    end

    --print("------------set act id="..tostring(act_id))

    return false

end


function ActivityDataCustom:_updateWelfareAct(act,u)
    if not act or not u then
        return
    end
    if u.quest_type == 209 then   --神将抽将折扣
        --必须在这个范围
        if u.param1 <= 1000 and u.param1> 0 then
            local drop = {}
            drop.activte = true
            drop.discount = u.param1
            drop.end_time = act["end_time"]
            drop.start_time = act.start_time
            drop.vip_level = rawget(act, "vip_level") and act.vip_level or 0           
            drop.max_vip = rawget(act, "max_vip") and act.max_vip or 0
            drop.level = rawget(act, "level") and act.level or 0
            drop.max_level = rawget(act, "max_level") and act.max_level or 0

            self.dropList[act.act_id] = drop
        end
    elseif u.quest_type == 210 then --神将商店折扣
        --必须在这个范围
        if u.param1 <= 1000 and u.param1> 0 then
            local secret = {}
            secret.activte = true
            secret.discount = u.param1
            secret.end_time = act["end_time"]
            secret.vip_level = rawget(act, "vip_level") and act.vip_level or 0  
            secret.max_vip = rawget(act, "max_vip") and act.max_vip or 0
            secret.level = rawget(act, "level") and act.level or 0
            secret.max_level = rawget(act, "max_level") and act.max_level or 0

            secret.start_time = act.start_time
            self.secretList[act.act_id] = secret
        end
    elseif u.quest_type == 211 then  --商店指定物品折扣
        --必须在这个范围
        if u.param1 <= 1000 and u.param1> 0 then
            local t = {}
            t.id = u.param2
            t.act_id = act.act_id
            t.discount = u.param1
            t.end_time = act["end_time"]
            t.start_time = act.start_time
            t.vip_level = rawget(act, "vip_level") and act.vip_level or 0 
            t.max_vip = rawget(act, "max_vip") and act.max_vip or 0
            t.level = rawget(act, "level") and act.level and 0
            t.max_level = rawget(act, "max_level") and act.max_level or 0

            local key = act.act_id .. "_" .. u.param2   -- 已经act_id和item_id拼接为key
            self.itemList[key] = t 
        end
    elseif u.quest_type == 201 then  --主线副本碎片掉落翻倍
        local dungeon = {}
        dungeon.activte = true
        dungeon.end_time= act["end_time"]
        dungeon.start_time= act["start_time"]
        dungeon.vip_level = rawget(act, "vip_level") and act.vip_level or 0  
        dungeon.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        dungeon.level = rawget(act, "level") and act.level or 0
        dungeon.max_level = rawget(act, "max_level") and act.max_level or 0

        self.dungeonList[act.act_id] = dungeon
    elseif u.quest_type == 202 then  --名将副本将魂掉落翻倍
        local storyDungeon = {}
        storyDungeon.activte = true
        storyDungeon.end_time= act["end_time"]
        storyDungeon.start_time= act["start_time"]
        storyDungeon.vip_level = rawget(act, "vip_level") and act.vip_level or 0   
        storyDungeon.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        storyDungeon.level = rawget(act, "level") and act.level or 0
        storyDungeon.max_level = rawget(act, "max_level") and act.max_level or 0

        self.storyDungeonList[act.act_id] = storyDungeon
    elseif u.quest_type == 203 then  --日常副本资源翻倍
        local dailyDungeon = {}
        dailyDungeon.activte = true
        dailyDungeon.end_time= act["end_time"]
        dailyDungeon.start_time= act["start_time"]
        dailyDungeon.vip_level = rawget(act, "vip_level") and act.vip_level or 0       
        dailyDungeon.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        dailyDungeon.level = rawget(act, "level") and act.level or 0
        dailyDungeon.max_level = rawget(act, "max_level") and act.max_level or 0

        self.dailyDungeonList[act.act_id] = dailyDungeon
    elseif u.quest_type == 204 then  --竞技场声望翻倍
        local arena = {}
        arena.activte = true
        arena.end_time= act["end_time"]
        arena.start_time= act["start_time"]
        arena.vip_level = rawget(act, "vip_level") and act.vip_level or 0     
        arena.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        arena.level = rawget(act, "level") and act.level or 0
        arena.max_level = rawget(act, "max_level") and act.max_level or 0

        self.arenaList[act.act_id] = arena
    elseif u.quest_type == 205 then  --三国无双战斗威名翻倍
        local wush = {}
        wush.activte = true
        wush.end_time= act["end_time"]
        wush.start_time= act["start_time"]
        wush.vip_level = rawget(act, "vip_level") and act.vip_level or 0        
        wush.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        wush.level = rawget(act, "level") and act.level or 0
        wush.max_level = rawget(act, "max_level") and act.max_level or 0

        self.wushList[act.act_id] = wush 

    elseif u.quest_type == 206 then  --领地征讨物品掉落翻倍

    elseif u.quest_type == 207 then  --功勋翻倍
        local gongxun = {}
        gongxun.activte = true
        gongxun.end_time= act["end_time"]
        gongxun.start_time= act["start_time"]
        gongxun.vip_level = rawget(act, "vip_level") and act.vip_level or 0
        gongxun.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        gongxun.level = rawget(act, "level") and act.level or 0
        gongxun.max_level = rawget(act, "max_level") and act.max_level or 0

        self.gongxunList[act.act_id] = gongxun

    elseif u.quest_type == 208 then  --征讨令减半
        local zhentaoling = {}
        zhentaoling.activte = true
        zhentaoling.end_time= act["end_time"]
        zhentaoling.start_time= act["start_time"]
        zhentaoling.vip_level = rawget(act, "vip_level") and act.vip_level or 0

        zhentaoling.max_vip = rawget(act, "max_vip") and act.max_vip or 0
        zhentaoling.level = rawget(act, "level") and act.level or 0
        zhentaoling.max_level = rawget(act, "max_level") and act.max_level or 0

        self.zhentaolingList[act.act_id] = zhentaoling
    elseif u.quest_type == 213 then -- 将灵商店折扣
        --必须在这个范围
        if u.param1 <= 1000 and u.param1> 0 then
            local heroSoul = {}
            heroSoul.activte = true
            heroSoul.discount = u.param1
            heroSoul.end_time = act["end_time"]
            heroSoul.vip_level = rawget(act, "vip_level") and act.vip_level or 0  
            heroSoul.max_vip = rawget(act, "max_vip") and act.max_vip or 0
            heroSoul.level = rawget(act, "level") and act.level or 0
            heroSoul.max_level = rawget(act, "max_level") and act.max_level or 0

            heroSoul.start_time = act.start_time
            self.heroSoulList[act.act_id] = heroSoul
        end
    end
end

--福利类型
function ActivityDataCustom:_initWelfareAct()
    self:initData()
    if not self.customList or table.nums(self.customList) == 0 then
        return
    end

    for i,item in pairs(self.customList) do
        local act = item.act
        for _,u in pairs(item.questList) do
            --限时类活动
           self:_updateWelfareAct(act,u)
        end
    end

   
end

--是否已经初始化了
function ActivityDataCustom:hasInit()
    return self.isInit
end

--判断指定道具是否打折
function ActivityDataCustom:isItemDiscountById(id)
    if not id or type(id) ~= "number" then
        return false
    end

    local t =G_ServerTime:getTime()  
    for key,item in pairs(self.itemList) do
        if key == string.format("%s_%s",item.act_id,id) then
            if t > item.start_time and t < item.end_time then
                if item.vip ~= 0 then
                    if G_Me.userData.vip >= item.vip then
                        return true,item.discount
                    end
                else
                    return true,item.discount
                end
            end
        end
    end
    return false
end
--[[
    self.secret = {activte = false,discount=0,end_time=0,start_time=0}     -- 神秘商店打折
    self.drop = {activte = false,discount=0,end_time=0,start_time=0}  --抽卡打折
]]
--判断神秘商店是否有打折
function ActivityDataCustom:isSecretDiscount()
    local isDiscount,item = self:_checkByData(self.secretList)
    if isDiscount then
        return isDiscount,item.discount
    end
    return false
end

--判断将灵商店是否有打折
function ActivityDataCustom:isHeroSoulShopDiscount()
    local isDiscount,item = self:_checkByData(self.heroSoulList)
    if isDiscount then
        return isDiscount,item.discount
    end
    return false
end


--判断神将抽卡是否有打折
function ActivityDataCustom:isGodlyDropDiscount()
    local isDiscount,item = self:_checkByData(self.dropList)
    if isDiscount then
        return isDiscount,item.discount
    end
    return false
end


--检查单个福利类活动是否有效
function ActivityDataCustom:_checkByAct(act)
    if not act or not act.activte then
        return false
    end
    local t =G_ServerTime:getTime()  --判断是否在活动时间内
    if act.start_time==0 or act.end_time == 0 or t < act.start_time or t > act.end_time then
        return false
    end

    return self:checkActUnlock(act)
end

--返回act的活动
function ActivityDataCustom:_checkByData(data)
    if not data or table.nums(data) == 0 then
        return false
    end
    for _,v in pairs(data) do
        if self:_checkByAct(v) then
            return true,v
        end
    end
    return false
end

--判断三国无双是否有活动
function ActivityDataCustom:isWushActive()
    local isActive,_ = self:_checkByData(self.wushList)
    return isActive
end

--判领地征讨物品掉落数量翻倍 
function ActivityDataCustom:isCityActive()
    return false
end

--日常副本资源掉落翻倍    
function ActivityDataCustom:isDailyDungeonActive()
    local isActive,_ = self:_checkByData(self.dailyDungeonList)
    return isActive
end

--主线副本碎片掉落数量翻倍  
function ActivityDataCustom:isDungeonActive()
    local isActive,_ = self:_checkByData(self.dungeonList)
    return isActive
end

--名将副本将魂掉落数量翻倍  
function ActivityDataCustom:isStoryDungeonActive()
    local isActive,_ = self:_checkByData(self.storyDungeonList)
    return isActive
end

--功勋翻倍
function ActivityDataCustom:isGongxunActive()
    local isActive,_ = self:_checkByData(self.gongxunList)
    return isActive
end

--征讨令减半
function ActivityDataCustom:isZhengtaoActive()
    local isActive,_ = self:_checkByData(self.zhentaolingList)
    return isActive
end

--声望翻倍
function ActivityDataCustom:isShengwangActive()
    local isActive,_ = self:_checkByData(self.arenaList)
    return isActive
end



--检查活动是否过期
function ActivityDataCustom:checkActActivate(act_id)
    if not act_id or type(act_id) ~= "number" then
        return false
    end
    local data = self.customList[act_id]
    if not data or (not data.act) then
        return false
    end
    
    local act = data.act
    local leftSecond = G_ServerTime:getLeftSeconds(act["end_time"])
    if leftSecond > 0 and act.start_time <= G_ServerTime:getTime() then
        return true
    else
        return false
    end

end

--检查是否有折扣
function ActivityDataCustom:isZhekou(quest)
    if not quest then return false end
    if quest.param1 <= 0 or quest.param1 >= 100 then return false end
    local zhekou = quest.param1
    if quest.param1%10 == 0 then
        zhekou = quest.param1/10
    end
    return true,zhekou
end

--检查是否可领奖
function ActivityDataCustom:checkActAward(act_id)
    if not act_id or type(act_id) ~= "number" then
        return false
    end
    local data = self.customList[act_id]
    if not data or (not data.act) then
        return false
    end
    
    local act = data.act
    local end_time = act["end_time"] > act["award_time"] and act["end_time"] or act["award_time"]
    -- 以领奖结束时间或活动结束时间为准
    local leftSecond = G_ServerTime:getLeftSeconds(end_time)
    if leftSecond > 0 and act.start_time <= G_ServerTime:getTime() then
        return true
    else
        return false
    end
end

--检查等级和VIP等级是否达到解锁条件
function ActivityDataCustom:checkActUnlock(act)
   
    if not act then
        return false
    else
        return true
    end

--[[ 客户端取消限制

    --兼容老协议
    local level_min = rawget(act,"level") and act.level or 0
    local level_max = rawget(act,"max_level") and act.max_level or 0

    local vip_level_min = rawget(act,"vip_level") and act.vip_level or 0
    local vip_level_max = rawget(act,"max_vip") and act.max_vip or 0

    local level_limit = false
    --用户等级达到与否
    if (level_max == 0 and G_Me.userData.level >= level_min) or 
        (level_max > 0 and G_Me.userData.level >= level_min and G_Me.userData.level <= level_max) then
        level_limit = true
    end

    local vip_level_limit = false
    --用户VIP等级达到与否
    if (vip_level_max == 0 and G_Me.userData.vip >= vip_level_min) or 
        (vip_level_max > 0 and G_Me.userData.vip >= vip_level_min and G_Me.userData.vip <= vip_level_max) then
        vip_level_limit = true
    end

    return  level_limit and vip_level_limit
]]

end

--[[
    检查活动是否显示红点
]]
function ActivityDataCustom:showTipsByActId(act_id)
    if not act_id or type(act_id) ~= "number" then
        return false
    end
    local item = self.customList[act_id]
    if not item then
        return false
    end
    local act = item.act

    --福利类不需要红点
    if not act or act.act_type == 2 then
        return false
    end

    if not self:checkActActivate(act.act_id) then
        if act.award_time == 0 then
            return false
        else
            if not self:checkActAward(act.act_id) then
                return false
            end
        end
    end

    --检查是否有奖励可领取
    if not item.questList or table.nums(item.questList) == 0 then
        return false
    end

    for i,quest in pairs(item.questList) do

        curQuest = G_Me.activityData.custom:getCurQuestByQuest(quest)

        if curQuest then
            --先判断是否领取
            if quest.award_limit == 0 or curQuest.award_times < quest.award_limit then
                --兑换类
                if act.act_type == 3 then
                    if self:checkExchangeCondition(quest) then
                        return true
                    end
                else
                    local value02 = quest.param1 or 0   --完成所需次数
                    local value01 = curQuest.progress or 0   --当前进度
                    --[[
                        [6] = {106,"活动期间获取#name##num#个",},
                    ]]
                    if quest.quest_type == 106 then
                        value02 = quest.param3

                        -- {303,"本日单笔充值满#num#元",},
                        -- {306,"本日单笔充值满#num1#~#num2#元",},
                    elseif quest.quest_type == 303 or quest.quest_type == 306 then
                        --特殊处理
                        value02 = curQuest.award_times
                        -- value01 = curQuest.award_times or 0   --当前进度
                    end

                    if quest.quest_type == 303 or quest.quest_type == 306 then
                        if value01 > value02 then
                            return true
                        end
                    else
                        if value01 >= value02 then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function ActivityDataCustom:getActivityByActId(act_id)
    if act_id and type(act_id) == "number" then
        local item = self.customList[act_id]
        if item and rawget(item,"act") then
            return item.act
        else 
            return nil
        end
    else
        return nil
    end
end

--[[
    接收可配置活动信息 
    1,推进
    2，限时
    3，限时贩售&物品兑换
    4，累冲/单冲
]]
function ActivityDataCustom:getQuestByActId(act_id)
    if act_id and type(act_id) == "number" then
        local item = self.customList[act_id]
        if not item then
            return {}
        end
        if rawget(item,"questList") then
            local list = {}
            for i,v in pairs(item.questList) do
                --服务器推过来的数据有可能是错误的
                if item.act.act_type == 1 then
                    if v.param1 ~= 0 and v.award_type1 ~= 0 then   --完成所需次数不为0
                        list[#list+1] = v 
                    end
                elseif item.act.act_type == 2 then
                    list[#list+1] = v 
                elseif item.act.act_type == 3 then  
                    if v.consume_type1 ~= 0 and v.award_type1 ~= 0 then   --消耗和奖励的都不能为0
                        list[#list+1] = v
                    end
                elseif item.act.act_type == 4 then
                    if v.quest_type == 306 and v.param2 ~= 0 then   --单笔区间充值
                        if v.param1 <= v.param2 then
                            list[#list+1] = v     
                        end
                    else
                        if v.param1 ~= 0 and v.award_type1 ~= 0 then   --完成所需金额不能为0
                            list[#list+1] = v 
                        end
                    end
                end 
            end
            --排序
            --未领取
            if #list > 0 then
                local sortFunc = function(a,b)
                --[[
                    local value02 = quest.param1 or 0   --完成所需次数
                    local value01 = curQuest.progress or 0   --当前进度
                ]]
                    -- print("----item.act_type = " .. item.act_type)

                    local typeA = a.quest_type
                    local typeB = b.quest_type

                    local curQuestA = item.currentQuestList[a.quest_id]
                    local curQuestB = item.currentQuestList[b.quest_id]
                    if not item or not curQuestA or not curQuestB then
                    elseif item.act.act_type == 1 or item.act.act_type == 4 then --领取类或充值类
                        --判断是否 已领取
                        local hasGotA = (a.award_limit ~= 0 and curQuestA.award_times >= a.award_limit) and 1 or 0
                        local hasGotB = (b.award_limit ~= 0 and curQuestB.award_times >= b.award_limit) and 1 or 0
                        if hasGotA ~= hasGotB then
                            return hasGotA < hasGotB
                        end
                        local valueA = a.param1 or 0   --完成所需次数
                        local progressA = curQuestA.progress or 0   --当前进度
                        local valueB = b.param1 or 0   --完成所需次数
                        local progressB = curQuestB.progress or 0   --当前进度
                        --这是个搜集类型
                        if a.quest_type == 106 then
                            valueA = a.param3 or 0
                        end
                        if b.quest_type == 106 then
                            valueB = b.param3 or 0
                        end

                        local isFinishA = nil
                        if a.quest_type == 303 then--{303,"本日单笔充值满#num#元",},
                            valueA = curQuestA.award_times
                            progressA = curQuestA.progress
                            isFinishA = progressA > valueA and 1 or 0
                        else
                            isFinishA = progressA >= valueA and 1 or 0
                        end

                        local isFinishB = nil
                        if b.quest_type == 303 then
                            valueB = curQuestB.award_times
                            progressB = curQuestB.progress
                            isFinishB = progressB > valueB and 1 or 0
                        else
                            isFinishB = progressB >= valueB and 1 or 0
                        end

                        if isFinishA ~= isFinishB then
                            return isFinishA > isFinishB
                        end

                        if typeA == typeB then --类型相同的时候，所需次数小的排前面
                            if valueA ~= valueB then
                                return valueA < valueB
                            elseif progressB ~= progressA then
                                return progressA < progressB
                            end
                        end
                    elseif item.act.act_type == 2 then  --福利类

                    elseif item.act.act_type == 3 then  --兑换类
                        -- 全服剩余优先
                        -- local is_server_limitA = a.server_limit > 0 and 1 or 0
                        -- local is_server_limitB = b.server_limit > 0 and 1 or 0
                        -- if  is_server_limitA ~= is_server_limitB then
                        --     return is_server_limitA > is_server_limitB
                        -- end

                        --先判断剩余兑换次数是否为0 
                        local valueA = a.award_limit or 0   --完成所需次数
                        local progressA = curQuestA.award_times or 0   --当前进度
                        local leftA = valueA - progressA
                        if a.server_limit > 0 then
                            if a.award_limit <= curQuestA.award_times or a.server_limit <= a.server_times then
                                leftA = 0
                            end
                        end

                        leftA = leftA <= 0 and 0 or leftA
                        local valueB = b.award_limit or 0   --完成所需次数
                        local progressB = curQuestB.award_times or 0   --当前进度
                        local leftB = valueB - progressB 
                        leftB = leftB <= 0 and 0 or leftB
                        if b.server_limit > 0 then
                            if b.award_limit <= curQuestB.award_times or b.server_limit <= b.server_times then
                                leftB = 0
                            end
                        end
                        local A = leftA > 0 and 1 or 0
                        local B = leftB > 0 and 1 or 0
                        if A ~= B then
                            --剩余次数
                            return A > B
                        end

                        --判断条件是否达成
                        local isFinishA = self:checkExchangeCondition(a) and 1 or 0
                        local isFinishB = self:checkExchangeCondition(b) and 1 or 0
                        if isFinishB ~= isFinishA then
                            return isFinishA > isFinishB
                        end

                    else

                    end

                    if typeA ~= typeB then
                        return typeA < typeB
                    end
                    return a.quest_id < b.quest_id
                end
                table.sort(list,sortFunc)
            end
            return list
        else 
            return {}
        end
    else
        return {}
    end
end

function ActivityDataCustom:getQuestLengthByActId(act_id)
    local item = self.customList[act_id]
    if not item or (not rawget(item,"questList")) then
        return 0
    end
    return table.nums(item.questList)
end

function ActivityDataCustom:getCurQuestByQuest(quest)
    if not quest then
        return nil
    end

    local item = self.customList[quest.act_id]
    if not item then
        return nil
    end
    return item.currentQuestList[quest.quest_id]
end

--检查是否满足条件兑换
function ActivityDataCustom:checkExchangeCondition(quest)
    if not quest then
        return false
    end

    --检查次数
    if quest.server_limit > 0 then
        local value02 = quest.server_limit or 0   --限制次数
        local value01 = quest.server_times or 0   --当前进度
        if value02 ~= 0 and value01 >= value02 then
            return false
        end
    else
        local curQuest = G_Me.activityData.custom:getCurQuestByQuest(quest)
        if not curQuest then
            return false
        end
        value02 = quest.award_limit or 0   --限制次数
        value01 = curQuest.award_times or 0   --当前进度
        if value02 ~= 0 and value01 >= value02 then
            return false
        end
    end

    local comsumeList = {}
    for i=1,4 do
        local _type = quest["consume_type" .. i]
        if _type > 0 then
            local value = quest["consume_value" .. i]
            local size = quest["consume_size" .. i]
            local good = G_Goods.convert(_type,value,size)
            if good then
                table.insert(comsumeList,good)
            end
        end
    end
    if #comsumeList == 0 then
        --数据异常
        return false
    end
    for _,good in ipairs(comsumeList) do
        --检查good是否拥有了
        if not G_Goods.checkOwnGood(good) then
            return false
        end
    end
    return true
end

--[[
    检查兑换物类型数量
    用于批量购买
]]
function ActivityDataCustom:getConsumeTypeNum(quest)
    if not quest then
        return 0
    end
    local num = 0
    for i=1,4 do
        local _type = quest["consume_type" .. i]
        if _type > 0 then
            local value = quest["consume_value" .. i]
            local size = quest["consume_size" .. i]
            local good = G_Goods.convert(_type,value,size)
            if good then
                num = num + 1
            end
        end
    end
    return num
end

function ActivityDataCustom:getUserQuestByActId(act_id)
    if act_id and type(act_id) == "number" then
        local item = self.customList[act_id]
        if rawget(item,"currentQuestList") then
            local list = {}
            for i,v in pairs(item.currentQuestList) do
                list[#list+1] = v 
            end
            return list
        else 
            return {}
        end
    else
        return {}
    end
end


--[[
    检查活动是否处于预览期
]]
function ActivityDataCustom:checkPreviewByActId(act_id)
    --暂时 return false
    if not act_id or type(act_id) ~= "number" then
        return false
    end
    local act = self:getActivityByActId(act_id)
    if not act then
        return false
    end 
    if not act.preview_time or act.preview_time == 0 then
        return false
    end
    local time = G_ServerTime:getTime()
    if time >= act.start_time or time < act.preview_time then
        return false
    end
    return true
end


--刷新活动
function  ActivityDataCustom:updateActivity(data)
    -- body
    if not data then
        return
    end
    if rawget(data,"activity") and #data.activity > 0 then
        for i,v in ipairs(data.activity) do
            local item = self.customList[v.act_id]
            if item then
                item.act = v
                item.questList = {}
            else
                --新增的活动
                item = {}
                item.act = v
                item.questList = {}
                item.currentQuestList={}
                if rawget(data,"quest") then
                    for _,u in ipairs(data.quest) do
                        if item["questList"] == nil then
                            item.questList = {}
                        end
                        if u.act_id == v.act_id then
                            item.questList[u.quest_id] = u
                            --默认创建一个用户进度
                            item.currentQuestList[u.quest_id] = self:_initUserQuest(v.act_id,u.quest_id)
                        end
                    end
                end
                self.customList[v.act_id] = item
            end
        end
    end

    if rawget(data,"quest") and #data.quest > 0 then
        for i,v in ipairs(data.quest) do
            local item = self.customList[v.act_id]
            if item then
                if v.act_id == item.act.act_id then
                    item.questList[v.quest_id] = v
                    if item.currentQuestList and item.currentQuestList[v.quest_id] == nil then
                        local curQuest = self:_initUserQuest(v.act_id,v.quest_id)
                        item.currentQuestList[v.quest_id]= curQuest
                    end
                end
            end
        end
    end
    if rawget(data,"delete_activity") and #data.delete_activity>0 then
        for i,act_id in ipairs(data.delete_activity) do
            if self.customList[act_id] ~= nil then
                self.customList[act_id] = nil
            end
        end
    end
    --福利类活动重新初始化
    self:_initWelfareAct()
end

function ActivityDataCustom:updateSeriesActivity(decodeBuffer)
    if not rawget(decodeBuffer,"series_id") or decodeBuffer.series_id == 0 then
        return
    end
    --先删除系列活动
    local series_id = decodeBuffer.series_id
    local actList = {}
    for act_id,item in pairs(self.customList) do
        if item.act.series_id == decodeBuffer.series_id then
            -- actList[#actList+1] = act_id
            self.customList[act_id] = nil   --删除
        end
    end
    self:updateActivity(decodeBuffer)
    self:updateActivityQuest(decodeBuffer)
end

--更新任务时，服务器不发送用户进度过来，只能自己初始化
function ActivityDataCustom:_initUserQuest(act_id,quest_id)
    local curQuest = {
        act_id = act_id,
        quest_id = quest_id,
        time= 0,
        progress=0,
        award_time=0,
        award_times=0,
    }
    return curQuest
end

--刷新进度
function ActivityDataCustom:updateActivityQuest(data)
    if not data then
        return
    end
    if rawget(data,"user_quest") then
        for i,v in ipairs(data.user_quest) do
            local act = self.customList[v.act_id]
            if act then
                act.currentQuestList[v.quest_id] = v
            end
        end
    end
end

function ActivityDataCustom:getAwardById(act_id,quest_id,award_id,num)
    local award = {}
    if act_id == nil or quest_id == nil or type(act_id) ~= "number" or type(quest_id) ~= "number" then
        return award
    end
    local act = self.customList[act_id]
    if not act then
        return award
    end
    local quest = act.questList[quest_id]
    if not quest then
        return award
    end

    --判断下是否多选
    if quest.award_select == 0 then
        award_id = nil
    end

    --判断是否是多选一
    if award_id ~= nil and type(award_id) == "number" then
        local _type = quest["award_type"..(award_id+1)]
        if _type > 0 then
            local good = G_Goods.convert(_type,quest["award_value"..(award_id+1)],quest["award_size"..(award_id+1)])
            if good then
                award[#award+1] = good
            end
        end
    else
        if not num or type(num) ~= "number" then
            num = 1
        end
        for i=1,4 do
            local _type = quest["award_type"..i]
            if _type > 0 then
                --乘以倍数
                local good = G_Goods.convert(_type,quest["award_value"..i],quest["award_size"..i]*num)
                if good then
                    award[#award+1] = good
                end
            end
        end
    end
    return award
end

--true表示满了
function ActivityDataCustom:checkBagFullByQuest(quest)
    if not quest then
        return true
    end
    local CheckFunc = require("app.scenes.common.CheckFunc")
    for i=1,4 do
        if quest["award_type"..i] > 0 then
            if CheckFunc.checkDiffByType(quest["award_type"..i],quest["award_size"..i]) then
                return true
            end
        end
    end
    return false
end

function ActivityDataCustom:isActivate()
    return false
end

--第二天的时候刷新
function ActivityDataCustom:refreshNextDay()
    if self._date == G_ServerTime:getDate() then
        return
    end
    self._date = G_ServerTime:getDate()
    if not self.customList or table.nums(self.customList) == 0 then
        return
    end
    for i,item in pairs(self.customList) do
        if item.currentQuestList and table.nums(item.currentQuestList) > 0 then
            for i,curQuest in pairs(item.currentQuestList) do
                --[[
                    每日相关的刷新进度
                    [10] = {301,"本日充值#num#元",},
                    [13] = {304,"本日消耗元宝#num#",},
                    }
                ]]

                local quest = item.questList[curQuest.quest_id]
                if quest then
                    if quest.quest_type == 301 or quest.quest_type == 304 then
                        curQuest.progress = 0  
                        curQuest.award_times = 0  
                    end 
                end
            end
        end
    end
end

function ActivityDataCustom:getStartDateByActId(act_id)
    local act = self:getActivityByActId(act_id)
    if not act then
        return nil
    end
    local startDate = G_ServerTime:getDateFormat(act.start_time)
    return startDate
end

return ActivityDataCustom