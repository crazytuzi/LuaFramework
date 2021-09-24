--AI部队的数据处理模块
require "luascript/script/game/gamemodel/AITroops/AITroopsVo"

AITroopsVoApi = {
    troopsList = {}, --当前拥有的AI部队列表
    troopsIds = {}, --记录拥有AI部队的id列表，用于部队排序
    AITroopsInfo = nil, --功能数据
    listRefreshFlag = nil, --是否需要刷新部队列表
}

function AITroopsVoApi:getModelCfg()
    local aiTroopsCfg = G_requireLua("config/gameconfig/aiTroops")
    return aiTroopsCfg
end

--@return 0：功能开关未开 -1：玩家等级不够 1：功能开启
function AITroopsVoApi:isOpen()
    local aiTroopsCfg = self:getModelCfg()
    if base.AITroopsSwitch == 0 then
        return 0
    end
    local playerLv = playerVoApi:getPlayerLevel()
    if playerLv < aiTroopsCfg.openLevel then
        return - 1, aiTroopsCfg.openLevel
    end
    return 1
end

--格式化功能数据
function AITroopsVoApi:formatData(data)
    local info = self.AITroopsInfo or {}
    if info.dayInfo == nil then
        info.dayInfo = {}
    end
    if data.day_ts then
        info.dayInfo.day_ts = data.day_ts --0点时间戳，用于跨天清数据
    else
        if info.dayInfo.day_ts == nil then
            info.dayInfo.day_ts = base.serverTime
        end
    end
    if data.day_pnum then
        info.dayInfo.day_pnum = data.day_pnum or 0 --当日生产次数
    end
    if data.day_dcnum then
        info.dayInfo.day_dcnum = data.day_dcnum or 0 --当日双倍消耗生产次数
    end
    if data.day_rnum then
        info.dayInfo.day_rnum = data.day_rnum --当日重置次数
    end
    if data.day_upnum then
        info.dayInfo.day_upnum = data.day_upnum --当日ai部队升级次数
    end
    if data.day_supnum then
        info.dayInfo.day_supnum = data.day_supnum --当日技能升级次数
    end
    if data.day_snum then
        info.dayInfo.day_snum = data.day_snum --当日技能洗练次数
    end
    if data.queue then
        info.produceQueue = data.queue or {} --部队生产队列  格式：{q1={r={奖励},c={消耗},st=0,et=0,s=1(是否被打断)}}
    end
    if data.costinfo then
        info.produceCost = data.costinfo or {} --部队阶位部队当前生产消耗
    end
    if data.strength then
        info.strength = data.strength or {} --各等级部队的总强度，用于部队解锁
    end
    if data.aitroops and SizeOfTable(data.aitroops) > 0 then --现有AI部队列表
        self.troopsList, self.troopsIds = {}, {}
        for k, v in pairs(data.aitroops) do
            local vo = AITroopsVo:new()
            vo:init(k, v)
            self.troopsList[k] = vo
            table.insert(self.troopsIds, k)
        end
        self:sortTroopsList()
    end
    local aiTroopsCfg = self:getModelCfg()
    local costPropId = aiTroopsCfg.expCostId
    local beforeNum = 0
    if info.prop and info.prop[costPropId] then
        beforeNum = info.prop[costPropId]
    end
    local refreshStateFlag = false
    if data.prop then
        info.prop = data.prop --功能道具列表
        local afterNum = info.prop[costPropId]
        --升级所需要的消耗道具发生变化则通知刷新AI部队状态
        if tonumber(beforeNum) ~= tonumber(afterNum) then
            refreshStateFlag = true
        end
    end
    if data.fragment then
        if info.fragment == nil then
            refreshStateFlag = true
        else
            for k, v in pairs(data.fragment) do
                if tonumber(info.fragment[k] or 0) ~= tonumber(v) then --部队碎片数发生变化
                    refreshStateFlag = true
                    do break end
                end
            end
        end
        info.fragment = data.fragment --当前拥有的部队碎片
    end
    if refreshStateFlag == true then
        eventDispatcher:dispatchEvent("aitroops.list.refresh", {rtype = 2})
    end
    if data.stats then --AI部队出征状态
        AITroopsFleetVoApi:syncStats(data.stats)
    end
    
    self.AITroopsInfo = info
end

--获取部队列表
function AITroopsVoApi:getTroopsList()
    return self.troopsList or {}
end

--因为设置部队中有些是镜像或者跨服带入的部队数据，则需要判断一下
function AITroopsVoApi:checkIsAITroopsMirror(atid)
    local arr = Split(atid, "-")
    if arr and SizeOfTable(arr) > 3 then
        --arr中包含了AI部队相关数据
        return true, arr
    end
    return false
end

function AITroopsVoApi:getRealAITroopsId(atid)
    if atid == 0 or atid == "" then
        return atid
    end
    local isMirror, arr = self:checkIsAITroopsMirror(atid)
    if isMirror == true then
        return arr[1]
    end
    return atid
end

--提取配置中的limit，看这个部队不能跟哪几个一起上场
function AITroopsVoApi:getLimitTroops( atid )
    local aiTroopsCfg = self:getModelCfg()
    local limitTb = aiTroopsCfg.aitroopType[atid].limit
    if limitTb then
        return true
    else
        return false
    end
end

function AITroopsVoApi:getLimitTroopsCfg( atid )
    local aiTroopsCfg = self:getModelCfg()
    local limitTb ={}
    if self:getLimitTroops( atid ) then
        limitTb = aiTroopsCfg.aitroopType[atid].limit
    end
    return limitTb
end

--aitroops_limit_a13文字
function AITroopsVoApi:getLimitDes( atid ,conflictTb)
    local num = 0
    local str = ""
    local limitDes = ""
    if atid~=nil and conflictTb==nil then
        local aiTroopsCfg = self:getModelCfg()
        local limitTb = aiTroopsCfg.aitroopType[atid].limit
        num=SizeOfTable(limitTb)
        if num ==1 then
            for k,v in pairs(limitTb) do
                local nameStr, color = AITroopsVoApi:getAITroopsNameStr(v)
                limitDes = getlocal("aitroops_limit_des1",{nameStr})
            end
        else
            local nameTb = {}
            for k,v in pairs(limitTb) do
                local nameStr, color = AITroopsVoApi:getAITroopsNameStr(v)
                -- nameTb[k]=nameStr
                if k~=num then
                    str = str..nameStr..","
                else
                    str = str..nameStr
                end
            end
           limitDes = getlocal("aitroops_limit_des2",{str})
        end
    else
        num=SizeOfTable(conflictTb)
        if num ==1 then
            for k,v in pairs(conflictTb) do
                local nameStr, color = AITroopsVoApi:getAITroopsNameStr(v)
                limitDes = getlocal("aitroops_limit_des1",{nameStr})
            end
        else
            local nameTb = {}
            for k,v in pairs(conflictTb) do
                local nameStr, color = AITroopsVoApi:getAITroopsNameStr(v)
                -- nameTb[k]=nameStr
                if k~=num then
                    str = str..nameStr..","
                else
                    str = str..nameStr
                end
            end
           limitDes = getlocal("aitroops_limit_des2",{str})
        end
    end
    return limitDes
end

--判断和外面防守部队中已选择部队有没有limit的，直接置灰，不可点击
function AITroopsVoApi:troopsConflict( limitTb, haveSelectAITroopsTb)
    local tb = {}
    local num = 1
    if limitTb and haveSelectAITroopsTb then
        for k,v in pairs(limitTb) do
            for i,j in pairs(haveSelectAITroopsTb) do
                if v==j then
                    table.insert(tb,j)
                end
            end
        end
    end
    return tb
end

function AITroopsVoApi:jointAITroopsMirrorStr(atid, lv, grade, slv1, slv2, sid3, slv3)
    local mirrorStr = atid .. "-" .. lv .. "-" .. grade .. "-" .. slv1 .. "-" .. slv2
    if sid3 and slv3 then
        mirrorStr = mirrorStr .. "-" .. sid3 .. "-" .. slv3
    end
    return mirrorStr
end

function AITroopsVoApi:getMaxLvAITroopsVo(atid, isShowInitLv)
    local aiTroopsCfg = self:getModelCfg()
    local tcfg = aiTroopsCfg.aitroopType[atid]
    --ai部队的最大等级
    local maxLv = self:getTroopsMaxLvById(atid)
    --第一个技能id和最大等级
    local sid1 = tcfg.skill1[1]
    local slv1 = aiTroopsCfg.skill[sid1].lvMax
    --第二个技能id和最大等级
    local sid2 = tcfg.skill2[1]
    local slv2 = aiTroopsCfg.skill[sid2].lvMax
    local sid3, slv3
    local grade = 2
    if tcfg.skill3 then
        --第三个技能id和最大等级
        sid3 = tcfg.skill3[1]
        slv3 = aiTroopsCfg.skill[sid3].lvMax
        grade = 3
    end
    if isShowInitLv == true then
        maxLv, slv1, slv2, slv3 = 1, 1, 1, 1
    end
    local arr = {atid, maxLv, grade, slv1, slv2, sid3, slv3}
    return self:createAITroopsVoByMirror(arr)
end

function AITroopsVoApi:getAITroopsId(id)
    local isMirror, arr = self:checkIsAITroopsMirror(id)
    if isMirror == true then
        return arr[1]
    end
    return id
end

function AITroopsVoApi:createAITroopsVoByMirror(arr)
    --部队id-等级-等阶-技能1等级-技能2等级-技能3id-技能3等级
    local vo = AITroopsVo:new()
    local atid, lv, grade, slv1, slv2, sid3, slv3 = arr[1], tonumber(arr[2]), tonumber(arr[3]), tonumber(arr[4]), tonumber(arr[5]), arr[6], tonumber(arr[7])
    local td = {lv, 0, grade}
    local aiTroopsCfg = self:getModelCfg()
    local acfg = aiTroopsCfg.aitroopType[atid]
    if acfg then
        local skills = {}
        if slv1 then
            local sk = {acfg.skill1[1], slv1, 0}
            table.insert(skills, sk)
        end
        if slv2 then
            local sk = {acfg.skill2[1], slv2, 0}
            table.insert(skills, sk)
        end
        if sid3 == nil and acfg.skill3 then
            sid3 = acfg.skill3[1]
        end
        if sid3 and slv3 then
            local sk = {sid3, slv3, 0}
            table.insert(skills, sk)
        end
        td[4] = skills
    end
    vo:init(atid, td)
    
    return vo
end

function AITroopsVoApi:getTroopsById(id)
    local isMirror, arr = self:checkIsAITroopsMirror(id)
    -- print("id,isMirror---->>>", id, isMirror)
    if isMirror == true then --如果是镜像临时创建一个AI部队的模块
        return self:createAITroopsVoByMirror(arr)
    end
    if self.troopsList and self.troopsList[id] then
        return self.troopsList[id]
    end
    return nil
end

function AITroopsVoApi:getTroopsIds()
    return self.troopsIds or {}
end

--排序现有部队列表
--AI部队排序规则，优先级为：已派>未派；阶级3>2>1；等级由高至低；强度由高至低
function AITroopsVoApi:sortTroopsList()
    if self.troopsList == nil or self.troopsIds == nil then
        do return end
    end
    local aiTroopsCfg = self:getModelCfg()
    local aitroopType = aiTroopsCfg.aitroopType
    local function sortTroops(t1, t2)
        local vo1, vo2 = self.troopsList[t1], self.troopsList[t2]
        local tcfg1, tcfg2 = aitroopType[t1], aitroopType[t2]
        if vo1 and vo2 and tcfg1 and tcfg2 then
            local battleFlag1 = AITroopsFleetVoApi:getIsBattled(vo1.id) == true and 2 or 1
            local battleFlag2 = AITroopsFleetVoApi:getIsBattled(vo2.id) == true and 2 or 1
            local strength1, strength2 = vo1:getTroopsStrength(), vo2:getTroopsStrength()
            local w1 = battleFlag1 * 1000000 + tcfg1.quality * 100000 + strength1
            local w2 = battleFlag2 * 1000000 + tcfg2.quality * 100000 + strength2
            if w1 > w2 then
                return true
            end
        end
        return false
    end
    table.sort(self.troopsIds, sortTroops)
end

--部队最大等级
function AITroopsVoApi:getTroopsMaxLvById(id)
    local aiTroopsCfg = self:getModelCfg()
    local quality = aiTroopsCfg.aitroopType[id].quality
    return #aiTroopsCfg.troopsExp[quality] + 1
end

--部队升级所需经验
function AITroopsVoApi:getTroopsUpgradeExpById(id, lv)
    local aiTroopsCfg = self:getModelCfg()
    local quality = aiTroopsCfg.aitroopType[id].quality
    if lv then
        return aiTroopsCfg.troopsExp[quality][lv] or 0
    end
    local troopsVo = self.troopsList[id]
    if troopsVo then
        return aiTroopsCfg.troopsExp[quality][troopsVo.lv] or 0
    end
    return 0
end

--获取当前选中的生产AI部队的类型
function AITroopsVoApi:getCurProduceTroopType()
    local dataKey = "aitroopsType@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
    local troopType = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey))
    if troopType == 0 then
        troopType = 1
    end
    local unlockFlag = self:isTroopsUnlock(troopType) --如果该类型没有解锁的话默认显示第一个
    if unlockFlag == false then
        troopType = 1
    end
    return troopType
end

--保存生产AI部队的类型
function AITroopsVoApi:saveCurProduceTroopType(troopType)
    local dataKey = "aitroopsType@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
    CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey, troopType)
    CCUserDefault:sharedUserDefault():flush()
end

--获取部队的总强度
--该部队总强度=部队初始强度+部队等级强度+技能强度之和
function AITroopsVoApi:getTroopsStrength(atid, grade, lv, skills)
    local strength = 0
    local aiTroopsCfg = self:getModelCfg()
    local tcfg = aiTroopsCfg.aitroopType[atid]
    if tcfg then
        strength = strength + tcfg.qiangdu --基础强度
        local maxStrengthLv = SizeOfTable(aiTroopsCfg.troopslvStrength[tcfg.quality])
        local strengthLv = (lv > maxStrengthLv) and maxStrengthLv or lv
        strength = strength + aiTroopsCfg.troopslvStrength[tcfg.quality][strengthLv] or 0 --部队等级强度
        --技能强度加成（部队绑定各个技能强度之和）
        local skill = aiTroopsCfg.skill
        local scfg, maxLv
        if skills then
            for k, v in pairs(skills) do
                local sid, slv = v[1], tonumber(v[2]) or 1
                if sid and slv and grade >= k then
                    scfg = skill[sid]
                    if scfg then
                        maxLv = scfg.lvMax
                        slv = (slv > maxLv) and maxLv or slv
                        strength = strength + (scfg.skillStrength[slv] or 0)
                    end
                end
            end
        end
    end
    return strength
end

--判断指定品质的部队是否解锁
function AITroopsVoApi:isTroopsUnlock(quality)
    if tonumber(quality) == 1 then
        do return true end
    end
    local aiTroopsCfg = self:getModelCfg()
    local curStrength = 0
    local needStrength = aiTroopsCfg.unlockStage[tonumber(quality)] or 0
    if self.AITroopsInfo and self.AITroopsInfo.strength then
        curStrength = self.AITroopsInfo.strength[tonumber(quality) - 1] or 0
        if curStrength >= needStrength then
            return true, needStrength, curStrength
        end
    end
    return false, needStrength, curStrength
end

--是否有生产队列
function AITroopsVoApi:isHasProduceQueue()
    if self.AITroopsInfo and self.AITroopsInfo.produceQueue and SizeOfTable(self.AITroopsInfo.produceQueue) > 0 then
        return true
    end
    return false
end

--是否有空闲的生产队列
function AITroopsVoApi:isFreeProduce()
    if self.AITroopsInfo == nil then --数据还没有回来
        return false
    end
    if self.AITroopsInfo.produceQueue and SizeOfTable(self.AITroopsInfo.produceQueue) > 0 then
        for k, v in pairs(self.AITroopsInfo.produceQueue) do
            if v.et and base.serverTime < v.et and tonumber(v.s or 0) ~= 1 then
                return false
            end
        end
    end
    return true
end

--获取当前生产队列
function AITroopsVoApi:getProduceQueue()
    if self.AITroopsInfo and self.AITroopsInfo.produceQueue then
        for k, v in pairs(self.AITroopsInfo.produceQueue) do
            return k, v --队列id，队列详情
        end
    end
    return nil, nil
end

--移除生产队列
function AITroopsVoApi:removeProduceQueue(slotId)
    if self.AITroopsInfo and self.AITroopsInfo.produceQueue then
        self.AITroopsInfo.produceQueue[tostring(slotId)] = nil
    end
end

--获取生产部队的坦克消耗
function AITroopsVoApi:getProduceCostByTroopType(quality)
    local tankId, num
    if self.AITroopsInfo and self.AITroopsInfo.produceCost then
        local dayInfo = self:getDayInfo()
        local costinfo = self.AITroopsInfo.produceCost[tonumber(quality)]
        if costinfo then
            for k, v in pairs(costinfo) do
                tankId, num = k, v
                local aiTroopsCfg = self:getModelCfg()
                if dayInfo.day_pnum then
                    if dayInfo.day_pnum < aiTroopsCfg.produceRssHalfNum then --前produceRssHalfNum次生产消耗减半
                        num = math.ceil(num / 2)
                    end
                end
                do break end
            end
        end
    end
    return tankId, num
end

--获取指定坦克在防守部队里占用的个数
function AITroopsVoApi:getDefenseTankCount(tankId)
    local defNum = 0
    tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
    local tankTb = tankVoApi:getTemDefenseTanks()
    for k, v in pairs(tankTb) do
        local tid, num = v[1], v[2]
        if tid and num then
            tid = tonumber(tid) or tonumber(RemoveFirstChar(tid))
            if tid == tankId then
                defNum = defNum + num
            end
        end
    end
    return defNum
end

--生产消耗时间
function AITroopsVoApi:getProduceCostTime(quality)
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.produceTime and aiTroopsCfg.produceTime[tonumber(quality)] then
        local time = aiTroopsCfg.produceTime[tonumber(quality)]
        local buff=buildDecorateVoApi:getAITroopsProduceTimeBuff()
        time = time - time*buff
        return time
    end
    return 0
end

--获取重置消耗金币数
function AITroopsVoApi:getResetCost()
    local aiTroopsCfg = self:getModelCfg()
    local maxc = SizeOfTable(aiTroopsCfg.resetCost)
    local dayInfo = self:getDayInfo()
    local rn = dayInfo.day_rnum or 0
    if (rn + 1) > maxc then
        return aiTroopsCfg.resetCost[maxc]
    else
        return aiTroopsCfg.resetCost[rn + 1]
    end
    return 0
end

--获取生产加速消耗的金币数
function AITroopsVoApi:getSpeedupCost(queue)
    if queue == nil then
        do return 0 end
    end
    local aiTroopsCfg = self:getModelCfg()
    local perCost = aiTroopsCfg.speedupCost --每分钟消耗的金币数
    local minutes = math.ceil((queue.et - base.serverTime) / 60)
    
    return math.ceil(minutes * perCost)
end

function AITroopsVoApi:checkIsToday()
    if self.AITroopsInfo and self.AITroopsInfo.dayInfo and self.AITroopsInfo.dayInfo.day_ts then
        if G_isToday(self.AITroopsInfo.dayInfo.day_ts) == false then
            return false
        end
    end
    return true
end

function AITroopsVoApi:resetDailyInfo()
    if self.AITroopsInfo == nil then
        self.AITroopsInfo = {}
    end
    if self.AITroopsInfo then
        self.AITroopsInfo.dayInfo = {
            -- day_ts = base.serverTime, --此处先不重置时间戳，当在面板自主tick时再重置为当前时间戳
            day_pnum = 0,
            day_dcnum = 0,
            day_rnum = 0,
            day_upnum = 0,
            day_supnum = 0,
            day_snum = 0,
        }
    end
end

function AITroopsVoApi:getDayInfo()
    if self:checkIsToday() == false then --跨天的话清空每日累计数据
        self:resetDailyInfo()
    end
    return self.AITroopsInfo.dayInfo
end

function AITroopsVoApi:resetDayTs()
    if self.AITroopsInfo and self.AITroopsInfo.dayInfo then
        self.AITroopsInfo.dayInfo.day_ts = base.serverTime
    end
end

--获取双倍消耗生产的次数
function AITroopsVoApi:getDaydcnum()
    local aiTroopsCfg = self:getModelCfg()
    local maxDcnum = aiTroopsCfg.doubleProduceLimitNum
    local dayInfo = self:getDayInfo()
    
    return tonumber(dayInfo.day_dcnum or 0), maxDcnum
end

function AITroopsVoApi:getFragmentIdByTroopsId(id)
    return "f" .. string.sub(id, 2)
end

--获取部队碎片数
function AITroopsVoApi:getTroopsFragment(id)
    if self.AITroopsInfo and self.AITroopsInfo.fragment then
        local fid = self:getFragmentIdByTroopsId(id)
        return self.AITroopsInfo.fragment[fid] or 0
    end
    return 0
end

--获取碎片兑换的道具
function AITroopsVoApi:getFragmentDeCompose(fid)
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.fragment[fid] then
        local deCompose = aiTroopsCfg.fragment[fid].deCompose
        for k, v in pairs(deCompose) do
            local arr = Split(k, "_")
            if arr[1] == "aitroops" then
                return arr[2], tonumber(v)
            end
        end
    end
    return nil
end

--获取部队进阶消耗
function AITroopsVoApi:getTroopsAdvancedCost(id, grade)
    local aiTroopsCfg = self:getModelCfg()
    local cfg = aiTroopsCfg.aitroopType[id]
    if cfg and cfg.upgrade.reward and cfg.upgrade.reward[tonumber(grade)] then
        local reward = FormatItem(cfg.upgrade.reward[tonumber(grade)])
        if reward and reward[1] then
            return reward[1]
        end
    end
    return nil
end

--获取技能信息
function AITroopsVoApi:getSkillInfo(sid, lv)
    local aiTroopsCfg = self:getModelCfg()
    local scfg = aiTroopsCfg.skill[sid]
    local maxLv = scfg.lvMax --技能最大等级
    lv = lv > maxLv and maxLv or lv
    local nextExp = scfg.exp[lv] or 9999999 --技能升级下一级所需经验
    local needTroopLv = scfg.trooplv[lv] --技能升级所需的部队等级限制
    
    return maxLv, nextExp, needTroopLv
end

--获取部队绑定的技能icon
function AITroopsVoApi:getSkillIcon(sid)
    local skillPic = "aitroops_skillpic1.png"
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.skill[sid] then
        skillPic = "aitroops_skillpic"..aiTroopsCfg.skill[sid].grade..".png"
    end
    local icon = LuaCCSprite:createWithSpriteFrameName(skillPic, function () end)
    return icon
end

--获取部队绑定技能的名称和描述
function AITroopsVoApi:getSkillNameAndDesc(sid, lv)
    local nameStr, desc, colorTb = "invalid skill", "invalid skill", {}
    local aiTroopsCfg = self:getModelCfg()
    local scfg = aiTroopsCfg.skill[sid]
    if scfg == nil then
        do return nameStr, desc, colorTb end
    end
    local dhstr = ","
    if G_isAsia() then --亚洲的用中文逗号间隔
        dhstr = "，"
    end
    local colorCfg = {G_ColorGreen, G_ColorBlue, G_ColorPurple, G_ColorOrange}
    if scfg.type == 1 or scfg.type == 0 then
        local str = ""
        local proNum = SizeOfTable(scfg.attType)
        if proNum == 1 then
            str = getlocal("add_attribute_" .. scfg.attType[1], {((scfg.value[lv] * 100) or 0) .. "%%"})
        elseif proNum > 1 then
            for k, v in pairs(scfg.attType) do
                local valueTb = scfg.value[lv] or {}
                local subStr = getlocal("add_attribute_" .. v, {((valueTb[k] * 100) or 0) .. "%%"})
                if k == 1 then
                    str = subStr
                else
                    str = str .. dhstr .. subStr
                end
            end
        end
        if scfg.type == 0 then
            desc = getlocal("atskill_t0_desc", {str})
        else
            desc = getlocal("atskill_t1_object" .. scfg.object .. "_range" .. scfg.range .. "_desc", {str})
        end
        colorTb = {nil, G_ColorGreen, nil}
    elseif scfg.type == 2 or scfg.type == 3 then
        local tankStr = ""
        local tankTb, tankType = self:checkSkillEffectTankType(sid, scfg.type)
        if tonumber(tankType) == 15 then
            tankStr = getlocal("believer_all_fleet")
        else
            for k, v in pairs(tankTb) do
                local subStr = getlocal("tankType_name" .. v)
                if k == 1 then
                    tankStr = subStr
                else
                    tankStr = tankStr .. dhstr .. subStr
                end
            end
        end
        
        local args = {}
        if scfg.type == 2 then
            args = {tankStr, (scfg.value[lv] or 0)}
            colorTb = {nil, G_ColorYellowPro, nil, G_ColorGreen, nil}
        else
            args = {tankStr, (scfg.value[lv] or 0) * 100, (scfg.turn or 0)}
            colorTb = {nil, G_ColorYellowPro, nil, G_ColorGreen, nil, G_ColorGreen, nil}
        end
        desc = getlocal("atskill_t" .. scfg.type .. "_object" .. scfg.object .. "_range" .. scfg.range .. "_desc", args)
    elseif scfg.type == 4 or scfg.type == 6 or scfg.type == 8 or scfg.type == 9 or scfg.type == 10 then
        local args = {}
        if scfg.type == 4 or scfg.type == 10 then
            args = {scfg.parm1, getlocal("atskill_name_"..scfg.parm2), (scfg.value[lv] or 0) * 100}
            colorTb = {nil, G_ColorGreen, nil, G_ColorGreen, nil, (colorCfg[scfg.quality] or G_ColorGreen), nil}
        elseif scfg.type == 6 or scfg.type == 8 then
            if scfg.type == 8 then
                args = {(scfg.value[lv] or 0) * 100}
            else
                args = {(scfg.value[lv] or 0)}
            end
            colorTb = {nil, (colorCfg[scfg.quality] or G_ColorGreen), nil}
        elseif scfg.type == 9 then
            local args1 = ""
            if scfg.parm1 then
                local equipLocationStr = ""
                for k, v in pairs(scfg.parm1) do
                    equipLocationStr = equipLocationStr .. v
                end
                if equipLocationStr == "123" then --前排生效
                    args1 = getlocal("atskill_t9_descParm1")
                elseif equipLocationStr == "456" then --后排生效
                    args1 = getlocal("atskill_t9_descParm2")
                elseif equipLocationStr == "123456" then --全体生效
                    args1 = getlocal("atskill_t9_descParm3")
                end
            else
                args1 = getlocal("atskill_t9_descParm4")
            end
            args = {args1, (scfg.value[lv] or 0) * 100}
            colorTb = {nil, G_ColorGreen, nil, (colorCfg[scfg.quality] or G_ColorGreen), nil}
        end
        desc = getlocal("atskill_t" .. scfg.type .. "_desc", args)
    elseif scfg.type == 5 or scfg.type == 7 then
        local args = {}
        if scfg.type == 5 then
            args = {(scfg.value[lv] or 0) * 100}
            colorTb = {nil, (colorCfg[scfg.quality] or G_ColorGreen), nil}
        elseif scfg.type == 7 then
            args = {scfg.parm2, (scfg.value[lv] or 0) * 100}
            colorTb = {nil, G_ColorGreen, nil, (colorCfg[scfg.quality] or G_ColorGreen), nil}
        end
        desc = getlocal("atskill_t" .. scfg.type .. "_parm" .. scfg.parm1 .. "_desc", args)
    end
    nameStr = getlocal("atskill_name_" .. scfg.grade)
    return nameStr, desc, colorTb
end

--获取技能洗练信息的描述
--@id: 部队ID
--@showType: 1：最低等级技能效果,2：最高等级技能效果
--@return { descStr, colorTb }
function AITroopsVoApi:getSkillWashInfoDesc(id, showType)
    local stype = showType or 1
    local valueColor = G_ColorGreen
    if stype == 1 then
        valueColor = G_ColorYellowPro
    end
    local descTb = {}
    local aiTroopsCfg = self:getModelCfg()
    local acfg = aiTroopsCfg.aitroopType[id]
    if acfg and acfg.skill3 then
        local skill2Id = acfg.skill2[1]
        local skill2Cfg = aiTroopsCfg.skill[skill2Id]
        if skill2Cfg and skill2Cfg.type then
            local refineRule = aiTroopsCfg.refineRule[skill2Cfg.type]
            if type(refineRule) == "table" then
                for k, v in pairs(refineRule) do
                    local skill3TypeDes = aiTroopsCfg.skill3TypeDes[v]
                    if type(skill3TypeDes) == "table" then
                        if v == 6 then
                            local tempDesc = {
                                getlocal("aitroops_skillWashInfo_t6_desc", {skill3TypeDes[stype][1]}),
                            {nil, valueColor, nil}}
                            table.insert(descTb, tempDesc)
                        else
                            local sn = 2
                            if v == 9 then
                                sn = 4
                            elseif v == 10 then
                                sn = 1
                            end
                            for i = 1, sn do
                                local colorTb = {}
                                if v == 4 or v == 10 then
                                    colorTb = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, valueColor, nil, valueColor, nil}
                                elseif v == 5 or v == 9 then
                                    colorTb = {nil, G_ColorYellowPro, nil, valueColor, nil, valueColor, nil}
                                end
                                if v ~= 7 and v ~= 9 then
                                    local tempDesc = {
                                        getlocal("aitroops_skillWashInfo_t" .. v .. "_desc" .. i, {skill3TypeDes[stype][1] * 100, skill3TypeDes[stype][2] * 100}),
                                        colorTb
                                    }
                                    table.insert(descTb, tempDesc)
                                elseif v == 9 then
                                    local tempDesc = {
                                        getlocal("aitroops_skillWashInfo_t" .. v .. "_desc", {getlocal("atskill_t9_descParm" .. i), skill3TypeDes[stype][1] * 100, skill3TypeDes[stype][2] * 100}),
                                        colorTb
                                    }
                                    table.insert(descTb, tempDesc)
                                end
                            end
                            if v == 7 then
                                local colorTb = {nil, G_ColorYellowPro, nil, valueColor, nil, valueColor, nil}
                                for sk, sv in pairs(skill3TypeDes) do
                                    for kk=1,2 do
                                        local tempDesc = {
                                            getlocal("aitroops_skillWashInfo_t" .. v .. "_desc" .. kk, {sk, sv[kk][stype][1] * 100, sv[kk][stype][2] * 100}),
                                            colorTb
                                        }
                                        table.insert(descTb, tempDesc)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return descTb
end

--@检测部队绑定的指定技能是否可以升级
--@skill：技能数据 troopsVo：部队数据 upgradeType：升级方式（1：消耗经验道具，2：消耗部队碎片）
--@1：可以升级 2：技能已到最高等级 3：部队等级限制 4：升级消耗不够 5：经验已满但部队等级有限制不能升级
function AITroopsVoApi:checkSkillUpgrade(skill, troopsVo, upgradeType)
    if skill == nil or troopsVo == nil then
        do return 0 end
    end
    local aiTroopsCfg = self:getModelCfg()
    local sid = skill.sid
    local scfg = aiTroopsCfg.skill[sid]
    if scfg then
        if skill.lv >= scfg.lvMax then
            return 2
        end
        if scfg.trooplv[skill.lv] > troopsVo.lv then --部队等级不够
            return 3, scfg.trooplv[skill.lv]
        end
        local maxLv, nextExp, needTroopLv = self:getSkillInfo(skill.sid, skill.lv)
        if skill.exp >= nextExp then --经验满了，但由于部队等级限制没有升级
            local needTroopLv = scfg.trooplv[skill.lv + 1]
            if troopsVo.lv < needTroopLv then
                return 5, needTroopLv
            end
        end
        if upgradeType then
            local num = 0
            local cost = AITroopsVoApi:getTroopsSkillUpgradeCost(upgradeType)
            if upgradeType == 1 then --消耗经验道具
                num = self:getPropNumById("p1")
            elseif upgradeType == 2 then --消耗碎片
                num = self:getTroopsFragment(troopsVo.id)
            end
            if cost > num then
                return 4, num, cost
            end
        else
            local cost1 = AITroopsVoApi:getTroopsSkillUpgradeCost(1)
            local cost2 = AITroopsVoApi:getTroopsSkillUpgradeCost(2)
            local num1, num2 = self:getPropNumById("p1"), self:getTroopsFragment(troopsVo.id)
            if cost1 > num1 and cost2 > num2 then
                return 4
            end
        end
        return 1
    end
    return 0
end

function AITroopsVoApi:produceHandler(data, callback, cmd)
    if data == nil then
        do return end
    end
    local ret, sData = base:checkServerData(data)
    if ret == true then
        if sData.data then
            if sData.data.aitroops then
                self:formatData(sData.data.aitroops)
                if sData.data.aitroops.gems then --因生产加速的时候实际金币消耗由后端决定，则需要同步一下
                    playerVoApi:setGems(sData.data.aitroops.gems)
                end
            end
            local arg = nil
            if cmd == "aitroops.aitroops.skilladdexp" or cmd == "aitroops.aitroops.addexp" then
                if sData.data.aitroops and sData.data.aitroops.rate then
                    arg = {expRate = sData.data.aitroops.rate}
                end
            end
            local rd = {rtype = 1}
            if sData.data.aitroopsr then --产出或者返还部队
                if sData.data.aitroopsr.br and (sData.data.troops == nil or sData.data.troops.troops == nil) then --被打断返回坦克，如果没有同步坦克数据的话，需要前端更新坦克数据
                    local rewardList = FormatItem(sData.data.aitroopsr.br)
                    if rewardList then
                        for k, v in pairs(rewardList) do
                            if v.type == "o" then
                                tankVoApi:addTank(v.id, v.num)
                            end
                        end
                        portScene:initTanks()
                    end
                end
                if rd == nil then
                    rd = {}
                end
                rd.pr, rd.br = sData.data.aitroopsr.pr, sData.data.aitroopsr.br
                if cmd == "aitroops.aitroops.cancel" then --取消生产队列
                    rd.cr, rd.br = sData.data.aitroopsr.br, nil
                elseif cmd == "aitroops.aitroops.get" then
                    if rd.pr then --正常产出
                        if callback then
                            callback(function()
                                eventDispatcher:dispatchEvent("aitroops.produce.refresh", rd)
                            end)
                        end
                        do return end
                    elseif rd.br then --生产被玩家打断
                        if callback then
                            callback()
                            rd.rtype = 2
                            eventDispatcher:dispatchEvent("aitroops.produce.refresh", rd)
                        end
                        do return end
                    end
                end
            end
            if callback then
                callback(arg)
            end
            if cmd == "aitroops.aitroops.reset" or cmd == "aitroops.aitroops.produce" or cmd == "aitroops.aitroops.speedup" or cmd == "aitroops.aitroops.cancel" then
                eventDispatcher:dispatchEvent("aitroops.produce.refresh", rd)
            end
        end
    end
end

--重置生产部队坦克消耗类型
function AITroopsVoApi:resetProduceCost(quality, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.reset")
    end
    socketHelper:AITroopsProduceCostReset(quality, handler)
end

function AITroopsVoApi:AITroopsGet(check, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.get")
    end
    socketHelper:AITroopsGet(check, handler)
end

--生产部队
function AITroopsVoApi:AITroopsProduce(quality, double, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.produce")
        if tonumber(double) == 1 then --双倍生产直接完成则需要刷新部队列表
            self:setListRefreshFlag(true)
        end
    end
    socketHelper:AITroopsProduce(quality, double, handler)
end

--部队生产加速
function AITroopsVoApi:AITroopsProduceSpeedup(qid, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.speedup")
        self:setListRefreshFlag(true)
    end
    socketHelper:AITroopsProduceSpeedup(qid, handler)
end

--部队生产取消
function AITroopsVoApi:AITroopsProduceCancel(qid, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.cancel")
    end
    socketHelper:AITroopsProduceCancel(qid, handler)
end

--部队进阶
function AITroopsVoApi:AITroopsAdvanced(id, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback)
        eventDispatcher:dispatchEvent("aitroops.list.refresh", {atid = id, isAdvanced = 1})
    end
    socketHelper:AITroopsAdvanced(id, handler)
end

--判断是否可以进阶
--return 1：可以进阶，2：已升到最大阶，3：升级所需部队等级不够，4：碎片数不够
function AITroopsVoApi:isAITroopsCanAdvance(troopsVo)
    local aiTroopsCfg = self:getModelCfg()
    local maxGrade = SizeOfTable(aiTroopsCfg.needTroopsLv)
    if troopsVo.grade >= maxGrade then
        return 2
    end
    local grade = troopsVo.grade + 1
    grade = grade >= maxGrade and maxGrade or grade
    local needLv = aiTroopsCfg.needTroopsLv[grade]
    if troopsVo.lv < needLv then --升阶所需部队等级不够
        return 3, needLv
    end
    local fragment = self:getTroopsFragment(troopsVo.id)
    local costItem = self:getTroopsAdvancedCost(troopsVo.id, grade - 1)
    if fragment < costItem.num then
        return 4, costItem.num
    end
    return 1, costItem.num
end

--部队升级
function AITroopsVoApi:AITroopsUpgrade(id, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.addexp")
        eventDispatcher:dispatchEvent("aitroops.list.refresh", {atid = id})
    end
    socketHelper:AITroopsUpgrade(id, handler)
end

--部队升级消耗
function AITroopsVoApi:getTroopsUpgradeCost()
    local aiTroopsCfg = self:getModelCfg()
    local dayInfo = self:getDayInfo()
    local base, rate, max = aiTroopsCfg.troopExtraCost[1], aiTroopsCfg.troopExtraCost[2], aiTroopsCfg.troopExtraCost[3]
    local num = (dayInfo.day_upnum > max) and max or dayInfo.day_upnum
    
    local cost = base + (rate * num)
    
    return cost
end

--判断部队是否可以升级
--return 1：可以升级 2：部队等级已达上限 3：升级消耗不足
function AITroopsVoApi:isAITroopsCanUpgrade(troopsVo)
    local aiTroopsCfg = self:getModelCfg()
    local maxLv = AITroopsVoApi:getTroopsMaxLvById(troopsVo.id)
    if troopsVo.lv >= maxLv then --部队等级已达上限
        return 2
    end
    local costPropId = aiTroopsCfg.expCostId
    local cost = self:getTroopsUpgradeCost()
    local num = self:getPropNumById(costPropId)
    if cost > num then
        return 3, cost
    end
    return 1, cost
end

--部队升级
--aid：部队id，index：第几个技能，ctype：消耗类型（1.经验道具，2.ai部队碎片）
function AITroopsVoApi:AITroopsSkillUpgrade(aid, index, ctype, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback, "aitroops.aitroops.skilladdexp")
        if ctype == 2 then
            eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 1})
        end
    end
    socketHelper:AITroopsSkillUpgrade(aid, index, ctype, handler)
end

--部队技能升级消耗
--upgradeType：升级方式   1：经验道具升级 2：碎片升级
function AITroopsVoApi:getTroopsSkillUpgradeCost(upgradeType)
    local cost = 0
    local aiTroopsCfg = self:getModelCfg()
    local dayInfo = self:getDayInfo()
    if upgradeType == 1 then --经验道具升级
        local base, rate, max = aiTroopsCfg.skillExtraCost[1], aiTroopsCfg.skillExtraCost[2], aiTroopsCfg.skillExtraCost[3]
        local num = (dayInfo.day_supnum > max) and max or dayInfo.day_supnum
        cost = base + (rate * num)
    elseif upgradeType == 2 then --碎片升级
        local base, rate, max = aiTroopsCfg.skillExtraCostFragment[1], aiTroopsCfg.skillExtraCostFragment[2], aiTroopsCfg.skillExtraCostFragment[3]
        local num = (dayInfo.day_supnum > max) and max or dayInfo.day_supnum
        cost = base + (rate * num)
    end
    
    return cost
end

--部队技能洗练消耗
function AITroopsVoApi:getSkillRefreshCost()
    local aiTroopsCfg = self:getModelCfg()
    local dayInfo = self:getDayInfo()
    local base, rate, max = aiTroopsCfg.skillChangeCost[1], aiTroopsCfg.skillChangeCost[2], aiTroopsCfg.skillChangeCost[3]
    local num = (dayInfo.day_snum > max) and max or dayInfo.day_snum
    
    local cost = base + (rate * num)
    
    return cost
end

function AITroopsVoApi:getAITroopsNameStr(id)
    local nameStr, color = getlocal("aitroops_troop_name_" .. id), G_ColorWhite
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.aitroopType[id] then
        local quality = aiTroopsCfg.aitroopType[id].quality
        if quality == 1 then
            color = G_ColorGreen
        elseif quality == 2 then
            color = G_ColorBlue
        elseif quality == 3 then
            color = G_ColorPurple
        end
    end
    return nameStr, color
end

function AITroopsVoApi:getAITroopsPic(id)
    local aitPic, aitTypePic
    local aiTroopsCfg = self:getModelCfg()
    local acfg = aiTroopsCfg.aitroopType[id]
    local sid = acfg.skill2[1]
    if sid and aiTroopsCfg.skill[sid] then
        local scfg = aiTroopsCfg.skill[sid]
        if scfg.type == 1 then --加基础属性
            aitTypePic = "ait_" .. scfg.attType[1] .. ".png"
        elseif scfg.type == 2 then --护盾类
            if scfg.enemyTargetType == 3 then
                aitTypePic = "ait_shield1.png"
            elseif scfg.enemyTargetType == 12 then
                aitTypePic = "ait_shield2.png"
            end
        elseif scfg.type == 3 then --攻击类
            if scfg.enemyTargetType == 3 then
                aitTypePic = "ait_attack1.png"
            else
                aitTypePic = "ait_attack2.png"
            end
        elseif scfg.type == 8 then --克制AI
            aitTypePic = "ait_restrain.png"
        end
    end
    if acfg and acfg.btPic then
        aitPic = acfg.btPic .. "_1.png"
    end
    
    return aitPic, aitTypePic
end

--设置AI部队图标特效
--@iconType: 1:小图标, 2:大图标
function AITroopsVoApi:setAITroopsIconEffect(icon, aitPic, iconType, aitroopsQuality, aitroopsGrade)
    if type(aitroopsGrade) ~= "number" then
        do return end
    end
    if aitroopsGrade >= 2 then
        local circleNode = icon:getParent():getChildByTag(-33333)
        if circleNode and tolua.cast(circleNode, "CCNode") then
            circleNode:removeFromParentAndCleanup(true)
            circleNode = nil
        end
        -- 底盘旋转
        local circleSp = CCSprite:createWithSpriteFrameName("aitroops_iconEffect_quality" .. aitroopsQuality .. ".png")
        G_setBlendFunc(circleSp, GL_ONE, GL_ONE)
        local circleNode = CCNode:create()
        circleNode:setContentSize(circleSp:getContentSize())
        if iconType == 1 then
            circleNode:setScale((icon:getParent():getContentSize().width - 6) / circleNode:getContentSize().width)
        elseif iconType == 2 then
            circleNode:setScale(0.7)
        end
        circleNode:setScaleY((circleNode:getContentSize().width * circleNode:getScaleX() / 2) / circleNode:getContentSize().height)
        circleNode:setPosition(ccp(icon:getPositionX(), icon:getPositionY() - 18))
        circleNode:setTag(-33333)
        icon:getParent():addChild(circleNode)
        circleNode:addChild(circleSp)
        circleSp:runAction(CCRepeatForever:create(CCRotateBy:create(2, 360)))
    end
    if aitroopsGrade >= 3 then
        local iconEffectSp = icon:getParent():getChildByTag(-44444)
        if iconEffectSp and tolua.cast(iconEffectSp, "CCNode") then
            iconEffectSp:removeFromParentAndCleanup(true)
            iconEffectSp = nil
        end
        -- 缩放
        local iconEffectSp = CCSprite:createWithSpriteFrameName(aitPic)
        G_setBlendFunc(iconEffectSp, GL_ONE, GL_ONE)
        local iconScale = icon:getScale()
        iconEffectSp:setScale(iconScale)
        iconEffectSp:setPosition(icon:getPosition())
        iconEffectSp:setOpacity(255 * 0.2)
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(1, iconScale + 0.15))
        arr:addObject(CCSequence:createWithTwoActions(CCFadeTo:create(0.4, 255 * 0.6), CCFadeTo:create(0.6, 0)))
        iconEffectSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCSpawn:create(arr), CCCallFunc:create(function()
            iconEffectSp:setOpacity(255 * 0.2)
            iconEffectSp:setScale(iconScale)
        end))))
        iconEffectSp:setTag(-44444)
        icon:getParent():addChild(iconEffectSp, icon:getZOrder() + 1)
    end
end

--AI部队小图标方式显示
--isFragment：是否是碎片
--notShowAit: true 不显示ait 和动画效果  false/nil 相反
function AITroopsVoApi:getAITroopsSimpleIcon(id, lv, grade, isFragment, callback, iconSize, lvFontSize,notShowAit)
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local aiTroopsCfg = self:getModelCfg()
    local acfg = aiTroopsCfg.aitroopType[id]
    --图标
    local iconBg = LuaCCSprite:createWithSpriteFrameName("aitroopsBg_small" .. acfg.quality .. ".png", touchHandler)
    if iconSize then
        iconBg:setScale(iconSize / iconBg:getContentSize().width)
    end
    local aitPic, aitTypePic = self:getAITroopsPic(id)
    if aitPic then
        local scale = 0.48
        if aitPic == "AIid_2_1.png" then
            scale = 0.42
        end
        local icon = CCSprite:createWithSpriteFrameName(aitPic)
        icon:setPosition(getCenterPoint(iconBg))
        icon:setScale(scale)
        icon:setTag(100)
        iconBg:addChild(icon, 1)
        if not notShowAit then
            self:setAITroopsIconEffect(icon, aitPic, 1, acfg.quality, tonumber(grade))
        end
    end
    if aitTypePic and not notShowAit then
        local aitTypeIconSp = CCSprite:createWithSpriteFrameName(aitTypePic)
        aitTypeIconSp:setPosition(aitTypeIconSp:getContentSize().width / 2 + 5, iconBg:getContentSize().height - aitTypeIconSp:getContentSize().height / 2 - 5)
        iconBg:addChild(aitTypeIconSp, 3)
    end
    
    if isFragment == true then --以部队碎片的形式显示
        local fragmentSp = CCSprite:createWithSpriteFrameName("aitroops_fragment.png")
        fragmentSp:setPosition(iconBg:getContentSize().width - fragmentSp:getContentSize().width / 2, fragmentSp:getContentSize().height / 2)
        iconBg:addChild(fragmentSp, 3)
    elseif lv and tonumber(lv) > 0 then --显示部队等级
        --部队等级
        local levelLb = GetTTFLabel(getlocal("fightLevel", {lv}), lvFontSize or 22)
        levelLb:setAnchorPoint(ccp(1, 0))
        levelLb:setTag(101)
        levelLb:setPosition(iconBg:getContentSize().width - 8, 5)
        iconBg:addChild(levelLb, 3)
    end
    
    return iconBg
end

--AI部队大图标方式显示
--isFragment：是否是碎片
function AITroopsVoApi:getAITroopsIcon(id, isFragment, callback)
    local troopsVo
    if type(id) == "table" then
        troopsVo = id
        id = troopsVo.id
    else
        troopsVo = AITroopsVoApi:getTroopsById(id)
    end
    if troopsVo == nil then
        do return nil end
    end
    local aiTroopsCfg = self:getModelCfg()
    local acfg = aiTroopsCfg.aitroopType[troopsVo.id]
    
    local function touchHandler()
        if callback then
            callback()
        end
    end
    local bgPic, qualityPic = "aitroopbg_" .. acfg.quality .. ".png", "aitroop_quality" .. acfg.quality .. ".png"
    -- print("bgPic,qualityPic--->>", bgPic, qualityPic)
    local iconBg = LuaCCSprite:createWithSpriteFrameName(bgPic, touchHandler)
    local aitQualityBg = CCSprite:createWithSpriteFrameName(qualityPic)
    aitQualityBg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
    iconBg:addChild(aitQualityBg)
    
    local aitPic, aitTypePic = AITroopsVoApi:getAITroopsPic(id)
    --图标
    if aitPic then
        local icon = CCSprite:createWithSpriteFrameName(aitPic)
        icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        icon:setScale(0.6)
        icon:setTag(101)
        iconBg:addChild(icon, 2)
        self:setAITroopsIconEffect(icon, aitPic, 2, acfg.quality, troopsVo.grade)
    end
    
    if aitTypePic then
        local aitTypeIconSp = CCSprite:createWithSpriteFrameName(aitTypePic)
        aitTypeIconSp:setPosition(20 + aitTypeIconSp:getContentSize().width / 2, iconBg:getContentSize().height - aitTypeIconSp:getContentSize().height / 2 - 70)
        iconBg:addChild(aitTypeIconSp, 3)
    end
    
    --部队名称
    local nameStr, color = AITroopsVoApi:getAITroopsNameStr(id)
    local nameLb = GetTTFLabelWrap(nameStr, 22, CCSize(iconBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    nameLb:setAnchorPoint(ccp(0.5, 0))
    nameLb:setColor(color)
    nameLb:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height - 45)
    iconBg:addChild(nameLb)
    --部队等级
    local levelLb = GetTTFLabel(getlocal("fightLevel", {troopsVo.lv}), 22)
    levelLb:setPosition(iconBg:getContentSize().width / 2, 60)
    levelLb:setTag(102)
    iconBg:addChild(levelLb)
    
    --部队强度
    local strength = troopsVo:getTroopsStrength()
    local strengthLb = GetTTFLabel(getlocal("emblem_infoStrong", {strength}), 20)
    strengthLb:setPosition(iconBg:getContentSize().width / 2, 25)
    strengthLb:setTag(103)
    iconBg:addChild(strengthLb)
    
    return iconBg
end

--获取指定道具个数
function AITroopsVoApi:getPropNumById(pid)
    if self.AITroopsInfo and self.AITroopsInfo.prop then
        return self.AITroopsInfo.prop[pid] or 0
    end
    return 0
end

--部队碎片兑换经验道具
function AITroopsVoApi:fragmentExchange(fid, num, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback)
        eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 1})
    end
    socketHelper:AITroopsFragmentExchange(fid, num, handler)
end

function AITroopsVoApi:setListRefreshFlag(flag)
    self.listRefreshFlag = flag
end

function AITroopsVoApi:getListRefreshFlag()
    return self.listRefreshFlag
end

--部队技能刷新
function AITroopsVoApi:AITroopsSkillRefresh(aid, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback)
    end
    socketHelper:AITroopsSkillRefresh(aid, handler)
end

--部队技能替换
function AITroopsVoApi:AITroopsSkillExchange(aid, callback)
    local function handler(fn, data)
        self:produceHandler(data, callback)
        eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 3})
        eventDispatcher:dispatchEvent("aitroops.list.refresh", {atid = aid})
    end
    socketHelper:AITroopsSkillExchange(aid, handler)
end

function AITroopsVoApi:showAITroopsDialog(layerNum)
    local flag, openLv = self:isOpen()
    if flag ~= 1 then
        local unlockStr = ""
        if flag == 0 then
            unlockStr = getlocal("backstage17000")
        elseif flag == -1 then
            unlockStr = getlocal("equip_explore_unlock", {openLv})
        end
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), unlockStr, 28)
        do return end
    end
    local function realShow()
        require "luascript/script/game/scene/gamedialog/AITroops/AITroopsDialog"
        local td = AITroopsDialog:new()
        local tbArr = {getlocal("aitroops_tab1"), getlocal("aitroops_tab2")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("aitroops_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    self:AITroopsGet(0, realShow)
end

--显示AI部队详情页面
function AITroopsVoApi:showTroopsDetailDialog(troopsVo, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsDetailDialog"
    local td = AITroopsDetailDialog:new(troopsVo)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("fleet_slot_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--显示AI部队信息页面
function AITroopsVoApi:showTroopsInfoDialog(troopsVo, isCheck, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsInfoDialog"
    AITroopsInfoDialog:showTroopsInfoDialog(troopsVo, isCheck, layerNum)
end

--生产部队二次确认弹窗
function AITroopsVoApi:showProduceConfirmDialog(produceType, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSmallDialog"
    AITroopsSmallDialog:showProduceConfirmDialog(produceType, layerNum)
end

function AITroopsVoApi:showRewardDialog(rewardList, titleStr, tipContent, confirmStr, confirmCallBack, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSmallDialog"
    AITroopsSmallDialog:showRewardDialog(rewardList, titleStr, tipContent, confirmStr, confirmCallBack, layerNum)
end

--技能提升页面
function AITroopsVoApi:showSkillUpgradeDialog(id, skillPos, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSkillSmallDialog"
    AITroopsSkillSmallDialog:showUpgradeDialog(id, skillPos, layerNum)
end

--技能洗练页面
function AITroopsVoApi:showSkillExchangeDialog(id, skillPos, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSkillSmallDialog"
    AITroopsSkillSmallDialog:showExchangeDialog(id, skillPos, layerNum)
end

--特殊技能洗练信息页面
function AITroopsVoApi:showSkillWashInfoDialog(id, showType, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSkillSmallDialog"
    AITroopsSkillSmallDialog:showSkillWashInfoDialog(id, getlocal("aitroops_skill_wash"), showType, layerNum)
end

--碎片兑换页面
function AITroopsVoApi:showFragmentExchangeDialog(exchangeType, fromItem, targetItem, exchangeRate, confirmCallBack, layerNum)
    if fromItem == nil or targetItem == nil then
        do return end
    end
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSmallDialog"
    AITroopsSmallDialog:showExchangeDialog(exchangeType, fromItem, targetItem, exchangeRate, confirmCallBack, layerNum)
end

--生产池
function AITroopsVoApi:showProducePoolDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsPoolDialog"
    AITroopsPoolDialog:showPoolDialog(layerNum)
end

--替换技能返还面板
function AITroopsVoApi:showSkillExchangeConfirmDialog(exchangeSkill, confirmCallBack, layerNum)
    require "luascript/script/game/scene/gamedialog/AITroops/AITroopsSmallDialog"
    AITroopsSmallDialog:showSkillExchangeConfirmDialog(exchangeSkill, confirmCallBack, layerNum)
end

--判断一个技能生效的坦克类型
function AITroopsVoApi:checkSkillEffectTankType(sid, stype)
    local tankTb, tankType = {}, nil
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.skill[sid] then
        if stype == 2 or stype == 3 then --技能类型为2或者3的话都是对敌方生效，所以生效坦克类型取enemyTargetType
            tankType = aiTroopsCfg.skill[sid].enemyTargetType
        else
            tankType = aiTroopsCfg.skill[sid].tankType
        end
        local tb = {1, 2, 4, 8}
        for k, v in pairs(tb) do
            if G_BitwiseAND(tankType, v) == v then
                table.insert(tankTb, v)
            end
        end
    end
    return tankTb, tankType
end

function AITroopsVoApi:isProduceLimit()
    local dayInfo = self:getDayInfo()
    local dayProduceNum = 0
    if dayInfo and dayInfo.day_pnum then
        dayProduceNum = dayInfo.day_pnum
    end
    local aiTroopsCfg = self:getModelCfg()
    if dayProduceNum >= aiTroopsCfg.dailyProduceLimitNum then
        return true
    end
    return false
end

--获取当日生产次数
function AITroopsVoApi:getDaydpnum()
    local dayInfo = self:getDayInfo()
    local dayProduceNum = 0
    if dayInfo and dayInfo.day_pnum then
        dayProduceNum = dayInfo.day_pnum
    end
    local aiTroopsCfg = self:getModelCfg()
    local maxDpnum = aiTroopsCfg.dailyProduceLimitNum
    return dayProduceNum, maxDpnum
end

function AITroopsVoApi:getTroopsAddExpByRate(rate)
    local aiTroopsCfg = self:getModelCfg()
    return aiTroopsCfg.troopBasicExp * (rate or 1)
end

function AITroopsVoApi:getSkillAddExpByRate(rate)
    local aiTroopsCfg = self:getModelCfg()
    return aiTroopsCfg.skillExpBasicExp * (rate or 1)
end

--根据部队id来获取其绑定的可以刷新的第三个技能库
function AITroopsVoApi:getExchangeSkillPoolById(atid)
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.aitroopType[atid] then
        --绑定的第二个技能的id
        local sid = aiTroopsCfg.aitroopType[atid].skill2[1]
        if aiTroopsCfg.skill[sid] then
            local stype = aiTroopsCfg.skill[sid].type
            return aiTroopsCfg.refineRule[tonumber(stype)] or {}
        end
    end
    return {}
end

--获取一个部队是否有第三个技能
function AITroopsVoApi:isHasSkill3(atid)
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.aitroopType[atid] and aiTroopsCfg.aitroopType[atid].skill3 then
        return true
    end
    return false
end

--替换技能返还的经验道具个数
--lv：被替换技能的等级
function AITroopsVoApi:getExchangeSkillReturnExpPropNum(lv)
    local aiTroopsCfg = self:getModelCfg()
    if aiTroopsCfg.changeSkillReturnExpItem[lv] then
        return aiTroopsCfg.changeSkillReturnExpItem[lv]
    end
    return 0
end

--判断AI部队是否已存在
function AITroopsVoApi:isExist(aitroopId)
    if self.troopsList and self.troopsList[aitroopId] then
        return true
    end
    return false
end

--添加IA部队(该方法仅用于在AI部队功能以外的地方使用，因为没有处理重复添加转换碎片的逻辑)
function AITroopsVoApi:addAITroopById(aitroopId)
    if aitroopId == nil then
        return
    end
    if self.troopsList and self.troopsList[aitroopId] then
        return --该部队已存在，不能重复获得
    end
    if self.troopsList == nil or self.troopsIds == nil then --这俩表要保证一定是成对添加/删除的
        self.troopsList, self.troopsIds = {}, {}
    end
    local aiTroopsCfg = AITroopsVoApi:getModelCfg()
    local cfgData = aiTroopsCfg.aitroopType[aitroopId]
    if cfgData then
        local vo = AITroopsVo:new()
        local skillData = {}
        for i = 1, 3 do --@目前配置最大技能个数为3，后续如果再增加技能，需要再做修改该值
            local sid
            if cfgData["skill" .. i] then
                sid = cfgData["skill" .. i][1]
            end
            if sid then
                table.insert(skillData, {
                    sid, --技能id
                    1,   --技能等级
                    0,   --技能当前等级经验
                })
            end
        end
        local v = {
            1,         --部队等级
            0,         --部队当前等级经验
            1,         --部队阶级
            skillData, --部队绑定的技能列表
        }
        vo:init(aitroopId, v)
        self.troopsList[aitroopId] = vo
        table.insert(self.troopsIds, aitroopId)
        self:sortTroopsList()
    end
end

function AITroopsVoApi:clear()
    self.troopsList = {}
    self.troopsIds = {}
    self.AITroopsInfo = nil
    self.listRefreshFlag = nil
end
