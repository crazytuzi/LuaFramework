airShipVoApi = {
    bid = 52,
    btype = 18,
}

function airShipVoApi:isOpen()
    return base.airShipSwitch == 1
end

--获取开启等级
function airShipVoApi:getOpenLv()
    local cfg = self:getAirShipCfg()
    return cfg.Lv
end

--飞艇总数
function airShipVoApi:getShipNum()
    return SizeOfTable(self:getAirShipCfg().airship)
end
--获取配置
function airShipVoApi:getAirShipCfg()
    if self.airShipCfg == nil then
        self.airShipCfg = G_requireLua("config/gameconfig/airShipCfg")
    end
    return self.airShipCfg
end

function airShipVoApi:isCanEnter(isShowTips)
    if self:isOpen() == false then
        if isShowTips then
            G_showTipsDialog(getlocal("backstage180"))
        end
        return false
    end
    local openLv = self:getOpenLv()
    if playerVoApi:getPlayerLevel() < openLv then
        if isShowTips then
            G_showTipsDialog(getlocal("elite_challenge_unlock_level", {openLv}))
        end
        return false
    end
    return true
end

--主入口界面(战略中心)
function airShipVoApi:showMainDialog(layerNum)
    if self:isCanEnter(true) then
        airShipVoApi:requestInit(function()
            require "luascript/script/game/scene/gamedialog/airShipDialog/airShipDialog"
            local td = airShipDialog:new(layerNum)
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("airShip_text"), true, layerNum)
            sceneGame:addChild(dialog, layerNum)
        end)
    end
end
--升级界面 入口
function airShipVoApi:greatUpGradeDialog(layerNum)
    local bid = self.bid
    local lvl = buildingVoApi:getBuildiingVoByBId(bid).level
    local td = homeBuildUpgradeDialog:new(bid)
    
    local tbArr = {getlocal("building")}
    local bName = getlocal(buildingCfg[self.btype].buildName)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..lvl..")", true, layerNum)
    sceneGame:addChild(dialog, layerNum)
    table.insert(G_CheckMem, td)
end

----tag 1 :仓库  2:排名  3:抽奖奖励库 4 飞艇入口
function airShipVoApi:gotoOtherpanel(layerNum, tag, parent)
    local td = nil
    local panelStr = getlocal("airShip_entryStr"..tag)
    if tag == 1 then
        require "luascript/script/game/scene/gamedialog/airShipDialog/airShipWarehouse"
        td = airShipWarehouse:new(layerNum)
    elseif tag == 2 then
        -- require "luascript/script/game/scene/gamedialog/airShipDialog/airShipRank"
        -- td = airShipRank:new(layerNum)
        local needTb = {"airShipLastDayRank", getlocal("activity_znkh2018_tab2_title2")}
        G_showCustomizeSmallDialog(layerNum + 1, needTb)
    elseif tag == 3 then
        require "luascript/script/game/scene/gamedialog/airShipDialog/airShipSmallDialog"
        airShipSmallDialog:showPropPoolDialog(layerNum)
    elseif tag == 4 then--airShipInfoDialog
        require "luascript/script/game/scene/gamedialog/airShipDialog/airShipInfoDialog"
        G_addResource8888(function()
            -- G_addingOrRemovingAirShipImage(true, true)
            spriteController:addPlist("public/airShipImage3.plist")
            spriteController:addTexture("public/airShipImage3.png")
            spriteController:addPlist("public/airShipImage6.plist")
            spriteController:addTexture("public/airShipImage6.png")
            spriteController:addPlist("public/airShipImage7.plist")
            spriteController:addTexture("public/airShipImage7.png")
        end)
        td = airShipInfoDialog:new(layerNum, parent)
        panelStr = getlocal("airShip_text")
    end
    if td == nil then
        do return end
    end
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, panelStr, true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function airShipVoApi:clear()
    self.lastDayRankInfo = {}
    self.lastDayAllRankInfo = {}
    self.hadLastDayRankAward = nil
    self.curAirshipId = nil
    self.chgNameTs = 0
    self.lotteryTb = {}
    self.specialNum = 0
    self.partsTb = {}
    self.airShipEquipPartsTb = {}
    self.airShipInfo = {}
    self.bossAttackNum = 0
    self.buyAttackNum = 0
    self.lastBuyTs = 0
    self.recoverTimer = nil
    self.lotteryUpType = nil
    self.outputTimeStrTb = nil
    self.strengthTb = nil
    self.tipInitFlag = nil
    self.redTipTb = nil
    self.battleAirship = nil
    self.tempAirshipId = nil
    self.attackAirships = nil
    if self == nil then
        do return end
    end
end
function airShipVoApi:initData(airShipAllData, params)
    local data = airShipAllData.airship or nil
    if data then
        
        --飞艇改名时间戳
        self.chgNameTs = data.rentime or self.chgNameTs or 0
        --抽奖信息
        self.lotteryTb = data.lottery or self.lotteryTb or {}
        --处理跨天抽奖数据
        if self.lotteryTb[2] > 0 and G_isToday(self.lotteryTb[2]) == false then
            self:resetLottery()
        end
        --特殊奖励 可领次数
        self.specialNum = data.special or self.specialNum or 0
        --材料相关数据
        self.partsTb = data.resource or self.partsTb or {}
        
        --哪两种飞艇抽出的零件的概率提高
        self.lotteryUpType = data.gup or self.lotteryUpType or nil
        
        --昨日排行信息
        self.lastDayAllRankInfo = data.shiprank and data.shiprank[1] or self.lastDayAllRankInfo or {}
        --自己昨日排行奖励
        self.lastDayRankInfo = data.shiprank and data.shiprank[2] or self.lastDayRankInfo or {}
        --昨日排行奖励标示
        self.hadLastDayRankAward = data.awardts and data.awardts[1] or self.hadLastDayRankAward or nil
        
        ---boss 类型 用于取昨日boss 1:昨日boss类型，2:当日boss类型
        self.bossTypeTb = data.boss or self.bossTypeTb
        --当前仓库内的所有零件 数据表
        self.airShipEquipPartsTb = data.props or self.airShipEquipTb or {}
        
        --每一种飞艇 所需数据 目前有：飞艇名称，装置激活几个，装置品质，飞艇战术
        self.airShipInfo = data.info or self.airShipInfo or {}
        
        if data.stats then
            self:syncStatus(data.stats) --飞艇的出站状态
        end
        if data.attnum then
            self.bossAttackNum = data.attnum --可用进攻次数
        end
        if data.buynum then
            self.buyAttackNum = data.buynum --已购买次数
        end
        if data.attnumts then
            self.recoverTimer = data.attnumts --进攻次数恢复时间
        end
        if data.buyts then
            self.lastBuyTs = data.buyts --上次购买进攻次数时的时间戳
        end
        
        if params and params.rfStrength == true then --是否刷新强度
            if params.rfAirshipId then
                self:refreshStrength(params.rfAirshipId)
                airShipVoApi:saveTip(2, {aid = params.rfAirshipId}) --保存红点提示数据
                eventDispatcher:dispatchEvent("airship.strength.refresh", {aid = params.rfAirshipId})
            else
                for k, v in pairs(airShipVoApi:getAirShipCfg().airship) do
                    self:refreshStrength(k)
                end
            end
        end
        
        if self.tipInitFlag ~= true then
            for k = 1, 4 do
                self:saveTip(k) --更新一下红点数据
            end
            self.tipInitFlag = true
        end
    end
end

--当前基地需要展示的飞艇
function airShipVoApi:getCurShowAirShip()
    if not self.curAirshipId then
        local dataKey = "airshipId@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
        self.curAirshipId = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if self.curAirshipId == "" then
            self.curAirshipId = "a1"
        end
    end
    return tonumber(Split(self.curAirshipId, "a")[2])--返回ID：1、2、3、4...
end

function airShipVoApi:setCurShowAirShip(airshipId)
    self.curAirshipId = "a"..airshipId
    local dataKey = "airshipId@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey, self.curAirshipId)
    CCUserDefault:sharedUserDefault():flush()
    
    G_showTipsDialog(getlocal("airShip_changeCurShipTip"))
end

--材料相关数据处理 1 仓库内材料数量 2 进度条收取时间
function airShipVoApi:formatPartsTb()
    if self.partsTb and next(self.partsTb) then-- 1 仓库内的材料数量，2 当前未领取的材料数量 3 最近一次升级的时间戳，用于计算到当前为止的未领取材料数量
        return self.partsTb[1] or 0, self.partsTb[2] or 0, self.partsTb[3]
    end
    return 0, 0, 0
end
--当日可抽奖的剩余次数
function airShipVoApi:getLastRewardNum()
    local curAwardNum = self:getCurlotteryNum()
    local topNum = self:getAirShipCfg().gNum1
    local lastNum = topNum - curAwardNum
    if lastNum >= 0 then
        return lastNum
    end
    return 0
end

--抽奖相关数据：1 已抽奖次数 2 最近一次抽奖时间
function airShipVoApi:getCurlotteryNum()
    if self.lotteryTb and next(self.lotteryTb) then--1 当天抽奖次数 2 最近一次抽奖时间 3 特定奖励次数， 4 资源次数
        return self.lotteryTb[1], self.lotteryTb[2], self.lotteryTb[3], self.lotteryTb[4]
    end
    return 0, 0, 0, 0
end

--跨天重置抽奖数据
function airShipVoApi:resetLottery()
    self.lotteryTb = {0, base.serverTime, self.lotteryTb[3] or 0, 0}
end

---是否可领特殊奖励
function airShipVoApi:isCanGetSpecAward()
    return self.specialNum and self.specialNum > 0 or false
end

function airShipVoApi:getAnyDataWithCfg(key)
    local airShipCfg = self:getAirShipCfg()
    if key == "gNum" then --必得紫色零件的条件
        return airShipCfg.gNum
    elseif key == "specialNum" then--可领 特殊奖励 数量 (与 cfg 无关)
        return self.specialNum
    end
end

--请求领取特殊奖励
function airShipVoApi:socketGetSpecial(callback)
    local isCanRward = self:isCanGetSpecAward()
    if isCanRward then
        local function socketCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData and sData.data then
                    self:initData(sData.data)
                    
                    if type(callback) == "function" then
                        local reward = {}
                        if sData.data.airship.cReward then
                            for k, v in pairs(sData.data.airship.cReward) do
                                local r = FormatItem(v)[1]
                                table.insert(reward, r)
                            end
                        end
                        callback(reward)
                    end
                    
                    eventDispatcher:dispatchEvent("airship.props.refresh", {props = G_clone(self.airShipEquipPartsTb)})
                end
            end
        end
        socketHelper:airShipSocket(socketCallback, "special")
    else
        G_showTipsDialog(getlocal("airShip_CurNotHasBigAward"))
    end
end

--请求初始化数据接口
function airShipVoApi:requestInit(callback, isRefresh)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data, {rfStrength = true})
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "get")
end

---boss 类型 用于取昨日boss 对应排行榜奖励使用，如果没有昨日boss数据，说明是第一天开功能，取当天boss数据用于展示
function airShipVoApi:getLastDayBossType()
    local bossTypeTb = self.bossTypeTb[1]
    if not next(self.bossTypeTb[1]) then
        bossTypeTb = self.bossTypeTb[2]
    end
    return bossTypeTb
end

function airShipVoApi:getLastDayBossTypeAward(rankIdx, p_bossTypeTb)
    local useAwardTb = {}
    local formatTb = {}
    local bossTypeTb
    if p_bossTypeTb then
        bossTypeTb = p_bossTypeTb
    else
        bossTypeTb = self:getLastDayBossType()
    end
    
    if not bossTypeTb or not next(bossTypeTb) then
        return {}
    end
    
    local bossAwardTb = self:getAirShipCfg().type
    
    for k, v in pairs(bossTypeTb) do
        formatTb[k] = FormatItem(bossAwardTb[v].r)[1]
    end
    
    local rankTb = self:getAirShipCfg().Rank[rankIdx].reward
    
    for k, v in pairs(rankTb) do
        
        if k == "as" then
            if not useAwardTb[k] then
                useAwardTb[k] = {}
            end
            for m, n in pairs(v) do
                if m < 3 then
                    for i, j in pairs(n) do
                        if i == "z998" or i == "z999" then
                            formatTb[m].num = j
                        end
                    end
                else
                    table.insert(useAwardTb[k], n)
                end
            end
        end
    end
    
    local lastAwardTb = FormatItem(useAwardTb)
    
    for k, v in pairs(lastAwardTb) do
        table.insert(formatTb, v)
    end
    
    return formatTb
end

--昨日排行倒计时
function airShipVoApi:getLastDayRankAwardTime()
    return getlocal("activity_shareHappiness_lastTimeTitle") .. "\n"..G_formatActiveDate(G_getWeeTs(base.serverTime) + 86400 - base.serverTime)
end

function airShipVoApi:getLastDayRankFormatAward(idx)
    local rankAwardInfo = self:getAirShipCfg().Rank[idx]
    local rankArea, rankAwardTb = rankAwardInfo.rank, self:getLastDayBossTypeAward(idx)--FormatItem(rankAwardInfo.reward,nil,true)
    return rankArea, rankAwardTb
end
---昨日排行所有数据
function airShipVoApi:getLastDayAllRankInfoInCell(idx)
    local rankInfoTb = {}
    if self.lastDayAllRankInfo then
        local rankArea, rankAwardTb = self:getLastDayRankFormatAward(idx)
        if self.lastDayAllRankInfo[idx] then
            if idx == 1 then
                rankInfoTb = self.lastDayAllRankInfo[idx]
                rankInfoTb[7] = rankArea
                rankInfoTb[8] = rankAwardTb
            else
                rankInfoTb[1] = self.lastDayAllRankInfo[idx]
                rankInfoTb[2] = rankArea
                rankInfoTb[3] = rankAwardTb
            end
        else
            if idx == 1 then
                rankInfoTb[1] = ""
                rankInfoTb[2] = getlocal("ladderRank_noRank")
                rankInfoTb[3] = nil
                rankInfoTb[4] = nil
                rankInfoTb[5] = getlocal("alienMines_unkown")--self:getAirShipCfg().rDmg
                rankInfoTb[6] = nil
                rankInfoTb[7] = rankArea
                rankInfoTb[8] = rankAwardTb
            else
                rankInfoTb[1] = self:getAirShipCfg().rDmg
                rankInfoTb[2] = rankArea
                rankInfoTb[3] = rankAwardTb
            end
        end
    end
    return rankInfoTb
end
--获取自身排名对应的奖励等级
function airShipVoApi:getMyRankAwardIdx(rankIdx)
    
    local rankCfg = self:getAirShipCfg().Rank
    if rankIdx > 0 then
        for k, v in pairs(rankCfg) do
            local rankArea = v.rank
            if k < 4 and rankIdx >= rankArea[1] and rankIdx <= rankArea[2] then
                return k
            elseif k == 4 then
                return k
            end
        end
    end
    return "999+"
end
function airShipVoApi:isHasLastDayRankToGet()
    ---昨日排行数据内 是否有我的
    if self.lastDayRankInfo and next(self.lastDayRankInfo) then
        ---今日 是否已领取 昨日排行奖励
        local rewardIdx = airShipVoApi:getMyRankAwardIdx(self.lastDayRankInfo[1] or 0)
        if tonumber(rewardIdx) then
            self.lastDayRankInfo[3] = rewardIdx
            if self.hadLastDayRankAward == 0 then
                return true, self.lastDayRankInfo, false
            elseif self.hadLastDayRankAward == 1 then
                return false, self.lastDayRankInfo, true
            end
        end
    end
    return false, {}
end

--昨日排行奖励领取接口
function airShipVoApi:socketGetLastDayReward(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                local reward = {}
                if sData.data.shipreward then
                    reward = FormatItem(sData.data.shipreward)
                    for k, v in pairs(reward) do
                        G_addPlayerAward(v.type, v.key, v.id, v.num)
                    end
                end
                if type(callback) == "function" then
                    callback(reward)
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "rankreward")
end

--获取某个飞艇的红点提示数据
function airShipVoApi:getAsTipResult(tip, tipIdx, aid, euqipIdx)
    if tipIdx == 1 then
        return tip[aid] or 0 --飞艇是否解锁
    end
    if tipIdx == 2 then
        local equipTb = tip[aid] or {}
        if euqipIdx then
            return equipTb[euqipIdx] or 0
        else
            for k, v in pairs(equipTb) do
                if v > 0 then --有可以激活的装置
                    return v
                end
            end
            return 0
        end
    end
    return 0
end

--主界面汽包标识 4 排行榜＞ 3 材料＞ 2 可激活改造＞ 1 可解锁
function airShipVoApi:getTip(tipIdx, params)-- 0 没有提示
    if self.redTipTb == nil or type(self.redTipTb) ~= "table" then
        return 0
    end
    local tipTb = self.redTipTb
    if (tipIdx == 1 or tipIdx == 2) then
        local flag = 0
        local airship = self:getAirShipCfg().airship
        local tipInfo = tipTb[tipIdx] or {}
        if params == nil then
            if tipIdx == 1 then
                for k, v in pairs(airship) do
                    flag = self:getAsTipResult(tipInfo, tipIdx, k)
                    if flag > 0 then
                        return flag, {aid = k}
                    end
                end
            else
                for k, v in pairs(airship) do
                    for eIdx, eId in pairs(v.equipId) do
                        flag = self:getAsTipResult(tipInfo, tipIdx, k, eIdx)
                        if flag > 0 then
                            return flag, {aid = k, equipIdx = eId}
                        end
                    end
                end
            end
            return 0
        elseif params.aid then
            if tipIdx == 1 then
                return self:getAsTipResult(tipInfo, tipIdx, params.aid)
            else
                if params.equipIdx then
                    return self:getAsTipResult(tipInfo, tipIdx, params.aid, params.equipIdx)
                else
                    for eIdx, eId in pairs(airship[params.aid].equipId) do
                        flag = self:getAsTipResult(tipInfo, tipIdx, params.aid, eIdx)
                        if flag > 0 then
                            return flag, {aid = params.aid, equipIdx = eId}
                        end
                    end
                end
            end
        end
    else
        return tipTb[tipIdx] or 0
    end
    return 0
end

--保存系统红点提示数据
function airShipVoApi:saveTip(tipIdx, params)
    local tipKey = "airship.redtip@"..playerVoApi:getUid()
    local tipTb = {}
    local str = CCUserDefault:sharedUserDefault():getStringForKey(tipKey)
    if str and str ~= "" then
        tipTb = G_Json.decode(str)
    end
    if tipIdx == 2 and params == nil then --矫正一下存储的装置激活改造的红点提示数据
        tipTb[tipIdx] = {}
        local airship = self:getAirShipCfg().airship
        for k, v in pairs(airship) do
            local asInfo = {}
            local airShipInfo = self:getCurAirShipInfo(k)
            for eIdx, eId in pairs(v.equipId) do
                local isUpgrade = airShipVoApi:getCurAirShipEquipPartsTbWithIdx(k, eIdx)
                asInfo[eIdx] = (isUpgrade == true and 1 or 0)
            end
            tipTb[tipIdx][k] = asInfo
        end
    elseif tipIdx == 1 and params == nil and tipTb[tipIdx] == nil then --初始化一下飞艇解锁的红点提示
        tipTb[tipIdx] = {}
        local flag = 0
        local airship = self:getAirShipCfg().airship
        for k, v in pairs(airship) do
            flag = 0
            if v.lock > 0 and self:isUnlockCurAirShip(k) == true then
                flag = 1
            end
            tipTb[tipIdx][k] = flag --飞艇是否已解锁
        end
    end
    if tipIdx == 4 then
        tipTb[tipIdx] = (self:isHasLastDayRankToGet() == true) and 1 or 0
    elseif tipIdx == 3 then
        tipTb[tipIdx] = (self:getCurUnGetPartsAnyData("isFull") == true) and 1 or 0
    elseif tipIdx == 2 and params and params.aid then
        local airship = self:getAirShipCfg().airship
        local asInfo = tipTb[tipIdx][params.aid]
        for eIdx, eId in pairs(airship[params.aid].equipId) do
            local isUpgrade = airShipVoApi:getCurAirShipEquipPartsTbWithIdx(params.aid, eIdx)
            asInfo[eIdx] = (isUpgrade == true and 1 or 0)
        end
        tipTb[tipIdx][params.aid] = asInfo
    elseif tipIdx == 1 and params and params.aid and params.tipv then
        tipTb[tipIdx][params.aid] = params.aid == 1 and 0 or (params.tipv or 1)
    end
    local str = G_Json.encode(tipTb)
    CCUserDefault:sharedUserDefault():setStringForKey(tipKey, str)
    CCUserDefault:sharedUserDefault():flush()
    self.redTipTb = tipTb
end

--当前空港等级
function airShipVoApi:getBuildingLevel()
    return buildingVoApi and buildingVoApi.allBuildings and buildingVoApi.allBuildings[self.bid] and buildingVoApi.allBuildings[self.bid].level or 1
end

--当天 抽零件概率高的飞艇类型的
function airShipVoApi:getLotteryUpType()
    return self.lotteryUpType or {}
end

--当前建筑 可收取的材料上限
function airShipVoApi:getCurPartsNumTop()
    return self:getAirShipCfg().resourceMax
end

--当前材料产出的总数（非材料仓库）
function airShipVoApi:getCurOutputPartsNum()
    local allParts, curUnGetParts, nearGetPartsTs = self:formatPartsTb()
    local resourceMax = self:getAirShipCfg().resourceMax--可产出的上限
    
    if curUnGetParts >= resourceMax then
        return true, resourceMax, resourceMax, 100
    end
    
    local outputSpeed = 3600 / self:getResourceRecoverSpeedByHour() --产出1点原料需要的时间（单位：秒）
    --outputTime：能产出原料的时间，surTime：产出不足1点原料所消耗的时间，该时间需要回溯不能浪费
    local add = (base.serverTime - nearGetPartsTs) / outputSpeed
    curUnGetParts = math.floor(curUnGetParts + add)
    curUnGetParts = (curUnGetParts > resourceMax) and resourceMax or curUnGetParts --当前未领取的产出总量
    
    return curUnGetParts == resourceMax, curUnGetParts, resourceMax, curUnGetParts / resourceMax * 100
end

function airShipVoApi:getCurUnGetPartsAnyData(key)
    local isFull, curUnGetParts, resourceMax, perNum = self:getCurOutputPartsNum()
    if key == "progress" then
        return perNum, curUnGetParts, resourceMax, isFull
    elseif key == "isFull" then
        return isFull, resourceMax - curUnGetParts == 0 -- 第二个值：可收取的是否为0
    end
end

--收取零件原材料
function airShipVoApi:socketGetParts(callback)
    ------------------------------------ 需要判断 当前是否有可收取的材料
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "collect")
end

--材料仓库的材料总数，以及每小时产量
function airShipVoApi:getTotalPartsNum()
    -- local buildingLv = self:getBuildingLevel()
    local hourOutput = self:getResourceRecoverSpeedByHour() --每小时的产量
    local totalPartsNum = self:formatPartsTb()
    return FormatNumber(totalPartsNum), hourOutput, math.floor(totalPartsNum)
end

--当天下一次抽奖对应需要的材料，
function airShipVoApi:getRewardNextUseParts()
    -- local topNum = self:getAirShipCfg().gNum1
    local nextNum = self.lotteryTb[4] and self.lotteryTb[4] + 1 or 1
    local nextUseParts = self:getAirShipCfg().gCost1[nextNum]
    local singleMaxIndex = SizeOfTable(self:getAirShipCfg().gCost1)
    
    if nextNum < singleMaxIndex then
        return nextUseParts, nextNum
    else
        return self:getAirShipCfg().gCost1[singleMaxIndex], nextNum
    end
end

--剩余的次数 用于必出紫装置
function airShipVoApi:getLastNumWithGetPurpleEquip()
    local lotteryNum = tonumber(self.lotteryTb[3]) or 0
    return 20 - lotteryNum--返回剩余次数
end

--抽奖需要的金币数
function airShipVoApi:getRewardNeedGems(rType)
    local airShipCfg = self:getAirShipCfg()
    if rType then
        return airShipCfg.gCost2[rType]
    end
    return airShipCfg.gCost2[1], airShipCfg.gCost2[2]
end

--当天是否还可继续抽取，
function airShipVoApi:getCurDayIsCanLottery(idx)
    local topNum = self:getAirShipCfg().gNum1
    local nextUseParts = self:getRewardNextUseParts()
    local noneData1, noneData2, curTotalPartsNum = self:getTotalPartsNum()
    local playerGems = playerVoApi:getGems()
    local isCanLottery = 0
    local leftLotteryNum = topNum - (self.lotteryTb[1] or 0)
    local num = self:getLotteryNum(idx)
    if leftLotteryNum < num then
        isCanLottery = 1
    elseif leftLotteryNum == 0 then
        isCanLottery = 2
    end
    if idx == 1 then--单抽
        local isCanUseParts = curTotalPartsNum >= nextUseParts
        if isCanUseParts then--可使用材料
            return isCanLottery, isCanUseParts, nil, nextUseParts
        else--判断单抽 使用金币的情况
            local useGems = self:getRewardNeedGems(idx)
            local isCanUseGems = playerGems >= useGems
            return isCanLottery, isCanUseParts, isCanUseGems, useGems, playerGems
        end
    elseif idx == 2 then--十连抽
        local useGems = self:getRewardNeedGems(idx)
        local isCanUseGems = playerGems >= useGems
        return isCanLottery, false, isCanUseGems, useGems, playerGems
    end
end

function airShipVoApi:getLotteryNum(idx)
    return self:getAirShipCfg().lotteryTb[idx]
end

--抽奖接口
function airShipVoApi:socketReward(rType, useGems, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if useGems then
                playerVoApi:setGems(playerVoApi:getGems() - self:getRewardNeedGems(rType))
            end
            if sData and sData.data then
                self:initData(sData.data)
                
                airShipVoApi:saveTip(2) --生产出材料后有可能使飞艇装置可以被解锁，所以需要更新红点数据
                
                if type(callback) == "function" then
                    local reward = {}
                    if sData.data.airship.cReward then
                        for k, v in pairs(sData.data.airship.cReward) do
                            local r = FormatItem(v)[1]
                            table.insert(reward, r)
                        end
                    end
                    callback(reward)
                end
                
                eventDispatcher:dispatchEvent("airship.props.refresh", {props = G_clone(self.airShipEquipPartsTb)})
            end
        end
    end
    local num = nil
    if useGems then
        num = rType == 1 and 1 or 10
    end
    socketHelper:airShipSocket(socketCallback, "draw", {num = num})
end

function airShipVoApi:lotteryClickBtn(callback, rType, layerNum)
    local canLottery, canUseParts, canUseGems, useNum, hasNum = self:getCurDayIsCanLottery(rType)
    if canLottery ~= 0 then
        G_showTipsDialog(getlocal("airShip_curDayNotLottery"..canLottery))
        do return end
    end
    if not canUseParts and not canUseGems then--钱不够
        GemsNotEnoughDialog(nil, nil, useNum - hasNum, layerNum + 2, useNum)
        do return end
    end
    
    local tipKey = "airShipLottery1"
    local confirmStr = "airShip_Lottery_secondtip1"
    if not canUseParts then
        tipKey = "airShipLottery2"
        confirmStr = "airShip_Lottery_secondtip2"
    end
    confirmStr = getlocal(confirmStr, {useNum})
    
    local function realLottery()
        self:socketReward(rType, canUseGems, callback)
    end
    G_dailyConfirm(tipKey, confirmStr, realLottery, layerNum)
end

---零件对应图片 和背景图
function airShipVoApi:getAirShipPropIcon(pid, iconSize, callback)
    local props = self:getAirShipCfg().Prop
    
    local name, desc, pic, bgname = self:getAirShipPropShowInfo(pid)
    local iconBg = LuaCCSprite:createWithSpriteFrameName(bgname, function (object, fn, tag)
        if callback then
            callback(object, fn, tag)
        end
    end)
    local iconSp = CCSprite:createWithSpriteFrameName(pic)
    if iconSp:getContentSize().width > iconBg:getContentSize().width then
        iconSp:setScale((iconBg:getContentSize().width - 4) / iconSp:getContentSize().width)
    end
    iconSp:setPosition(getCenterPoint(iconBg))
    iconBg:addChild(iconSp)
    if iconSize then
        iconBg:setScale(iconSize / iconBg:getContentSize().width)
    end
    
    return iconBg
end

--抽奖 奖池里所有零件 和 各品级概率
function airShipVoApi:getAwardList()
    local poolTb = self:getAirShipCfg().Pool
    local awardTb = FormatItem(poolTb) or {}
    if not next(awardTb) then
        print(" ~~~~~~ e r r o r in getAwardList with awardTb is nil ~~~~~~")
    end
    return awardTb
end

--------------------------------- 飞 艇 相 关 数 据 处 理 ---------------------------------

--可解锁飞艇 : return 1 是否有可解锁飞艇， 2 都有哪些可解锁飞艇
function airShipVoApi:getCanBeUnLockAirShip()
    local strength = self:getTotalStrength()
    local airShipInfoCfg = self:getAirShipCfg().airship
    local canUnlockTb = {}
    if strength == 0 then
        return false, {}
    end
    for k, v in pairs(airShipInfoCfg) do
        if k ~= 1 and k ~= 7 then
            if strength >= v.lock then
                canUnlockTb[k] = 1
            end
        end
    end
    if next(canUnlockTb) then
        return true, canUnlockTb
    else
        return false, {}
    end
end

--当前飞艇是否解锁
function airShipVoApi:isUnlockCurAirShip(id)
    local curShip = self:getCurAirShipInfo(id)
    local isUnlock = curShip and true or false
    return isUnlock, self.airShipInfo
end
--获取当前已解锁的飞艇相关数据
function airShipVoApi:getCurAirShipInfo(id)
    return self.airShipInfo["a"..id] or nil
end

--获取当前飞艇已有的装置 属性表
function airShipVoApi:getCurAirShipProperty(id)
    if self:isCanEnter() == false then
        return {}
    end
    local airShipInfo = self:getCurAirShipInfo(id) or {}
    local shipEquipTb = airShipInfo[2]
    local asEquip = self:getAirShipCfg().asEquip
    local propertyTb = {}
    if shipEquipTb and next(shipEquipTb) then
        if id == 1 then--运输艇
            for i = 1, 4 do
                if shipEquipTb["as"..i] then
                    local equipLv = shipEquipTb["as"..i]
                    propertyTb[i] = asEquip[equipLv]["as"..i].att
                end
            end
        else
            for k, v in pairs(shipEquipTb) do
                propertyTb[asEquip[v][k].attType] = asEquip[v][k].att
            end
        end
    end
    return propertyTb
end
--获取所选的飞艇的装置的品质
function airShipVoApi:getCurAirShipEquipQuality(airshipIdx, equipId)
    local airShipInfo = self:getCurAirShipInfo(airshipIdx)
    return airShipInfo and airShipInfo[2] and airShipInfo[2][equipId] or 0
end

--当前选择的飞艇的装置的 下一级 所有零件和对应数量 ,
function airShipVoApi:getCurAirShipEquipParts(airshipIdx, equipId, onlyCheckUpGrade)
    local isCanUpGrade = true -- 装置是否可以激活改造
    local airShipCfg = self:getAirShipCfg()
    
    local hadQuality = self:getCurAirShipEquipQuality(airshipIdx, equipId)
    local asEquip = airShipCfg.asEquip[hadQuality] and airShipCfg.asEquip[hadQuality][equipId] or nil--当前装置 激活？
    local nextAsEquip = airShipCfg.asEquip[1 + hadQuality or 0] and airShipCfg.asEquip[1 + hadQuality or 0][equipId] or nil--下一品阶装置 满级？
    local formatTb = {}--格式化下一品阶所需的装置零件
    if onlyCheckUpGrade and not nextAsEquip then--检测 是否升品阶 满级情况 直接false
        return false
    end
    -- print("airshipIdx----equipId-----hadQuality---->>>",airshipIdx,equipId,hadQuality)
    --当前装置显示下一品阶 需要的零件数据
    --如果没有下一品阶的tb 说明 等级已满，取上一品阶的tb 用于显示即可
    local costTb = nextAsEquip and nextAsEquip.cost or asEquip.cost
    formatTb = FormatItem(costTb, nil, true)
    for k, v in pairs(formatTb) do
        v.curHasNum = tonumber(self.airShipEquipPartsTb[v.key]) or 0
        if v.curHasNum < v.num then
            isCanUpGrade = false
        end
    end
    if not nextAsEquip then-- 满级
        isCanUpGrade = false
    end
    if not self:isUnlockCurAirShip(airshipIdx) then
        isCanUpGrade = false
    end
    
    return isCanUpGrade, formatTb, asEquip, nextAsEquip
end

--是否有飞艇 有可激活改造的装置
function airShipVoApi:isCanUpGradeEquipParts()
    local isCanUpGrade = false
    if next(self.airShipInfo) then
        local index = 1
        for k, v in pairs(self.airShipInfo) do
            if not v[2] or not next(v[2]) then
                do break end
            else
                for m, n in pairs(v[2]) do
                    isCanUpGrade = self:getCurAirShipEquipParts(index, m, true)
                    if isCanUpGrade then
                        return isCanUpGrade
                    end
                end
            end
            index = index + 1
        end
    end
    return false
end

---飞艇装置 请求激活改造
function airShipVoApi:socketProduce(callback, aid, equipIdx)
    if airShipVoApi:isGoInto(aid) == true then
        G_showTipsDialog(getlocal("airShip_attacking_tip"))
        do return end
    end
    local equipId = self:getAirShipCfg().airship[aid].equipId[equipIdx]
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data, {rfStrength = true, rfAirshipId = aid})
                
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "produce", {aid = aid, asid = equipId})
end

--递归排列零件 增长排列
function airShipVoApi:reorderWithAddCurTb(thisId, thisCurTb, thisCfg)
    if thisCfg[thisId].compound then
        local newEquipPartsId = thisCfg[thisId].compound[1]
        local quality = thisCfg[newEquipPartsId].quality
        thisCurTb[quality] = thisCfg[newEquipPartsId]
        thisCurTb[quality].zId = newEquipPartsId
        self:reorderWithAddCurTb(newEquipPartsId, thisCurTb, thisCfg)
    end
end
function airShipVoApi:reorderWithSubCurTb(thisId, thisCurTb, thisCfg)
    if thisCfg[thisId].resolve then
        local newEquipPartsId = thisCfg[thisId].resolve[1]
        local quality = thisCfg[newEquipPartsId].quality
        thisCurTb[quality] = thisCfg[newEquipPartsId]
        thisCurTb[quality].zId = newEquipPartsId
        self:reorderWithAddCurTb(newEquipPartsId, thisCurTb, thisCfg)
    end
end
--当前材料 所需的合成 分解 的材料数据
function airShipVoApi:getEquipPartsWithData(equipPartsId)
    local equipPartsTbCfg = self:getAirShipCfg().Prop
    local quality = equipPartsTbCfg[equipPartsId].quality
    local curTb = {}
    curTb[quality] = equipPartsTbCfg[equipPartsId]
    curTb[quality].zId = equipPartsId
    if quality < 5 then
        self:reorderWithAddCurTb(equipPartsId, curTb, equipPartsTbCfg)
    end
    if quality > 1 then
        self:reorderWithSubCurTb(equipPartsId, curTb, equipPartsTbCfg)
    end
    return curTb
end

---零件分解 或 合成  请求
function airShipVoApi:socketMaterial(callback, act, pid, remakeNum)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                
                airShipVoApi:saveTip(2) --材料发生变化有可能使飞艇装置可以被解锁，所以需要更新红点数据
                
                if type(callback) == "function" then
                    callback()
                end
                eventDispatcher:dispatchEvent("airship.props.refresh", {props = G_clone(self.airShipEquipPartsTb), cmd = "material"})
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "material", {act = act, pid = pid, num = remakeNum})
end

function airShipVoApi:isCurAirShipInfoEquipNumFull(id)
    local curShip = self:getCurAirShipInfo(id)
    local num = curShip and curShip[2] and SizeOfTable(curShip[2]) or 0
    if num == 0 or (id == 1 and num < 4) or (id > 1 and num < 6) then
        return false
    end
    return true
end

function airShipVoApi:isCanRename(id, rename, nameCheck)
    if base.serverTime < (self.chgNameTs + 7 * 86400) then
        G_showTipsDialog(getlocal("airShip_notRenameTip", {GetTimeStr(self.chgNameTs + 7 * 86400 - base.serverTime)}))
        return false
    end
    if id == nil then
        return false
    end
    if not self:isCurAirShipInfoEquipNumFull(id) then
        G_showTipsDialog(getlocal("airShip_lockEquipTip"))
        return false
    end
    if nameCheck ~= false then
        if rename == "" or not tostring(rename) then
            G_showTipsDialog(getlocal("airShip_oohRenameTip"))
            return false
        elseif rename == self:getAirshipNameById(id, true) then
            G_showTipsDialog(getlocal("airShip_nooRenameTip"))
            return false
        elseif rename and rename ~= "" then
            local len = G_utfstrlen(rename)
            if len < 2 or len > 5 then -- 名字长度1~8位
                G_showTipsDialog(getlocal("airShip_name_lackLength", {2, 5}))
                return false
            end
            if string.match(rename, "^[A-Za-z0-9]+$") == nil then --只能包含数字和字母
                G_showTipsDialog(getlocal("airShip_name_illegitmacy2"))
                return false
            end
        end
        if platCfg.platCfgKeyWord[G_curPlatName()] ~= nil then --检测屏蔽字
            if keyWordCfg:keyWordsJudge(rename, false) == false then
                G_showTipsDialog(getlocal("airShip_name_illegitmacy"))
                return false
            end
        end
    end
    return true
end

--飞艇改名字
function airShipVoApi:socketShipRename(callback, id, rename)
    if self:isCanRename(id, rename) == false then
        return false
    end
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "rename", {aid = id, rename = rename})
    return true
end

--获取飞艇的名称
function airShipVoApi:getAirshipNameById(aid, simpleNameFlag)
    local nameStr = ""
    if self.airShipInfo['a'..aid] and self.airShipInfo['a'..aid][1] and self.airShipInfo['a'..aid][1] ~= "" then
        nameStr = self.airShipInfo['a'..aid][1]
        if simpleNameFlag ~= true then
            local name, postfix = self:splitAirshipNameById(aid)
            nameStr = nameStr..postfix
        end
    else
        if simpleNameFlag ~= true then
            nameStr = self:getAirshipDefaultName(aid)
        else
            nameStr = self:splitAirshipNameById(aid)
        end
    end
    return nameStr
end

--获取飞艇的默认名字
function airShipVoApi:getAirshipDefaultName(aid)
    return getlocal("airShip_name_"..aid)
end

--拆分一下飞艇的名称
function airShipVoApi:splitAirshipNameById(aid)
    local name = self:getAirshipDefaultName(aid)
    local splitIdx = string.find(name, "%[")
    if splitIdx == nil then
        return name, ""
    end
    return string.sub(name, 1, splitIdx - 1), string.sub(name, splitIdx)
end

----------------------- 飞 艇 内 主界面 一些数据处理逻辑 -----------------------

--当前飞艇装置 名称, 图片
function airShipVoApi:getCurAirShipEquipName(id, eqIdx)
    local useIdx1 = id == 1 and id or 2
    
    -- if id == 1 then--缺图，
    -- return getlocal("airShip_asEquipName"..useIdx1.."_"..eqIdx),"Icon_BG.png"
    -- end
    
    return getlocal("airShip_asEquipName"..useIdx1.."_"..eqIdx), "arpl_asEquipIcon"..useIdx1.."_"..eqIdx..".png"
end

-- 点中当前的 飞艇的 装置idx的 返回所需要所需的下一品阶零件表
function airShipVoApi:getCurAirShipEquipPartsTbWithIdx(id, eqIdx)
    local equipId = self:getAirShipCfg().airship[id].equipId[eqIdx]
    -- print("eqIdx， equipId===>>",eqIdx,equipId)
    local isUpgrade, equipPartsTb, curEquip, nextEquip = self:getCurAirShipEquipParts(id, equipId)
    return isUpgrade, equipPartsTb, curEquip, nextEquip
end

--飞艇属性界面内的 战术属性展示
function airShipVoApi:getCurAirShipTacticsLbTb(id)
    local stactLvl, curStacticTb = self:getCurAirShipTacticsData(id)
    local stacticStrTb = {}
    if stactLvl and curStacticTb then
        local pdata
        local tactic = {}
        local airShipInfo = self:getCurAirShipInfo(id)
        if airShipInfo and airShipInfo[3] then
            tactic = airShipInfo[3]
        end
        for k, v in pairs(tactic) do
            pdata = self:getTacticsPropertyById(v, stactLvl)
            stacticStrTb[k] = pdata.desc.."+" .. self:getPropertyValueStr(pdata.pkey, pdata.pv)
        end
    end
    local jhNum = SizeOfTable(stacticStrTb)
    return stacticStrTb, jhNum
end

----------------------------------- 飞 艇 战 术 --------------------------------

--当前飞艇战术等级 以及个数 ，向下取整、 return的值 既是战术的品级，也是当前已激活的条目数
function airShipVoApi:getTacticsFloorLvl(curEquipTb, equipTbCfg)
    if SizeOfTable(curEquipTb) == SizeOfTable(equipTbCfg) then--当前飞艇所有装置激活情况下，才能确定战术等级以及个数
        local lvl = nil
        for k, v in pairs(curEquipTb) do
            if not lvl then
                lvl = v
            elseif lvl > v then
                lvl = v
            end
        end
        return lvl
    end
    return nil
end
--当前飞艇战术
function airShipVoApi:getCurAirShipTacticsData(airshipIdx)
    local curAirShip = self:getCurAirShipInfo(airshipIdx)
    if not curAirShip then--无飞艇数据
        return nil
    end
    
    local airShipCfg = self:getAirShipCfg()
    local resetTb = airShipCfg.serverreward.reset--战术配置表，洗练也用这个表
    local stactLvl = self:getTacticsFloorLvl(curAirShip[2], airShipCfg.airship[airshipIdx].equipId)
    if not stactLvl then -- 无战术可用
        return nil
    end
    
    local curStacticTb = {}
    if curAirShip[3] then
        for k, v in pairs(curAirShip[3]) do
            curStacticTb[k] = resetTb[v]
        end
    end
    return stactLvl, curStacticTb
end

--获取指定战术的属性 tId：战术id，tLv：战术等级
function airShipVoApi:getTacticsPropertyById(tId, tLv)
    local airShipCfg = self:getAirShipCfg()
    local resetTb = airShipCfg.serverreward.reset
    local typeNameTb = {[1] = getlocal("tanke"), [2] = getlocal("jianjiche"), [4] = getlocal("zixinghuopao"), [8] = getlocal("huojianche"), [15] = getlocal("allTypeTank")}
    
    local pcfg = resetTb[tId]
    if pcfg == nil then
        return {"", 0, 0}
    end
    local desc, pv, strength
    desc = typeNameTb[pcfg.type]..getlocal(buffEffectCfg[buffKeyMatchCodeCfg[pcfg.attType]].name)
    if tLv then --如果传了tLv则取对应战术等级的值
        if tLv > 0 then
            pv = pcfg.att[tLv]
            strength = pcfg.strength[tLv]
        else
            pv, strength = 0, 0
        end
    else --如果没有传tLv则取所有等级数据
        pv = pcfg.att
        strength = pcfg.strength
    end
    return {desc = desc, pv = pv, pkey = pcfg.attType, strength = strength}
end

--获取飞艇战术属性值
function airShipVoApi:getTacticsPropertyByType(airshipId, attType)
    if airshipId == nil then
        return 0
    end
    airshipId = tonumber(airshipId) and 'a'..airshipId or airshipId
    if tonumber(RemoveFirstChar(airshipId)) == 0 then
        return 0
    end
    if self.airShipInfo == nil or next(self.airShipInfo) == nil or self.airShipInfo[airshipId] == nil or self.airShipInfo[airshipId][3] == nil then
        return 0
    end
    local pv = 0
    local resetTb = self:getAirShipCfg().serverreward.reset
    local stactLvl = self:getCurAirShipTacticsData(tonumber(RemoveFirstChar(airshipId)))
    for tIdx, tacticsId in pairs(self.airShipInfo[airshipId][3]) do
        local cfg = resetTb[tacticsId]
        if cfg and cfg.attType == attType then
            pv = pv + (cfg.att[stactLvl] or 0)
        end
    end
    return pv
end

---当前飞艇战术洗练
function airShipVoApi:socketSuccinct(callback, aid, lock, costGold)--lock：锁住的战术id表
    if airShipVoApi:isGoInto(aid) == true then
        G_showTipsDialog(getlocal("airShip_attacking_tip"))
        do return end
    end
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                
                --本次洗练消耗的金币数
                if costGold and costGold > 0 then
                    playerVoApi:setGems(playerVoApi:getGems() - costGold)
                end
                
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "succinct", {aid = aid, lock = lock})
end

---当前飞艇战术替换
function airShipVoApi:tacticsReplace(callback, aid)
    if airShipVoApi:isGoInto(aid) == true then
        G_showTipsDialog(getlocal("airShip_attacking_tip"))
        do return end
    end
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data, {rfStrength = true, rfAirshipId = aid})
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "replace", {aid = aid})
end

---------------------------------- 飞 艇 共 振 --------------------------------

--当前飞艇装置共振的算法 向下取整
function airShipVoApi:getCurAirShipEquipInfo(curAirShip)
    local combineEffect = {[2] = 0, [4] = 0}
    local equipTb = curAirShip and curAirShip[2] or {}
    if equipTb and next(equipTb) then
        local quaArr = table.values(equipTb)
        table.sort(quaArr, function (a, b)
            return a > b
        end)
        
        local combKey = table.keys(self:getAirShipCfg().combine)
        local len = table.length(quaArr)
        
        if len < 6 and len > 3 then
            combineEffect[4] = quaArr[4] or 0
        else
            if len <= 3 then
                combineEffect[2] = quaArr[2] or 0
            elseif len == 6 then
                local mq = 5 --最小的品质
                quaArr = {}
                for k, v in pairs(equipTb) do
                    quaArr[v] = (quaArr[v] or 0) + 1
                    if mq > v then
                        mq = v
                    end
                end
                local s, q = 0, 0
                for k = 5, 1, -1 do
                    s = s + (quaArr[k] or 0)
                    if s >= 2 or s >= 4 then
                        q = k
                        do break end
                    end
                end
                if s == 6 then
                    combineEffect[2] = q
                    combineEffect[4] = q
                elseif s >= 4 then
                    combineEffect[4] = q
                    combineEffect[2] = mq
                elseif s >= 2 then
                    combineEffect[2] = q
                    combineEffect[4] = mq
                end
            end
        end
    end
    return combineEffect
end
--当前飞艇共振数据
function airShipVoApi:getCurAirShipResonanceData(airshipIdx)
    local curAirship = self:getCurAirShipInfo(airshipIdx)
    
    local combineEffect = self:getCurAirShipEquipInfo(curAirship)
    local combineTb = self:getAirShipCfg().combine
    local resonanceData = {}
    for i = 1, 2 do
        resonanceData[i] = {}
        if i == 1 then
            resonanceData[i] = combineTb[4]
            resonanceData[i].rIdx = 4
            resonanceData[i].qualtyLv = combineEffect[4] or 0
        else
            resonanceData[i] = combineTb[2]
            resonanceData[i].rIdx = 2
            resonanceData[i].qualtyLv = combineEffect[2] or 0
        end
        
    end
    return resonanceData
end

--quality：共振品质，num：共振品质个数
function airShipVoApi:getAirShipResonance(quality, num)
    local desc, value, attkey, strength = "", 0, ""
    local combine = self:getAirShipCfg().combine
    if combine[num] then
        attkey = combine[num].att
        value = combine[num].atttype[quality] or 0
        desc = getlocal(buffEffectCfg[buffKeyMatchCodeCfg[attkey]].name)
        strength = combine[num].strength[quality] or 0
    end
    return {desc, value, attkey, strength}
end

function airShipVoApi:getAirShipPropShowInfo(pid, isShowQuality)
    local name, desc, pic, bgname = "", "", "taskPointIcon.png", "Icon_BG.png"
    local item = airShipVoApi:getAirShipCfg().Prop[pid]
    if item then
        local gidx = item.group - tonumber(item.type) * 10
        name = getlocal("astype"..item.type.."_prop"..gidx.."_name")
        desc = "astype"..item.type.."_prop"..gidx.."_desc"
        pic = "airship"..item.type.."_propicon_"..gidx..".png"
        local quality = item.quality
        if (quality == 1) then
            bgname = "equipBg_gray.png"
        elseif(quality == 2)then
            bgname = "equipBg_green.png"
        elseif(quality == 3)then
            bgname = "equipBg_blue.png"
        elseif(quality == 4)then
            bgname = "equipBg_purple.png"
        elseif(quality == 5)then
            bgname = "equipBg_orange.png"
        end
        if isShowQuality == true then
            name = name.."["..getlocal("armorMatrix_color_"..quality) .. "]"
        end
    end
    return name, desc, pic, bgname
end

function airShipVoApi:getCurAirShipResonanceLb(airshipIdx)
    local resonanceData = self:getCurAirShipResonanceData(airshipIdx)
    local resonanceLb = {}
    for k, v in pairs(resonanceData) do
        local qLv = v.qualtyLv
        local rType = v.att
        local prptyData = G_getAttributeInfoByType(rType)
        if not prptyData then
            print("~~~~~~~~~~~ e r r o r prptyData ~~~~~~~~~", rType)
            return {}
        end
        local addStr = k == 1 and "+" or ""
        local rValue = qLv > 0 and resonanceData[k].atttype[qLv] or 0
        resonanceLb[k] = getlocal(prptyData.name)..addStr..rValue
    end
    return resonanceLb, resonanceData
end

--获取飞艇总强度
function airShipVoApi:getTotalStrength()
    local strength = 0
    for k, v in pairs(self.strengthTb or {}) do
        strength = strength + v
    end
    return strength
end

--获取一架飞艇的强度值
function airShipVoApi:getStrength(airshipId)
    airshipId = tonumber(airshipId) and "a"..airshipId or airshipId
    if self.strengthTb then
        return self.strengthTb[airshipId] or 0
    end
    return 0
end

--airshipId：刷新飞艇的id
--data：消息数据
function airShipVoApi:refreshStrength(airshipId)
    if self.strengthTb == nil then
        self.strengthTb = {}
    end
    local strength = 0
    airshipId = tonumber(airshipId) and "a"..airshipId or airshipId
    if self.airShipInfo and self.airShipInfo[airshipId] and self.airShipInfo[airshipId][2] then
        local airShipCfg = self:getAirShipCfg()
        local airShipEquip = self.airShipInfo[airshipId][2]
        local resetQuality = nil
        for equipId, equipQuality in pairs(airShipEquip) do
            if airShipCfg.asEquip[equipQuality] and airShipCfg.asEquip[equipQuality][equipId] then
                local equipCfg = airShipCfg.asEquip[equipQuality][equipId]
                strength = strength + equipCfg.strength
            end
            if resetQuality == nil then
                resetQuality = equipQuality
            end
            if resetQuality > equipQuality then
                resetQuality = equipQuality
            end
        end
        
        if airshipId ~= "a1" then --运输艇没有共振和战术效果
            if resetQuality then
                local resetData = self.airShipInfo[airshipId][3]
                if resetData then
                    for k, resetId in pairs(resetData) do
                        local resetCfg = airShipCfg.serverreward.reset[resetId]
                        if resetCfg then
                            local resetStrength = resetCfg.strength[resetQuality]
                            if resetStrength then
                                strength = strength + resetStrength
                            end
                        end
                    end
                end
            end
            
            local combineEffect = self:getCurAirShipEquipInfo(self.airShipInfo[airshipId])
            local qualityFour, qualityTwo = (combineEffect[4] or 0), (combineEffect[2] or 0)
            if qualityFour and qualityFour > 0 then
                local combineStrength = airShipCfg.combine[4].strength[qualityFour]
                if combineStrength then
                    strength = strength + combineStrength
                end
            end
            if qualityTwo and qualityTwo > 0 then
                local combineStrength = airShipCfg.combine[2].strength[qualityTwo]
                if combineStrength then
                    strength = strength + combineStrength
                end
            end
        end
    end
    self.strengthTb[airshipId] = math.floor(strength)
end

--获取一架飞艇的属性
function airShipVoApi:getAttribute(airshipId)
    if self.airShipInfo and self.airShipInfo[airshipId] and self.airShipInfo[airshipId][2] then
        local attributeTb = {}
        local airShipCfg = self:getAirShipCfg()
        local airShipEquip = self.airShipInfo[airshipId][2]
        local resetQuality = nil
        --装置属性
        for equipId, equipQuality in pairs(airShipEquip) do
            if airShipCfg.asEquip[equipQuality] and airShipCfg.asEquip[equipQuality][equipId] then
                local equipCfg = airShipCfg.asEquip[equipQuality][equipId]
                if attributeTb[1] == nil then
                    attributeTb[1] = {}
                end
                attributeTb[1][equipCfg.attType] = (attributeTb[1][equipCfg.attType] or 0) + equipCfg.att
            end
            if resetQuality == nil then
                resetQuality = equipQuality
            end
            if resetQuality > equipQuality then
                resetQuality = equipQuality
            end
        end
        
        --共振属性
        local combineEffect = self:getCurAirShipEquipInfo(self.airShipInfo[airshipId])
        local qualityFour, qualityTwo = (combineEffect[4] or 0), (combineEffect[2] or 0)
        if qualityFour and qualityFour > 0 then
            local combineCfg = airShipCfg.combine[4]
            local attValue = combineCfg.atttype[qualityFour]
            if attValue then
                if attributeTb[2] == nil then
                    attributeTb[2] = {}
                end
                attributeTb[2][combineCfg.att] = (attributeTb[2][combineCfg.att] or 0) + attValue
            end
        end
        if qualityTwo and qualityTwo > 0 then
            local combineCfg = airShipCfg.combine[2]
            local attValue = combineCfg.atttype[qualityTwo]
            if attValue then
                if attributeTb[2] == nil then
                    attributeTb[2] = {}
                end
                attributeTb[2][combineCfg.att] = (attributeTb[2][combineCfg.att] or 0) + attValue
            end
        end
        
        --战术属性
        if resetQuality then
            local resetData = self.airShipInfo[airshipId][3]
            if resetData then
                for k, resetId in pairs(resetData) do
                    local resetCfg = airShipCfg.serverreward.reset[resetId]
                    if resetCfg then
                        local attValue = resetCfg.att[resetQuality]
                        if attValue then
                            if attributeTb[3] == nil then
                                attributeTb[3] = {}
                            end
                            -- attributeTb[3][resetCfg.attType] = (attributeTb[3][resetCfg.attType] or 0) + attValue
                            attributeTb[3][k] = {resetCfg.type, resetCfg.attType, attValue}
                        end
                    end
                end
            end
        end
        return attributeTb
    end
end

--所有已获得的材料
function airShipVoApi:getProps()
    return self.airShipEquipPartsTb or {}
end

function airShipVoApi:syncStatus(statusData)
    if statusData then
        -- 基地防守
        if statusData.d then
            self:setBattleEquip(1, statusData.d[1])
        end
        -- 出征队列
        if statusData.a then
            self.attackAirships = statusData.a
        else
            self.attackAirships = {}
        end
        
        -- 军事演习
        if statusData.m then
            self:setBattleEquip(5, statusData.m[1])
        end
        -- 超级武器
        if statusData.w then
            self:setBattleEquip(20, statusData.w[1])
        end
    end
end

--获取道具拥有数量
function airShipVoApi:getPropNumById(pid)
    if self.airShipEquipPartsTb and self.airShipEquipPartsTb[pid] then
        return tonumber(self.airShipEquipPartsTb[pid])
    end
    return 0
end

function airShipVoApi:setTempLineupId(airshipId)
    self.tempAirshipId = airshipId
end

function airShipVoApi:getTempLineupId()
    if base.airShipSwitch == 0 then
        return nil
    end
    if tonumber(self.tempAirshipId) == 0 then
        return nil
    end
    return self.tempAirshipId
end

function airShipVoApi:setBattleEquip(bType, airshipId)
    if self.battleAirship == nil then
        self.battleAirship = {}
    end
    if tonumber(airshipId) == 0 then
        airshipId = nil
    end
    self.battleAirship["bType" .. bType] = airshipId
end

function airShipVoApi:getBattleEquip(bType)
    if base.airShipSwitch == 0 then
        return nil
    end
    if bType == 2 then
        return nil
    end
    if self.battleAirship then
        local airshipId = self.battleAirship["bType" .. bType]
        if bType == 1 or bType == 3 then --防守部队需要检测飞艇是否可用
            if self:isGoInto(airshipId) == true then
                return nil
            end
        end
        return airshipId
    end
    return nil
end

--判断飞艇是否出战
function airShipVoApi:isGoInto(airshipId)
    if airshipId == nil then
        return false
    end
    if self.attackAirships and next(self.attackAirships) then
        for k, v in pairs(self.attackAirships) do
            if v == airshipId then
                return true
            end
        end
    end
    return false
end

function airShipVoApi:showWorldAirShipDialog(landData, layerNum)
    require "luascript/script/game/scene/gamedialog/worldAirShipDialog"
    local td = worldAirShipDialog:new(landData, layerNum)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {getlocal("airShip_worldTroopsTab1Ttitle"), getlocal("airShip_worldTroopsTab2Ttitle")}, nil, nil, getlocal("airShip_worldTroops"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--检测飞艇是否激活可上战（飞艇至少要激活一个装置）
function airShipVoApi:checkIsActiveForBattle(airshipId)
    airshipId = tonumber(airshipId) and "a"..airshipId or airshipId
    local asCfg = self:getAirShipCfg().airship[tonumber(RemoveFirstChar(airshipId))]
    if self.airShipInfo == nil or self.airShipInfo[airshipId] == nil or self.airShipInfo[airshipId][2] == nil then
        return false
    end
    local equipTb = self.airShipInfo[airshipId][2] or {}
    for k, equipId in pairs(asCfg.equipId) do
        local equipQuality = tonumber(equipTb[equipId]) or 0
        if equipQuality > 0 then
            return true
        end
    end
    return false
end

--获取最大可上阵飞艇数
function airShipVoApi:getMaxForBattle()
    local totalStrength = self:getTotalStrength()
    local goInLimitTb = self:getAirShipCfg().asNum
    local maxfb = SizeOfTable(goInLimitTb)
    local curMaxfb = 0 --当前强度下最大可出战飞艇数量
    for k = 1, maxfb do
        if totalStrength >= goInLimitTb[k] then
            curMaxfb = k
        end
    end
    return curMaxfb, maxfb
end

function airShipVoApi:getLineupList(bType)
    local state, extra = nil, nil
    local tempList = {{}, {}, {}}
    local asCfg = self:getAirShipCfg()
    
    local curMaxfb, maxfb = airShipVoApi:getMaxForBattle() --当前可出战飞艇数
    
    local goIntoNum = 0 --已出战飞艇个数
    for asIdx, v in pairs(asCfg.airship) do
        if v.target > 0 then --排除掉非战斗艇
            local airshipVo = {
                id = "a" .. asIdx,
                name = self:getAirshipDefaultName(asIdx)
                --tagState 列表中的表状态：nil[可上阵],1[已派出],-1[未解锁]
            }
            local airshipId = "a" .. asIdx
            if self.airShipInfo and self.airShipInfo[airshipId] then
                if self.airShipInfo[airshipId][1] and self.airShipInfo[airshipId][1] ~= "" then
                    local name, postfix = self:splitAirshipNameById(asIdx)
                    airshipVo.name = self.airShipInfo[airshipId][1]..postfix
                end
                local isActivate = self:checkIsActiveForBattle(airshipId)
                if isActivate then
                    local flag, additional = self:checkAirshipCanUse(bType, airshipVo.id)
                    if flag ~= 0 then
                        if flag == 1 then --已派出
                            airshipVo.tagState = 1
                            table.insert(tempList[2], airshipVo)
                            goIntoNum = goIntoNum + 1
                        elseif flag == 2 then --当前部队已上阵
                            table.insert(tempList[1], airshipVo)
                        elseif flag == 3 then --大战非当前部队已上阵
                            airshipVo.tagState = 2
                            airshipVo.additional = additional
                            table.insert(tempList[1], airshipVo)
                            goIntoNum = goIntoNum + 1
                        end
                    else --可上阵
                        table.insert(tempList[1], airshipVo)
                    end
                else --未激活装置
                    airshipVo.tagState = -1
                    table.insert(tempList[3], airshipVo)
                end
            else ---未解锁
                airshipVo.tagState = -1
                table.insert(tempList[3], airshipVo)
            end
        end
    end
    if maxfb > curMaxfb then
        if goIntoNum >= curMaxfb then
            state = -2
            extra = {nextGoIn = (goIntoNum + 1), strength = asCfg.asNum[goIntoNum + 1]} --已达当前总强度值下的最大飞艇上阵数，可去飞艇系统提升强度值来解锁
        end
    else
        if goIntoNum >= maxfb then
            state = -1 --已达最大飞艇上阵数
        end
    end
    if state == nil and #(tempList[1]) == 0 then
        state = 0 --暂无可上阵飞艇
    end
    local lineupList = {}
    for k, v in pairs(tempList) do
        table.sort(v, function(a, b) return self:getStrength(a.id) > self:getStrength(b.id) end)
        for kk, vv in pairs(v) do
            table.insert(lineupList, vv)
        end
    end
    return lineupList, state, extra
end

function airShipVoApi:getBossTroops(bossIndex)
    if bossIndex == nil then
        return
    end
    local airShipCfg = self:getAirShipCfg()
    local bossCfg = airShipCfg.serverreward.Boss[bossIndex]
    if bossCfg then
        return bossCfg.tank
    end
end

function airShipVoApi:getBossCurAttackNum()
    return self.bossAttackNum or 0
end

function airShipVoApi:getBossMaxAttackNum()
    local airShipCfg = self:getAirShipCfg()
    return airShipCfg.bMax
end

function airShipVoApi:getBossAtkRecoverTimer()
    if self.recoverTimer == nil or self.recoverTimer == 0 then
        return
    end
    local airShipCfg = self:getAirShipCfg()
    return (self.recoverTimer + airShipCfg.bCD) - base.serverTime
end

function airShipVoApi:requestBuyAttackNum(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "buyatt")
end

function airShipVoApi:getBossAttackOfBuyNum()
    local airShipCfg = self:getAirShipCfg()
    return airShipCfg.bCount
end

function airShipVoApi:getBossAttackOfBuyCost()
    local buyNum = self.buyAttackNum or 0
    if G_getWeeTs(self.lastBuyTs or 0) ~= G_getWeeTs(base.serverTime) then --跨天了
        buyNum = 0 --重置购买次数
    end
    local airShipCfg = self:getAirShipCfg()
    if airShipCfg.bCost[buyNum + 1] then
        return airShipCfg.bCost[buyNum + 1]
    else
        return airShipCfg.bCost[SizeOfTable(airShipCfg.bCost)]
    end
end

function airShipVoApi:getBossAttackReward(bossType)
    local airShipCfg = self:getAirShipCfg()
    local bossCfg = airShipCfg.serverreward.boss[bossType]
    if bossCfg and bossCfg[3] then
        local rewardTb = {}
        for k, v in pairs(bossCfg[3]) do
            local keyStr = Split(v[1], "_")
            if keyStr[1] == "props" then
                local itemTb = FormatItem({p = {[keyStr[2]] = v[2]}})
                if itemTb and itemTb[1] then
                    table.insert(rewardTb, itemTb[1])
                end
            end
        end
        return rewardTb
    end
end

function airShipVoApi:getRankMinDamage()
    local airShipCfg = self:getAirShipCfg()
    return airShipCfg.rDmg
end

function airShipVoApi:getBossIconPic(bossType)
    return "airShip_bossIcon_" .. bossType .. ".png"
end

function airShipVoApi:getBossWorldMapTankId(bossIndex)
    local troopsData = self:getBossTroops(bossIndex)
    if troopsData then
        for k, v in ipairs(troopsData) do
            if v[1] then
                return tonumber(RemoveFirstChar(v[1]))
            end
        end
    end
end

--显示材料分解合成页面
function airShipVoApi:showRemakePropDialog(pid, sameTypeProps, layerNum)
    require "luascript/script/game/scene/gamedialog/airShipDialog/airShipSmallDialog"
    airShipSmallDialog:showRemakePropDialog(pid, sameTypeProps, layerNum)
end

--获取属性值的字符串显示形式
function airShipVoApi:getPropertyValueStr(pkey, pv)
    if pkey == "add" or pkey == "first" or pkey == "antifirst" or pkey == "armor" or pkey == "arp" then
        return tostring(pv)
    else
        return (pv * 100) .. "%"
    end
end

--获取洗练战术的消耗
function airShipVoApi:getTacticsWashCost(tLv, lockNum)
    local cfg = self:getAirShipCfg()
    local resetCost = cfg.resetCost
    local pid = cfg.mirror[99][tLv] or "z1"
    return pid, (lockNum == 0 and resetCost[1] or (resetCost[lockNum + 1] or 5)), cfg.Prop[pid].gold
end

--获取飞艇建筑恢复原料零件的速度
function airShipVoApi:getResourceRecoverSpeedByHour()
    local buildingLv = self:getBuildingLevel()
    return tonumber(Split(buildingCfg[self.btype].resourceSpeed, ",")[buildingLv] or 2)
end

--是否玩家已经做过引导
function airShipVoApi:isGuidePlayed()
    local cfg = self:getAirShipCfg()
    if self.partsTb and self.partsTb[2] and self.partsTb[2] < cfg.gCost1[1] then --判断原料是否提取
        return true
    end
    local airShipInfo = airShipVoApi:getCurAirShipInfo(1)
    if airShipInfo and airShipInfo[2] and tonumber(airShipInfo[2]["as1"] or 0) > 0 then --判断运输艇生产核心是否激活
        return true
    end
    return false
end

--获取坦克类型名称
function airShipVoApi:getTankTypeName(tankType)
    if tankType == 1 then
        return getlocal("tanke")
    elseif tankType == 2 then
        return getlocal("jianjiche")
    elseif tankType == 4 then
        return getlocal("zixinghuopao")
    elseif tankType == 8 then
        return getlocal("huojianche")
    elseif tankType == 15 then
        return getlocal("allTypeTank")
    end
    return ""
end

-- 获取不可上阵的飞艇
function airShipVoApi:getAirshipCanNotUse(bType)
    local notEquipTb = {}
    if bType == 11 then --远征军阵亡的飞艇
        return self.deadAirships or {}
    elseif bType == 7 or bType == 8 or bType == 9 then
        for k = 7, 9 do
            if k ~= bType then
                notEquipTb[k - 6] = self:getBattleEquip(k)
            end
        end
    elseif bType == 13 or bType == 14 or bType == 15 then
        for k = 13, 15 do
            if k ~= bType then
                notEquipTb[k - 12] = self:getBattleEquip(k)
            end
        end
    elseif bType == 21 or bType == 22 or bType == 23 then
        for k = 21, 23 do
            if k ~= bType then
                notEquipTb[k - 20] = self:getBattleEquip(k)
            end
        end
    elseif bType == 24 or bType == 25 or bType == 26 then
        for k = 24, 26 do
            if k ~= bType then
                notEquipTb[k - 23] = self:getBattleEquip(k)
            end
        end
    elseif bType == 35 or bType == 36 then -- 领土争夺战
        return {}
    end
    return notEquipTb
end

-- 设置不可重复上阵的飞艇
function airShipVoApi:setAirshipCanNotUse(bType, notEquipTb)
    --远征军阵亡的飞艇不能重复上阵
    if bType == 11 then
        self.deadAirships = notEquipTb
    end
end

--判断此飞艇是否可以上阵
--bType:战斗类型，airshipId:飞艇id
--state：1：已派出，2：当前部队已上阵，3：其余部队已上阵 （适用于大战多支部队）
function airShipVoApi:checkAirshipCanUse(bType, airshipId)
    if airshipId == self:getBattleEquip(bType) then
        return 2
    end
    -- 不重复上阵的飞艇(大战和远征不可重复使用)
    local notEquipTb = self:getAirshipCanNotUse(bType)
    -- 只有多支部队上阵时才会涉及重复问题
    if notEquipTb and type(notEquipTb) == "table" then
        for k, v in pairs(notEquipTb) do
            if v == airshipId then
                return 3, {troopIdx = k}
            end
        end
    end
    if self:isGoInto(airshipId) then
        return 1
    end
    return 0
end

--获取可出战最大强度的飞艇
function airShipVoApi:getBestAirship(bType)
    if self:isCanEnter() == false then
        return nil
    end
    local battleNum = 0
    local airship = {}
    for k, v in pairs(self:getAirShipCfg().airship) do
        if k ~= 1 then --排除运输艇
            local airshipId = "a"..k
            local isActivate = self:checkIsActiveForBattle(airshipId)
            if isActivate == true then
                local inBattle = self:isGoInto(airshipId)
                if inBattle == true then --该部队在非镜像部队已出征
                    battleNum = battleNum + 1
                end
                local flag = self:checkAirshipCanUse(bType, airshipId)
                if flag == 0 or flag == 2 then --最大战力不能排除当前部队即flag=2的
                    table.insert(airship, airshipId)
                elseif flag == 3 then --大战非当前部队上阵
                    if inBattle == false then --如果镜像部队和非镜像部队上阵了同一飞艇，则出战个数只能加一次
                        battleNum = battleNum + 1
                    end
                end
            end
        end
    end
    
    local curMaxfb = airShipVoApi:getMaxForBattle() --当前可出战飞艇数
    if battleNum >= curMaxfb then --判断上阵个数是否达上限
        return nil
    else
        if airship and SizeOfTable(airship) > 1 then
            table.sort(airship, function (a, b)
                return self:getStrength(a) > self:getStrength(b)
            end)
        end
    end
    return airship[1] or nil
end

--战报中是否显示飞艇
function airShipVoApi:isShowAirshipInReport(report)
    if base.airShipSwitch == 1 and report and report.airship and next(report.airship) then
        return true
    end
    return false
end

function airShipVoApi:getMyPhoneType()
    -- 1 4; 2 5; 3 x; 0 安卓
    -- if G_isIOS() then
        return G_getIphoneType()
    -- else
    --     return 0
    -- end
end

--使用飞艇原料
function airShipVoApi:useMaterial(num)
    if self.partsTb and self.partsTb[1] then
        self.partsTb[1] = self.partsTb[1] - num
        if self.partsTb[1] < 0 then
            self.partsTb[1] = 0
        end
    end
end
