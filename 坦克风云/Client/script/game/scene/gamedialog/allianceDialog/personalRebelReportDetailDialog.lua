personalRebelReportDetailDialog = commonDialog:new()

function personalRebelReportDetailDialog:new(layerNum, report)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.report = report
    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function personalRebelReportDetailDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function personalRebelReportDetailDialog:initReportData()
    if self.report.eid then
        local data = self.report
        local myInfo = {
            name = data.content.attInfo[1], 
            level = data.content.attInfo[2], 
            fight = data.content.attInfo[3], 
            vip = data.content.attInfo[4], 
            rank = data.content.attInfo[5], 
            pic = data.content.attInfo[6] or headCfg.default, 
            hfid = data.content.attInfo[7] or headFrameCfg.default, 
            allianceName = data.content.attInfo[8] or "", 
        }
        local params = Split(data.title, "-")
        local rid = params[1]
        local monsterId = tonumber(params[2])
        local monsterLv = params[3]
        local isVictory = (tonumber(params[4]) == 1)
        local enemyInfo
        local npc = rebelVoApi:pr_getCfg().npcList[rid]
        if npc then
            local tankId = rebelVoApi:pr_getMonsterIconId(npc.type, monsterId)
            if tankId then
                enemyInfo = {}
                enemyInfo.tid = tonumber(RemoveFirstChar(tankId))
                enemyInfo.name = rebelVoApi:pr_getMonsterName(npc.type, enemyInfo.tid)
                enemyInfo.level = monsterLv
            end
        end
        --战斗损失
        local lostShip = {
            attackerLost = {}, 
            defenderLost = {}, 
            attackerTotal = {}, 
            defenderTotal = {}, 
        }
        if data.content.lostShip then
            local attackerLost = data.content.lostShip.attacker
            local defenderLost = data.content.lostShip.defenser
            if attackerLost then
                lostShip.attackerLost = FormatItem({o = attackerLost}, false)
            end
            if defenderLost then
                lostShip.defenderLost = FormatItem({o = defenderLost}, false)
            end
        end
        if data.content.tank then
            local attackerTotal = data.content.tank.a
            local defenderTotal = data.content.tank.d
            if attackerTotal then
                lostShip.attackerTotal = FormatItem({o = attackerTotal}, false)
            end
            if defenderTotal then
                lostShip.defenderTotal = FormatItem({o = defenderTotal}, false)
            end
        end
        self.report = {
            eid = data.eid, 
            time = data.ts, 
            isVictory = isVictory, 
            report = data.content.report, 
            myInfo = myInfo, 
            enemyInfo = enemyInfo, 
            rebel = data.rebel, 
            lostShip = lostShip, 
            award = data.content.award, 
            accessory = data.content.aey or {}, 
            hero = data.content.hh or {{{}, 0}, {{}, 0}}, 
            emblemID = data.content.equip, 
            plane = data.content.plane, 
            weapon = data.content.weapon, 
            armor = data.content.armor, 
            troops = data.content.troops, 
            aitroops = data.content.aitroops, 
            rp = data.content.rp, --军功
            --ri字段为战报新增功能扩展字段
            --tskinList：敌我双方坦克皮肤数据
            tskinList = G_formatExtraReportInfo(data.content.repInfo), 
            airship = data.content.ap --飞艇
        }
    end
end

function personalRebelReportDetailDialog:initTableView()
    if self.report == nil then
        do return end
    end
    self:initReportData()
    if self.report.eid then
        self:initBattleReport()
    else
        self:initScoutReport()
    end
end

function personalRebelReportDetailDialog:initBattleReport()
    self.baseLayer = CCLayer:create()
    self.detailLayer = CCLayer:create()
    self.baseLayer:setPosition(0, 0)
    self.detailLayer:setPosition(G_VisibleSizeWidth, 0)
    self.bgLayer:addChild(self.baseLayer, 1)
    self.bgLayer:addChild(self.detailLayer, 1)
    
    local resultBg, resultPic, targetStr
    if self.report.isVictory == true then
        resultBg = "reportSuccessBg.png"
        if G_getCurChoseLanguage() == "cn" then
            resultPic = "reportSuccessIcon_cn.png"
        elseif G_getCurChoseLanguage() == "tw" then
            resultPic = "reportSuccessIcon_tw.png"
        else
            resultPic = "reportSuccessIcon_en.png"
        end
    else
        resultBg = "reportFailBg.png"
        if G_getCurChoseLanguage() == "cn" then
            resultPic = "reportFailIcon_cn.png"
        elseif G_getCurChoseLanguage() == "tw" then
            resultPic = "reportFailIcon_tw.png"
        else
            resultPic = "reportFailIcon_en.png"
        end
    end
    if self.report.enemyInfo and self.report.enemyInfo.name then
        targetStr = getlocal("battleReport_attack_type4", {self.report.enemyInfo.name})
    end
    
    local infoBgSize = CCSizeMake(640, 116)
    local infoBg = CCSprite:createWithSpriteFrameName(resultBg)
    infoBg:setAnchorPoint(ccp(0.5, 1))
    infoBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 82)
    self.bgLayer:addChild(infoBg)
    
    --战斗结果
    if resultPic then
        local resultSp = CCSprite:createWithSpriteFrameName(resultPic)
        resultSp:setAnchorPoint(ccp(0, 0.5))
        resultSp:setPosition(50, infoBgSize.height / 2)
        infoBg:addChild(resultSp)
    end
    local fontSize = 22
    if G_isAsia() == false then
        fontSize = 15
    end
    if targetStr then
        local adaH = 0
        if G_isAsia() == true or G_getCurChoseLanguage() == "ko" then
            adaH = 30
        end
        local targetLb = GetTTFLabelWrap(targetStr, fontSize, CCSizeMake(300, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        targetLb:setAnchorPoint(ccp(1, 1))
        targetLb:setColor(G_ColorYellowPro)
        targetLb:setPosition(infoBgSize.width - 20, infoBgSize.height / 2 + targetLb:getContentSize().height + 30 - adaH)
        infoBg:addChild(targetLb)
        
        --战斗时间
        if self.report.time then
            local timeLb = GetTTFLabel(G_getDataTimeStr(self.report.time), fontSize)
            timeLb:setAnchorPoint(ccp(1, 1))
            timeLb:setPosition(targetLb:getPositionX(), infoBgSize.height / 2 - 30)
            infoBg:addChild(timeLb)
        end
    end
    
    --我方信息
    local iconWidth, infoWidth, infoHeight = 90, 630 / 2 - 1, 110
    local myInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportBlueBg.png", CCRect(4, 4, 1, 1), function ()end)
    myInfoBg:setAnchorPoint(ccp(0.5, 1))
    myInfoBg:setContentSize(CCSizeMake(infoWidth, infoHeight))
    myInfoBg:setPosition(5 + infoWidth / 2, infoBg:getPositionY() - infoBgSize.height)
    self.bgLayer:addChild(myInfoBg)
    if self.report.myInfo then
        local myName = self.report.myInfo.name or ""
        local myLevel = self.report.myInfo.level or 1
        local myFight = self.report.myInfo.fight or 0
        local myVip = self.report.myInfo.vip or 1
        local myRank = self.report.myInfo.rank or 0
        local myPic = self.report.myInfo.pic or headCfg.default
        local myHFid = self.report.myInfo.hfid or headFrameCfg.default
        local allianceName = self.report.myInfo.allianceName or ""
        local myIconSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(myPic), nil, nil, nil, iconWidth, myHFid)
        myIconSp:setPosition(2 + iconWidth / 2, infoHeight / 2)
        -- myIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
        myInfoBg:addChild(myIconSp)
        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50, 20))
        lvBg:setPosition(myIconSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 6, myIconSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 2)
        myInfoBg:addChild(lvBg)
        local lvLb = GetTTFLabel(getlocal("fightLevel", {myLevel}), fontSize - 4)
        lvLb:setAnchorPoint(ccp(1, 0.5))
        lvLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
        myInfoBg:addChild(lvLb, 2)
        local nameLb = GetTTFLabelWrap(myName, fontSize, CCSizeMake(200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(myIconSp:getPositionX() + 5 + iconWidth / 2, myIconSp:getPositionY() + iconWidth / 2)
        myInfoBg:addChild(nameLb)
        local allianceLb = GetTTFLabelWrap(allianceName, fontSize - 4, CCSizeMake(180, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        allianceLb:setAnchorPoint(ccp(0, 0.5))
        allianceLb:setPosition(nameLb:getPositionX(), infoHeight / 2)
        myInfoBg:addChild(allianceLb)
        local fightSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
        fightSp:setAnchorPoint(ccp(0, 0.5))
        fightSp:setScale(0.5)
        local fightLb = GetTTFLabel(FormatNumber(myFight), fontSize - 4) --战斗力
        fightLb:setAnchorPoint(ccp(0, 0.5))
        fightLb:setPosition(nameLb:getPositionX() + fightSp:getContentSize().width * 0.5 + 10, 10 + fightLb:getContentSize().height / 2)
        myInfoBg:addChild(fightLb)
        fightSp:setPosition(nameLb:getPositionX(), fightLb:getPositionY())
        myInfoBg:addChild(fightSp)
        local campBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg.png", CCRect(30, 0, 2, 24), function ()end)
        campBg:setContentSize(CCSizeMake(100, 24))
        campBg:setPosition(infoWidth - campBg:getContentSize().width / 2, campBg:getContentSize().height / 2)
        campBg:setOpacity(255 * 0.1)
        myInfoBg:addChild(campBg)
        local campLb = GetTTFLabel(getlocal("battleCamp1"), fontSize)
        campLb:setPosition(campBg:getContentSize().width / 2 + 10, campBg:getContentSize().height / 2)
        campLb:setColor(G_LowfiColorGreen)
        campBg:addChild(campLb)
    end
    
    --敌方信息
    local enemyInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportRedBg.png", CCRect(4, 4, 1, 1), function ()end)
    enemyInfoBg:setAnchorPoint(ccp(0.5, 1))
    enemyInfoBg:setContentSize(CCSizeMake(infoWidth, infoHeight))
    enemyInfoBg:setPosition(G_VisibleSizeWidth - infoWidth / 2 - 5, infoBg:getPositionY() - infoBgSize.height)
    self.bgLayer:addChild(enemyInfoBg)
    if self.report.enemyInfo then
        local rebelData = self.report.rebel or {}
        local rebelTotalLife = rebelData.rebelTotalLife or 0
        local rebelLeftLife = rebelData.rebelLeftLife or 0
        local reduceLife = rebelData.reduceLife or 0
        local rpx, rpy = infoWidth - iconWidth / 2 - 2, infoHeight / 2
        local rightPosX = rpx - iconWidth / 2 - 5
        local enemyIconSp = tankVoApi:getTankIconSp(self.report.enemyInfo.tid, nil, nil, false)
        enemyIconSp:setScale(iconWidth / enemyIconSp:getContentSize().width)
        enemyIconSp:setPosition(rpx, rpy)
        enemyInfoBg:addChild(enemyIconSp)
        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50, 20))
        lvBg:setPosition(enemyIconSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 6, enemyIconSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 2)
        lvBg:setOpacity(150)
        enemyInfoBg:addChild(lvBg)
        local lvLb = GetTTFLabel(getlocal("fightLevel", {self.report.enemyInfo.level}), fontSize - 4)
        lvLb:setAnchorPoint(ccp(1, 0.5))
        lvLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
        enemyInfoBg:addChild(lvLb)
        local nameLbFontSize = fontSize
        if G_getCurChoseLanguage() == "ja" then
            nameLbFontSize = fontSize - 6
        end
        local nameLb = GetTTFLabelWrap(self.report.enemyInfo.name, nameLbFontSize, CCSizeMake(200, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(1, 1))
        nameLb:setPosition(rightPosX, enemyIconSp:getPositionY() + iconWidth / 2)
        enemyInfoBg:addChild(nameLb)
        local scalex = 0.4
        local leftPer = (rebelLeftLife / rebelTotalLife) * 100
        local scheduleStr = ""
        if leftPer > 0 and leftPer < 1 then
            scheduleStr = "1%"
        else
            scheduleStr = G_keepNumber(leftPer, 0) .. "%"
        end
        AddProgramTimer(enemyInfoBg, ccp(rightPosX - 286 * scalex * 0.5 - 5, infoHeight / 2), 11, 12, scheduleStr, "rebelProgressBg.png", "rebelProgress.png", 13, scalex, 1, nil, nil, 18)
        local per = (rebelLeftLife / rebelTotalLife) * 100
        local timerSpriteLv = enemyInfoBg:getChildByTag(11)
        timerSpriteLv = tolua.cast(timerSpriteLv, "CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        local lb = tolua.cast(timerSpriteLv:getChildByTag(12), "CCLabelTTF")
        lb:setScaleX(1 / scalex)
        local reducePer = (reduceLife / rebelTotalLife) * 100
        reducePer = string.format("%.2f", reducePer)
        local perLb = GetTTFLabel("-" .. reducePer .. "%", fontSize)
        perLb:setAnchorPoint(ccp(1, 0.5))
        perLb:setPosition(rightPosX, 10 + perLb:getContentSize().height / 2)
        perLb:setColor(G_LowfiColorRed)
        enemyInfoBg:addChild(perLb)
        local enemyCampBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg2.png", CCRect(0, 0, 2, 24), function ()end)
        enemyCampBg:setContentSize(CCSizeMake(100, 24))
        enemyCampBg:setPosition(enemyCampBg:getContentSize().width / 2, enemyCampBg:getContentSize().height / 2)
        enemyCampBg:setOpacity(255 * 0.1)
        enemyInfoBg:addChild(enemyCampBg)
        local enemyCampLb = GetTTFLabel(getlocal("battleCamp2"), fontSize)
        enemyCampLb:setPosition(enemyCampBg:getContentSize().width / 2 - 10, enemyCampBg:getContentSize().height / 2)
        enemyCampLb:setColor(G_LowfiColorRed)
        enemyInfoBg:addChild(enemyCampLb)
    end
    
    self:initShowType() --初始化战报显示元素类型
    self.baseNum = SizeOfTable(self.baseShowType)
    self.detailNum = 0
    if self.detailShowType then
        self.detailNum = SizeOfTable(self.detailShowType)
    end
    
    self.tvTb = {}
    self.tvWidth, self.tvHeight = 630, G_VisibleSizeHeight - 450
    if self.detailNum == 0 then
        self.tvHeight = self.tvHeight + 30
    end
    
    for i = 1, 2 do
        local function callBack(...)
            if i == 1 then
                return self:reportEventHandler1(...)
            else
                return self:reportEventHandler2(...)
            end
        end
        local hd = LuaEventHandler:createHandler(callBack)
        local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
        tv:setAnchorPoint(ccp(0, 0))
        tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, myInfoBg:getPositionY() - myInfoBg:getContentSize().height - self.tvHeight)
        tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
        if i == 1 then
            self.baseLayer:addChild(tv)
        else
            self.detailLayer:addChild(tv)
        end
        self.tvTb[i] = tv
    end
    
    --显示实力对比
    if self.detailShowType and self.detailNum > 0 then
        self.showIdx = 1
        local tv = tolua.cast(self.tvTb[1], "LuaCCTableView")
        local function showDetail()
            if self.detailBtn then
                local function realShow()
                    local detailLb = tolua.cast(self.detailBtn:getChildByTag(101), "CCLabelTTF")
                    local moveDis = 0
                    if self.showIdx == 1 then
                        self.showIdx = 2
                        detailLb:setString(getlocal("checkReportBaseInfoStr"))
                        moveDis = - G_VisibleSizeWidth
                    else
                        self.showIdx = 1
                        detailLb:setString(getlocal("checkReportDetailStr"))
                        moveDis = G_VisibleSizeWidth
                    end
                    local infoTv = tolua.cast(self.tvTb[self.showIdx], "LuaCCTableView")
                    if infoTv then
                        infoTv:reloadData()
                    end
                    self.moving = true
                    for i = 1, 2 do
                        local moveBy = CCMoveBy:create(0.5, ccp(moveDis, 0))
                        local function moveEnd()
                            self.moving = false
                        end
                        if i == 1 then
                            self.baseLayer:runAction(CCSequence:createWithTwoActions(moveBy, CCCallFunc:create(moveEnd)))
                        else
                            self.detailLayer:runAction(moveBy)
                        end
                    end
                end
                
                G_touchedItem(self.detailBtn, realShow, 0.9)
            end
        end
        local detailBtn = LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png", showDetail)
        detailBtn:setPosition(G_VisibleSizeWidth / 2, tv:getPositionY() - detailBtn:getContentSize().height / 2)
        detailBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(detailBtn, 5)
        self.detailBtn = detailBtn
        for i = 1, 2 do
            local arrowSp = CCSprite:createWithSpriteFrameName("reportArrow.png")
            if i == 1 then
                arrowSp:setPosition(150, detailBtn:getContentSize().height / 2)
            else
                arrowSp:setPosition(detailBtn:getContentSize().width - 150, detailBtn:getContentSize().height / 2)
                arrowSp:setRotation(180)
            end
            detailBtn:addChild(arrowSp)
        end
        local detailLb = GetTTFLabelWrap(getlocal("checkReportDetailStr"), 22, CCSizeMake(200, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        detailLb:setPosition(getCenterPoint(detailBtn))
        detailLb:setTag(101)
        detailBtn:addChild(detailLb)
    else
        local tv = tolua.cast(self.tvTb[1], "LuaCCTableView")
        if tv then
            local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
            mLine:setPosition(ccp(G_VisibleSizeWidth / 2, tv:getPositionY() - mLine:getContentSize().height / 2))
            mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth - 10, mLine:getContentSize().height))
            self.bgLayer:addChild(mLine)
        end
    end
    
    self:initBottomBtutton()
end

function personalRebelReportDetailDialog:initBottomBtutton()
    local report = self.report
    
    local function operateHandler(tag, object)
        if G_checkClickEnable() == false then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        
        if tag == 11 then
            --如果没有战斗
            if report.report == nil or SizeOfTable(report.report) == 0 then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("fight_content_result_no_play"), true, self.layerNum + 1)
            else
                local isAttacker = true
                local enemyName = self.report.enemyInfo and self.report.enemyInfo.name or ""
                local data = {data = report, isAttacker = isAttacker, isReport = true, personalRebelData = {prName = enemyName or ""}}
                -- data.battleType = self.battleType
                battleScene:initData(data, nil, nil, self.layerNum + 1)
            end
        elseif tag == 16 then
            --检测是否被禁言
            if chatVoApi:canChat(self.layerNum) == false then
                do return end
            end
            
            local playerLv = playerVoApi:getPlayerLevel()
            local timeInterval = playerCfg.chatLimitCfg[playerLv] or 0
            local diffTime = 0
            if base.lastSendTime then
                diffTime = base.serverTime - base.lastSendTime
            end
            if diffTime >= timeInterval then
                self.canSand = true
            end
            if self.canSand == nil or self.canSand == false then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("time_limit_prompt", {timeInterval - diffTime}), true, self.layerNum + 1)
                do return end
            end
            self.canSand = false
            
            local sender = playerVoApi:getUid()
            local chatContent = getlocal("championshipWar_title") .. championshipWarVoApi:getRoundTitle(self.report.round) .. " " .. report.myInfo.name .. " VS " .. report.enemyInfo.name
            --如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
            if report.report ~= nil and SizeOfTable(report.report) > 0 then
                local hasAlliance = allianceVoApi:isHasAlliance()
                local reportData = report.report or {}
                local isAttacker = true
                if hasAlliance == false then
                    base.lastSendTime = base.serverTime
                    local senderName = playerVoApi:getPlayerName()
                    local level = playerVoApi:getPlayerLevel()
                    local rank = playerVoApi:getRank()
                    local language = G_getCurChoseLanguage()
                    local params = {}
                    params = {subType = 1, contentType = 2, message = chatContent, level = level, rank = rank, power = playerVoApi:getPlayerPower(), uid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), pic = playerVoApi:getPic(), report = reportData, ts = base.serverTime, vip = playerVoApi:getVipLevel(), language = language, isExpedition = true, isAttacker = isAttacker, wr = playerVoApi:getServerWarRank(), st = playerVoApi:getServerWarRankStartTime(), title = playerVoApi:getTitle()}
                    --chatVoApi:addChat(1,sender,senderName,0,"",params)
                    chatVoApi:sendChatMessage(1, sender, senderName, 0, "", params)
                    --mainUI:setLastChat()
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
                else
                    local function sendReportHandle(tag, object)
                        base.lastSendTime = base.serverTime
                        local channelType = tag or 1
                        
                        local senderName = playerVoApi:getPlayerName()
                        local level = playerVoApi:getPlayerLevel()
                        local rank = playerVoApi:getRank()
                        local allianceName
                        local allianceRole
                        if allianceVoApi:isHasAlliance() then
                            local allianceVo = allianceVoApi:getSelfAlliance()
                            allianceName = allianceVo.name
                            allianceRole = allianceVo.role
                        end
                        local language = G_getCurChoseLanguage()
                        params = {subType = channelType, contentType = 2, message = chatContent, level = level, rank = rank, power = playerVoApi:getPlayerPower(), uid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), pic = playerVoApi:getPic(), report = reportData, ts = base.serverTime, allianceName = allianceName, allianceRole = allianceRole, vip = playerVoApi:getVipLevel(), language = language, isExpedition = true, isAttacker = isAttacker, wr = playerVoApi:getServerWarRank(), st = playerVoApi:getServerWarRankStartTime(), title = playerVoApi:getTitle()}
                        local aid = playerVoApi:getPlayerAid()
                        if channelType == 1 then
                            chatVoApi:sendChatMessage(1, sender, senderName, 0, "", params)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
                        elseif aid then
                            chatVoApi:sendChatMessage(aid + 1, sender, senderName, 0, "", params)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
                        end
                    end
                    allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png", CCSizeMake(450, 350), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, sendReportHandle)
                end
            end
        end
    end
    
    local scale = 0.75
    self.replayBtn = GetButtonItem("letterBtnPlay_v2.png", "letterBtnPlay_Down_v2.png", "letterBtnPlay_Down_v2.png", operateHandler, 11, nil, nil)
    self.replayBtn:setScaleX(scale)
    self.replayBtn:setScaleY(scale)
    local replaySpriteMenu = CCMenu:createWithItem(self.replayBtn)
    replaySpriteMenu:setAnchorPoint(ccp(0.5, 0))
    replaySpriteMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    
    -- self.sendBtn = GetButtonItem("letterBtnSend_v2.png", "letterBtnSend_Down_v2.png", "letterBtnSend_Down_v2.png", operateHandler, 16, nil, nil)
    -- self.sendBtn:setScaleX(scale)
    -- self.sendBtn:setScaleY(scale)
    -- local sendSpriteMenu = CCMenu:createWithItem(self.sendBtn)
    -- sendSpriteMenu:setAnchorPoint(ccp(0.5, 0))
    -- sendSpriteMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    
    local height = 45
    local posXScale = self.bgLayer:getContentSize().width
    
    self.bgLayer:addChild(replaySpriteMenu, 2)
    -- self.bgLayer:addChild(sendSpriteMenu, 2)
    -- replaySpriteMenu:setPosition(ccp(posXScale / 4 * 1, height))
    replaySpriteMenu:setPosition(ccp(G_VisibleSizeWidth / 2, height))
    -- sendSpriteMenu:setPosition(ccp(posXScale / 4 * 3, height))
    
    if report and report.report == nil or SizeOfTable(report.report) == 0 then
        self.replayBtn:setEnabled(false)
        -- self.sendBtn:setEnabled(false)
    end
end

function personalRebelReportDetailDialog:reportEventHandler1(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.baseNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getReportCellHeight1(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getReportCellHeight1(idx + 1)
        local showType = self.baseShowType[idx + 1]
        
        local isAttacker = true
        if showType == 1 then --资源信息
            local resourceTb = self:getReportResource()
            G_reportResourceLayout(cell, cellWidth, cellHeight, resourceTb, getlocal("fight_award"), self.layerNum, self.report, isAttacker)
        elseif showType == 3 then --部队损耗信息
            local troops
            if isAttacker == true then
                troops = self.report.troops
            else
                troops = {self.report.troops[2], self.report.troops[1]}
            end
            G_getBattleReportTroopsLayout(cell, cellWidth, cellHeight, troops, self.layerNum, self.report, isAttacker, idx ~= 1)
        elseif showType == 10 then --攻打叛军时的战斗信息
            local titleBg = G_createReportTitle(cellWidth - 20, getlocal("fight_content_fight_info"), idx ~= 1)
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(cellWidth / 2, cellHeight - 5)
            cell:addChild(titleBg, 2)
            local fontSize, fontWidth = 20, cellWidth - 60
            local rebelData = self.report.rebel or {}
            local attNum = rebelData.attNum or 0
            local posY = cellHeight - 32 - 15
            if attNum and attNum > 0 then
                local attNumStr = getlocal("email_report_rebel_attack_num", {attNum})
                local colorTab = {G_ColorWhite, G_ColorGreen, G_ColorWhite}
                local attNumLb, lbHeight = G_getRichTextLabel(attNumStr, colorTab, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                attNumLb:setAnchorPoint(ccp(0.5, 1))
                attNumLb:setPosition(cellWidth / 2, posY)
                cell:addChild(attNumLb, 1)
                posY = posY - lbHeight - 10
                
                local buff = rebelCfg.attackBuff * 100 * attNum
                local buffLb = GetTTFLabel(getlocal("worldRebel_comboBuff", {buff .. "%%"}), fontSize)
                buffLb:setAnchorPoint(ccp(0.5, 1))
                buffLb:setPosition(cellWidth / 2, posY)
                buffLb:setColor(G_ColorGreen)
                cell:addChild(buffLb, 1)
            end
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function personalRebelReportDetailDialog:reportEventHandler2(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.detailNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getReportCellHeight2(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getReportCellHeight2(idx + 1)
        local showType = self.detailShowType[idx + 1]
        local isAttacker = true
        if showType == 4 then --装甲矩阵
            G_getReportArmorMatrixLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 5 then --配件
            G_getReportAccessoryLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 6 then --将领
            G_getReportHeroLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 7 then --超级武器
            G_getReportSuperWeaponLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 8 then --军徽
            G_getReportEmblemLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 9 then --飞机
            G_getReportPlaneLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
        elseif showType == 11 then --AI部队
            G_getBattleReportAITroopsLayout(cell, cellWidth, cellHeight, (self.report.aitroops or {}), self.layerNum, self.report, isAttacker)
        elseif showType==12 then --飞艇
            G_getReportAirShipLayout(cell, cellWidth, cellHeight, self.report, isAttacker)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function personalRebelReportDetailDialog:getReportCellHeight1(idx)
    if self.cellHeightTb1 == nil then
        self.cellHeightTb1 = {}
    end
    if self.cellHeightTb1[idx] == nil then
        local height = 0
        local showType = self.baseShowType[idx]
        if showType == 1 then --战斗资源相关
            local resource = self:getReportResource()
            height = G_reportResourceCellHeight(resource)
        elseif showType == 3 then --战斗部队损耗
            height = G_getBattleReportTroopsHeight(self.report)
        elseif showType == 10 then --攻打叛军时的战斗信息
            height = 32
            local fontSize, fontWidth = 20, self.tvWidth - 60
            local rebelData = self.report.rebel or {}
            local attNum = rebelData.attNum or 0
            if attNum and attNum > 0 then
                local buff = rebelCfg.attackBuff * 100 * attNum
                local buffLb = GetTTFLabel(getlocal("worldRebel_comboBuff", {buff .. "%%"}), fontSize)
                local attNumStr = getlocal("email_report_rebel_attack_num", {attNum})
                local attNumLb, lbHeight = G_getRichTextLabel(attNumStr, {}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                height = height + buffLb:getContentSize().height + lbHeight + 30
            end
        end
        self.cellHeightTb1[idx] = height
    end
    return self.cellHeightTb1[idx]
end

function personalRebelReportDetailDialog:getReportCellHeight2(idx)
    if self.cellHeightTb2 == nil then
        self.cellHeightTb2 = {}
    end
    if self.cellHeightTb2[idx] == nil then
        local height = 0
        local showType = self.detailShowType[idx]
        if showType == 4 then --装甲矩阵
            height = G_getReportArmorMatrixHeight()
        elseif showType == 5 then --配件
            height = G_getReportAccessoryHeight()
        elseif showType == 6 then --将领
            height = G_getReportHeroLayoutHeight()
        elseif showType == 7 then --超级武器
            height = G_getReportSuperWeaponLayoutHeight()
        elseif showType == 8 then --军徽
            height = G_getReportEmblemLayoutHeight()
        elseif showType == 9 then --飞机
            height = G_getReportPlaneLayoutHeight()
        elseif showType == 11 then --AI部队
            height = G_getBattleReportAITroopsHeight()
        elseif showType==12 then --飞艇
            height=G_getReportAirShipLayoutHeight()
        end
        self.cellHeightTb2[idx] = height
    end
    return self.cellHeightTb2[idx]
end

--战斗资源相关
function personalRebelReportDetailDialog:getReportResource()
    if self.resource == nil then
        self.resource = G_getReportResource(self.report)
    end
    return self.resource
end

--根据战报的类型来初始化报告详情的显示类型
--showType：1.战利品(资源)，2.繁荣度，3.部队损耗，4.装甲矩阵，5.配件，6.将领，7.超级武器，8.军徽，9.飞机，10.攻打叛军时的战斗信息，11.AI部队
function personalRebelReportDetailDialog:initShowType()
    self.baseShowType = {}
    table.insert(self.baseShowType, 1) --战利品(资源)
    local rebelData = self.report.rebel or {}
    local attNum = rebelData.attNum or 0
    if attNum and attNum > 0 then
        table.insert(self.baseShowType, 10) --攻打叛军时的战斗信息
    end
    table.insert(self.baseShowType, 3) --部队损耗
    local isShowHero = false--将领
    local isShowAccessory = false--配件
    local isShowEmblem = false --军徽
    local isShowPlane = false--飞机
    local armorMatrixFlag = false --装甲矩阵
    local superWeaponFlag = false --超级武器
    
    if base.heroSwitch == 1 then
        isShowHero = true
    end
    
    if base.ifAccessoryOpen == 1 then
        isShowAccessory = true
    end
    
    if base.emblemSwitch == 1 and self.report.emblemID and SizeOfTable(self.report.emblemID) == 2 and (self.report.emblemID[1] ~= 0 or self.report.emblemID[2] ~= 0) then
        isShowEmblem = true
    end
    
    isShowPlane = G_isShowPlaneInReport(self.report)
    
    if armorMatrixVoApi:isOpenArmorMatrix() == true and self.report.armor then
        armorMatrixFlag = true
    end
    
    if self.report.weapon then
        superWeaponFlag = true
    end
    
    self.detailShowType = {}
    if armorMatrixFlag == true then
        table.insert(self.detailShowType, 4) --装甲矩阵
    end
    if isShowAccessory == true then
        table.insert(self.detailShowType, 5) --配件
    end
    if isShowHero == true then
        table.insert(self.detailShowType, 6) --将领
    end
    if superWeaponFlag == true then
        table.insert(self.detailShowType, 7) --超级武器
    end
    local aiFlag = G_isShowAITroopsInReport(self.report) --AI部队
    if aiFlag == true then
        table.insert(self.detailShowType, 11)
    end
    if isShowEmblem == true then
        table.insert(self.detailShowType, 8) --军徽
    end
    if isShowPlane == true then
        table.insert(self.detailShowType, 9) --飞机
    end
    if airShipVoApi:isCanEnter() == true then --飞艇
        table.insert(self.detailShowType,12)
    end
end

function personalRebelReportDetailDialog:initScoutReport()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local topBg = CCSprite:create("public/reportTopContentBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(self.bgLayer:getContentSize().width / 2, G_VisibleSizeHeight - 83)
    self.bgLayer:addChild(topBg)
    
    local params = Split(self.report.title, "-")
    local rid = params[1]
    local monsterId = tonumber(params[2])
    local monsterLv = params[3]
    
    local _lbFontSize = 20 --字体大小
    local islandShowSize = 150 --图标显示大小
    local islandSpPosX = 35 + islandShowSize / 2
    local npc = rebelVoApi:pr_getCfg().npcList[rid]
    if npc then
        local tankId = rebelVoApi:pr_getMonsterIconId(npc.type, monsterId)
        if tankId then
            tankId = tonumber(RemoveFirstChar(tankId))
            local tankIcon = G_getTankPic(tankId, nil, nil, nil, nil, false)
            if tankIcon then
                tankIcon:setPosition(islandSpPosX, topBg:getContentSize().height / 2 + 20)
                tankIcon:setScale(islandShowSize / tankIcon:getContentSize().width)
                topBg:addChild(tankIcon)
                
                --侦察时间
                local timeLb = GetTTFLabel(G_getDataTimeStr(self.report.ts), _lbFontSize)
                timeLb:setAnchorPoint(ccp(0.5, 1))
                timeLb:setPosition(islandSpPosX, tankIcon:getPositionY() - islandShowSize / 2)
                timeLb:setColor(G_ColorYellowPro)
                topBg:addChild(timeLb)
                
                --图标
                local typeIcon = CCSprite:createWithSpriteFrameName("emailNewUI_scout1.png")
                typeIcon:setAnchorPoint(ccp(1, 0.5))
                typeIcon:setPosition(timeLb:getPositionX() - timeLb:getContentSize().width / 2, timeLb:getPositionY() - timeLb:getContentSize().height / 2)
                typeIcon:setScale(0.9)
                topBg:addChild(typeIcon)
                
                --名称
                local nameStr = rebelVoApi:pr_getMonsterName(npc.type, tankId) .. getlocal("fightLevel", {monsterLv})
                local siteLb = GetTTFLabel(getlocal("scout_content_site") .. nameStr, _lbFontSize)
                siteLb:setAnchorPoint(ccp(0, 0.5))
                siteLb:setPosition(islandSpPosX + islandShowSize / 2 + 20, topBg:getContentSize().height / 2)
                siteLb:setColor(G_ColorYellowPro)
                topBg:addChild(siteLb)
            end
        end
    end
    
    self.tvWidth, self.tvHeight = 616, topBg:getPositionY() - topBg:getContentSize().height - 90 - 10
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, 90)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(self.tv)
end

function personalRebelReportDetailDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getReportCellHeight(idx))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth, cellHeight = self.tvWidth, self.cellHeightTb[idx + 1]
        local titleBg, titleLb = G_createReportTitle(cellWidth - 20, "")
        titleBg:setAnchorPoint(ccp(0.5, 0))
        titleBg:setPosition(ccp(cellWidth / 2, cellHeight - titleBg:getContentSize().height))
        cell:addChild(titleBg)
        titleLb:setString(getlocal("alliance_challenge_enemy_info"))
        local shipTab = {}
        if type(self.report.defendShip) == "table" then
            for k, v in pairs(self.report.defendShip) do
                if v and v[1] and v[2] and v[2] > 0 then
                    local key = v[1]
                    local num = v[2]
                    local name, pic, desc = getItem(key, "o")
                    table.insert(shipTab, k, {name = name, pic = pic, num = num, key = key})
                else
                    table.insert(shipTab, k, {})
                end
            end
        end
        
        local _posX1 = cellWidth / 2 - 150
        local _posX2 = cellWidth / 2 + 150
        local _posY = titleBg:getPositionY() - 10
        local lb1 = GetTTFLabel(getlocal("front"), 20)
        local lb2 = GetTTFLabel(getlocal("back"), 20)
        lb1:setAnchorPoint(ccp(0.5, 1))
        lb2:setAnchorPoint(ccp(0.5, 1))
        lb1:setPosition(_posX1, _posY)
        lb2:setPosition(_posX2, _posY)
        cell:addChild(lb1)
        cell:addChild(lb2)
        
        local _tankIconSize = 100
        local _tankIconSpaceY = 50
        _posY = _posY - lb1:getContentSize().height - 10
        
        for k = 1, 6 do
            local tankIconBgPosX = (k > 3) and _posX2 or _posX1
            local tankIconBgPosY = _posY - _tankIconSize / 2 - ((k - 1)%3) * (_tankIconSize + _tankIconSpaceY)
            local v
            if shipTab then
                v = shipTab[k]
            end
            if v and v.pic and v.name and v.num then
                local icon = CCSprite:createWithSpriteFrameName(v.pic)
                icon:setPosition(tankIconBgPosX, tankIconBgPosY)
                icon:setScale(_tankIconSize / icon:getContentSize().width)
                cell:addChild(icon)
                
                if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
                    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    icon:addChild(pickedIcon)
                    pickedIcon:setPosition(icon:getContentSize().width * 0.7, icon:getContentSize().height * 0.5 - 10)
                end
                
                -- local str=(v.name).."("..FormatNumber(v.num)..")"
                local str = tostring(FormatNumber(v.num))
                local descLable = GetTTFLabelWrap(str, 20, CCSizeMake(24 * 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                descLable:setAnchorPoint(ccp(0.5, 1))
                descLable:setPosition(ccp(tankIconBgPosX, tankIconBgPosY - _tankIconSize / 2))
                cell:addChild(descLable)
            else
                local tankIconBg = CCSprite:createWithSpriteFrameName("tankShadeIcon.png")
                tankIconBg:setAnchorPoint(ccp(0.5, 0.5))
                tankIconBg:setPosition(ccp(tankIconBgPosX, tankIconBgPosY))
                tankIconBg:setScale(_tankIconSize / tankIconBg:getContentSize().width)
                cell:addChild(tankIconBg)
            end
        end
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end

function personalRebelReportDetailDialog:getReportCellHeight(idx)
    if self.cellHeightTb == nil then
        self.cellHeightTb = {}
    end
    if self.cellHeightTb[idx + 1] == nil then
        local height = 0
        
        height = height + 32 --titleBgHeight
        height = height + 10 --local _posY=titleBg:getPositionY()-10
        
        local lb1 = GetTTFLabel(getlocal("front"), 20)
        height = height + lb1:getContentSize().height + 10 --_posY=_posY-lb1:getContentSize().height-10
        
        local _tankIconSize = 100
        local _tankIconSpaceY = 50
        height = height + 3 * (_tankIconSize + _tankIconSpaceY)
        
        self.cellHeightTb[idx + 1] = height
    end
    return self.cellHeightTb[idx + 1]
end

function personalRebelReportDetailDialog:dispose()
    self = nil
    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
end