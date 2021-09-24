--[[
军团一键捐献

@author JNK
]]

allianceOneKeyDonateDialog = commonDialog:new()

function allianceOneKeyDonateDialog:new()
    local nc = {
        layerNum,
        sid,
        tableView,
    }
    setmetatable(nc, self)
    self.__index = self
   
    return nc
end

function allianceOneKeyDonateDialog:init(layerNum, idx, tableView)
    self.layerNum = layerNum
    self.sid = tonumber(idx) or 0
    self.tableView = tableView

    local skillId = self.sid
    local donateTab = {}
    local signDonateData = {} -- start_key起始捐献次数；end_key捐献几次；cost_key花费资源
    local ssid
    if skillId == 0 then
        ssid = "alliance"
    else
        if tonumber(skillId) == SizeOfTable(allianceSkillCfg) then
            skillId = 99
        end
        ssid = "s" .. skillId
    end

    -- 数据
    local bgSize = CCSizeMake(560, 680)
    local nameFontSize = 30

    -- 对话框Layer
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true)
    local function close()
        self:close()
    end
    self.bgLayer = G_getNewDialogBg(bgSize, getlocal("oneKeyDonate"), nameFontSize, nil, self.layerNum, true, close)
    self.bgLayer:setTouchPriority(-(layerNum - 1) * 20 -1)
    self.bgLayer:setContentSize(bgSize)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    --遮罩层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    -- 框
    local showBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    showBgSp:setContentSize(CCSizeMake(bgSize.width - 30, 370))
    showBgSp:setAnchorPoint(ccp(0.5, 0))
    showBgSp:setPosition(ccp(bgSize.width / 2, 125))
    self.bgLayer:addChild(showBgSp)

    -- 需要添加的经验
    local isMaxLevel = false -- 捐献是否满级
    local addExp = 0 -- 添加exp
    if self.sid ~= 0 and allianceSkillCfg[self.sid].sid == "99" then
        addExp = -1
    end

    -- 捐献显示
    local isCanDonate = false
    local offTitleHeight = 50
    local offIconHeight = 64
    local donateTitlePosX = {42, 180, 340, 460}
    local donateTitlePosY = showBgSp:getContentSize().height
    local donateIcon = {"", "resourse_normal_gold.png", "resourse_normal_metal.png", "resourse_normal_oil.png", "resourse_normal_silicon.png", "resourse_normal_uranium.png"}
    local donateKey = {"", "gold", "r1", "r2", "r3", "r4"}
    for i=1,6 do
        if i == 1 then
            -- 标题
            for j=1,4 do
                local titleSize = CCSizeMake(200, 0)
                local titleLb = GetTTFLabelWrap(getlocal("oneKeyDonateTitle" .. j), 22, titleSize, kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                titleLb:setAnchorPoint(ccp(0.5, 0.5))
                titleLb:setPosition(ccp(donateTitlePosX[j] - 2, donateTitlePosY - offTitleHeight/2 - 1))
                showBgSp:addChild(titleLb)
                titleLb:setColor(G_ColorGreen)
            end
        else
            -- 内容
            local iconSp = CCSprite:createWithSpriteFrameName(donateIcon[i])
            iconSp:setAnchorPoint(ccp(0.5, 0.5))
            iconSp:setPosition(ccp(donateTitlePosX[1], (donateTitlePosY - offTitleHeight) - (i - 1) * offIconHeight + offIconHeight/2 + 1))
            iconSp:setScale(0.5)
            showBgSp:addChild(iconSp)

            -- 设置变量
            local cost1, cost2, donateNum, donateNow, donateMax = 0, 0, 0, 0, 0
            local key = donateKey[i]
            donateNow = allianceVoApi:getDonateCount(key)
            donateMax = allianceVoApi:getDonateMaxNum()

            local donateIndex = donateNow + 1
            if donateIndex > donateMax then
                donateIndex = donateMax
            end
            if playerVo[key] and tonumber(playerVo[key]) then
                -- 当前拥有量
                cost2 = tonumber(playerVo[key])
            end

            -- 需要资源
            local needRes = 0
            local haveDouble = true -- 是否有加倍
            for add=donateIndex, (donateIndex + donateMax - donateNow - 1) do
                -- 判断一键捐献是否满级
                local selfAlliance = allianceVoApi:getSelfAlliance()
                local lastDonateTime = selfAlliance.lastDonateTime
                if selfAlliance then
                    if addExp >= 0 then
                        if self.sid == 0 then
                            if selfAlliance.level >= allianceVoApi:getMaxLevel() and selfAlliance.exp + addExp >= allianceVoApi:getMaxExp() then
                                isMaxLevel = true
                            end
                        else
                            if allianceSkillVoApi:getSkillLevel(self.sid) >= allianceSkillVoApi:getSkillMaxLevel(self.sid) and allianceSkillVoApi:getSkillExp(self.sid) + addExp >= allianceSkillVoApi:getSkillMaxExp(self.sid) then
                                isMaxLevel = true
                            end
                        end
                    end
                else
                    isMaxLevel = true
                end

                if isMaxLevel then
                    -- 满级了
                else
                    needRes = needRes + playerCfg.allianceDonateResources[add]
                    if needRes <= cost2 then
                        -- 判断是否超过等级
                        local rewardCfg = playerCfg.allianceDonate[add]
                        if self.sid == SizeOfTable(allianceSkillCfg) then
                            rewardCfg = playerCfg.zijinDonate[add]
                        end
                        local num = rewardCfg[1]

                        if haveDouble and (lastDonateTime and G_isToday(lastDonateTime) == false) and selfAlliance.alevel and allianceActiveCfg.ActiveDonateCount[selfAlliance.alevel] > 1 then
                            num = num * allianceActiveCfg.ActiveDonateCount[selfAlliance.alevel]
                        end

                        addExp = addExp + num
                        cost1 = needRes
                        donateNum = donateNum + 1
                        isCanDonate = true

                        if not donateTab[key] then
                            donateTab[key] = {}
                        end

                        donateTab[key][1] = donateNow -- 当前捐献次数，即起始次数
                        donateTab[key][2] = donateNum -- 捐献几次

                        -- 记录数据
                        signDonateData["start_" .. key] = donateIndex
                        signDonateData["end_" .. key] = donateIndex + donateTab[key][2] - 1
                        signDonateData["cost_" .. key] = cost1

                        haveDouble = false -- 只是可以捐献的第一次加倍
                    elseif add == donateIndex then
                        -- 1次
                        cost1 = needRes
                    end
                end
            end

            -- 消耗
            local costLb = GetTTFLabel(getlocal("oneKeyDonateFormat", {FormatNumber(cost1), FormatNumber(cost2)}), 20)
            costLb:setAnchorPoint(ccp(0.5, 0.5))
            costLb:setPosition(ccp(donateTitlePosX[2], iconSp:getPositionY()))
            showBgSp:addChild(costLb)
            if cost1 > cost2 then
                costLb:setColor(G_ColorRed)
            else
                costLb:setColor(G_ColorGreen)
            end

            -- 捐献次数
            local donateLb = GetTTFLabel("" .. donateNum, 20)
            donateLb:setAnchorPoint(ccp(0.5, 0.5))
            donateLb:setPosition(ccp(donateTitlePosX[3], iconSp:getPositionY()))
            showBgSp:addChild(donateLb)
            donateLb:setColor(G_ColorWhite)

            -- 今日捐献
            local donateLimitLb = GetTTFLabel(getlocal("oneKeyDonateFormat", {donateNow, donateMax}), 20)
            donateLimitLb:setAnchorPoint(ccp(0.5, 0.5))
            donateLimitLb:setPosition(ccp(donateTitlePosX[4], iconSp:getPositionY()))
            showBgSp:addChild(donateLimitLb)
            donateLimitLb:setColor(G_ColorWhite)

            -- 次数满置灰
            if donateNow >= donateMax or cost1 == 0 then
                costLb:setColor(G_ColorGray)
                donateLb:setColor(G_ColorGray)
                donateLimitLb:setColor(G_ColorGray)
            end
        end

        if i ~= 6 then
            local cellLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 1, 1, 1), function () end)
            cellLine:setContentSize(CCSizeMake(showBgSp:getContentSize().width - 20, cellLine:getContentSize().height))
            cellLine:setPosition(ccp(showBgSp:getContentSize().width / 2, (donateTitlePosY - offTitleHeight) - (i - 1) * offIconHeight))
            showBgSp:addChild(cellLine)
        end
    end

    -- 科技图标、描述、进度相关
    local iconName = nil
    local nameAndLvStr = nil
    if idx == 0 then
        iconName = "alliance_icon.png"
        if allianceVoApi:getSelfAlliance().level >= allianceVoApi:getMaxLevel() then
            nameAndLvStr = getlocal("alliance_scene_level") .. "(" .. getlocal("alliance_lvmax") .. ")"
        else
            nameAndLvStr = getlocal("alliance_scene_level") .. "(" .. G_LV() .. allianceVoApi:getSelfAlliance().level .. ")"
        end
    else
        iconName = allianceSkillCfg[idx].imageName
        if (allianceSkillCfg[idx].sid == "22" or allianceSkillCfg[idx].sid == "23") and base.allianceCitySwitch == 0 then
            nameAndLvStr = nil
        else
            local skillLv = allianceSkillVoApi:getAllSkills()[idx].level
            if skillLv >= allianceSkillVoApi:getSkillMaxLevel(idx) then
                nameAndLvStr = getlocal(allianceSkillCfg[idx].name) .. "(" .. getlocal("alliance_lvmax") .. ")"
            else
                nameAndLvStr = getlocal(allianceSkillCfg[idx].name) .. "(" .. G_LV() .. skillLv .. ")"
            end
            if allianceSkillCfg[idx].sid == "99" then
                nameAndLvStr = getlocal(allianceSkillCfg[idx].name)
            end
        end
    end

    local iconSp = CCSprite:createWithSpriteFrameName(iconName)
    iconSp:setAnchorPoint(ccp(0, 0.5))
    iconSp:setPosition(ccp(15, bgSize.height - 125))
    self.bgLayer:addChild(iconSp)

    if nameAndLvStr then
        local nameLb = GetTTFLabelWrap(nameAndLvStr, 24, CCSizeMake(24 * 18, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        nameLb:setPosition(iconSp:getPositionX() + iconSp:getContentSize().width + 10, iconSp:getPositionY() + 30)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorGreen)
        nameLb:setTag(9)
        self.bgLayer:addChild(nameLb, 2)
    end

    local progressPos = ccp(self.bgLayer:getContentSize().width/2 + 18, iconSp:getPositionY() - 30)
    if idx~=0 then
        local skillLv, curExp, curMaxExp, percent = allianceSkillVoApi:getSkillLvAndExpAndPerById(idx)
        -- print("sid, skillLv, curExp, curMaxExp, percent ====== ", idx, skillLv, curExp, curMaxExp, percent)
        if allianceSkillCfg[idx].sid == "99" then
            AddProgramTimer(self.bgLayer, progressPos, 10, 11, "", "skillBg.png", "skillBar.png", 11)
            local ccprogress = self.bgLayer:getChildByTag(10)
            ccprogress = tolua.cast(ccprogress,"CCProgressTimer")
            ccprogress:setPercentage(percent)
        else
            AddProgramTimer(self.bgLayer, progressPos, 10, 11, curExp .. "/" .. curMaxExp, "skillBg.png", "skillBar.png", 11)
            local ccprogress = self.bgLayer:getChildByTag(10)
            ccprogress = tolua.cast(ccprogress, "CCProgressTimer")
            ccprogress:setPercentage(percent)
        end
    else
        local allianceLv, curExp, curMaxExp, percent = allianceVoApi:getLvAndExpAndPer()
        AddProgramTimer(self.bgLayer, progressPos, 10, 11, curExp .. "/" .. curMaxExp, "skillBg.png", "skillBar.png", 11)
        local ccprogress = self.bgLayer:getChildByTag(10)
        ccprogress = tolua.cast(ccprogress, "CCProgressTimer")
        ccprogress:setPercentage(percent)
    end

    -- 判断一键捐献是否满级
    local selfAlliance = allianceVoApi:getSelfAlliance()
    if selfAlliance then
        if self.sid == 0 then
            if selfAlliance.level >= allianceVoApi:getMaxLevel() and selfAlliance.exp >= allianceVoApi:getMaxExp() then
                isCanDonate = false
            end
        else
            if allianceSkillVoApi:getSkillLevel(self.sid) >= allianceSkillVoApi:getSkillMaxLevel(self.sid) and allianceSkillVoApi:getSkillExp(self.sid) >= allianceSkillVoApi:getSkillMaxExp(self.sid) then
                isCanDonate = false
            end
        end
    else
        isCanDonate = false
    end

    -- 一键捐献描述
    local oneKeyDescLb = GetTTFLabel(getlocal("oneKeyDonateDesc"), 20)
    oneKeyDescLb:setAnchorPoint(ccp(0.5,0.5))
    oneKeyDescLb:setPosition(ccp(bgSize.width / 2, 100))
    oneKeyDescLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(oneKeyDescLb)
    -- 一键捐献按钮
    local oneKeyItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", function (tag, object)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end

        PlayEffect(audioCfg.mouseClick)
        if allianceVoApi:isCanDonate() == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                getlocal("backstage8058"), 30)
            do return end
        end

        if not allianceVoApi:isOverstep24Hours( ) then
            G_showTipsDialog(getlocal("joinTimeNotEnough"))
            do return end
        end
        
        local aid = playerVoApi:getPlayerAid()
        local sid = self.sid
        local lastSkillLv = 0
        local signDonateCount = 0
        if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "22" then
            lastSkillLv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
        elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then
            lastSkillLv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
        elseif selfAlliance and sid == 0 then
            lastSkillLv = selfAlliance.level
        end

        local function allianceOneKeyDonateCallBack(fn, data)
            local ret, sData = base:checkServerData(data)

            if ret == true then
                local alliance = allianceVoApi:getSelfAlliance()
                local lastDonateTime = alliance.lastDonateTime

                local rewardStr = ""
                local rewardStrTab = {}
                local selfAlliance = allianceVoApi:getSelfAlliance()
                local oldMaxnum = selfAlliance.maxnum
                local signLevel = 0
                local signLevelOld = 0
                local haveDouble = true -- 是否有加倍

                for si,sv in ipairs(sData.data.rdata) do
                    local currentKey = sv.rname
                    local currentData = sv

                    local point = currentData.point
                    local donateTime = currentData.raising_at
                    local totalDonate = currentData.raising
                    local weekDonate = currentData.weekraising
                    local skill = {}
                    local level = 0
                    local exp = 0
                    if currentData.alliance then
                        if currentData.alliance.skills then
                            skill = currentData.alliance.skills
                            for m,n in pairs(skill) do
                                sid = tonumber(m) or tonumber(RemoveFirstChar(m))
                                level = tonumber(n[1]) or 0
                                exp = tonumber(n[2]) or 0
                            end
                        else
                            skill = currentData.alliance
                            level = tonumber(skill.level) or 0
                            exp = tonumber(skill.level_point) or 0
                        end
                    end

                    if signLevel <= level then
                        signLevel = level
                    end

                    local oldLevel
                    if sid == 0 then 
                        oldLevel = selfAlliance.level
                    else
                        oldLevel = allianceSkillVoApi:getSkillLevel(sid)
                    end
                    local diffRes = tonumber(playerVo[currentKey]) - signDonateData["cost_" .. currentKey]
                    playerVoApi:setValue(currentKey, diffRes) -- 设置资源

                    if signLevelOld <= oldLevel then
                        signLevelOld = oldLevel
                    end

                    local params = {}
                    local uid = playerVoApi:getUid()
                    params[1] = uid

                    local playerHonors = playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb = Split(playerCfg.honors, ",")
                    local maxHonors = honTb[maxLevel] --当前服 最大声望值

                    for ri = signDonateData["start_" .. currentKey], signDonateData["end_" .. currentKey] do
                        signDonateCount = signDonateCount + 1
                        local rewardCfg = playerCfg.allianceDonate[ri]
                        if sid == SizeOfTable(allianceSkillCfg) then
                            rewardCfg = playerCfg.zijinDonate[ri]
                        end
                        for k,v in pairs(rewardCfg) do
                            local name = ""
                            if k == 1 then        --科技
                                name = getlocal("alliance_skill")
                                for m,n in pairs(skill) do
                                    if sid == 0 then
                                        allianceVoApi:setAllianceLevel(level)
                                        allianceVoApi:setAllianceExp(exp)
                                    else
                                        allianceSkillVoApi:setSkillLevel(sid, level)
                                        allianceSkillVoApi:setSkillExp(sid, exp)
                                    end
                                    params[4] = sid
                                    params[5] = level
                                    params[6] = exp
                                end
                            elseif k == 2 then    --贡献
                                allianceMemberVoApi:setDonate(uid, totalDonate)
                                allianceMemberVoApi:setWeekDonate(uid, donateTime, weekDonate)
                                params[2] = totalDonate
                                params[3] = weekDonate
                                params[7] = donateTime
                                name = getlocal("alliance_contribution")
                            elseif k == 3 then    --声望
                                if base.isConvertGems == 1 and tonumber(playerHonors) >= tonumber(maxHonors) then
                                    name = getlocal("money")
                                    playerVoApi:setValue("gold", playerVoApi:getGold() + playerVoApi:convertGems(2, tonumber(v)))
                                else
                                    playerVoApi:setValue("honors", playerVoApi:getHonors() + v)
                                    name = getItem("honors", "u")
                                end
                            elseif k == 4 then    --荣誉勋章
                                if v and v > 0 then
                                    bagVoApi:addBag(19, v)
                                end
                                name = getItem("p19", "p")
                            elseif k == 5 then    --军功
                                name = getlocal("alliance_medals")
                            elseif k == 6 then    --军团资金
                                name = getlocal("alliance_funds")
                            end
                            local num = v
                            if base.isConvertGems == 1 and tonumber(playerHonors) >= tonumber(maxHonors) and k == 3 then
                                num = playerVoApi:convertGems(2, tonumber(v))
                            end

                            if (lastDonateTime and G_isToday(lastDonateTime) == false) and (donateTime and G_isToday(donateTime) == true) and (k == 1 or k == 2 or k == 6) and alliance.alevel and allianceActiveCfg.ActiveDonateCount[alliance.alevel] > 1 then
                                if haveDouble == true then
                                    num = num * allianceActiveCfg.ActiveDonateCount[alliance.alevel]
                                end
                            end

                            if v > 0 then
                                if not rewardStrTab["sign" .. k] then
                                    rewardStrTab["sign" .. k] = {}
                                end
                                rewardStrTab["sign" .. k].name = name
                                if not rewardStrTab["sign" .. k].num then
                                    rewardStrTab["sign" .. k].num = 0
                                end
                                rewardStrTab["sign" .. k].num = rewardStrTab["sign" .. k].num + num
                            end
                        end

                        haveDouble = false

                        -- 设置捐献次数
                        allianceVoApi:donateRefreshData(donateTime, currentKey)
                        allianceVoApi:apointRefreshData(1, currentData)
                    end
                    if point then
                        params[8] = point
                        local updateData = {point = point}
                        allianceVoApi:formatSelfAllianceData(updateData)
                    end
                    chatVoApi:sendUpdateMessage(9, params, aid+1)
                end

                for k,v in pairs(rewardStrTab) do
                    if rewardStr == "" then
                        rewardStr = getlocal("daily_lotto_tip_10") .. v.name .. " x" .. v.num
                    else
                        rewardStr = rewardStr .. "," .. v.name .. " x" .. v.num
                    end
                end

                G_isRefreshAllianceMemberTb = true
                local function showTip1()
                    if rewardStr ~= "" then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                            rewardStr, 28)
                    end
                end
                local function showTip2()
                    if signLevel > signLevelOld then
                        if sid == 0 then
                            local newAlliance = allianceVoApi:getSelfAlliance()
                            local newMaxnum = newAlliance.maxnum
                            local isUnlockSkill = false
                            for k,v in pairs(allianceSkillCfg) do
                                if tostring(v.allianceUnlockLevel) == tostring(signLevel) then
                                    isUnlockSkill = true
                                end
                            end
                            local tipStr = ""
                            tipStr = getlocal("alliance_levelup", {signLevel})
                            if newMaxnum > oldMaxnum then
                                tipStr = tipStr .. "," .. getlocal("alliance_levelup_unlock_maxnum")
                            end
                            if isUnlockSkill then
                                tipStr = tipStr .. "," .. getlocal("alliance_levelup_unlock_newskill")
                            end
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                                tipStr, 28)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                                getlocal("alliance_levelup_skill", {getlocal(allianceSkillCfg[sid].name), level}), 28)
                        end
                    end
                end
                local callFunc1 = CCCallFuncN:create(showTip1)
                local delay = CCDelayTime:create(0.5)
                local callFunc2 = CCCallFuncN:create(showTip2)
                local acArr = CCArray:create()
                acArr:addObject(callFunc1)
                acArr:addObject(delay)
                acArr:addObject(callFunc2)
                local seq = CCSequence:create(acArr)
                self.bgLayer:runAction(seq)
                local vo = activityVoApi:getActivityVo("fundsRecruit")
                if vo ~= nil and activityVoApi:isStart(vo) == true then
                    acFundsRecruitVoApi:updateAllianceDonateCount(signDonateCount)
                end
                if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "22" then --如果是“城市等级”的科技，则通知刷新世界地图军团城市等级
                    local curlv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                    if curlv > lastSkillLv then --等级发生变化
                        allianceCityVoApi:refreshWorldMapCity(curlv)
                    end
                elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then -- 军旗品质等级变化并解锁旗帜通知军团
                    local curlv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                    allianceVoApi:checkUnlockState(3, lastSkillLv, curlv)
                elseif sid == 0 then -- 军团等级变化并解锁旗帜通知军团
                    local curlv = 0
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance then
                        curlv = selfAlliance.level
                    end
                    allianceVoApi:checkUnlockState(1, lastSkillLv, curlv)
                end
            end

            self:close()
        end
        socketHelper:allianceAlldonate(allianceOneKeyDonateCallBack, aid, ssid, donateTab)
    end, 101, getlocal("oneKeyDonate"), 25/0.7)
    oneKeyItem:setScale(0.7)
    oneKeyItem:setEnabled(isCanDonate)
    local oneKeyMenu = CCMenu:createWithItem(oneKeyItem)
    oneKeyMenu:setPosition(ccp(bgSize.width / 2, 50))
    oneKeyMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(oneKeyMenu)

    return self.dialogLayer
end

function allianceOneKeyDonateDialog:dispose()
end