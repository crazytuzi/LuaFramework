exerWarReportDetailDialog = commonDialog:new()

function exerWarReportDetailDialog:new(layerNum, report, reportTitleStr)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.report = report
    self.reportTitleStr = reportTitleStr
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

function exerWarReportDetailDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function exerWarReportDetailDialog:initReportData()
    local data = self.report
    local attInfo = {
        name = data.attInfo[1], 
        fight = data.attInfo[2], 
        rank = data.attInfo[3], 
        pic = data.attInfo[4] or headCfg.default, 
        level = data.attInfo[6], 
        allianceName = data.attInfo[7] or "", 
    }
    local defInfo = {
        name = data.defInfo[1], 
        fight = data.defInfo[2], 
        rank = data.defInfo[3], 
        pic = data.defInfo[4] or headCfg.default, 
        level = data.defInfo[6], 
        allianceName = data.defInfo[7] or "", 
    }
    local isVictory = (data.report.r == 1)
    self.report = {
        -- time = data.ts, 
        isVictory = isVictory, 
        report = data.report, 
        myInfo = attInfo, 
        enemyInfo = defInfo, 
        hero = data.hh or {{{}, 0}, {{}, 0}}, 
        emblemID = data.se, 
        plane = data.plane, 
        troops = data.troops, 
        aitroops = data.ait, 
        landform = data.landform,
    }
end

function exerWarReportDetailDialog:initTableView()
    if self.report == nil then
        do return end
    end
    self:initReportData()
    
    self.baseLayer = CCLayer:create()
    self.detailLayer = CCLayer:create()
    self.baseLayer:setPosition(0, 0)
    self.detailLayer:setPosition(G_VisibleSizeWidth, 0)
    self.bgLayer:addChild(self.baseLayer, 1)
    self.bgLayer:addChild(self.detailLayer, 1)
    
    local resultBg, resultPic
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
    if self.reportTitleStr then
        local adaH = 0
        if G_isAsia() == true or G_getCurChoseLanguage() == "ko" then
            adaH = 30
        end
        local targetLb = GetTTFLabelWrap(self.reportTitleStr, fontSize, CCSizeMake(300, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
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
        local myPic = self.report.myInfo.pic or headCfg.default
        local myHFid = self.report.myInfo.hfid or headFrameCfg.default
        local allianceName = self.report.myInfo.allianceName or ""
        local myIconSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(myPic), nil, nil, nil, iconWidth, myHFid)
        myIconSp:setPosition(2 + iconWidth / 2, infoHeight / 2)
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
        local defName = self.report.enemyInfo.name or ""
        local defLevel = self.report.enemyInfo.level or 1
        local defFight = self.report.enemyInfo.fight or 0
        local defPic = self.report.enemyInfo.pic or headCfg.default
        local defHFid = self.report.enemyInfo.hfid or headFrameCfg.default
        local defAllianceName = self.report.enemyInfo.allianceName or ""
        local rpx, rpy = infoWidth - iconWidth / 2 - 2, infoHeight / 2
        local rightPosX = rpx - iconWidth / 2 - 5
        local enemyIconSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(defPic), nil, nil, nil, iconWidth, defHFid)
        enemyIconSp:setScale(iconWidth / enemyIconSp:getContentSize().width)
        enemyIconSp:setPosition(rpx, rpy)
        enemyInfoBg:addChild(enemyIconSp)
        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50, 20))
        lvBg:setPosition(enemyIconSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 6, enemyIconSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 2)
        enemyInfoBg:addChild(lvBg)
        local lvLb = GetTTFLabel(getlocal("fightLevel", {defLevel}), fontSize - 4)
        lvLb:setAnchorPoint(ccp(1, 0.5))
        lvLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
        enemyInfoBg:addChild(lvLb)
        local nameLbFontSize = fontSize
        if G_getCurChoseLanguage() == "ja" then
            nameLbFontSize = fontSize - 6
        end
        local nameLb = GetTTFLabelWrap(defName, nameLbFontSize, CCSizeMake(200, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(1, 1))
        nameLb:setPosition(rightPosX, enemyIconSp:getPositionY() + iconWidth / 2)
        enemyInfoBg:addChild(nameLb)
        
        local allianceLb = GetTTFLabelWrap(defAllianceName, fontSize - 4, CCSizeMake(180, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        allianceLb:setAnchorPoint(ccp(0, 0.5))
        allianceLb:setPosition(nameLb:getPositionX(), infoHeight / 2)
        enemyInfoBg:addChild(allianceLb)
        local fightSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
        fightSp:setAnchorPoint(ccp(1, 0.5))
        fightSp:setScale(0.5)
        local fightLb = GetTTFLabel(FormatNumber(defFight), fontSize - 4) --战斗力
        fightLb:setAnchorPoint(ccp(1, 0.5))
        fightLb:setPosition(nameLb:getPositionX(), 10 + fightLb:getContentSize().height / 2)
        enemyInfoBg:addChild(fightLb)
        fightSp:setPosition(fightLb:getPositionX() - fightLb:getContentSize().width, fightLb:getPositionY())
        enemyInfoBg:addChild(fightSp)
        
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

function exerWarReportDetailDialog:initBottomBtutton()
    local function operateHandler(tag, object)
        if G_checkClickEnable() == false then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 11 then
            --如果没有战斗
            if self.report.report == nil or SizeOfTable(self.report.report) == 0 then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("fight_content_result_no_play"), true, self.layerNum + 1)
            else
                local isAttacker = true
                local data = {data = self.report, landform = self.report.landform, isAttacker = isAttacker, isReport = true}
                -- data.battleType = self.battleType
                battleScene:initData(data, nil, nil, self.layerNum + 1)
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
    
    self.bgLayer:addChild(replaySpriteMenu, 2)
    replaySpriteMenu:setPosition(ccp(G_VisibleSizeWidth / 2, 45))
    
    if self.report and self.report.report == nil or SizeOfTable(self.report.report) == 0 then
        self.replayBtn:setEnabled(false)
    end
end

function exerWarReportDetailDialog:reportEventHandler1(handler, fn, idx, cel)
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
        if showType == 3 then --部队损耗信息
            local troops
            if isAttacker == true then
                troops = self.report.troops
            else
                troops = {self.report.troops[2], self.report.troops[1]}
            end
            G_getBattleReportTroopsLayout(cell, cellWidth, cellHeight, troops, self.layerNum, self.report, isAttacker, idx ~= 1)
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

function exerWarReportDetailDialog:reportEventHandler2(handler, fn, idx, cel)
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
        elseif showType == 12 then --飞机技能
            G_getReportPlaneSkillLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, isAttacker)
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

function exerWarReportDetailDialog:getReportCellHeight1(idx)
    if self.cellHeightTb1 == nil then
        self.cellHeightTb1 = {}
    end
    if self.cellHeightTb1[idx] == nil then
        local height = 0
        local showType = self.baseShowType[idx]
        if showType == 3 then --战斗部队损耗
            height = G_getBattleReportTroopsHeight(self.report)
        end
        self.cellHeightTb1[idx] = height
    end
    return self.cellHeightTb1[idx]
end

function exerWarReportDetailDialog:getReportCellHeight2(idx)
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
        elseif showType == 12 then --飞机技能
            height = G_getReportPlaneSkillLayoutHeight()
        end
        self.cellHeightTb2[idx] = height
    end
    return self.cellHeightTb2[idx]
end

--根据战报的类型来初始化报告详情的显示类型
--showType：1.战利品(资源)，2.繁荣度，3.部队损耗，4.装甲矩阵，5.配件，6.将领，7.超级武器，8.军徽，9.飞机，10.攻打叛军时的战斗信息，11.AI部队，12.飞机技能
function exerWarReportDetailDialog:initShowType()
    self.baseShowType = {}
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
    
    -- if base.ifAccessoryOpen == 1 then
    --     isShowAccessory = true
    -- end
    
    if base.emblemSwitch == 1 and self.report.emblemID and SizeOfTable(self.report.emblemID) == 2 and (self.report.emblemID[1] ~= 0 or self.report.emblemID[2] ~= 0) then
        isShowEmblem = true
    end
    
    isShowPlane = G_isShowPlaneInReport(self.report)
    
    -- if armorMatrixVoApi:isOpenArmorMatrix() == true and self.report.armor then
    --     armorMatrixFlag = true
    -- end
    
    -- if self.report.weapon then
    --     superWeaponFlag = true
    -- end
    
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
        table.insert(self.detailShowType, 12) --飞机技能
    end
end

function exerWarReportDetailDialog:dispose()
    self = nil
    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
end