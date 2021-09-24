require "luascript/script/game/gamemodel/building/buildingVo"

buildingVoApi = {
    allBuildings = {},
    jsTb = nil,
    upgradeRequire = {b = 7, r1 = 1, r2 = 2, r3 = 3},
    --serverChangeData=false  --存起来的数据在服务器更新数据后需要重新获取新数据
    
    autoUpgradeBuilds = 0, -- 是否开启自动升级建筑
    autoUpgradeExpire = 0, -- 自动升级建筑的剩余时间
    commandCenterLastLevel = 0, --指挥中心的升级前等级
    arenaTipTypeTb = {}, --作战中心各个大战功能红点标识存储
    removeBuildTs = 0, --拆除建筑cd
}

function buildingVoApi:clear()
    --self.serverChangeData=true
    for k, v in pairs(self.allBuildings) do
        v = nil
    end
    self.commandCenterLastLevel = 0
    self.allBuildings = {}
    self.arenaTipTypeTb = {}
    self.removeBuildTs = 0
end

function buildingVoApi:init()
    
    for k, v in pairs(homeCfg.buildingUnlock) do
        self.allBuildings[k] = buildingVo:new(k)
        if k == 15 or k == 52 then
            self:initBuild(k, v.type, 1)
        end
    end
end

function buildingVoApi:initBuild(id, t, l)
    local tmpVo = self.allBuildings[id]
    local s = 1
    --[[
     if buildingSlotVoApi.allBuildingSlots[id]~=nil then
         s=2
     end
     ]]
    tmpVo:initWithData(t, l, s)
    
    if id == 1 and self.commandCenterLastLevel == 0 then
        local uid = playerVoApi:getUid()
        local lastLevelKey = self:getCommandLastLevelKey(uid)
        local lastLevel = CCUserDefault:sharedUserDefault():getIntegerForKey(lastLevelKey)
        if lastLevel == 0 then
            self:setCommandCenterLastLevel()
        else
            self.commandCenterLastLevel = lastLevel
        end
    end
end

function buildingVoApi:remove(id)
    self.allBuildings[id] = nil
end

function buildingVoApi:getBuildiingVoByBId(id)
    local tmpVo = self.allBuildings[id]
    if tmpVo ~= nil then
        return tmpVo
    else
        return nil
    end
end
function buildingVoApi:getBuildingVoHaveByBtype(type)
    local resultTb = {}
    for k, v in pairs(self.allBuildings) do
        
        if v.type == type and v.level > 0 then
            --resultTb[k]=v
            table.insert(resultTb, v)
        end
    end
    return resultTb
end
function buildingVoApi:getBuildingVoByBtype(type)
    local resultTb = {}
    for k, v in pairs(self.allBuildings) do
        if v.type == type then
            --resultTb[k]=v
            table.insert(resultTb, v)
        end
    end
    return resultTb
end
--判断是否有某种建筑
function buildingVoApi:getBuildingVoIsBuildByBtype(type)
    local resultTb = {}
    local result = false
    for k, v in pairs(self.allBuildings) do
        if v.type == type then
            --resultTb[k]=v
            table.insert(resultTb, v)
        end
    end
    for k, v in pairs(resultTb) do
        if v.level > 0 then
            result = true;
        end
        
    end
    
    return result
    
end
function buildingVoApi:isHaveResBuilding()
    
    local isHave = false
    for i = 1, 4 do
        if self:getBuildingVoIsBuildByBtype(i) == true then
            isHave = true
            break
        end
    end
    return isHave
    
end

function buildingVoApi:unlockBuildingByCommanderCenterLevel()
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k <= buildVo.level then
            for i = 1, #infoTb do
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.status == -1 then --指挥中心达到等级，解锁建筑
                    tmpBuild.status = 0
                    if tmpBuild.id < 16 or tmpBuild.id > 100 then
                        tmpBuild.type = homeCfg.buildingUnlock[tmpBuild.id].type
                    end
                end
            end
        end
    end
end

function buildingVoApi:unlockBuildingTip()
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k == buildVo.level then
            for i = 1, #infoTb do
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.id < 16 then
                    
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("command_finish_tip")..getlocal("command_finish_tip_"..buildVo.level), 28)
                end
                
            end
        end
    end
end
--主基地升级解锁描述
function buildingVoApi:unlockBuildingDesc()
    local descStr = ""
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    local commonMineNum = 0
    local taiMineNum = 0
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k == buildVo.level then
            for i = 1, #infoTb do
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.id < 16 or tmpBuild.id > 100 then
                    descStr = getlocal("command_finish_tip_"..buildVo.level) .. ","
                end
                if (tonumber(infoTb[i])) > 15 and (tonumber(infoTb[i])) < 45 then
                    commonMineNum = commonMineNum + 1
                end
                if (tonumber(infoTb[i])) >= 45 then
                    taiMineNum = taiMineNum + 1
                end
            end
        end
    end
    if commonMineNum > 0 then
        descStr = descStr..getlocal("unlockCommonMine", {commonMineNum}) .. ","
    end
    if taiMineNum > 0 then
        descStr = descStr..getlocal("unlockTaiMine", {taiMineNum}) .. ","
    end
    if descStr ~= "" then
        descStr = getlocal("upgradeUnlock")..descStr
        descStr = string.sub(descStr, 1, -2)
    end
    return descStr
end

function buildingVoApi:getPortBuilding()
    local resultTb = {}
    
    for k, v in pairs(self.allBuildings) do
        if v.status > 0 and (v.id < 16 or v.id > 100 or v.id == 52 ) then
            resultTb[v.id] = v
        end
    end
    
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k <= buildVo.level then
            for i = 1, #infoTb do
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.status == -1 and (tmpBuild.id < 16 or tmpBuild.id > 100 or tmpBuild.id == 52 ) then --指挥中心达到等级，解锁建筑
                    tmpBuild.status = 0
                    tmpBuild.type = homeCfg.buildingUnlock[tmpBuild.id].type
                end
                --如果是地库的话, 只有本账号以前做过地库引导, 地库才会出现
                if(tmpBuild.id == 15)then
                    -- if(otherGuideMgr:checkGuide(1))then
                    --     tmpBuild.status = 1
                    -- else
                    --     tmpBuild.status = -1
                    --     tmpBuild.type = -1
                    -- end
                    resultTb[tmpBuild.id] = tmpBuild
                elseif tmpBuild.status <= 0 and (tmpBuild.id < 16 or tmpBuild.id > 100 or tmpBuild.id == 52) then
                    --id:8 异星科技，10异星工厂
                    if tmpBuild.id == 14 or tmpBuild.id == 9 or tmpBuild.id == 8 or tmpBuild.id == 10 or tmpBuild.id == 101 or tmpBuild.id == 102 or tmpBuild.id == 103 then
                        tmpBuild.status = 1
                    end
                    resultTb[tmpBuild.id] = tmpBuild
                end
            end
        else --未解锁的也要显示
            for i = 1, #infoTb do
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.id < 16 or tmpBuild.id > 100 or tmpBuild.id == 52 then
                    resultTb[tmpBuild.id] = tmpBuild
                end
            end
        end
    end
    return resultTb
end

function buildingVoApi:getHomeBuilding()
    local resultTb = {}
    for k, v in pairs(self.allBuildings) do
        if v.status > 0 and (v.id >= 16 and v.id <= 100) then
            resultTb[v.id] = v
        end
    end
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k <= buildVo.level then
            for i = 1, #infoTb do
                
                local tmpBuild = self.allBuildings[tonumber(infoTb[i])]
                if tmpBuild.status == -1 and (tmpBuild.id >= 16 and tmpBuild.id <= 100) then --指挥中心达到等级，解锁建筑
                    tmpBuild.status = 0
                end
                if tmpBuild.status == 0 and (tmpBuild.id >= 16 and tmpBuild.id <= 100) then
                    resultTb[tmpBuild.id] = tmpBuild
                end
            end
        end
    end
    return resultTb
end

function buildingVoApi:getUpgradeBuildRequire(bid, btype)
    if bid ~= nil then
        local bvo = self:getBuildiingVoByBId(bid)
        
        if bvo.type == -1 then
            local bcfg = buildingCfg[btype]
            return {1, Split(bcfg.metalConsumeArray, ",")[1], Split(bcfg.oilConsumeArray, ",")[1], Split(bcfg.siliconConsumeArray, ",")[1]}
        else
            local curLevel = bvo.level
            local nextLevel = curLevel + 1
            local bcfg = buildingCfg[bvo.type]
            if bvo.type == 7 then
                return {curLevel, Split(bcfg.metalConsumeArray, ",")[nextLevel], Split(bcfg.oilConsumeArray, ",")[nextLevel], Split(bcfg.siliconConsumeArray, ",")[nextLevel]}
            else
                
                return {nextLevel, Split(bcfg.metalConsumeArray, ",")[nextLevel], Split(bcfg.oilConsumeArray, ",")[nextLevel], Split(bcfg.siliconConsumeArray, ",")[nextLevel]}
            end
        end
        
    end
end

function buildingVoApi:checkUpgradeRequire(bid, btype)
    local require = self:getUpgradeBuildRequire(bid, btype)
    local results = {}
    local result = true
    local have = {}
    if require[1] > self:getBuildingVoByBtype(7)[1].level then
        results[1] = false
        result = false
        
    else
        results[1] = true
    end
    have[1] = self:getBuildingVoByBtype(7)[1].level
    
    local desVate = 1
    local levelVo = activityVoApi:getActivityVo("leveling")
    if levelVo ~= nil and activityVoApi:isStart(levelVo) == true and bid == 1 then
        desVate = acLevelingVoApi:getDesVate()
    end
    
    local level2Vo = activityVoApi:getActivityVo("leveling2")
    if level2Vo ~= nil and activityVoApi:isStart(level2Vo) == true and bid == 1 then
        if acLeveling2VoApi:checkIfDesVate() == true then
            desVate = acLeveling2VoApi:getDesVate()
        end
    end
    
    if tonumber(math.ceil(require[2] * desVate)) > playerVoApi:getR1() then
        results[2] = false
        result = false
    else
        results[2] = true
    end
    have[2] = playerVoApi:getR1()
    if tonumber(math.ceil(require[3] * desVate)) > playerVoApi:getR2() then
        results[3] = false
        result = false
    else
        results[3] = true
    end
    have[3] = playerVoApi:getR2()
    if tonumber(math.ceil(require[4] * desVate)) > playerVoApi:getR3() then
        results[4] = false
        result = false
    else
        results[4] = true
    end
    have[4] = playerVoApi:getR3()
    return result, results, have
end

function buildingVoApi:checkUpgradeBeforeSendServer(bid, btype)
    
    if buildingSlotVoApi:getFreeSlotNum() <= 0 then
        do
            return 1
        end
    end
    local require = self:getUpgradeBuildRequire(bid, btype)
    local result = self:checkUpgradeRequire(bid, btype)
    if result == false then
        do
            return 2
        end
    end
    return 0
end
function buildingVoApi:upgrade(bid, btype, st, et)
    
    local bvo = self:getBuildiingVoByBId(bid)
    local type
    local level
    if bvo.type ~= -1 then
        type = bvo.type
        level = bvo.level + 1
    else
        type = btype
        level = 1
    end
    --buildingSlotVoApi:add(bid,st,et) --添加队列
    bvo:initWithData(type, level - 1, 2)
    --playerVoApi:useResource(require[2],require[3],require[4],0,0,0)
    if level == 1 then
        buildings:upgrade(bid, true)--需要换图
    end
    return true
end

function buildingVoApi:removeBuild(bid)
    local bvo = self:getBuildiingVoByBId(bid)
    bvo:initWithData(-1, 0, 0)
    buildings:removeBuild(bid)--移除建筑
end
--获取正常的建筑升级下一级的信息
function buildingVoApi:getUpgradeTotalTimeByBid(bid)
    local bvo = self:getBuildiingVoByBId(bid)
    return tonumber(Split(buildingCfg[bvo.type].timeConsumeArray, ",")[bvo.level + 1])
end

--取消建筑升级 返回值 0:已经升级完成
function buildingVoApi:checkCancleUpgradeBuildBeforeServer(bid)
    local bvo = self:getBuildiingVoByBId(bid)
    if bvo.status == 1 then
        local tsD = smallDialog:new()
        tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisfinish"), nil, 10)
        do
            return false
        end
    end
    return true
end
--取消建筑升级 返回值 0:已经升级完成
function buildingVoApi:cancleUpgradeBuild(bid)
    do
        return true
    end
    local bvo = self:getBuildiingVoByBId(bid)
    G_cancelPush("b"..bid, G_BuildUpgradeTag)
    if bvo.status == 1 then
        local tsD = smallDialog:new()
        tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisfinish"), nil, 10)
        do
            return false
        end
    elseif bvo.status == 2 then
        if bvo.level > 0 then
            bvo.status = 1 --修改建筑状态
        else
            bvo.status = 0
        end
        buildingSlotVoApi:remove(bvo.id) --移除升级队列
        --退还部分资源
        local require = buildingVoApi:getUpgradeBuildRequire(bid, bvo.type)
        local th = 0.5
        playerVoApi:useResource(-math.ceil(require[2] * th), -math.ceil(require[3] * th), -math.ceil(require[4] * th), 0, 0, 0)
        
    end
    return true
end

function buildingVoApi:checkSuperUpgradeBuildBeforeServer(bid)
    local bvo = self:getBuildiingVoByBId(bid)
    if bvo.status == 1 then
        local tsD = smallDialog:new()
        tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisSpeed"), nil, 10)
        do
            return false
        end
    elseif bvo.status == 2 then
        --[[
        local gems=TimeToGems(tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1]))
        if gems>playerVoApi:getGems() then --宝石不足
             GemsNotEnoughDialog(nil,nil,gems-playerVoApi:getGems())
             do
                return false
             end
        end
        ]]
    end
    return true
end

function buildingVoApi:superUpgradeBuild(bid, showTipsWait)
    buildingSlotVoApi:upgradeSuccess(bid, showTipsWait)
    do
        return true
    end
    local bvo = self:getBuildiingVoByBId(bid)
    if bvo.status == 1 then
        local tsD = smallDialog:new()
        tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisSpeed"), nil, 10)
        do
            return false
        end
    elseif bvo.status == 2 then
        bvo.status = 1 --修改建筑状态
        buildingSlotVoApi:upgradeSuccess(bvo.id, showTipsWait)
        --[[
        local gems=TimeToGems(tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1]))
        if gems>playerVoApi:getGems() then --宝石不足
             GemsNotEnoughDialog(nil,nil,gems-playerVoApi:getGems())    
             do
                return false
             end
        else --加速成功
                
             --playerVoApi:useResource(0,0,0,0,0,gems)
             
             bvo.status=1 --修改建筑状态
 
             --bvo.level=bvo.level+1
             --buildingSlotVoApi:remove(bvo.id) --移除升级队列
             buildingSlotVoApi:upgradeSuccess(bvo.id)
        end]]
    end
    return true
end

function buildingVoApi:getTotalProduceCapacity()
    local r1, r2, r3, r4, gd
    local r1Cfg, r2Cfg, r3Cfg, r4Cfg, gdCfg = buildingCfg[1], buildingCfg[2], buildingCfg[3], buildingCfg[4], buildingCfg[5]
    local c1, c2, c3, c4, c5 = 0, 0, 0, 0, 0
    for k, v in pairs(self.allBuildings) do
        if v.level > 0 then
            if v.type == 1 then
                c1 = c1 + tonumber(Split(r1Cfg.capacity, ",")[v.level])
            elseif v.type == 2 then
                c2 = c2 + tonumber(Split(r2Cfg.capacity, ",")[v.level])
            elseif v.type == 3 then
                c3 = c3 + tonumber(Split(r3Cfg.capacity, ",")[v.level])
            elseif v.type == 4 then
                c4 = c4 + tonumber(Split(r4Cfg.capacity, ",")[v.level])
            elseif v.type == 5 then
                c5 = c5 + tonumber(Split(gdCfg.capacity, ",")[v.level])
            end
        end
    end
    local commandCenter = self:getBuildingVoByBtype(7)[1] --指挥中心只有一个且等级至少是一级
    local cbCfg = buildingCfg[7]
    local ccenter = tonumber(Split(cbCfg.capacity, ",")[commandCenter.level])
    c1 = c1 + ccenter
    c2 = c2 + ccenter
    c3 = c3 + ccenter
    c4 = c4 + ccenter
    c5 = c5 + ccenter
    local restores = self:getBuildingVoByBtype(10) --仓库有可能没有
    local cCfg = buildingCfg[10]
    local cc = 0
    for k, v in pairs(restores) do
        if v.level > 0 then
            cc = tonumber(Split(cCfg.capacity, ",")[v.level])
            c1 = c1 + cc
            c2 = c2 + cc
            c3 = c3 + cc
            c4 = c4 + cc
            c5 = c5 + cc
        end
    end
    
    --加成值
    local upPercent = 0
    --vip
    local warehouseStorage = playerCfg.warehouseStorage[playerVoApi:getVipLevel() + 1]
    upPercent = upPercent + warehouseStorage
    --技能
    local techVo2 = technologyVoApi:getTechVoByTId(25)
    if techVo2 ~= nil then
        if techVo2.level ~= nil and techVo2.level > 0 then
            upPercent = upPercent + 0.05 * techVo2.level
            -- local upPercent=0.05*techVo2.level
            -- c1=math.floor(c1*upPercent)+c1
            -- c2=math.floor(c2*upPercent)+c2
            -- c3=math.floor(c3*upPercent)+c3
            -- c4=math.floor(c4*upPercent)+c4
            -- c5=math.floor(c5*upPercent)+c5
        end
    end
    --军徽技能提升
    local emblemValue = 0
    if base.emblemSwitch == 1 then
        local emblemValue = emblemVoApi:getSkillValue(6)
        upPercent = upPercent + emblemValue
    end

    --战机改装技能加成（直接加总容量）
    local cadd = planeRefitVoApi:getSkvByType(52)
    
    c1 = math.floor(c1 * upPercent) + c1 + cadd
    c2 = math.floor(c2 * upPercent) + c2 + cadd
    c3 = math.floor(c3 * upPercent) + c3 + cadd
    c4 = math.floor(c4 * upPercent) + c4 + cadd
    c5 = math.floor(c5 * upPercent) + c5 + cadd
    
    return c1, c2, c3, c4, c5
end

--获取指定类型资源的产量和容量加成总和--> btype：资源类型 showFlag：是否作为显示加成详情用
function buildingVoApi:getTotalProduceSpeedAndCapacityByBType(btype, showFlag)
    local allBuildVo = self:getBuildingVoByBtype(btype)
    local tspeed = 0
    local tcapacity = 0
    local sdetail = {} --产量详情
    local cdetail = {} --容量详情
    local function getAddedStr(value, isBase, isCapacity)
        if isBase and isBase == true then
            if isCapacity and isCapacity == true then
                return value
            else
                return value..getlocal("schedule_hours")
            end
        else
            local percent = tonumber(value) * 100
            return "+"..percent.."%"
        end
    end
    if allBuildVo then
        local bspeed = 0 --资源建筑产量基础加成
        local bcapacity = 0 --资源建筑容量基础加成
        local bCfg = buildingCfg[btype]
        for k, v in pairs(allBuildVo) do
            if v.level > 0 then
                bspeed = bspeed + tonumber(Split(bCfg.produceSpeed, ",")[v.level])
                bcapacity = bcapacity + tonumber(Split(bCfg.capacity, ",")[v.level])
            end
        end
        tspeed = tspeed + bspeed
        tcapacity = tcapacity + bcapacity
        if showFlag and showFlag == true then
            local descStr = getlocal(bCfg.buildName)
            if bspeed > 0 then
                local sbAddn = {key = {descStr}, value = {getAddedStr(bspeed, true)}} --产量基础加成信息
                table.insert(sdetail, sbAddn)
            end
            if bcapacity > 0 then
                local abAddn = {key = {descStr}, value = {getAddedStr(bcapacity, true, true)}} --容量基础加成信息
                table.insert(cdetail, abAddn)
            end
        end
    end
    
    local commandCenter = self:getBuildingVoByBtype(7)[1] --指挥中心只有一个且等级至少是一级
    if commandCenter then
        local cbCfg = buildingCfg[7]
        local bspeed = tonumber(Split(cbCfg.produceSpeed, ",")[commandCenter.level])
        local bcapacity = tonumber(Split(cbCfg.capacity, ",")[commandCenter.level])
        tspeed = tspeed + bspeed
        tcapacity = tcapacity + bcapacity
        if showFlag and showFlag == true then
            local descStr = getlocal(cbCfg.buildName)
            if bspeed > 0 then
                local sbAddn = {key = {descStr}, value = {getAddedStr(bspeed, true)}}
                table.insert(sdetail, sbAddn)
            end
            if bcapacity > 0 then
                local abAddn = {key = {descStr}, value = {getAddedStr(bcapacity, true, true)}}
                table.insert(cdetail, abAddn)
            end
        end
    end
    local baseSpeed = tspeed
    local restores = self:getBuildingVoByBtype(10) --仓库有可能没有
    if restores then
        local bcapacity = 0
        local bCfg = buildingCfg[10]
        for k, v in pairs(restores) do
            if v.level > 0 then
                bcapacity = bcapacity + tonumber(Split(bCfg.capacity, ",")[v.level])
            end
        end
        tcapacity = tcapacity + bcapacity
        if showFlag and showFlag == true and bcapacity > 0 then
            local descStr = getlocal(bCfg.buildName)
            local abAddn = {key = {descStr}, value = {getAddedStr(bcapacity, true, true)}}
            table.insert(cdetail, abAddn)
        end
    end
    
    local techIDs = {15, 16, 17, 18, 19}
    local techId = techIDs[tonumber(btype)]
    local techVo = technologyVoApi:getTechVoByTId(techId)
    local addSpeed = 0
    if techVo ~= nil then
        if techVo.level ~= nil and techVo.level > 0 then
            local upPercent = 0.05 * techVo.level
            addSpeed = math.floor(baseSpeed * upPercent)
            if showFlag and showFlag == true and upPercent > 0 then
                local descStr = getlocal(techCfg[techVo.id].name)
                local sbAddn = {key = {descStr}, value = {getAddedStr(upPercent), G_ColorGreen}}
                table.insert(sdetail, sbAddn)
            end
        end
    end
    
    local slotTb = useItemSlotVoApi:getAllSlots()
    if slotTb then
        local percentAdd = 0
        for k, v in pairs(slotTb) do
            if propCfg["p"..k].buffType == btype then
                local percent = propCfg["p"..k].buffValue / 100
                addSpeed = addSpeed + math.floor(baseSpeed * percent)
                percentAdd = percentAdd + percent
                break
            end
        end
        if showFlag and showFlag == true and percentAdd > 0 then
            local descStr = getlocal("advancePropAddedStr")
            local sbAddn = {key = {descStr}, value = {getAddedStr(percentAdd), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    
    tspeed = tspeed + addSpeed
    local result, baseNum = allianceVoApi:isAllianceWarBuff()
    if result then
        tspeed = tspeed + math.floor(baseSpeed * (baseNum / 100))
        if showFlag and showFlag == true and baseNum > 0 then
            local descStr = getlocal("addedStr", {getlocal("alliance_war")..getlocal("fight_content_result_win")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(baseNum / 100), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    
    local baseCapacity = tcapacity
    local techAdd25 = 0 --储存技术科技加成
    local warehouseStorage = 0 --vip加成
    local techVo2 = technologyVoApi:getTechVoByTId(25)
    if techVo2 ~= nil then
        if techVo2.level ~= nil and techVo2.level > 0 then
            warehouseStorage = playerCfg.warehouseStorage[playerVoApi:getVipLevel() + 1]
            techAdd25 = 0.05 * techVo2.level
            local upPercent = techAdd25 + warehouseStorage
            tcapacity = math.floor(baseCapacity * upPercent) + tcapacity
        else
            warehouseStorage = playerCfg.warehouseStorage[playerVoApi:getVipLevel() + 1]
            tcapacity = math.floor(baseCapacity * warehouseStorage) + tcapacity
        end
    else
        warehouseStorage = playerCfg.warehouseStorage[playerVoApi:getVipLevel() + 1]
        tcapacity = math.floor(baseCapacity * warehouseStorage) + tcapacity
    end
    if techAdd25 > 0 then
        if showFlag and showFlag == true then
            local descStr = getlocal(techCfg[techVo2.id].name)
            local abAddn = {key = {descStr}, value = {getAddedStr(techAdd25), G_ColorGreen}}
            table.insert(cdetail, abAddn)
        end
    end
    if warehouseStorage > 0 then
        if showFlag and showFlag == true then
            local vipStr = getlocal("vipPrivilege")
            local descStr = getlocal("addedStr", {vipStr})
            local abAddn = {key = {descStr}, value = {getAddedStr(warehouseStorage), G_ColorGreen}}
            table.insert(cdetail, abAddn)
        end
    end
    --军徽技能提升
    if base.emblemSwitch == 1 then
        local emblemValue, eid = emblemVoApi:getSkillValue(6)
        tcapacity = math.floor(baseCapacity * emblemValue) + tcapacity
        if showFlag and showFlag == true and emblemValue > 0 and eid then
            local emblemName = emblemVoApi:getEquipName(eid)
            local descStr = getlocal("addedStr", {emblemName})
            local abAddn = {key = {descStr}, value = {getAddedStr(emblemValue), G_ColorGreen}}
            table.insert(cdetail, abAddn)
        end
    end

    --战机改装技能加成（直接加总容量）
    local cadd = planeRefitVoApi:getSkvByType(52)
    if cadd > 0 then
        tcapacity = tcapacity + cadd
        if showFlag == true then
            local descStr = getlocal("addedStr", {getlocal("planeRefit_text")})
            local abAddn = {key = {descStr}, value = {getAddedStr(cadd, true, true), G_ColorGreen}}
            table.insert(cdetail, abAddn)
        end
    end

    if checkPointVoApi then
        local addPercent = checkPointVoApi:getResAddPercent()
        tspeed = tspeed + math.floor(baseSpeed * addPercent)
        if showFlag and showFlag == true and addPercent > 0 then
            local descStr = getlocal("checkpointAddedStr")
            local sbAddn = {key = {descStr}, value = {getAddedStr(addPercent), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    
    --区域战buff
    local buffValue = 0
    if localWarVoApi then
        local buffType = 7
        local buffTab = localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab, buffType) == true then
            buffValue = G_getLocalWarBuffValue(buffType)
        end
        tspeed = tspeed + math.floor(baseSpeed * buffValue)
        if showFlag and showFlag == true and buffValue > 0 then
            local descStr = getlocal("localWarAddedStr")
            local sbAddn = {key = {descStr}, value = {getAddedStr(buffValue), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    
    if base.isGlory == 1 then
        local bufValue = nil
        if gloryVoApi:isGloryOver() == true then
            bufValue = gloryCfg.destoryGlory.prductAdd
        else
            local gloryTb = gloryVoApi:getPlayerGlory()
            bufValue = gloryTb.productAdd
        end
        tspeed = tspeed + math.floor(baseSpeed * bufValue)
        if showFlag and showFlag == true and bufValue > 0 then
            local descStr = getlocal("addedStr", {getlocal("island")..getlocal("gloryDegreeStr")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(bufValue), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    --NB技能系统的buff
    -- local skillAdd=skillVoApi:getSkillAddPerById("s201")
    -- if(skillAdd>0)then
    --   tspeed=tspeed+math.floor(baseSpeed*skillAdd)
    --   if showFlag and showFlag==true then
    --     local nameKey=skillVoApi:getSkillNameById("s201")
    --     local descStr=getlocal("addedStr",{getlocal(nameKey)})
    --     local sbAddn={key={descStr},value={getAddedStr(skillAdd),G_ColorGreen}}
    --     table.insert(sdetail,sbAddn)
    --   end
    -- end
    --三周活动七重福利所加的buff
    local threeYearAdd = 0
    if acThreeYearVoApi then
        local upPercent = acThreeYearVoApi:getBuffAdded(3)
        threeYearAdd = baseSpeed * upPercent
        if showFlag and showFlag == true and upPercent > 0 then
            local descStr = getlocal("addedStr", {getlocal("activity_threeyear_title")..getlocal("activity")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(upPercent), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    local btzxAdd = 0
    if acBtzxVoApi and acBtzxVoApi:isActiveTime("btzx") then
        local upPercent = acBtzxVoApi:buildAdd("btzx")
        btzxAdd = baseSpeed * upPercent
        if showFlag and showFlag == true and upPercent > 0 then
            local descStr = getlocal("addedStr", {getlocal("activity_btzx_title")..getlocal("activity")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(upPercent), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
    end
    tspeed = tspeed + threeYearAdd + btzxAdd
    
    local warStatueBuff = 0 --战争塑像的加成
    local battleBuff, skillBuff = warStatueVoApi:getTotalWarStatueAddedBuff("madeSpeed")
    warStatueBuff = skillBuff.madeSpeed or 0
    if warStatueBuff > 0 then
        if showFlag and showFlag == true then
            local descStr = getlocal("addedStr", {getlocal("warStatue_title")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(warStatueBuff), G_ColorGreen}}
            table.insert(sdetail, sbAddn)
        end
        warStatueBuff = baseSpeed * warStatueBuff
        tspeed = tspeed + warStatueBuff
    end
    
    --水晶丰收周是最终产量翻倍。--注意：将此加成代码始终放在最后面
    if acCrystalYieldVoApi ~= nil and acCrystalYieldVoApi:getAcVo() ~= nil and base.serverTime > acCrystalYieldVoApi:getAcVo().st and base.serverTime < acCrystalYieldVoApi:getAcVo().et and btype == 5 then
        tspeed = tspeed * 2
        if showFlag and showFlag == true then
            local descStr = getlocal("crystalYield")..getlocal("activity") .. "("..getlocal("totalres_speed") .. ")"
            local sbAddn = {key = {descStr}, value = {getAddedStr(1), G_ColorOrange}}
            table.insert(sdetail, sbAddn)
        end
    end

    --战机改装技能加成（直接加采集速度）
    local sadd = planeRefitVoApi:getSkvByType(54)
    if sadd > 0 then
        tspeed = tspeed + sadd
        if showFlag == true then
            local descStr = getlocal("addedStr", {getlocal("planeRefit_text")})
            local sbAddn = {key = {descStr}, value = {getAddedStr(sadd, true), G_ColorGreen}}
            table.insert(sdetail, sbAddn)    
        end
    end
    
    if showFlag and showFlag == true then
        if tspeed > 0 then
            local descStr = getlocal("totalres_speed")
            local sbAddn = {key = {descStr, G_ColorYellowPro}, value = {getAddedStr(tspeed, true), G_ColorYellowPro}}
            table.insert(sdetail, 1, sbAddn)
        end
        if tcapacity > 0 then
            local descStr = getlocal("totalres_capacity")
            local abAddn = {key = {descStr, G_ColorYellowPro}, value = {getAddedStr(tcapacity, true, true), G_ColorYellowPro}}
            table.insert(cdetail, 1, abAddn)
        end
    end
    
    return tspeed, tcapacity, sdetail, cdetail
end

function buildingVoApi:getBuildingsEnableUpgrade()
    local buildTab = {};
    for k, v in pairs(self.allBuildings) do
        if v.type == 18 and not self:isBuildingOpen(v.type) then
        elseif tonumber(v.status) == 1 and tonumber(v.id) ~= 15 then
            if v.level > 0 and v.type ~= -1 and v.type ~= 9 then
                if tonumber(v.level) < self:canUpgradeMaxLevel(v.type) then

                    table.insert(buildTab, v)
                    
                end
            end
        end
    end
    table.sort(buildTab, function(a, b) return a.level < b.level end)
    
    for k, v in pairs(buildingSlotVoApi:sortBuilding()) do
        if tonumber(v.bid) ~= 15 then
            table.insert(buildTab, 1, buildingVoApi:getBuildiingVoByBId(v.bid))
        end
    end
    
    return buildTab;
    
end

function buildingVoApi:isBuildingOpen(bType,bId)---某些建筑需要特殊判断是否开启或等级到达
    if bType == 18 then
        return airShipVoApi:isCanEnter()
    end
end

--取出每种资源所占百分比
function buildingVoApi:getResourcePercent()
    local r1, r2, r3, r4, rG = 0, 0, 0, 0, 0;
    local r1t, r2t, r3t, r4t, rGt = self:getTotalProduceCapacity()
    -- local a,r1t=self:getTotalProduceSpeedAndCapacityByBType(1)
    r1 = (playerVoApi:getR1() / r1t) * 100
    
    -- local b,r2t=self:getTotalProduceSpeedAndCapacityByBType(2)
    r2 = (playerVoApi:getR2() / r2t) * 100
    
    -- local c,r3t=self:getTotalProduceSpeedAndCapacityByBType(3)
    r3 = (playerVoApi:getR3() / r3t) * 100
    
    -- local d,r4t=self:getTotalProduceSpeedAndCapacityByBType(4)
    r4 = (playerVoApi:getR4() / r4t) * 100
    
    -- local e,rGt=self:getTotalProduceSpeedAndCapacityByBType(5)
    rG = (playerVoApi:getGold() / rGt) * 100
    
    return r1, r2, r3, r4, rG;
    
end

function buildingVoApi:getProtectResource()
    local tab = self:getBuildingVoByBtype(10)
    local ret = 0
    for k, v in pairs(tab) do
        if v.level > 0 then
            ret = ret + tonumber(Split(buildingCfg[v.type].capacity, ",")[v.level])
        end
    end
    
    -------------------- start vip新特权 仓库保护量增加
    local vipPrivilegeSwitch = base.vipPrivilegeSwitch
    if vipPrivilegeSwitch and vipPrivilegeSwitch.vps == 1 and playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.protectResources then
        local vipLevel = playerVoApi:getVipLevel()
        local protectResCfg = playerCfg.vipRelatedCfg.protectResources
        local needLevel, multiple = protectResCfg[1], protectResCfg[2]
        if vipLevel > 0 and needLevel and multiple and vipLevel >= needLevel then
            ret = ret * multiple
        end
    end
    --------------------- end
    
    --区域战buff
    local buffValue = 0
    if localWarVoApi then
        local buffType = 9
        local buffTab = localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab, buffType) == true then
            buffValue = G_getLocalWarBuffValue(buffType)
        end
    end
    
    --军徽技能提升
    local upPercent = 0
    if base.emblemSwitch == 1 then
        local emblemValue = emblemVoApi:getSkillValue(6)
        upPercent = upPercent + emblemValue
    end
    
    --科技
    local tecVo = technologyVoApi:getTechVoByTId(25)
    if tecVo.level > 0 then
        upPercent = upPercent + tonumber(Split(techCfg[25].value, ",")[tecVo.level]) / 100
    end
    ret = math.floor(ret * (1 + upPercent) * (1 - buffValue))

    --(战机改装技能加成)
    local prtctAdd = planeRefitVoApi:getSkvByType(55)
    ret = ret + prtctAdd
    
    return ret
end

--获取正在升级的建筑剩余时间
function buildingVoApi:getUpgradeLeftTime(bid)
    local result = 0
    local svo = buildingSlotVoApi:getSlotByBid(bid)
    if svo then
        result = svo.et - base.serverTime
        if result < 0 then
            result = 0
        end
    end
    return result
end

--获取正在升级的建筑总升级时长
function buildingVoApi:getUpgradingTotalUpgradeTime(bid)
    local svo = buildingSlotVoApi:getSlotByBid(bid)
    if svo == nil then
        do
            return nil
        end
    end
    return svo.et - svo.st
end
--获取建造时间(需要考虑科技)
function buildingVoApi:getBuildingTime(btype, level)
    local bcfg = buildingCfg[btype]
    local tcf = tonumber(Split(bcfg.timeConsumeArray, ",")[level + 1])
    
    --区域战buff
    local buffValue = 0
    if localWarVoApi then
        local buffType = 1
        local buffTab = localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab, buffType) == true then
            buffValue = G_getLocalWarBuffValue(buffType)
        end
    end
    
    local totalValue = 1 + buffValue
    local jzxTechVo = technologyVoApi:getTechVoByTId(23)
    if jzxTechVo ~= nil and jzxTechVo.level > 0 then
        totalValue = totalValue + 0.05 * jzxTechVo.level
    end
    --三周活动七重福利所加的buff
    local threeYearAdd = 0
    if acThreeYearVoApi then
        threeYearAdd = acThreeYearVoApi:getBuffAdded(6)
    end
    totalValue = totalValue + threeYearAdd
    
    --军徽技能提升
    local emblemValue = 0
    if base.emblemSwitch == 1 then
        emblemValue = emblemVoApi:getSkillValue(4)
        totalValue = totalValue + emblemValue
    end
    
    local warStatueBuff = 0 --战争塑像的加成
    local battleBuff, skillBuff = warStatueVoApi:getTotalWarStatueAddedBuff("buildSpeed")
    warStatueBuff = skillBuff.buildSpeed or 0
    totalValue = totalValue + warStatueBuff
    
    tcf = math.ceil(tcf / totalValue)
    
    return tcf
end

--判断是否所有建筑等级全是最高级别
function buildingVoApi:isAllBuildingsMax()
    local isAllMax = true
    local buildingsNum = 0
    for k, v in pairs(self.allBuildings) do
        --判断是否是可以建造和升级的建筑
        if v and v.type and v.type > 0 and (v.type <= 10 or v.type == 14) then
            buildingsNum = buildingsNum + 1
            if v.level < self:canUpgradeMaxLevel(v.type) then
                isAllMax = false
                break
            end
        end
    end
    if buildingsNum < homeCfg.canBuildNumber then
        isAllMax = false
    end
    return isAllMax
end

--同一类type的，等级level最高的建筑
function buildingVoApi:getBuildingVoByLevel(type)
    local bvo = nil
    local haveTypeTab = self:getBuildingVoHaveByBtype(type)
    if haveTypeTab and SizeOfTable(haveTypeTab) > 0 then
        for k, v in pairs(haveTypeTab) do
            if v and v.level and v.level > 0 then
                if bvo == nil then
                    bvo = v
                else
                    if bvo.level and bvo.level < v.level then
                        bvo = v
                    end
                end
            end
        end
    end
    return bvo
end

--解锁的资源地块的数量
function buildingVoApi:unlockResourcePortNum()
    local portNum = 0
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k <= buildVo.level then
            for i = 1, #infoTb do
                local portId = infoTb[i]
                if portId and (tonumber(portId) >= 16 and tonumber(portId) <= 100)then
                    portNum = portNum + 1
                end
            end
        end
    end
    return portNum
end

--是否还有空的资源地块
function buildingVoApi:isHasEmptyPort()
    local portNum = self:unlockResourcePortNum()
    local hasResourcePortNum = 0
    for i = 1, 4 do
        local haveTypeTab = self:getBuildingVoHaveByBtype(i)
        if haveTypeTab then
            hasResourcePortNum = hasResourcePortNum + SizeOfTable(haveTypeTab)
        end
    end
    if portNum == hasResourcePortNum then
        return false
    end
    return true
end

--是否还有没建造的建筑
function buildingVoApi:isHasNOBuild()
    local isHas = false
    for k, v in pairs(self.allBuildings) do
        if v.status == 0 then
            isHas = true
            break
        end
    end
    return isHas
end

-- 显示装置车间（优化后）
function buildingVoApi:showWorkshop(bid, type, layerNum, level)
    require "luascript/script/game/scene/gamedialog/portbuilding/workshopDialog"
    local bName = getlocal(buildingCfg[type].buildName)
    local td = workshopDialog:new(bid)
    local tbArr
    if level == 0 then
        tbArr = {getlocal("buildingTab"), getlocal("startProduceProp"), getlocal("chuanwu_scene_process")}
    else
        tbArr = {getlocal("startProduceProp"), getlocal("chuanwu_scene_process")}
    end
    -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..self:getLevel()..")",true,3)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName, true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
function buildingVoApi:isBuildingVisible(bid)
    -- 指挥中心的等级
    local zhhzxVo = self:getBuildiingVoByBId(1)
    local zhhzxLevel = zhhzxVo.level
    -- 玩家等级
    local playerLevel = playerVoApi:getPlayerLevel()
    local heroOpenLv = base.heroOpenLv or 20
    local heroEquipOpenLv = base.heroEquipOpenLv or 30
    local expeditionOpenLv = base.expeditionOpenLv or 25
    local superWeaponOpenLv = base.superWeaponOpenLv or 25
    local alienTechOpenLv = base.alienTechOpenLv or 22
    local flag = false
    if bid < 16 or bid >= 101 or bid == 52 then
        if homeCfg.buildingUnDisplay[bid][1] <= zhhzxLevel and homeCfg.buildingUnDisplay[bid][2] <= playerLevel then
            flag = true
        end
        if bid == 101 and G_isMemoryServer() == true then --配件车间 怀旧服做一下特殊处理
            if accessoryCfg.accessoryUnlockLv <= playerLevel then
                flag = true
            end
        end
        if flag and (base.richMineOpen == 0 or base.alien == 0 or playerLevel < alienTechOpenLv) and (bid == 8 or bid == 10) then
            flag = false
        elseif flag and base.heroSwitch == 0 and bid == 9 then
            flag = false
        elseif flag and base.ifAccessoryOpen == 0 and bid == 101 then
            flag = false
        elseif flag and (base.ifSuperWeaponOpen == 0 or playerLevel < superWeaponOpenLv) and bid == 102 then
            flag = false
        elseif flag and base.ladder == 0 and bid == 103 then
            flag = false
        elseif flag and (base.emblemSwitch == 0 or playerLevel < emblemCfg.equipOpenLevel) and bid == 104 then
            flag = false
        elseif flag and (base.armor == 0 or playerLevel < armorCfg.openLvLimit) and bid == 105 then
            flag = false
        elseif flag and (base.plane == 0 or playerLevel < planeVoApi:getOpenLevel()) and bid == 106 then
            flag = false
        elseif flag and warStatueVoApi:isWarStatueOpened() ~= 0 and bid == 107 then
            flag = false
        elseif flag and AITroopsVoApi:isOpen() ~= 1 and bid == 108 then
            flag = false
        elseif flag and strategyCenterVoApi:isOpen() ~= true and bid == 109 then
            flag = false
        elseif flag and base.heroSwitch ~= 0 and bid == 9 then
            local herolist = heroVoApi:getHeroList()
            local soullist = heroVoApi:getSoulList()
            if playerLevel >= heroOpenLv or SizeOfTable(herolist) > 0 or SizeOfTable(soullist) > 0 then
                
            else
                flag = false
            end
        elseif flag and (airShipVoApi:isOpen() == false or playerLevel < airShipVoApi:getOpenLv()) and bid == 52 then
            flag = false
        end
    end
    return flag
end

function buildingVoApi:isYouhua()
    if base.byh == 0 then
        return false
    end
    return true
end

function buildingVoApi:newBuildingVisible(bid)
    -- 指挥中心的等级
    local zhhzxVo = self:getBuildiingVoByBId(1)
    local zhhzxLevel = zhhzxVo.level
    -- 玩家等级
    local playerLevel = playerVoApi:getPlayerLevel()
    local superWeaponOpenLv = base.superWeaponOpenLv or 25
    local flag = false
    if bid == 102 then
        if base.ifSuperWeaponOpen ~= 0 and homeCfg.buildingUnDisplay[bid][1] <= zhhzxLevel and homeCfg.buildingUnDisplay[bid][2] <= playerLevel and playerLevel >= superWeaponOpenLv then
            flag = true
        end
    end
    return flag
end

-- 设置是否开启自动升级建筑
function buildingVoApi:setAutoUpgradeBuilding(value)
    
    self.autoUpgradeBuilds = tonumber(value)
end

-- 获取是否开启自动升级建筑
function buildingVoApi:getAutoUpgradeBuilding()
    return (self.autoUpgradeBuilds == nil and 0 or self.autoUpgradeBuilds)
end

-- 设置自动升级建筑的剩余时间
function buildingVoApi:setAutoUpgradeExpire(value)
    self.autoUpgradeExpire = tonumber(value)
end

-- 获取自动升级建筑的剩余时间  自动升级开启时：功能截止时间   自动升级关闭时：功能剩余时间
function buildingVoApi:getAutoUpgradeExpire()
    if self.autoUpgradeExpire == nil or self.autoUpgradeExpire <= 0 then
        self.autoUpgradeExpire = 0
    end
    return self.autoUpgradeExpire
end

--获得自动升级下一个要升级的建筑
function buildingVoApi:getNextUpgradeVo(...)
    local bid = nil
    local buildTab = {};
    for k, v in pairs(self.allBuildings) do
        if v.type == 18 and not self:isBuildingOpen(v.type) then
        elseif tonumber(v.status) == 1 and tonumber(v.id) ~= 15 then
            if v.level > 0 and v.type ~= -1 then
                local t = v.type
                -- print("建筑类型==="..t)
                local sortid = tonumber(buildingCfg[t].sortId)
                local bvo = v
                bvo:setSortId(sortid)
                if tonumber(bvo.level) < tonumber(self:canUpgradeMaxLevel(bvo.type)) and self:checkUpgradeRequire(bvo.id, bvo.type) then
                    table.insert(buildTab, bvo)
                end
            end
        end
    end
    table.sort(buildTab, function(a, b)
        return a.level < b.level
    end)
    local nextTab = {}
    local nextVo = nil
    if SizeOfTable(buildTab) > 0 then
        table.insert(nextTab, buildTab[1])
        nextVo = buildTab[1]
    else
        return nextVo
    end
    --检测除此之外还有没有相同等级的建筑
    for k, v in pairs(buildTab) do
        local vo = v
        if vo.level == nextTab[1].level then
            table.insert(nextTab, vo)
        end
    end
    
    table.sort(nextTab, function(a, b)
        return a.sortId < b.sortId
    end)
    nextVo = nextTab[1]
    return nextVo
end

-- 获取建筑最高可以升级的等级
function buildingVoApi:canUpgradeMaxLevel(btype)
    local bcfg = buildingCfg[btype]
    if bcfg == nil then
        return 0
    end
    local maxLevel = math.min(bcfg.maxLevel or 0, tonumber(playerVoApi:getMaxLvByKey("buildingMaxLevel")))
    return maxLevel
end

-- 获取建筑最高可以升级的等级
function buildingVoApi:getAllBuildings()
    return self.allBuildings
end

--更新建筑数据
function buildingVoApi:updateBuild(bid, btype, blevel)
    if self.allBuildings then
        for k, v in pairs(self.allBuildings) do
            if v and v.id == bid then
                v.level = blevel
                v.status = 1
            end
        end
    end
end

function buildingVoApi:getUnlockBuildingCfg()
    local unlockCfg = {}
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local jsAreas = homeCfg.pIndexArrayByLevel
    for k, v in pairs(jsAreas) do
        local infoTb = v
        if k == buildVo.level then
            unlockCfg = G_clone(infoTb)
            do break end
        end
    end
    return unlockCfg
end
function buildingVoApi:getCommandLastLevelKey(uid)
    local lastLevelKey = "commandCenterLastLevel@"..tostring(uid) .. "@"..tostring(base.curZoneID)
    return lastLevelKey
end

function buildingVoApi:getCommandCenterLastLevel()
    return self.commandCenterLastLevel
end

function buildingVoApi:setCommandCenterLastLevel()
    local uid = playerVoApi:getUid()
    local key = self:getCommandLastLevelKey(uid)
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local level = 1
    if buildVo then
        level = buildVo.level
    end
    CCUserDefault:sharedUserDefault():setIntegerForKey(key, level)
    CCUserDefault:sharedUserDefault():flush()
    self.commandCenterLastLevel = level
end

function buildingVoApi:isCommanderCenterLvUp()
    local flag = false
    local buildVo = self:getBuildingVoByBtype(7)[1]
    local level = 1
    if buildVo then
        level = buildVo.level
    end
    if self.commandCenterLastLevel < level then
        flag = true
    end
    return flag
end

--设置拆除建筑的时间戳
function buildingVoApi:setRemoveBuildTs(ts)
    self.removeBuildTs = ts or 0
end

--判断一个建筑是否有移除功能
function buildingVoApi:checkBuildCanRemove(bid)
    local bvo = self:getBuildiingVoByBId(bid)
    if bvo and tonumber(bvo.id) >= 16 and tonumber(bvo.id) <= 45 and tonumber(bvo.status) == 1 then --只有资源建筑已建造并且不在升级状态时才可以移除
        return true
    end
    return false
end
--移除建筑是否在冷却中
function buildingVoApi:isBuildRemoveInCd()
    if self.removeBuildTs == 0 then
        do return false, 0 end
    end
    local rmbEndTs = self.removeBuildTs + playerCfg.removeBuildCd
    if base.serverTime >= rmbEndTs then
        return false, 0
    end
    return true, rmbEndTs - base.serverTime
end
--移除建筑优化功能是否开启
function buildingVoApi:isRemoveBuildCdOpen()
    return base.rbSwitch == 1 and true or false
end

function buildingVoApi:isBuildShowLvByType(type)
    if type == 18 or type == 17 or type == 13 or type == 12 or type == 11 or type == 102 or type == 101 or type == 103 or type == 104 or type == 105 or type == 106 or type == 107 or type == 108 then
        return false
    end
    return true
end

--修理厂buff
function buildingVoApi:getRepairFactoryBuff(lv)
    local vo = self:getBuildiingVoByBId(15)
    local cfg = buildingCfg[vo.type]
    if lv > cfg.maxLevel then
        lv = cfg.maxLevel
    end
    return cfg.pencent[lv], cfg.tankNum[lv], cfg.troopsAdd[lv]
end

--获取省级修理厂需要的条件
function buildingVoApi:getRepairFactoryUpgradeCondition(lv)
    local vo = self:getBuildiingVoByBId(15)
    local cfg = buildingCfg[vo.type]
    local prop = FormatItem(cfg.prop)[1]
    prop.num = cfg.propNum[lv]
    
    return cfg.centralGrade[lv], prop
end

function buildingVoApi:showRepairConfirmDialog(buildVo, layerNum, repairCallBack)
    local tankWarehouseRepairSmalldialog = require "luascript/script/game/scene/gamedialog/tankWarehouse/tankWarehouseRepairSmalldialog"
    tankWarehouseRepairSmalldialog:showRepairConfirmDialog(buildVo, layerNum, repairCallBack)
end
