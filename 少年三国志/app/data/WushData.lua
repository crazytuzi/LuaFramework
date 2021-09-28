local WushData = class("WushData")
require("app.cfg.dead_battle_buff_info")
require("app.cfg.dead_battle_info")
require("app.cfg.passive_skill_info")
require("app.cfg.dead_battle_reset_info")
require("app.cfg.dead_battle_award_info")

-- 精英boss初始默认的挑战次数
WushData.InitChallengeTimes = 3

-- local maxFloor = 36
function WushData:ctor()
    self._starTotal = 0
    self._starCur = 0
    self._starHis = 0
    self._starList = {}
    self._buffList = {}
    self.failed = 0
    self._floor = 1
    self._resetCount = 0
    self._buffValue = nil
    self._inited = false
    self._needGo = false
    self._buffToChoose = {}
    self._buffChoosedIndex = 0
    self._resetFreeCount = 0
    self._resetTotalCount = 0
    self._buyId = 0
    self._bought = false
    self.maxFloor = dead_battle_info.getLength()
    self._fastMax = 0

    -- 三国无双精英boss相关数据
    -- 当前激活boss id
    self._wushBossActiveId = -1 
    -- 首次攻打boss id
    self._wushBossFirstId = -1
    -- 旧的首次攻打boss id
    self._wushBossOldFirstId = -1
    -- 今天已攻打次数
    self._wushBossChallengeTimes = 0
    -- 今天已购买过的挑战次数
    self._wushBossBuyChallengeTimes = 0
    -- 当前是否处于无双精英挑战界面，用于战斗返回时处理speedbar层级高于挑战界面的问题
    self._isInWushBossLayer = false
end

function WushData:setWushInfo(data)
    self._date = G_ServerTime:getDate()
    self._inited = true
    self._starTotal = data.star_total
    self._starCur = data.star_cur
    self._starHis = data.star_his
    self.failed = data.failed
    self._floor = data.floor+1
    self._resetCount = data.reset_count
    self:_initBuff(data)
    self:_initStar(data)
    self:_setResetCount()
    self._buyId = data.buy_id
    self._bought = data.bought
    self._fastMax = data.max_clean
end

function WushData:getFastMax()
     return self._fastMax
end

-- @desc 是否重新需要拉数据
function WushData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function WushData:_initBuff(data)
    if rawget(data,"star") then
        self._starList = data.star
    else
        self._starList = {}
    end
end

function WushData:_initStar(data)
    if rawget(data,"buffs") then
        self._buffList = data.buffs
    else
        self._buffList = {}
    end
end

function WushData:setBuffToChoose(data)
     self._buffToChoose = data
end

function WushData:getBuffToChoose()
     return self._buffToChoose
end

function WushData:getResetCount()
     return self._resetCount
end

function WushData:getResetTotalCount()
    local addChance = G_Me.vipData:getData(29).value
    addChance = addChance >=0 and addChance or 0
     return self._resetTotalCount + addChance
end

function WushData:getResetFreeCount()
     return self._resetFreeCount
end

function WushData:showTips()
     return self:getResetCount() < self:getResetFreeCount()
end

function WushData:getResetCost()
     return dead_battle_reset_info.get(self._resetCount+1).cost
end

function WushData:_setResetCount()
    -- local total = dead_battle_reset_info.getLength()
    -- local free = 0
    -- for i = 1, total do 
    --     if dead_battle_reset_info.get(i).cost == 0 then 
    --         free = free + 1
    --     end
    -- end
    -- self._resetFreeCount = free
    -- self._resetTotalCount = total

    --还是写死吧
    self._resetFreeCount = 1
    self._resetTotalCount = 3
end

function WushData:setBuffToChooseIndex(index)
     self._buffChoosedIndex = index
end

function WushData:getBuffToChooseIndex()
     return self._buffChoosedIndex
end

function WushData:getFloor()
     return self._floor
end

function WushData:getStarCur()
     return self._starCur
end

function WushData:getStarHis()
     return self._starHis
end

function WushData:getStarTotal()
     return self._starTotal
end

function WushData:getStar(floor)
     return self._starList[floor]
end

function WushData:calcCurStar(floor1,floor2)
    local total = 0
    for i = floor1,floor2 do
        if self._starList[i] then
            total = total + self._starList[i]
        else
            return total
        end
    end
     return total
end

function WushData:isNew()
     return not self._inited
end

function WushData:battleWin(star)
    self._needGo = true
    self._starList[self._floor] = star
    -- local info = dead_battle_info.get(self._floor)
    -- local addScore = info["tower_score_"..star]
    -- print("addScore "..addScore)
    -- G_Me.userData:setTowerScore(G_Me.userData.tower_score+addScore)
    self._floor = self._floor + 1
    self._starCur = self._starCur + star
    self._starTotal = self._starTotal + star
    if  self._starHis < self._starTotal then
        self._starHis = self._starTotal
    end
end

function WushData:hasWin()
     self._needGo = false
end

function WushData:battleLose()
     self.failed = 1
end

function WushData:battleReset(max_clean)
     self._starTotal = 0
     self._starCur = 0
     self._starTotal = 0
     self._buffList = {}
     self.failed = 0
     self._floor = 1
     self._resetCount = self._resetCount + 1
     self._buffValue = nil
     self._needGo = false
     self._buffToChoose = {}
     self._buffChoosedIndex = 0
     self._buyId = 0
     self._bought = false
     if max_clean then
        self._fastMax = max_clean
    end
end

function WushData:needGo()
     return self._needGo
end

function WushData:calcBuff()
    self._buffValue = {}
    -- for index = 1,17 do
    --     self._buffValue[index] = 0
    -- end
    for i = 1,#self._buffList do
        local skill = passive_skill_info.get(self._buffList[i])
        if self._buffValue[skill.affect_type] then
            self._buffValue[skill.affect_type] = self._buffValue[skill.affect_type] + skill.affect_value
        else
            self._buffValue[skill.affect_type] = skill.affect_value
        end
    end
end

function WushData:getBuffList()
    if not self._buffValue then
        self:calcBuff()
    end
    return self._buffValue
end

function WushData:AddBuff()
    if not self._buffValue then
        self:calcBuff()
    end
    local star = self._buffChoosedIndex*3
    self._starCur = self._starCur - star
    local buffId = self._buffToChoose[self._buffChoosedIndex]
    local skill = passive_skill_info.get(buffId)
    table.insert(self._buffList, #self._buffList + 1, buffId)
    if self._buffValue[skill.affect_type] then
        self._buffValue[skill.affect_type] = self._buffValue[skill.affect_type] + skill.affect_value
    else
        self._buffValue[skill.affect_type] = skill.affect_value
    end
end

function WushData:needBuff()
    if self._floor > self.maxFloor then
        return false
    end
    local buffCount = #self._buffList
    if self._floor%3 == 1 and (self._floor-1)/3 > buffCount then
        return true
    else
        return false
    end
end

local buffIconList = {"cg_ming","cg_shan","cg_bao","cg_kang","cg_shang","cg_mian","cg_xue","cg_gong"}

function WushData:getBuffIcon(type)
    local name = ""
    if type <= 6 then
        name = buffIconList[type]
    elseif type == 9 then
        name = buffIconList[7]
    else
        name = buffIconList[8]
    end
    return "ui/text/txt/"..name..".png"
end

local isAttrTypeRate = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [9] = true,
}

function WushData.convertAttrTypeAndValue(type, value)
    if isAttrTypeRate[type] ~= nil then
        --比率型,那么value是千分比啊, 让它变百分比吧
        value = value / 10
    end

    local  valueString =  G_lang.getSkillValue(type, value)
    local  typeString = G_lang.getSkillTypeName(type)    
    return typeString, valueString    
end

function WushData:getAwardById(id)
     local info = dead_battle_award_info.get(id)
     local award = {}
     for i = 1 , 4 do 
        if info["type_"..i] > 0 then
            local isHoliday = G_Goods.checkHolidayByTypeValue(info["type_"..i],info["value_"..i],info["size_"..i])
            if isHoliday == 0 then  --普通道具
                table.insert(award,#award+1,{type=info["type_"..i],value=info["value_"..i],size=info["size_"..i]})  
            elseif isHoliday == 1 then  --掉落活动道具
                if G_Me.activityData.holiday:isActivate() then
                    table.insert(award,#award+1,{type=info["type_"..i],value=info["value_"..i],size=info["size_"..i]})  
                end
            elseif isHoliday == 2 then  --special activity item
                if G_Me.specialActivityData:isInActivityTime() then
                    table.insert(award,#award+1,{type=info["type_"..i],value=info["value_"..i],size=info["size_"..i]}) 
                end
            end
        end
     end
     return award
end

-- 三国无双精英boss相关数据操作
function WushData:setBossInfo( data )
    self._wushBossOldFirstId = self._wushBossFirstId

    self._wushBossActiveId = data.active_id
    self._wushBossFirstId = data.first_id
    self._wushBossChallengeTimes = data.times
    self._wushBossBuyChallengeTimes = data.buy_times
end

function WushData:setBossBuyChallengeTimes( num )
    self._wushBossBuyChallengeTimes = num
end

function WushData:getBossActiveId(  )
    return self._wushBossActiveId
end

function WushData:getBossFirstId(  )
    return self._wushBossFirstId
end

function WushData:getBossOldFirstId(  )
    return self._wushBossOldFirstId
end

function WushData:getBossChallengeTimes(  )
    return self._wushBossChallengeTimes
end

function WushData:getBossBuyChallengeTimes(  )   
    return self._wushBossBuyChallengeTimes
end

-- 判断是否还有精英boss的挑战次数
function WushData:getCurBossChallengeTimes(  )
    local curChallengeTimes = WushData.InitChallengeTimes + self:getBossBuyChallengeTimes() - self:getBossChallengeTimes()
    return math.max(curChallengeTimes, 0)
end

function WushData:setIsInWushBossLayer( isInBossLayer )
    self._isInWushBossLayer = isInBossLayer
end

function WushData:getIsInWushBossLayer(  )
    return self._isInWushBossLayer
end

return WushData

