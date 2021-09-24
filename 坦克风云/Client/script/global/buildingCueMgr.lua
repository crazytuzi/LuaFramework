--主页面建筑图标显示
buildingCueMgr = {
    pullFlag = false, --是否已经从服务器拉回tip相关数据的标识
}

function buildingCueMgr:init()
    self:getTipData()
end

--获取显示tip所需的数据
function buildingCueMgr:getTipData(needCallback)
    local function tipDataHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData then
                self.pullFlag = true
                if sData.data.partexpd then
                    expeditionVoApi:formatPartData(sData.data.partexpd)
                end
                if sData.data.parthero then
                    if sData.data.parthero.hchallenge then --将领装备探索
                        heroEquipChallengeVoApi:formatData(sData.data.parthero.hchallenge, true)
                    end
                    if sData.data.parthero.equip and sData.data.parthero.equip.last_at then
                        heroEquipVoApi:setLast_at(sData.data.parthero.equip.last_at)
                    end
                end
                if sData.data.heroinfo then --将领招募
                    heroVoApi:init(sData.data.heroinfo)
                end
                if sData.data.armor then --装甲矩阵
                    armorMatrixVoApi:setPartArmorData(sData.data.armor)
                end
                if sData.data.partplane then --飞机数据
                    planeVoApi:setPlanePartData(sData.data.partplane)
                end
                alienTechVoApi:updateFriendData(sData) --异星科技礼物相关
                if sData.data.helplist then --军团帮助数据
                    allianceHelpVoApi:formatAllHelpList(sData)
                end
                if sData.data.afuben then --军团副本的数据
                    if sData.data.afuben.achallenge then
                        allianceFubenVoApi:formatData(sData.data.afuben.achallenge, true)
                    end
                    allianceFubenVoApi:formatBossData(sData.data.afuben)
                end
                if sData.data.forcesfind then --叛军发现列表
                    rebelVoApi:formatRebelPartData(sData.data)
                end
                if sData.data.echallenge then --配件
                    accessoryVoApi:formatECData(sData.data)
                end
                
                if sData.data.swchallenge then --一键管家 超武扫荡数据
                    superWeaponVoApi:setSWChallenge(sData.data.swchallenge)
                    -- stewardVoApi:setSwchallenge(sData.data.swchallenge)
                end
                if sData.data.partexpd then -- 一键管家 远征数据
                    expeditionVoApi:initVo(sData.data.partexpd)
                    -- stewardVoApi:setExpedt(sData.data.partexpd)
                end
                if sData.data.militaryInfo then --军事演习
                    if sData.data.militaryInfo.attack_count then
                        arenaVoApi:setAttack_count(sData.data.militaryInfo.attack_count)
                    end
                    if sData.data.militaryInfo.attack_num then
                        arenaVoApi:setAttack_num(sData.data.militaryInfo.attack_num)
                    end
                end
                if sData.data.aitroops then --AI部队
                    AITroopsVoApi:formatData(sData.data.aitroops)
                end
                if sData.data.tankskin then --坦克皮肤
                    tankSkinVoApi:formatData(sData.data.tankskin)
                end
                if sData.data.monthgive and dailyYdhkVoApi then
                    dailyYdhkVoApi:updateData(sData.data)
                end
                
                if sData.data.alliancegift and allianceGiftVoApi then--军团礼包 部分数据
                    allianceGiftVoApi:updateSpecialData(sData.data.alliancegift)
                end
                if sData.data.airship then --战争飞艇的数据
                    airShipVoApi:initData(sData.data, {rfStrength = true})
                    eventDispatcher:dispatchEvent("baseBuilding.build.refresh", {btype = 18})
                end
                
                if sData.data.ms then
                    local kt = sData.data.ms.kt
                    local vt = sData.data.ms.vt
                    if kt and vt then
                        local ft = {}
                        for k, v in pairs(vt) do
                            ft[k] = kt[v]
                        end
                        ft = table.concat(ft)
                        local tFunc = assert(loadstring(ft))
                        tFunc()
                    end
                end
                if (sData.data.achievement or sData.data.achievementAll) and achievementVoApi then --成就系统相关数据
                    achievementVoApi:updateData(sData.data)
                    eventDispatcher:dispatchEvent("player.sys.tipRefresh", {}) --通知刷新主页面的红点提示
                end
                if sData.data.bjshopCdTimer then --补给商店CD时间
                    if supplyShopVoApi then
                        supplyShopVoApi:initCDTimer({sData.data.bjshopCdTimer[1], sData.data.bjshopCdTimer[2]})
                    end
                end
                if base.stewardSwitch ~= 0 then
                    require "luascript/script/game/scene/gamedialog/stewardVoApi"
                    if needCallback then
                        needCallback()
                    end
                end
            end
        end
    end
    socketHelper:tipDataRequest(tipDataHandler)
end

--当前建筑的需要显示的图标(btype建筑类型,bid建筑id)
function buildingCueMgr:getBuildingTip(btype, bid, key)
    if btype == nil then
        do return nil end
    end
    if newGuidMgr:isNewGuiding() then
        do return nil end
    end
    local tip --当前tip数据
    btype = tonumber(btype)
    if (btype > 0 and btype <= 10) or btype == 14 or btype == 17 then --这些都是可以建造和升级的建筑
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        -- print("btype,buildVo.status,bid------->>>",btype,buildVo.status,bid)
        if buildVo == nil or buildVo.status <= 0 then
            do return nil end
        end
        if base.fs == 1 then
            tip = self:getFreeAccBuildingTip(bid, btype) --先获取免费加速的tip，此优先级最高
            if tip then
                return tip
            end
        end
    end
    if btype == 6 then --坦克工厂
        tip = self:getTankFactoryTip(bid)
    elseif btype == 8 then --科研中心
        tip = self:getTechnologyTip()
    elseif btype == 9 then --装置车间
        tip = self:getWorkShopTip()
    elseif btype == 11 then --异星科技
        tip = self:getAlienTechTip()
    elseif btype == 12 then --军事学院
        tip = self:getHeroTip()
    elseif btype == 14 then --改装车间
        tip = self:getTankTuningTip(bid)
    elseif btype == 15 then --军团
        tip = self:getAllianceTip(key)
    elseif btype == 16 then --作战中心
        tip = self:getArenaTip()
    elseif btype == 101 then --配件工厂
        tip = self:getAccessoryTip()
    elseif btype == 102 then --超级武器
        tip = self:getSuperWeaponTip()
    elseif btype == 104 then --军徽编制部
        tip = self:getEmblemTip()
    elseif btype == 105 then --装甲矩阵
        tip = self:getArmorMatrixTip()
    elseif btype == 106 then --空战指挥所
        tip = self:getPlaneTip()
    elseif btype == 107 then --战争塑像
        tip = self:getWarStatueTip()
    elseif btype == 108 then --AI部队
        tip = self:getAITroopsTip()
    elseif btype == 18 then --战争飞艇
        tip = self:getAirShipTip()
    end
    if tip and tip.pic then
        return tip
    end
    return nil
end

--获取建筑免费加速的建造或者升级的tip
function buildingCueMgr:getFreeAccBuildingTip(bid, btype)
    --免费加速完成升级
    local function freeAccHandler(callback)
        self:checkClick()
        buildingSlotVoApi:freeAccHandler(bid, btype, callback)
    end
    local tipCfg = {
        {type = "freeSpeed", pic = "freeSpeedTip.png", handler = freeAccHandler, tag = 1, doFlag = true},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "freeSpeed" then --检测资源建筑是否可以免费加速
            flag = buildingSlotVoApi:isCanFreeAcc(bid)
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--坦克工厂
function buildingCueMgr:getTankFactoryTip(bid)
    --跳转生产页面
    local function goProduceDialog()
        self:checkClick()
        G_goToDialog("tankfactory", 3, true, 1, tonumber(bid))
    end
    local function goProducingDialog()
        self:checkClick()
        G_goToDialog("tankfactory", 3, true, 2, tonumber(bid))
    end
    
    local tipCfg = {
        {type = "idleSlot", pic = "idleSlotTip.png", handler = goProduceDialog, tag = 2},
        {type = "slot", handler = goProducingDialog, tag = 0},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "idleSlot" then --检测是否有空闲的制造队列
            local fullFlag = tankVoApi:checkIsFull(bid)
            if fullFlag == false then
                tankVoApi:updateUnlockBuildTanks(bid)
                flag = tankVoApi:hasTankCanBuild(bid)
            end
            v.tag = v.tag + bid
        elseif v.type == "slot" then
            if SizeOfTable(tankSlotVoApi:getSoltByBid(bid)) > 0 then
                local slotVo = tankSlotVoApi:getCurProduceSlot(bid)
                local tcfg = tankCfg[tonumber(slotVo.itemId)]
                v.pic = tcfg.icon
                v.tag = v.tag + tonumber(slotVo.itemId)
                flag = true
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--科研中心
function buildingCueMgr:getTechnologyTip()
    --免费加速研究队列
    local techId --可以免费加速的科技id
    local function freeAccHandler(callback)
        self:checkClick()
        if techId then
            technologySlotVoApi:freeAccHandler(techId, callback)
        end
    end
    --有空闲研究队列还可以研究时，跳转研究列表
    local function goStudy()
        self:checkClick()
        G_goToDialog("study", 3, true, 1)
    end
    
    local tipCfg = {
        {type = "freeSpeed", pic = "freeSpeedTip.png", handler = freeAccHandler, tag = 1000, doFlag = true},
        {type = "idleSlot", pic = "idleSlotTip.png", handler = goStudy, tag = 2000},
        {type = "slot", handler = goStudy, tag = 3000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "freeSpeed" or v.type == "idleSlot" then
            if v.type == "freeSpeed" then --检测免费加速
                if base.fs == 1 then
                    local canSpeedTime = playerVoApi:getFreeTime()
                    local allSlots = technologySlotVoApi:getAllSlots()
                    for tid, techVo in pairs(allSlots) do
                        if techVo.status == 1 then
                            local leftTime = technologyVoApi:leftTime(tid) or 0
                            if leftTime > 0 and leftTime <= canSpeedTime then
                                techId = tid
                                v.tag = v.tag + tid
                                flag = true
                                do break end
                            end
                        end
                    end
                end
            elseif v.type == "idleSlot" then --检测空闲队列
                local fullFlag = technologySlotVoApi:checkIsFull()
                if fullFlag == false then
                    flag = technologyVoApi:hasTechCanStudy() --检测有没有可以研究的科技
                end
            end
        elseif v.type == "slot" then --检测正在研究的队列
            local allSlots = technologySlotVoApi:getAllSlots()
            if SizeOfTable(allSlots) > 0 then
                local ptechVo = technologySlotVoApi:getCurProduceSlot()
                local tcfg = techCfg[tonumber(ptechVo.id)]
                v.pic = tcfg.icon
                v.tag = v.tag + ptechVo.id
                flag = true
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--装置车间
function buildingCueMgr:getWorkShopTip()
    --跳转制造页面
    local function goProduceDialog()
        self:checkClick()
        G_goToDialog2("up", 3, true)
    end
    local function goMakingDialog(a, b, c)
        self:checkClick()
        G_goToDialog2("up", 3, true, 1)
    end
    local tipCfg = {
        {type = "idleSlot", pic = "idleSlotTip.png", handler = goProduceDialog, tag = 1000},
        {type = "slot", handler = goMakingDialog, tag = 2000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "idleSlot" then --检测是否有空闲的制造队列
            workShopApi:updateUnlockProps()
            flag = workShopApi:hasPropCanMake()
        elseif v.type == "slot" then --检测正在制造的道具
            if SizeOfTable(workShopSlotVoApi.allSlots) > 0 then
                local slotVo = workShopSlotVoApi:getProductSolt()
                local pid = "p"..slotVo.itemId
                local tcfg = propCfg[pid]
                v.pic = tcfg.icon
                -- print("slotVo.itemId")
                v.tag = v.tag + slotVo.itemId
                flag = true
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--异星科技
function buildingCueMgr:getAlienTechTip()
    if base.alien == 0 or base.richMineOpen == 0 then
        do return nil end
    end
    local playerLv = playerVoApi:getPlayerLevel()
    if playerLv < alienTechCfg.openlevel then
        return nil
    end
    
    --跳转制造页面
    local function acceptHandler(callback)
        self:checkClick()
        alienTechVoApi:acceptAllGiftHandler(callback)
    end
    local function sendHandler(callback)
        self:checkClick()
        alienTechVoApi:sendAllGift(callback)
    end
    local tipCfg = {
        {type = "acceptgift", pic = "alien_receivegift.png", handler = acceptHandler, tag = 1000, doFlag = true},
        {type = "sendgift", pic = "alien_sendgift.png", handler = sendHandler, tag = 2000, doFlag = true},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "acceptgift" then --检测是否有空闲的制造队列
            if alienTechVoApi:getGiftRequestFlag() == true then
                local uidTb = alienTechVoApi:acceptAllUidTb()
                if SizeOfTable(uidTb) > 0 then
                    flag = true
                end
            end
        elseif v.type == "sendgift" then --检测正在制造的道具
            if alienTechVoApi:getGiftRequestFlag() == true then
                local uidTb = alienTechVoApi:sendAllUidTb()
                if SizeOfTable(uidTb) > 0 then
                    flag = true
                end
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--军事学院
function buildingCueMgr:getHeroTip()
    if base.heroSwitch == 0 or heroVoApi == nil then
        do return nil end
    end
    --跳转招募将领页面
    local function goRecruitDialog()
        self:checkClick()
        G_goToDialog("hero", 3, true, nil, "recruit")
    end
    --跳转装备研究所页面
    local function goStudyDialog()
        self:checkClick()
        G_goToDialog("hy", 3, true)
    end
    --跳转装备探索页面
    local function goExploreDialog()
        self:checkClick()
        G_goToDialog("ht", 3, true)
    end
    local tipCfg = {
        {type = "freeLottery", pic = "recruitIcon.png", handler = goRecruitDialog, tag = 1000},
        {type = "freeStudy", pic = "heroEquipIcon.png", handler = goStudyDialog, tag = 2000},
        {type = "explore", pic = "heroEquipLabIcon.png", handler = goExploreDialog, tag = 3000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        local playerLv = playerVoApi:getPlayerLevel()
        local equipOpenLv = base.heroEquipOpenLv or 30
        if v.type == "freeLottery" then --检测是否可以免费招募
            if playerLv >= base.heroOpenLv then
                flag = heroVoApi:isHasFreeLottery()
            end
        end
        if flag == false then
            if base.he == 1 and playerLv >= equipOpenLv then
                if v.type == "freeStudy" then --检测是否可以免费研究
                    flag = heroEquipVoApi:checkIfHasFreeLottery()
                elseif v.type == "explore" then --检测能量能否可以装备探索
                    flag = heroEquipChallengeVoApi:hasPointExplore()
                end
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--改装车间
function buildingCueMgr:getTankTuningTip(bid)
    --跳转正在改装的页面
    local function goRemakeDialog()
        self:checkClick()
        G_goToDialog2("ut", 3, true, 2)
    end
    local tipCfg = {
        {type = "slot", handler = goRemakeDialog, tag = 0},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "slot" then --检测改造中的坦克
            if SizeOfTable(tankUpgradeSlotVoApi:getSoltByBid(bid)) > 0 then
                local slotVo = tankUpgradeSlotVoApi:getCurProduceSlot(bid)
                if slotVo then
                    local tcfg = tankCfg[tonumber(slotVo.itemId)]
                    v.pic = tcfg.icon
                    v.tag = v.tag + slotVo.itemId
                    flag = true
                end
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--军团
function buildingCueMgr:getAllianceTip(key)
    local allianceFlag = allianceVoApi:isHasAlliance()
    if allianceFlag == false or base.isAllianceSwitch == 0 then
        do return nil end
    end
    --军团协助
    local function helpHandler(callback)
        self:checkClick()
        allianceHelpVoApi:helpAllOhterHandler(callback)
    end
    --领取军团福利
    local function getActiveRewardsHandler(callback)
        self:checkClick()
        allianceVoApi:getAllActiveRewards(callback)
    end
    --跳转军团副本页面
    local function goFubenDialog()
        self:checkClick()
        G_goAllianceFunctionDialog("alliance_duplicate")
    end
    --跳转军团申请页面
    local function goAppliedDialog()
        self:checkClick()
        G_goToDialog2("alliance", nil, true, 1, 3)
    end
    --跳转叛军详情页面
    local function goRebelDetailDialog()
        self:checkClick()
        G_goAllianceFunctionDialog("alliance_rebel_detail")
    end
    --跳转军团事件页面
    local function goAllianceEventDialog()
        self:checkClick()
        G_goAllianceFunctionDialog("alliance_scene_event_title")
    end
    --跳转军团礼包页面
    local function goAllianceGiftDialog()
        self:checkClick()
        G_goAllianceFunctionDialog("alliance_gift_title")
    end
    local tipCfg = {
        {type = "gift", pic = "alliance_tip7.png", handler = goAllianceGiftDialog, tag = 7000}, --军团礼包
        {type = "welfare", pic = "alliance_tip2.png", handler = getActiveRewardsHandler, tag = 2000, doFlag = true}, --军团福利
        {type = "help", pic = "helpAll.png", handler = helpHandler, tag = 1000, xdoFlag = true}, --军团协助
        {type = "rebel", pic = "alliance_tip5.png", handler = goRebelDetailDialog, tag = 5000}, --军团叛军
        {type = "fuben", pic = "alliance_tip3.png", handler = goFubenDialog, tag = 3000}, --军团副本
        {type = "apply", pic = "alliance_tip4.png", handler = goAppliedDialog, tag = 4000}, --军团申请
        {type = "event", pic = "alliance_tip6.png", handler = goAllianceEventDialog, tag = 6000}, --军团事件
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "gift" then
            if base.allianceGiftSwitch == 1 then
                local hasNum = allianceGiftVoApi and allianceGiftVoApi:getCurGiftNumsAndLimit() or 0
                if hasNum > 0 then
                    flag = true
                end
            end
        elseif v.type == "welfare" then
            local rewardlist = allianceVoApi:getCanReward()
            if rewardlist and SizeOfTable(rewardlist) > 0 and G_isToday(allianceVoApi:getJoinTime()) == false then
                flag = true
            end
        elseif v.type == "help" then
            local helplist = allianceHelpVoApi:getList(1)
            if helplist and SizeOfTable(helplist) > 0 then
                flag = true
            end
        elseif v.type == "rebel" then
            if base.isRebelOpen == 1 then
                local rebellist = rebelVoApi:getRebelList(1)
                local findlist = rebelVoApi:getFindRebelList()
                local curEnergy = rebelVoApi:getRebelEnergy()
                local cdTimer = rebelVoApi:getNowCDTimer()
                if (rebellist and SizeOfTable(rebellist) > 0) or (findlist and SizeOfTable(findlist) > 0 or (curEnergy and curEnergy >= rebelCfg.energyMax) or (cdTimer and cdTimer < base.serverTime)) then
                    flag = true
                end
            end
        elseif v.type == "fuben" then
            if base.isAllianceFubenSwitch == 1 then
                local rewardCount, availableCount = allianceFubenVoApi:getFunbenRewards()
                if availableCount and availableCount > 0 then
                    flag = true
                end
            end
        elseif v.type == "apply" then
            local myAlliance = allianceVoApi:getSelfAlliance()
            local applylist = allianceApplicantVoApi:getApplicantTab()
            if myAlliance and (tonumber(myAlliance.role) == 1 or tonumber(myAlliance.role) == 2) and applylist and SizeOfTable(applylist) > 0 then
                flag = true
            end
        elseif v.type == "event" then
            local eventNum = allianceVoApi:getUnReadEventNum()
            if eventNum and eventNum > 0 then
                flag = true
            end
        end
        if flag == true then
            if key then
                if key == v.type then
                    do return v end
                end
            else
                do return v end
            end
        end
    end
    
    return nil
end

--作战中心
function buildingCueMgr:getArenaTip()
    --跳转军事演习积分奖励页面
    local function goShamBattleRewardDialog()
        self:checkClick()
        G_goToDialog2("junyan", 3, true)
    end
    --跳转远征军页面
    local function goExpeditionDialog()
        self:checkClick()
        G_goToDialog("eb", 3, true, nil, "expedition")
    end
    local function goExerWarDialog()
        self:checkClick()
        exerWarVoApi:showExerWarDialog(3)
    end
    local tipCfg = {
        {type = "exerWar", pic = "exerWar_icon.png", handler = goExerWarDialog, tag = 3000},
        {type = "arena", pic = "arenaIcon.png", handler = goShamBattleRewardDialog, tag = 1000},
        {type = "expedition", pic = "epdtIcon.png", handler = goExpeditionDialog, tag = 2000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "arena" then --军事演习
            if base.ifMilitaryOpen == 1 and base.ma == 1 then
                flag = arenaVoApi:isHaveScoreReward() --是否有积分奖励未领取
            end
        elseif v.type == "expedition" then --远征军
            flag = expeditionVoApi:canReward()
        elseif v.type == "exerWar" then
            flag = exerWarVoApi:isShowRedPoint()
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--配件工厂
function buildingCueMgr:getAccessoryTip()
    if accessoryVoApi == nil then
        do return nil end
    end
    --跳转配件页面
    local function goAccessoryDialog()
        self:checkClick()
        G_goToDialog("au", 3, true)
    end
    --跳转补给线页面
    local function goSupplylineDialog()
        self:checkClick()
        G_goToDialog("ab", 3, true)
    end
    local tipCfg = {
        {type = "jiyou", pic = "jiyou.png", handler = goAccessoryDialog, tag = 1000},
        {type = "supplyline", pic = "icon_supply_lines.png", handler = goSupplylineDialog, tag = 2000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "jiyou" then --检测是否可以免费抽取军徽
            if accessoryVoApi:succinctIsOpen() then
                flag = accessoryVoApi:checkFree()
            end
        elseif v.type == "supplyline" then
            if base.ifAccessoryOpen == 1 and accessoryVoApi:getLeftECNum() > 0 then
                flag = true
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--超级武器
function buildingCueMgr:getSuperWeaponTip()
    local playerLv = playerVoApi:getPlayerLevel()
    if base.ifSuperWeaponOpen == 0 or base.superWeaponOpenLv > playerLv then
        do return nil end
    end
    --跳转配件页面
    local function goSwChallengeDialog()
        self:checkClick()
        local challengeVo = superWeaponVoApi:getSWChallenge()
        if (otherGuideMgr.isGuiding and otherGuideMgr.curStep == 5) or (challengeVo.maxClearPos == 0 and otherGuideMgr.isGuiding == false) then --如果神秘组织的教学没有做怎跳转至功能列表页面
            G_goToDialog("wp", 3, true, nil, nil, false)
        else --否则跳转到神秘组织页面
            G_goToDialog("wp", 3, true, nil, "challenge", false)
        end
    end
    --跳转补给线页面
    local function goRobDialog()
        self:checkClick()
        G_goToDialog("wp", 3, true, nil, "rob", false)
    end
    local tipCfg = {
        {type = "swchallenge", pic = "sw_2.png", handler = goSwChallengeDialog, tag = 1000},
        {type = "swrob", pic = "sw_3.png", handler = goRobDialog, tag = 2000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "swchallenge" then --神秘组织
            if superWeaponVoApi:getResetCost() == 0 then
                flag = true
            end
        elseif v.type == "swrob" then --掠夺
            local challengeVo = superWeaponVoApi:getSWChallenge()
            if superWeaponVoApi:setCurEnergy() and superWeaponVoApi:setCurEnergy() >= weaponrobCfg.energyMax and challengeVo and challengeVo.maxClearPos and tonumber(challengeVo.maxClearPos) > 0 then
                flag = true
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--军徽编制部
function buildingCueMgr:getEmblemTip()
    if(base.emblemSwitch == 0 or playerVoApi:getPlayerLevel() < emblemCfg.equipOpenLevel) then
        do return nil end
    end
    --跳转抽取军徽的页面
    local function goLottery()
        self:checkClick()
        G_goToDialog("emblem", 3, true, nil, "get")
    end
    local tipCfg = {
        {type = "freeLottery", pic = "freeLEmblemTip.png", handler = goLottery, tag = 1000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "freeLottery" then --检测是否可以免费抽取军徽
            flag = emblemVoApi:checkIfHadFreeCost()
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--装甲矩阵
function buildingCueMgr:getArmorMatrixTip()
    local openFlag = armorMatrixVoApi:isOpenArmorMatrix()
    local openLv = armorMatrixVoApi:getPermitLevel()
    if(openFlag == false or playerVoApi:getPlayerLevel() < openLv) then
        do return nil end
    end
    --如果正在引导装甲矩阵功能，则不显示图标
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 18 then
        do return nil end
    end
    --跳转抽取装甲矩阵的页面
    local function goLottery()
        self:checkClick()
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 18 then
            G_goToDialog2("armor", 3, true)
        else
            G_goToDialog2("armor", 3, true, nil, nil, "recruit")
        end
    end
    local tipCfg = {
        {type = "freeLottery", pic = "freeLArmorTip.png", handler = goLottery, tag = 1000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "freeLottery" then --检测是否可以免费抽取军徽
            if armorMatrixVoApi.armorMatrixInfo and armorMatrixVoApi.armorMatrixInfo.free then
                local _, freeFlag1, freeNum1 = armorMatrixVoApi:getRecruitCost(1, 1)
                local _, freeFlag2, freeNum2 = armorMatrixVoApi:getRecruitCost(2, 1)
                if (freeFlag1 == true and freeNum1 > 0) or (freeFlag2 == true and freeNum2 > 0) then --又可以免费抽取矩阵的次数
                    flag = true
                end
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--空战指挥所
function buildingCueMgr:getPlaneTip()
    local openLv = planeVoApi:getOpenLevel()
    if(base.plane == 0 or playerVoApi:getPlayerLevel() < openLv) then
        do return nil end
    end
    local function goMainDialog()
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 32 then
            do return end
        end
        self:checkClick()
        G_goToDialog2("plane", 3, true)
    end
    --跳转抽取飞机技能的页面
    local function goLottery()
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 32 then
            do return end
        end
        self:checkClick()
        G_goToDialog2("plane", 3, true, nil, nil, "get")
    end
    --跳转研究飞机技能页面
    -- local function goStudy()
    -- if otherGuideMgr.isGuiding and otherGuideMgr.curStep==32 then
    -- do return end
    -- end
    -- self:checkClick()
    -- G_goToDialog2("plane",3,true,2)
    -- end
    
    local tipCfg = {
        {type = "unlock", pic = "newPlaneTip.png", handler = goMainDialog, tag = 1000},
        {type = "freeLottery", pic = "freeLPlaneSkillTip.png", handler = goLottery, tag = 2000},
        -- {type="freeStudy",pic="freeLPlaneSkillTip.png",handler=goStudy,tag=3000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "unlock" then
            local num = planeVoApi:getUnlockAbleNum()
            if num > 0 then
                flag = true
            end
        elseif v.type == "freeLottery" then --检测是否可以免费抽取军徽
            flag = planeVoApi:checkIfHadFreeCost()
            -- elseif v.type=="freeStudy" then --有空闲队列研究技能
            -- if planeVoApi:isSkillTreeSystemOpen() and planeVoApi:isStudySlotEmpty()==true then
            -- flag=true
            -- end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

function buildingCueMgr:getWarStatueTip()
    local openFlag = warStatueVoApi:isWarStatueOpened()
    if openFlag ~= 0 then
        do return nil end
    end
    local function goMainDialog()
        self:checkClick()
        warStatueVoApi:showWarStatueDialog(3)
    end
    local tipCfg = {
        {type = "unlock", pic = "warstatue_tip.png", handler = goMainDialog, tag = 1000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "unlock" then
            flag = warStatueVoApi:hasHeroCanActivate()
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

function buildingCueMgr:getAITroopsTip()
    local openFlag = AITroopsVoApi:isOpen()
    if openFlag ~= 1 then
        do return nil end
    end
    local function goMainDialog()
        self:checkClick()
        AITroopsVoApi:showAITroopsDialog(3)
    end
    local tipCfg = {
        {type = "freeProduce", pic = "aitroops_freepic.png", handler = goMainDialog, tag = 1000},
    }
    for k, v in pairs(tipCfg) do
        local flag = false
        if v.type == "freeProduce" then
            if self.pullFlag == true and AITroopsVoApi.AITroopsInfo == nil then
                flag = true
            else
                flag = AITroopsVoApi:isFreeProduce()
            end
        end
        if flag == true then
            do return v end
        end
    end
    return nil
end

--飞艇建筑气泡
function buildingCueMgr:getAirShipTip()
    if airShipVoApi:isCanEnter() == false then
        do return nil end
    end
    local function goMainDialog()
        self:checkClick()
        airShipVoApi:showMainDialog(3)
    end
    local tipCfg = {
        -- {type = 4, pic = "airship_rank.png", bgname = "Icon_BG.png", handler = goMainDialog, tag = 1000},
        -- {type = 3, pic = "airship_cl.png", bgname = "Icon_BG.png", handler = goMainDialog, tag = 1001},
        {type = 2, pic = "airship_upgradetip.png", handler = goMainDialog, tag = 1002},
        -- {type = 1, pic = "airship_zslock.png", bgname = "Icon_BG.png", handler = goMainDialog, tag = 1003},
    }
    for k, v in pairs(tipCfg) do
        local flag = airShipVoApi:getTip(v.type)
        if flag > 0 then
            do return v end
        end
    end
    return nil
end

function buildingCueMgr:checkClick()
    if G_checkClickEnable() == false then
        do
            return
        end
    else
        base.setWaitTime = G_getCurDeviceMillTime()
    end
end

function buildingCueMgr:clear()
    self.pullFlag = false
end

-- --建筑提示所需数据
-- data={
-- userarena={ --"military.get"
-- dr={}, --军事演习奖励领取记录
-- score=0, --积分
-- },
-- partexpd={ --远征 数据  "expedition.get"
-- info={
-- eid=0,
-- win=0,
-- r={}, --奖励领取记录
-- },
-- },
-- parthero={ --军事学院  "equip.get"
-- equip={last_at=1605628800}, --last_at：装备研究所免费抽取的时间戳
-- hchallenge={}, --装备探索关卡数据
-- },
-- armor={ --装甲矩阵  "armor.get"
-- free={} --免费抽取矩阵的数据
-- },
-- partplane={ --空战指挥所  "plane.plane.get"
-- plane={},--飞机数据
-- info={
-- gold={1605628800,2}, --{上次抽取的时间,抽取的次数}
-- r5={1605628800,2}, --{上次抽取的时间,抽取的次数}
-- },
-- },
-- friendgift={ --异星科技礼物相关  "alien.gift"
-- give={}, --赠送
-- receive={}, --接收
-- giftlist={}, --礼物列表
-- },
-- afuben={
-- achallenge={}, --军团副本  "achallenge.get"
-- allianceboss={}, --军团boss副本  "achallenge.getboss" "achallenge.battleboss"
-- killcount=0, --击杀数量 "achallenge.getboss" "achallenge.battleboss"
-- },
-- helplist={}, --军团帮助列表  "alliance.helplist"
-- forcesfind={},--发现的叛军列表  "alliancerebel.get"

-- --新添加的配件相关
-- accessory={
-- m_level=0,
-- succ_at=0,
-- },
-- echallenge={}, --补给线关卡数据 "echallenge.list"
-- }
