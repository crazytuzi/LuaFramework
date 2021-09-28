-- 用户vip信息
require("app.cfg.vip_level_info")
require("app.cfg.vip_function_info")
require("app.cfg.dungeon_vip_info")
require("app.cfg.dungeon_daily_info")

local VipData = class("VipData")

local maxLevel = 12

function VipData:ctor()
    self._level  = 0
    self._exp = 0 
    self._dungeons = {}
    self._dungeon_count = 0
    self._dungeonResetCost = 0
    self._data = nil
    self._nextData = nil
    self._nextWholeData = nil
    self.maxLevel = maxLevel

    -- 新版日常副本，今天尚未打通的副本
    self._unbeatenDungeons = {}
end


function VipData:setVipLevel(level)
    self._level = level
end

function VipData:setVip(vip)

    self._date = G_ServerTime:getDate()
    self._level = vip.level
    self._exp = vip.exp
    self._dungeons = vip.vip_dungeons
    self._dungeon_count = vip.vip_dungeon_count
    self._dungeonResetCost = vip.vip_reset_cost
    self:refreshData()
    self:refreshNextData()
    self:refreshNextWholeData()
end

function VipData:getVipResetCost()
    return self._dungeonResetCost
end

function VipData:setVipResetCost(cost)
    self._dungeonResetCost = cost
end

-- @desc 是否重新需要拉数据
function VipData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function VipData:getLeftCount()
    -- return self._dungeon_count

    local unbeatenCount = 0

    -- 取出已经解锁的
    for i = 1, #self._unbeatenDungeons do
        local dungeonInfo = dungeon_daily_info.get(self._unbeatenDungeons[i])
        if dungeonInfo then
            if dungeonInfo.level_1 <= G_Me.userData.level then
                unbeatenCount = unbeatenCount + 1
            end
        end
    end

    return unbeatenCount
end

function VipData:setLeftCount(count)
    self._dungeon_count = count
end

function VipData:getExp()
    return self._exp
end

function VipData:_initData()
    if self._data then 
        return
    end
    self._data = {}
    for i = 1, 100 do 
        self._data[i] = {value=-1,desc=""}
    end
    self:refreshData()
end

function VipData:_initNextData()
    if self._nextData then 
        return
    end
    self._nextData = {}
    for i = 1, 100 do 
        self._nextData[i] = -1
    end
    self:refreshNextData()
    -- dump(self._nextData)
end

function VipData:_initNextWholeData()
    if self._nextWholeData then 
        return
    end
    self._nextWholeData = {}
    for i = 1, 100 do 
        self._nextWholeData[i] = {level=-1,data=-1}
    end
    self:refreshNextWholeData()
    -- dump(self._nextData)
end

function VipData:refreshData()
    -- local fullData = {}
    if self._data == nil then 
        return
    end
    for i = 0, self._level do 
        for j = 1, 50 do 
        local info = vip_level_info.get(i)
            if vip_level_info.hasKey("function_type_"..j) then
                local _type = info["function_type_"..j]
                local _id = info["function_id_"..j]
                if _id > 0 then
                    local vipInfo = vip_function_info.get(_id)
                    local _desc = vipInfo.name
                    local _value = vipInfo.value_1
                    self._data[_type] = {value=_value,desc=_desc}
                end
            end
        end
    end
    -- self._data = fullData
end

function VipData:refreshNextData()
    -- local fullData = {}
    if self._nextData == nil then 
        return
    end
    if self._level == maxLevel then
        for i = 1, 100 do 
            self._nextData[i] = -1
        end
        return 
    end
    for i = self._level+1, maxLevel do 
        for j = 1, 50 do 
            local info = vip_level_info.get(i)
            if vip_level_info.hasKey("function_type_"..j) then
                local _type = info["function_type_"..j]
                local _id = info["function_id_"..j]
                if _id > 0 then
                    local vipInfo = vip_function_info.get(_id)
                    local _desc = vipInfo.name
                    local _value = vipInfo.value_1
                    local beforeValue = self._data[_type].value
                    if beforeValue ~= _value and self._nextData[_type] == -1 then
                        self._nextData[_type] = i
                    end
                end
            end
        end
    end
    -- self._data = fullData
end

function VipData:refreshNextWholeData()
    if self._nextWholeData == nil then 
        return
    end
    if self._level == maxLevel then
        for i = 1, 100 do 
            self._nextWholeData[i] = {level=-1,data=-1}
        end
        return 
    end
    for i = self._level+1, maxLevel do 
        for j = 1, 50 do 
            local info = vip_level_info.get(i)
            if vip_level_info.hasKey("function_type_"..j) then
                local _type = info["function_type_"..j]
                local _id = info["function_id_"..j]
                if _id > 0 then
                    local vipInfo = vip_function_info.get(_id)
                    local _desc = vipInfo.name
                    local _value = vipInfo.value_1
                    local beforeValue = self._data[_type].value
                    if beforeValue ~= _value and self._nextWholeData[_type].level <= self._level then
                        self._nextWholeData[_type] = {level=i,data=_value}
                    end
                end
            end
        end
    end
end

-- vip特权类型
-- 1   战斗跳过无等待时间，类型值=0
-- 2   武将突破消耗银两减少X%，类型值=X，百分比，配100就是免费，配50就是减少50%。
-- 3   洗练X次资格开启，X=5 X=10，只做2种
-- 4   装备强化+2几率X%，类型值=X，百分比，填50就是增加50%。
-- 5   装备强化+3几率X%，类型值=X，百分比，填50就是增加50%。
-- 6   宝物精炼消耗银两减少X%，类型值=X，百分比，配100就是免费，配50就是减少50%。
-- 7   主线副本每日可以重置X次，类型值=X，配1就是每天可以重置1次，配10就是每天可以重置10次。
-- 8   闯关每日可以重置X次，类型值=X，配1就是每天可以重置1次，配10就是每天可以重置10次。
-- 9   攻略剧情副本时，引用一个加生命的passiveskill,类型值=id
-- 10  攻略剧情副本时，引用一个加攻击的passiveskill,类型值=id
-- 11  每日可以购买出征令的次数=X，配置5就是每天可以购买5次，配置100就是每天可以购买100次。
-- 12  神秘商店每日可以刷新X次，配置5就是每天可以刷新5次，配置10就是每天可以刷新10次，每日0点（暂定）重置。
-- 13  开启20连抽功能，20连抽需要抽卡系统做特殊处理，必出一个橙将。类型值=0
-- 14  VIP副本中引用一个加攻击的passiveskill，类型值=id
-- 15  VIP副本中引用一个加生命的passiveskill,类型值=id
-- 16  每日VIP次数增加至X次，类型值=X，绝对值，配置10就是10.

--[[
    desc描述
    value值
]]
function VipData:getData(type)
    self:_initData()
    -- dump(self._data)
    return self._data[type]
end

function VipData:getNextData(type)
    self:_initData()
    self:_initNextData()
    -- dump(self._nextData)
    return self._nextData[type]
end

function VipData:getNextWholeData(type)
    self:_initData()
    self:_initNextWholeData()
    -- dump(self._nextData)
    return self._nextWholeData[type]
end

local vipNameImg = {"vip_yinliangfuben",
                                    "vip_yinliangfuben",
                                    "vip_jingyanyinyinfuben",
                                    "vip_jinjiedanfuben",
                                    "vip_xilianshifuben",
                                    "vip_zhuangbeijinglianfuben",
                                    "vip_baowujinglianfuben",
                                    "vip_guanghuanshifuben",
                                        }
-- local vipMapImg = {"fuben_yinliang",
--                                     "fuben_yinlongbaobao",
--                                     "fuben_jinjiedan",
--                                     "fuben_xilianshi",
--                                     "fuben_jingyanyinyin",
--                                     "fuben_zhuangbeixiangzi",
--                                     "fuben_baowuxiangzi",
--                                     "fuben_zhuangbeijinglian",
--                                     "fuben_baowujinglian",
--                                     "fuben_guanghuanshi",
--                                         }

function VipData:getVipNameImg(map)
    return "ui/text/txt/"..vipNameImg[map]..".png"
end

function VipData:getVipMapImg(map)
    return "ui/vipdungeon/"..dungeon_vip_info.get(map).icon_pic..".png"
end

function VipData:getMapName( map )
    local info = dungeon_vip_info.get(map)
    local name = info.name
    if map ~= 1 then 
        name = name.."副本"
    end
    return name
end

function VipData:getVipMap()
    local info = vip_level_info.get(self._level)
    local maps = {}
    for i = 1,10 do 
        maps[i] = 0
    end
    for i = 1,10 do 
        local mapId = info["vip_dungeon_"..i]
        maps[mapId] = 1
    end
    return maps
end

function VipData:getMapVip(map)
    
    for i = 0,maxLevel do 
        local info = vip_level_info.get(i)
        local value = info["vip_dungeon_"..map]
        if value > 0 then
            return i
        end
    end
    return -1
end

function VipData:getVipBuffData()

    local per = 0

    if self._level < 3 then
        return 0,0
    elseif self._level < 5 then
        return 200,5000
    elseif self._level < 7 then
        return 500,10000
    elseif self._level < 9 then
        return 1000,20000
    else
        return 2000,35000
    end
end

function VipData:getMainBuffData()
    
    local per = 0

    if self._level < 4 then
        return 0
    elseif self._level < 6 then
        return 5
    elseif self._level < 8 then
        return 10
    elseif self._level < 10 then
        return 15
    else
        return 20
    end
end

function VipData:getAttackAward(mapId,damage)
    local value = 0
    -- if mapId == 1 then
    --     -- 银两
    --   value = math.max(math.min(math.floor(-80000+10000* math.log(damage)),50000),10000) + self:getAddedAward(mapId,damage)
    -- elseif mapId == 4 or mapId == 6 then
    --   value = math.max(math.min(math.floor(-114+15*math.log(damage)),80),20) + self:getAddedAward(mapId,damage)
    -- elseif mapId == 5 or mapId == 7 then
    --   value = math.max(math.min(math.floor(-57+7.5*math.log(damage)),40),10) + self:getAddedAward(mapId,damage)
    -- else 
    --   value = 0
    -- end
    if mapId == 1 then
        -- 银两
      value = math.max(math.min(math.floor(2300*(damage^0.32)),250000),40000) + self:getAddedAward(mapId,damage)
    elseif mapId == 4 then
      value = math.max(math.min(math.floor(3.7*(damage^0.26)),160),40) + self:getAddedAward(mapId,damage)
    elseif mapId == 5 then
      value = math.max(math.min(math.floor(1.85*(damage^0.26)),80),20) + self:getAddedAward(mapId,damage)
      elseif mapId == 6 then
        value = math.max(math.min(math.floor(1.85*(damage^0.26)),80),20) + self:getAddedAward(mapId,damage)
      elseif mapId == 7 then
        value = math.max(math.min(math.floor(1.85*(damage^0.26)),80),20) + self:getAddedAward(mapId,damage)
    else 
      value = 0
    end
    return value
end

function VipData:getDefenceAward(mapId,round)
    return self:getAddedAward(mapId,round)
end

function VipData:getAddedAward(mapId,data)
    local award = 0
    local info = dungeon_vip_info.get(mapId)
    for i = 1, 8 do
        if data >= info["extra_ratio_"..i] then
            award = info["extra_size_"..i]
        else 
            -- print(info["extra_ratio_"..i])
            -- print(info["extra_size_"..i])
            return award
        end
    end
    return award
end

function VipData:getNextExp()
    local exp = self:getExp()
    local expMax = vip_level_info.get(self._level+1).low_value
    return expMax - exp
end

-- 新日常副本
-- （后来更改）data中为已经通过的副本
function VipData:setUnbeatenDungeons( dids )
    self._unbeatenDungeons = {}

    local beatenDungeons = {}
    beatenDungeons = dids

    local openDungeons = self:getOpenDailyDungeon()
    for i=1,#openDungeons do
        self._unbeatenDungeons[i] = openDungeons[i].id
    end

    -- 蛋疼。。。
    for i=1, #openDungeons do
        for j=1, #beatenDungeons do
            if beatenDungeons[j] == openDungeons[i].id then                
                for k=1,#self._unbeatenDungeons do
                    if self._unbeatenDungeons[k] == beatenDungeons[j] then
                        table.remove(self._unbeatenDungeons, k)  
                        break      
                    end
                end
                break
            end 
        end
    end    
end

function VipData:getUnbeatenDungeons(  )
    return self._unbeatenDungeons
end

-- 获取今天开放的副本
function VipData:getOpenDailyDungeon(  )
    local openDungeonList = {}
    local dateObj = G_ServerTime:getDateObject()
    local dayOfWeek = self:_changeWeekFormat(dateObj.wday)
    if dayOfWeek == 7 then
        for i=1, dungeon_daily_info.getLength() do
            table.insert(openDungeonList, dungeon_daily_info.indexOf(i))
        end
    elseif dayOfWeek%2 == 0 then
        for i=1, dungeon_daily_info.getLength() do
            local dungeonInfo = dungeon_daily_info.indexOf(i)
            if dungeonInfo.dungeon_type == 2 then
                table.insert(openDungeonList, dungeonInfo)
            end
        end
    else
        for i=1, dungeon_daily_info.getLength() do
            local dungeonInfo = dungeon_daily_info.indexOf(i)
            if dungeonInfo.dungeon_type == 1 then
                table.insert(openDungeonList, dungeonInfo)
            end
        end
    end 

    local sortFunc = function ( a, b )
        if a.level_1 == b.level_1 then
            return a.id > b.id
        else
            return a.level_1 < b.level_1
        end
    end 

    table.sort( openDungeonList, sortFunc )

    return openDungeonList  
end

function VipData:getDailyDungeonList(  )
    local listOdd = {}
    local listEven = {}
    local listTotal = {}

    local dateObj = G_ServerTime:getDateObject()
    local dayOfWeek = self:_changeWeekFormat(dateObj.wday)

    for i=1, dungeon_daily_info.getLength() do 
        local dungeonInfo = dungeon_daily_info.indexOf(i)
        if dungeonInfo.dungeon_type == 1 then
            if dayOfWeek % 2 == 1 then
                dungeonInfo["isOpenToday"] = true
            else
                dungeonInfo["isOpenToday"] = false
            end
            table.insert(listOdd, dungeonInfo)
        elseif dungeonInfo.dungeon_type == 2 then
            if dayOfWeek % 2 == 0 or dayOfWeek == 7 then
                dungeonInfo["isOpenToday"] = true
            else
                dungeonInfo["isOpenToday"] = false
            end
            table.insert(listEven, dungeonInfo)
        end
    end

    local sortFunc = function ( a, b )
        if a.level_1 == b.level_1 then
            return a.id > b.id
        else
            return a.level_1 < b.level_1
        end
    end

    table.sort(listOdd, sortFunc)
    table.sort(listEven, sortFunc)

    local listFirst = {}
    local listSecond = {}
    if listOdd[1]["isOpenToday"] then
        listFirst = listOdd
        listSecond = listEven
    else
        listFirst = listEven
        listSecond = listOdd
    end

    for i=1, #listFirst do
        table.insert(listTotal, listFirst[i])
    end
    for i=1, #listSecond do
        table.insert(listTotal, listSecond[i])
    end

    -- 如果是星期天则所有的副本按照开放等级排序
    if listOdd[1]["isOpenToday"] and listEven[1]["isOpenToday"] then
        table.sort(listTotal, sortFunc)
    end

    return listTotal
end

-- 将星期几转换成
function VipData:_changeWeekFormat( wday )
    local wdayReal = wday - 1
    if wdayReal == 0 then wdayReal = 7 end
    return wdayReal
end

-- 根据副本ID获取怪物缩略图
function VipData:getMosterIconPic( resId )
    return "ui/vipdungeon/" .. resId .. ".png"
end

return VipData
