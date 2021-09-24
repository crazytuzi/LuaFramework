require "luascript/script/config/gameconfig/playerCfg"
require "luascript/script/game/gamemodel/player/playerVo"
require "luascript/script/game/gamemodel/slot/buildingSlotVo"

buildingSlotVoApi = {
allBuildingSlots = {}}
function buildingSlotVoApi:getAllBuildingSlots()
    
    return self.allBuildingSlots;
    
end
function buildingSlotVoApi:judgeAndShowSlot(bTb)--同步之前判断后台先完成 然后飘板
    if SizeOfTable(bTb) ~= SizeOfTable(self.allBuildingSlots) then
        for k, v in pairs(self.allBuildingSlots) do
            if(v and v.bid)then
                local bid = "b"..tonumber(v.bid)
                local foundFlag = false
                for kk, vv in pairs(bTb) do
                    if(vv and vv.id and vv.id == bid)then
                        foundFlag = true
                        break
                    end
                end
                if(foundFlag == false)then
                    self:upgradeSuccess(v.bid)
                end
            end
        end
    end
    
end

function buildingSlotVoApi:clear()
    for k, v in pairs(self.allBuildingSlots) do
        v = nil
    end
    self.allBuildingSlots = nil
    self.allBuildingSlots = {}
end

function buildingSlotVoApi:add(bid, st, et, hid, isPushMsg) --添加队列成功返回 true 否则 false
    --加上这个判断之后，如果购买了临时建造队列，队列到期之后实际升级的建筑数目比玩家拥有的建造位多的时候，会有一个无法添不到客户端的队列中，因此暂时将这个判断注释掉
    -- if self:getFreeSlotNum()<=0 then
    --     return false
    -- else
    local tmpSlot = buildingSlotVo:new()
    tmpSlot:initWithData(bid, st, et, hid)
    local bVo = buildingVoApi:getBuildiingVoByBId(bid)
    bVo.status = 2
    if bVo.type ~= -1 and isPushMsg ~= false then
        G_pushMessage(getlocal("build_finish", {getlocal(buildingCfg[bVo.type].buildName), "("..G_LV() .. (bVo.level + 1) .. ")"}), et - base.serverTime, "b"..bid, G_BuildUpgradeTag)
    end
    self.allBuildingSlots[bid] = tmpSlot
    return true
    -- end
end

function buildingSlotVoApi:remove(bid)
    if self.allBuildingSlots[bid] ~= nil then
        self.allBuildingSlots[bid] = nil
    end
end

function buildingSlotVoApi:getSlotByBid(bid)
    return self.allBuildingSlots[bid]
end

function buildingSlotVoApi:getFreeSlotNum() --空闲队列数量
    return (playerVoApi:getBuildingSlotNum() - SizeOfTable(self.allBuildingSlots))
end
function buildingSlotVoApi:remove(bid)
    self.allBuildingSlots[bid] = nil
end

function buildingSlotVoApi:getCanHaveSlotsMaxNum() --与VIP等级相关
    local vipLv = playerVo.vip
    local vipCfg = playerCfg.vip4BuildQueue
    return tonumber(Split(vipCfg, ",")[vipLv + 1])
end

--获取当前版本开放的最大vip等级对应的建筑位数目
function buildingSlotVoApi:getVersionMaxSlots()
    local maxVip = playerVoApi:getMaxLvByKey("maxVip")
    local vipCfg = Split(playerCfg.vip4BuildQueue, ",")
    if(vipCfg[maxVip + 1])then
        return tonumber(vipCfg[maxVip + 1])
    else
        return vipCfg[#vipCfg]
    end
end

function buildingSlotVoApi:getShortestSlot()
    
    local tab = {}
    for k, v in pairs(self.allBuildingSlots) do
        table.insert(tab, v)
    end
    table.sort(tab, function(a, b) return a.et < b.et end)
    return tab[1]
    
end

function buildingSlotVoApi:tick()
    
    for k, v in pairs(self.allBuildingSlots) do
        local buildVo = buildingVoApi:getBuildiingVoByBId(v.bid)
        if buildVo.status == 0 or buildVo.status == 1 then
            buildVo.status = 2
        end
        if buildVo.type == nil or buildVo.type == -1 then
            self.allBuildingSlots[k] = nil --前台先把队列移除了
            buildVo.status = 1
            buildVo.upgradePercent = 1
        else
            
            local buildCfg = buildingCfg[buildVo.type]
            
            buildVo.upgradePercent = (base.serverTime - v.st) / (v.et - v.st)
            if base.serverTime >= v.et then
                buildVo.upgradePercent = 1
                buildVo.status = 1
                if buildVo.level < buildingVoApi:canUpgradeMaxLevel(buildVo.type) then
                    buildVo.level = buildVo.level + 1
                    self.allBuildingSlots[k] = nil --前台先把队列移除了
                    self:upgradeSuccess(v.bid)
                    G_SyncData() --前台自己完成后需要和后台同步下
                end
            end
        end
    end
    
    local upgradeFlag = buildingVoApi:isCommanderCenterLvUp()
    if upgradeFlag == true then
        local unlockCfg = buildingVoApi:getUnlockBuildingCfg()
        for k, stepId in pairs(unlockCfg) do
            buildingGuildMgr:setGuildStep(stepId)
        end
        buildingVoApi:setCommandCenterLastLevel()
    end
end

function buildingSlotVoApi:upgradeSuccess(bid, showTipsWait)
    self.allBuildingSlots[bid] = nil
    local bvo = buildingVoApi:getBuildiingVoByBId(bid)
    G_cancelPush("b"..bid, G_BuildUpgradeTag)
    if bvo.type ~= -1 then
        bvo.status = 1
        if bvo.type == 8 or bvo.type == 6 or bvo.type == 9 then
            if bvo.level == 1 then --建造完成
                mainUI:pushSmallMenu()
                mainUI:pushSmallMenu()
            end
        end
        local bcfg = buildingCfg[bvo.type]
        local buildNameStr = getlocal(bcfg.buildName)
        if bvo.type == 17 then
            buildNameStr = getlocal("repair_factory")
        end
        local tipStr = getlocal("promptBuildFinish", {buildNameStr, bvo.level})
        --[[
        --主基地升级feed
        if newGuidMgr:isNewGuiding()==false and bid==1 and bvo.level>=5 then
if battleScene.isBattleing==true then
base.isShowFeedDialog=true
else
smallDialog:showUpgradeFeedDialog("PanelPopup.png",CCSizeMake(500,380),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,7)
end
else
        ]]
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(400, 300), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 25, nil, true, nil, nil, showTipsWait)
        --end
        if newGuidMgr:isNewGuiding() and bid == 11 then --新手引导
            newGuidMgr:toNextStep()
        end
    end
    if bid == 1 then
        activityVoApi:updateByBaseUpgradeSuccess()
        -- buildingVoApi:unlockBuildingTip()
    end
    eventDispatcher:dispatchEvent("building.upgrade.success", {bid = bid})
end

function buildingSlotVoApi:sortBuilding()
    --[[
    for k,v in pairs(self.allBuildingSlots) do
          local remainingTime=buildingVoApi:getUpgradeTotalTimeByBid(v.bid)-(base.serverTime-v.st)
          v.leftTime=remainingTime
    end
    table.sort(self.allBuildingSlots,function(a,b) return a.leftTime>b.leftTime end)
    return self.allBuildingSlots
    ]]
    local tmpTb = {}
    local tmpIndex = 1
    local inserted = false
    for k, v in pairs(self.allBuildingSlots) do
        v.leftTime = buildingVoApi:getUpgradeTotalTimeByBid(v.bid) - (base.serverTime - v.st)
        if #tmpTb == 0 then
            table.insert(tmpTb, 1, v)
        else
            inserted = false
            for kk, vv in pairs(tmpTb) do
                if inserted == false and v.leftTime >= vv.leftTime then
                    inserted = true
                    tmpIndex = kk
                end
            end
            if inserted == false then
                --table.insert(tmpTb,v)
                tmpIndex = #tmpTb + 1
            end
            table.insert(tmpTb, tmpIndex, v)
        end
    end
    return tmpTb
end

--检测该建筑是否可以免费加速升级或者建造
function buildingSlotVoApi:isCanFreeAcc(bid)
    if base.fs == 1 then
        local bvo = buildingVoApi:getBuildiingVoByBId(bid)
        -- print("bvo.status，bid------->>>>",bvo.status,bid)
        if bvo and bvo.status and bvo.status == 2 then
            local bsv = self:getSlotByBid(bvo.id)
            if bsv then
                local canSpeedTime = playerVoApi:getFreeTime()
                local leftTime = buildingVoApi:getUpgradeLeftTime(bvo.id)
                if leftTime and leftTime <= canSpeedTime then
                    return true
                end
            end
        end
    end
    return false
end

--免费加速处理逻辑
function buildingSlotVoApi:freeAccHandler(bid, btype, callback)
    local function serverSuperUpgrade(fn, data)
        if base:checkServerData(data) == true then
            if buildingVoApi:superUpgradeBuild(bid) then --加速成功
                base:tick()
            end
            if callback then
                callback()
            end
        end
    end
    if buildingVoApi:checkSuperUpgradeBuildBeforeServer(bid) == true then
        socketHelper:freeUpgradeBuild(bid, btype, serverSuperUpgrade)
    end
end
