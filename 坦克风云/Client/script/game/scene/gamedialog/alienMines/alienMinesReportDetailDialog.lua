alienMinesReportDetailDialog = commonDialog:new()

function alienMinesReportDetailDialog:new(layerNum, eid)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.eid = eid
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
    
    return nc
end

function alienMinesReportDetailDialog:initTableView()
    local panelBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png", CCRect(30, 0, 2, 3), function ()end)
    panelBg:setAnchorPoint(ccp(0.5, 0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 82))
    panelBg:setPosition(G_VisibleSizeWidth / 2, 5)
    self.bgLayer:addChild(panelBg)
    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
    if self.panelTopLine then
        self.panelTopLine:setVisible(true)
        self.panelTopLine:setPositionY(G_VisibleSizeHeight - 82)
    end
    
    local emailVo = nil
    if self.eid then
        emailVo = alienMinesEmailVoApi:getEmailByEid(self.eid)
    end
    self.report = nil
    if emailVo then
        self.report = alienMinesEmailVoApi:getReport(emailVo.eid)
    end
    
    if self.report == nil or SizeOfTable(self.report) == 0 then
        do return end
    end
    
    if self.report.type == 1 then --战斗报告
        self:battleReportUI(self.report)
    elseif self.report.type == 2 then --侦查报告
        self:scoutReportUI(self.report)
    elseif self.report.type == 3 then --返回报告
        self:returnReportUI(self.report)
    end
    
    self:initBottomBtutton(self.report)
end

--战斗报告
function alienMinesReportDetailDialog:battleReportUI(report)
    self.baseLayer = CCLayer:create()
    self.detailLayer = CCLayer:create()
    self.baseLayer:setPosition(0, 0)
    self.detailLayer:setPosition(G_VisibleSizeWidth, 0)
    self.bgLayer:addChild(self.baseLayer, 1)
    self.bgLayer:addChild(self.detailLayer, 1)
    
    self.isAttacker = alienMinesEmailVoApi:isAttacker(report)
    
    --初始化战斗目标点信息
    local successFlag = false
    local resultBg, resultPic, targetStr, myInfo, enemyInfo, myLandform, enemyLandform, myNameStr, enemyNameStr
    if self.isAttacker == true then
        if report.isVictory == 1 then --我方胜利
            successFlag = true
        else --我方失败
            successFlag = false
        end

        targetStr = getlocal("battleReport_attack_type2", {getlocal("alienMines")})

        myInfo, enemyInfo, myLandform, enemyLandform = report.attacker, report.defender, report.aLandform, report.dLandform
        myNameStr, enemyNameStr = myInfo.name, enemyInfo.name
        if report.helpDefender and report.helpDefender ~= "" then --敌方显示协防玩家的名称
            enemyNameStr = report.helpDefender
        end
        if report.islandOwner == nil or report.islandOwner == 0 then
            enemyNameStr = G_getAlienIslandName(report.islandType)
            enemyInfo.fight = nil
            enemyInfo.level = report.level
            enemyInfo.pic = "alien_mines"..report.islandType..".png"
        end
    else
        if report.isVictory == 1 then --我方失败
            successFlag = false
        else --我方胜利
            successFlag = true
        end
        targetStr = getlocal("battleReport_defend_type2", {getlocal("alienMines")})
        
        myInfo, enemyInfo, myLandform, enemyLandform = report.defender, report.attacker, report.dLandform, report.aLandform
        myNameStr, enemyNameStr = myInfo.name, enemyInfo.name
        if report.helpDefender and report.helpDefender ~= "" then --我方是协防玩家，显示协防玩家的名称
            myNameStr = report.helpDefender
        end
    end
    if successFlag == true then --我方胜利
        resultBg = "reportSuccessBg.png"
        if G_getCurChoseLanguage() == "cn" then
            resultPic = "reportSuccessIcon_cn.png"
        elseif G_getCurChoseLanguage() == "tw" then
            resultPic = "reportSuccessIcon_tw.png"
        else
            resultPic = "reportSuccessIcon_en.png"
        end
    else --我方失败
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
    if targetStr then
        --战斗地点
        local targetLb = GetTTFLabelWrap(targetStr, fontSize, CCSizeMake(300, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        targetLb:setAnchorPoint(ccp(1, 1))
        targetLb:setColor(G_ColorYellowPro)
        targetLb:setPosition(infoBgSize.width - 20, infoBgSize.height / 2 + targetLb:getContentSize().height + 30)
        infoBg:addChild(targetLb)
        --战斗地点坐标
        if report.place then
            local menu, menuItem, placeLb = G_createReportPositionLabel(ccp(report.place.x, report.place.y), fontSize, nil, false)
            -- local placeLb=GetTTFLabel(getlocal("city_info_coordinate_style",{report.place.x,report.place.y}),fontSize)
            menu:setAnchorPoint(ccp(1, 0.5))
            menuItem:setAnchorPoint(ccp(1, 0.5))
            menu:setPosition(targetLb:getPositionX(), infoBgSize.height / 2)
            infoBg:addChild(menu)
        end
        --战斗时间
        if report and report.time then
            local timeLb = GetTTFLabel(emailVoApi:getTimeStr(report.time), fontSize)
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
    if myInfo then
        local fight, pic, fhid = (tonumber(myInfo.fight) or 0), (myInfo.pic or headCfg.default), (myInfo.fhid or headFrameCfg.default)
        local function showMyInfo()
            if myInfo.fight then
                local player = {uid = myInfo.id, name = myNameStr, level = myInfo.level, pic = pic, fhid = fhid, vip = myInfo.vip, rank = myInfo.rank, fight = myInfo.fight, alliance = myInfo.allianceName}
                smallDialog:showReportPlayerInfoSmallDialog(player, self.layerNum + 1, true, nil, false)
            end
        end
        local picName = playerVoApi:getPersonPhotoName(pic)
        -- print("pic,picName----???",pic,picName)
        local myIconSp = playerVoApi:GetPlayerBgIcon(picName, showMyInfo, nil, nil, iconWidth, fhid)
        myIconSp:setPosition(2 + iconWidth / 2, infoHeight / 2)
        myIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        myInfoBg:addChild(myIconSp)
        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50, 20))
        lvBg:setPosition(myIconSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 6, myIconSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 2)
        myInfoBg:addChild(lvBg)
        local lvLb = GetTTFLabel(getlocal("fightLevel", {myInfo.level}), fontSize - 4)
        lvLb:setAnchorPoint(ccp(1, 0.5))
        lvLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
        myInfoBg:addChild(lvLb, 2)
        local nameLb = GetTTFLabelWrap(myNameStr, fontSize, CCSizeMake(200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(myIconSp:getPositionX() + 5 + iconWidth / 2, myIconSp:getPositionY() + iconWidth / 2)
        myInfoBg:addChild(nameLb)
        local allianceName = "["..getlocal("noAlliance") .. "]"
        if myInfo.allianceName and myInfo.allianceName ~= "" then
            allianceName = myInfo.allianceName
        end
        local allianceLb = GetTTFLabelWrap(allianceName, fontSize - 4, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        allianceLb:setAnchorPoint(ccp(0, 0.5))
        allianceLb:setPosition(nameLb:getPositionX(), infoHeight / 2)
        myInfoBg:addChild(allianceLb)
        
        if fight > 0 then
            local fightSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
            fightSp:setAnchorPoint(ccp(0, 0.5))
            fightSp:setScale(0.5)
            local fightLb = GetTTFLabel(FormatNumber(fight), fontSize - 4) --战斗力
            fightLb:setAnchorPoint(ccp(0, 0.5))
            fightLb:setPosition(nameLb:getPositionX() + fightSp:getContentSize().width * 0.5 + 10, 10 + fightLb:getContentSize().height / 2)
            myInfoBg:addChild(fightLb)
            fightSp:setPosition(nameLb:getPositionX(), fightLb:getPositionY())
            myInfoBg:addChild(fightSp)
        end
        
        local campBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg.png", CCRect(30, 0, 2, 24), function ()end)
        campBg:setContentSize(CCSizeMake(100, 24))
        campBg:setPosition(infoWidth - campBg:getContentSize().width / 2, campBg:getContentSize().height / 2)
        campBg:setOpacity(255 * 0.1)
        myInfoBg:addChild(campBg)
        local campStr, campStrColor = ""
        if self.isAttacker == true then
            campStr = getlocal("battleCamp1")
            campStrColor = G_LowfiColorGreen
        else
            campStr = getlocal("battleCamp2")
            campStrColor = G_LowfiColorRed
        end
        local campLb = GetTTFLabel(campStr, fontSize)
        campLb:setPosition(campBg:getContentSize().width / 2 + 10, campBg:getContentSize().height / 2)
        campLb:setColor(campStrColor)
        campBg:addChild(campLb)
    end
    
    --敌方信息
    local enemyInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportRedBg.png", CCRect(4, 4, 1, 1), function ()end)
    enemyInfoBg:setAnchorPoint(ccp(0.5, 1))
    enemyInfoBg:setContentSize(CCSizeMake(infoWidth, infoHeight))
    enemyInfoBg:setPosition(G_VisibleSizeWidth - infoWidth / 2 - 5, infoBg:getPositionY() - infoBgSize.height)
    self.bgLayer:addChild(enemyInfoBg)
    if enemyInfo then
        local rpx, rpy = infoWidth - iconWidth / 2 - 2, infoHeight / 2
        local rightPosX = rpx - iconWidth / 2 - 5
        local enemyIconSp, enemyLv, nameStr
        local fight, pic, fhid = (tonumber(enemyInfo.fight) or 0), (enemyInfo.pic or headCfg.default), (enemyInfo.fhid or headFrameCfg.default)
        if report.islandOwner == nil or report.islandOwner == 0 then
            enemyNameStr = G_getAlienIslandName(report.islandType)
            enemyLv = report.level
            enemyIconSp = CCSprite:createWithSpriteFrameName("icon_bg_gray.png")
            local icon = CCSprite:createWithSpriteFrameName("alien_mines"..report.islandType..".png")
            icon:setPosition(enemyIconSp:getContentSize().width / 2, enemyIconSp:getContentSize().height / 2)
            icon:setScaleX(enemyIconSp:getContentSize().width / icon:getContentSize().width)
            icon:setScaleY(enemyIconSp:getContentSize().height / icon:getContentSize().height)
            enemyIconSp:addChild(icon)
            enemyIconSp:setScale(iconWidth / enemyIconSp:getContentSize().width)
        else
            enemyLv = enemyInfo.level
            enemyNameStr = enemyNameStr
            local function showMyInfo()
                if enemyInfo.fight then
                    local player = {uid = enemyInfo.id, name = enemyNameStr, level = enemyInfo.level, pic = pic, fhid = fhid, vip = enemyInfo.vip, rank = enemyInfo.rank, fight = enemyInfo.fight, alliance = enemyInfo.allianceName}
                    smallDialog:showReportPlayerInfoSmallDialog(player, self.layerNum + 1, true, nil, false)
                end
            end
            local picName = playerVoApi:getPersonPhotoName(pic)
            enemyIconSp = playerVoApi:GetPlayerBgIcon(picName, showMyInfo, nil, nil, iconWidth, fhid)
            enemyIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        end
        local allianceName = "["..getlocal("noAlliance") .. "]"
        if enemyInfo.allianceName and enemyInfo.allianceName ~= "" then
            allianceName = enemyInfo.allianceName
        end
        local allianceLb = GetTTFLabelWrap(allianceName, fontSize - 4, CCSizeMake(150, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        allianceLb:setAnchorPoint(ccp(1, 0.5))
        allianceLb:setPosition(rightPosX, infoHeight / 2)
        enemyInfoBg:addChild(allianceLb)
        if fight > 0 then
            local fightLb = GetTTFLabel(FormatNumber(fight), fontSize - 4)
            fightLb:setAnchorPoint(ccp(1, 0.5))
            fightLb:setPosition(rightPosX, 10 + fightLb:getContentSize().height / 2)
            enemyInfoBg:addChild(fightLb)
            local fightSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
            fightSp:setAnchorPoint(ccp(1, 0.5))
            fightSp:setScale(0.5)
            fightSp:setPosition(fightLb:getPositionX() - fightLb:getContentSize().width, fightLb:getPositionY())
            enemyInfoBg:addChild(fightSp)
        end
        local rpx, rpy = infoWidth - iconWidth / 2 - 2, infoHeight / 2
        enemyIconSp:setPosition(rpx, rpy)
        enemyInfoBg:addChild(enemyIconSp)
        
        local lvBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png", CCRect(0, 0, 1, 9), function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50, 20))
        lvBg:setPosition(enemyIconSp:getPositionX() + iconWidth / 2 - lvBg:getContentSize().width / 2 - 6, enemyIconSp:getPositionY() - iconWidth / 2 + lvBg:getContentSize().height / 2 + 2)
        lvBg:setOpacity(150)
        enemyInfoBg:addChild(lvBg)
        local lvLb = GetTTFLabel(getlocal("fightLevel", {enemyInfo.level}), fontSize - 4)
        lvLb:setAnchorPoint(ccp(1, 0.5))
        lvLb:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 - 5, lvBg:getPositionY())
        enemyInfoBg:addChild(lvLb)
        local nameLb = GetTTFLabelWrap(enemyNameStr, fontSize, CCSizeMake(200, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(1, 1))
        nameLb:setPosition(rightPosX, enemyIconSp:getPositionY() + iconWidth / 2)
        enemyInfoBg:addChild(nameLb)
        
        local enemyCampBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg2.png", CCRect(0, 0, 2, 24), function ()end)
        enemyCampBg:setContentSize(CCSizeMake(100, 24))
        enemyCampBg:setPosition(enemyCampBg:getContentSize().width / 2, enemyCampBg:getContentSize().height / 2)
        enemyCampBg:setOpacity(255 * 0.1)
        enemyInfoBg:addChild(enemyCampBg)
        local campStr, campStrColor = ""
        if self.isAttacker == true then
            campStr = getlocal("battleCamp2")
            campStrColor = G_LowfiColorRed
        else
            campStr = getlocal("battleCamp1")
            campStrColor = G_LowfiColorGreen
        end
        local enemyCampLb = GetTTFLabel(campStr, fontSize)
        enemyCampLb:setPosition(enemyCampBg:getContentSize().width / 2 - 10, enemyCampBg:getContentSize().height / 2)
        enemyCampLb:setColor(campStrColor)
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
                return self:battleReportEventHandler1(...)
            else
                return self:battleReportEventHandler2(...)
            end
        end
        local hd = LuaEventHandler:createHandler(callBack)
        local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
        tv:setAnchorPoint(ccp(0, 0))
        tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, myInfoBg:getPositionY() - myInfoBg:getContentSize().height - self.tvHeight)
        tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
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
                        moveDis = -G_VisibleSizeWidth
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
        detailBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
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
end

function alienMinesReportDetailDialog:initTopContent()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local topBg = CCSprite:create("public/reportTopContentBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(self.bgLayer:getContentSize().width / 2, G_VisibleSizeHeight - 83)
    self.bgLayer:addChild(topBg)
    
    local _lbFontSize = 20 --字体大小
    
    --侦察的岛屿图标
    local islandShowSize = 150 --图标显示大小
    local islandSpPosX = 35 + islandShowSize / 2
    local _islandType = self.report.islandType
    local islandSp = CCSprite:createWithSpriteFrameName("alien_mines".._islandType..".png")
    islandSp:setPosition(islandSpPosX, topBg:getContentSize().height / 2 + 20)
    islandSp:setScale(islandShowSize / islandSp:getContentSize().width)
    topBg:addChild(islandSp)
    
    --侦察时间
    local timeLb = GetTTFLabel(emailVoApi:getTimeStr(self.report.time), _lbFontSize)
    timeLb:setAnchorPoint(ccp(0.5, 1))
    timeLb:setPosition(islandSpPosX, islandSp:getPositionY() - islandShowSize / 2)
    timeLb:setColor(G_ColorYellowPro)
    topBg:addChild(timeLb)
    
    --图标
    local iconName
    if self.report.type == 2 then --侦查报告
        iconName = "emailNewUI_scout1.png"
    elseif self.report.type == 3 then --返回报告
        iconName = "emailNewUI_return1.png"
    end
    if iconName then
        local typeIcon = CCSprite:createWithSpriteFrameName(iconName)
        typeIcon:setAnchorPoint(ccp(1, 0.5))
        typeIcon:setPosition(timeLb:getPositionX() - timeLb:getContentSize().width / 2, timeLb:getPositionY() - timeLb:getContentSize().height / 2)
        typeIcon:setScale(0.9)
        topBg:addChild(typeIcon)
    end
    
    local content = alienMinesReportVoApi:getReportContent(self.report)
    if content and content[1] then
        local _lbSpaceY = 10 --label之间的行间距
        local strSize = SizeOfTable(content)
        local lb = GetTTFLabel(content[1][1], _lbFontSize)
        local _lbTotalHeight = strSize * lb:getContentSize().height + (strSize - 1) * _lbSpaceY
        local _posY = topBg:getContentSize().height - (topBg:getContentSize().height - _lbTotalHeight) / 2
        _posY = _posY - lb:getContentSize().height / 2
        for k, v in pairs(content) do
            local _str, _color
            if type(v) == "table" then
                _str = v[1]
                _color = v[2]
            else
                _str = v
            end
            if _str then
                local label = GetTTFLabel(_str, _lbFontSize)
                label:setAnchorPoint(ccp(0, 0.5))
                label:setPosition(islandSpPosX + islandShowSize / 2 + 20, _posY)
                if _color then
                    label:setColor(_color)
                end
                topBg:addChild(label)
                if k == 2 then --坐标
                    local menu, menuItem, posLb = G_createReportPositionLabel(ccp(self.report.place.x, self.report.place.y), _lbFontSize, nil, false)
                    menuItem:setAnchorPoint(ccp(0, 0.5))
                    menu:setAnchorPoint(ccp(0, 0.5))
                    menu:setPosition(label:getPositionX() + label:getContentSize().width, label:getPositionY())
                    topBg:addChild(menu)
                end
                _posY = label:getPositionY() - label:getContentSize().height - _lbSpaceY
            end
        end
    end
    
    return topBg
end

--侦查报告
function alienMinesReportDetailDialog:scoutReportUI(report)
    local topBg = self:initTopContent()
    
    self.tvWidth, self.tvHeight = 616, topBg:getPositionY() - topBg:getContentSize().height - 90 - 10
    local function callBack(...)
        return self:scoutReportHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, 90)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(self.tv)
end

--返回报告
function alienMinesReportDetailDialog:returnReportUI(report)
    local topBg = self:initTopContent()
    
    self.tvWidth, self.tvHeight = 616, topBg:getPositionY() - topBg:getContentSize().height - 90 - 5
    local function callBack(...)
        return self:returnReportHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, 90)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(self.tv)
end

function alienMinesReportDetailDialog:initBottomBtutton(report)
    local function operateHandler(tag, object)
        if G_checkClickEnable() == false then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        
        if tag == 11 then
            --如果没有战斗
            if report.report == nil then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("fight_content_result_no_play"), true, self.layerNum + 1)
            else
                local data = {data = report, isAttacker = self.isAttacker, isReport = true, alienBattleData = {islandType = report.islandType}}
                battleScene:initData(data)
            end
        elseif tag == 12 or tag == 13 then
            if report then
                self:close()
                local type = report.islandType
                local place = report.place
                local island = G_clone(alienMinesVoApi:getBaseVo(place.x, place.y))
                local flag
                if tag == 12 then
                    flag = 0
                else
                    flag = 1
                end
                alienMinesVoApi:showAttackDialog(flag, island, self.layerNum + 1)
            end
        end
    end
    
    local scale = 0.75
    self.replayBtn = GetButtonItem("letterBtnPlay_v2.png", "letterBtnPlay_Down_v2.png", "letterBtnPlay_Down_v2.png", operateHandler, 11, nil, nil)
    self.replayBtn:setScale(scale)
    local replaySpriteMenu = CCMenu:createWithItem(self.replayBtn)
    replaySpriteMenu:setAnchorPoint(ccp(0.5, 0))
    replaySpriteMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    
    self.attackBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", operateHandler, 12, getlocal("alienMines_plunder"), 24 / (scale - 0.2))
    self.attackBtn:setScale(scale - 0.2)
    local attackSpriteMenu = CCMenu:createWithItem(self.attackBtn)
    attackSpriteMenu:setAnchorPoint(ccp(0.5, 0))
    attackSpriteMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    
    self.occupyBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", operateHandler, 13, getlocal("alienMines_Occupied"), 24 / (scale - 0.2))
    self.occupyBtn:setScale(scale - 0.2)
    local occupySpriteMenu = CCMenu:createWithItem(self.occupyBtn)
    occupySpriteMenu:setAnchorPoint(ccp(0.5, 0))
    occupySpriteMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    
    local height = 45
    local posXScale = self.bgLayer:getContentSize().width
    if report ~= nil then
        if report.type == 1 then
            local isAttacker = alienMinesEmailVoApi:isAttacker(report, self.chatSender)
            if isAttacker == true then
                self.bgLayer:addChild(replaySpriteMenu, 2)
                replaySpriteMenu:setPosition(ccp(posXScale / 2, height))
                if report.report == nil then
                    self.replayBtn:setEnabled(false)
                end
            else
                self.bgLayer:addChild(replaySpriteMenu, 2)
                replaySpriteMenu:setPosition(ccp(posXScale / 2, height))
                if report.report == nil then
                    self.replayBtn:setEnabled(false)
                end
            end
        elseif report.type == 2 then
            attackSpriteMenu:setAnchorPoint(ccp(0.5, 0))
            occupySpriteMenu:setAnchorPoint(ccp(0.5, 0))
            
            self.bgLayer:addChild(attackSpriteMenu, 2)
            self.bgLayer:addChild(occupySpriteMenu, 2)
            attackSpriteMenu:setPosition(ccp(posXScale / 3 * 1, height))
            occupySpriteMenu:setPosition(ccp(posXScale / 3 * 2, height))
            
            if report.allianceName and allianceVoApi:isSameAlliance(report.allianceName) then
                self.attackBtn:setEnabled(false)
                self.occupyBtn:setEnabled(false)
            elseif report.islandOwner == 0 then
                self.attackBtn:setEnabled(false)
            end
        elseif report.type == 3 then
        end
    end
end
--根据战报的类型来初始化报告详情的显示类型
--showType：1.资源，2.繁荣度，3.部队损耗，4.装甲矩阵，5.配件，6.将领，7.超级武器，8.军徽，9.飞机，10.攻打叛军时的战斗信息,11.AI部队
function alienMinesReportDetailDialog:initShowType()
    self.baseShowType = {1} --默认有奖励
    table.insert(self.baseShowType, 3) --部队损耗
    if self.report.islandOwner == nil or self.report.islandOwner == 0 then
        do return end
    end
    local isShowHero = alienMinesEmailVoApi:isShowHero(self.report)
    local isShowAccessory = alienMinesEmailVoApi:isShowAccessory(self.report)
    local isShowEmblem = alienMinesEmailVoApi:isShowEmblem(self.report)
    local isShowPlane = G_isShowPlaneInReport(self.report, 4)
    self.detailShowType = {}
    local armorMatrixFlag = emailVoApi:isShowArmorMatrix(self.report)
    if armorMatrixFlag == true then
        table.insert(self.detailShowType, 4) --装甲矩阵
    end
    if isShowAccessory == true then
        table.insert(self.detailShowType, 5) --配件
    end
    if isShowHero == true then
        table.insert(self.detailShowType, 6) --将领
    end
    local superWeaponFlag = emailVoApi:isShowSuperWeapon(self.report)
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
    if airShipVoApi:isShowAirshipInReport(self.report) == true then --飞艇
        table.insert(self.detailShowType, 12)
    end
end

--战斗资源相关
function alienMinesReportDetailDialog:getReportResource()
    if self.resource == nil then
        self.resource = G_getReportResource(self.report)
    end
    return self.resource
end

function alienMinesReportDetailDialog:getCellHeight1(idx)
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
        end
        self.cellHeightTb1[idx] = height
    end
    return self.cellHeightTb1[idx]
end

function alienMinesReportDetailDialog:getCellHeight2(idx)
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
        elseif showType == 12 then --飞艇
            height = G_getReportAirShipLayoutHeight()
        end
        self.cellHeightTb2[idx] = height
    end
    return self.cellHeightTb2[idx]
end

--战斗损耗部队详情
function alienMinesReportDetailDialog:getReportTroopsLost()
    if self.troops then
        do return self.troops end
    end
    if self.report.troops then --新的战报部队数据格式
        if self.isAttacker == true then
            self.troops = self.report.troops
        else
            self.troops = {self.report.troops[2], self.report.troops[1]}
        end
    else
        local attTotal, attLost, defTotal, defLost --部队损失情况
        if self.report.lostShip.attackerLost then
            if self.report.lostShip.attackerLost.o then
                attLost = FormatItem(self.report.lostShip.attackerLost, false)
            else
                attLost = self.report.lostShip.attackerLost
            end
        end
        
        if self.report.lostShip.defenderLost then
            if self.report.lostShip.defenderLost.o then
                defLost = FormatItem(self.report.lostShip.defenderLost, false)
            else
                defLost = self.report.lostShip.defenderLost
            end
        end
        
        if self.report.lostShip.attackerTotal then
            if self.report.lostShip.attackerTotal.o then
                attTotal = FormatItem(self.report.lostShip.attackerTotal, false)
            else
                attTotal = self.report.lostShip.attackerTotal
            end
        end
        if self.report.lostShip.defenderTotal then
            if self.report.lostShip.defenderTotal.o then
                defTotal = FormatItem(self.report.lostShip.defenderTotal, false)
            else
                defTotal = self.report.lostShip.defenderTotal
            end
        end
        self.troops = {attTotal, attLost, defTotal, defLost}
    end

    return self.troops
end

function alienMinesReportDetailDialog:battleReportEventHandler1(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.baseNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getCellHeight1(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getCellHeight1(idx + 1)
        local showType = self.baseShowType[idx + 1]
        if showType == 1 then --资源信息
            local resourceTb = self:getReportResource()
            G_reportResourceLayout(cell, cellWidth, cellHeight, resourceTb, getlocal("fight_award"), self.layerNum, self.report, self.isAttacker)
        elseif showType == 3 then --部队损耗信息
            local troops = self:getReportTroopsLost()
            G_getBattleReportTroopsLayout(cell, cellWidth, cellHeight, troops, self.layerNum, self.report, self.isAttacker, idx ~= 1)
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

function alienMinesReportDetailDialog:battleReportEventHandler2(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.detailNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getCellHeight2(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getCellHeight2(idx + 1)
        local showType = self.detailShowType[idx + 1]
        if showType == 4 then --装甲矩阵
            G_getReportArmorMatrixLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 5 then --配件
            G_getReportAccessoryLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 6 then --将领
            G_getReportHeroLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 7 then --超级武器
            G_getReportSuperWeaponLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 8 then --军徽
            G_getReportEmblemLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 9 then --飞机
            G_getReportPlaneLayout(cell, cellWidth, cellHeight, self.layerNum, self.report, self.isAttacker)
        elseif showType == 11 then --AI部队
            G_getBattleReportAITroopsLayout(cell, cellWidth, cellHeight, (self.report.aitroops or {}), self.layerNum, self.report, self.isAttacker)
        elseif showType == 12 then --飞艇
            G_getReportAirShipLayout(cell, cellWidth, cellHeight, self.report, self.isAttacker)
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

function alienMinesReportDetailDialog:getReportCellHeight(idx)
    if self.cellHeightTb == nil then
        self.cellHeightTb = {}
    end
    if self.cellHeightTb[idx] == nil then
        local height = 0
        if self.report.type == 2 then
            if idx == 1 then
                local resType = 4
                local alienResType = self.report.islandType
                local resName = getlocal("scout_content_product_"..resType)
                local resNum = tonumber(mapCfg[resType][self.report.level].resource)
                local alienResName = getlocal("alien_tech_res_name_"..alienResType)
                local rate = alienMineCfg.collect[alienResType].rate
                local alienResNum = math.floor(resNum * rate)
                
                self.output = {
                    {pic = "IconUranium.png", name = resName, speed = resNum},
                    {pic = "alien_mines"..alienResType.."_"..alienResType..".png", name = alienResName, speed = alienResNum},
                }
                
                height = height + 32
                height = height + 10
                
                local mineResLb = GetTTFLabel(getlocal("alienMines_scout_resources_desc_1"), 20)
                height = height + mineResLb:getContentSize().height + 10
                
                local iconSize = 38.5
                local spaceY = 10
                for k, v in pairs(self.output) do
                    if v then
                        height = height + iconSize + spaceY
                    end
                end
                
                if self.report.islandOwner > 0 then --是否有驻军
                    local gatherLb = GetTTFLabel(getlocal("gather_output_defend"), 20)
                    height = height + gatherLb:getContentSize().height + 10
                    for k, v in pairs(self.report.resource) do
                        if v then
                            height = height + iconSize + spaceY
                        end
                    end
                end
            elseif idx == 2 then
                height = height + 32 --titleBgHeight
                height = height + 10 --local _posY=titleBg:getPositionY()-10

                local lb1 = GetTTFLabel(getlocal("front"), 20)
                height = height + lb1:getContentSize().height + 10 --_posY=_posY-lb1:getContentSize().height-10
                
                local _tankIconSize = 100
                local _tankIconSpaceY = 50
                height = height + 3 * (_tankIconSize + _tankIconSpaceY)
            end
        elseif self.report.type == 3 then
            if idx == 1 then
                local _resourceData = self.report.resource
                if (self.report.resource.u or self.report.resource.r) then
                    _resourceData = FormatItem(self.report.resource)
                end
                height = G_reportResourceCellHeight(_resourceData)
            elseif idx == 2 then
                local alienPoint = self.report.alienPoint
                local aAlienPoint = self.report.aAlienPoint
                local msgStr1 = getlocal("alienMines_return_alien_point", {alienPoint})
                local msgStr2 = getlocal("alienMines_return_alliance_alien_point", {aAlienPoint})
                local msgTab = {msgStr1, msgStr2}
                height = height + 10
                for k, v in pairs(msgTab) do
                    local resourceLabel = GetTTFLabelWrap(v, 22, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    height = height + resourceLabel:getContentSize().height + 10
                end
                height = height + 10
            end
        end
        self.cellHeightTb[idx] = height
    end
    return self.cellHeightTb[idx]
end

function alienMinesReportDetailDialog:scoutReportHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 2
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getReportCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth, cellHeight = self.tvWidth, self:getReportCellHeight(idx + 1)
        
        if idx == 0 then
            local titleBg, titleLb = G_createReportTitle(cellWidth - 20, getlocal("fight_content_resource_info"))
            titleBg:setAnchorPoint(ccp(0.5, 0))
            titleBg:setPosition(ccp(cellWidth / 2, cellHeight - titleBg:getContentSize().height))
            cell:addChild(titleBg)
            local posY = titleBg:getPositionY() - 10
            
            local function showResources(showType, resTb)
                if resTb == nil then
                    do return end
                end
                local iconSize = 38.5
                local spaceY = 10
                for k, v in pairs(resTb) do
                    if v then
                        local resSp = CCSprite:createWithSpriteFrameName(v.pic)
                        resSp:setPosition(20 + iconSize / 2, posY - iconSize / 2)
                        resSp:setScale(iconSize / resSp:getContentSize().height)
                        cell:addChild(resSp)
                        
                        local str = v.name.."："
                        if showType == 1 then
                            str = str..FormatNumber(v.speed) .. "/h"
                        else
                            str = str..FormatNumber(v.num)
                        end
                        local numLable = GetTTFLabelWrap(str, 20, CCSizeMake(cellWidth - resSp:getPositionX() - iconSize / 2 - 15, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
                        numLable:setAnchorPoint(ccp(0, 0.5))
                        numLable:setPosition(ccp(resSp:getPositionX() + iconSize / 2 + 15, resSp:getPositionY()))
                        numLable:setColor(G_ColorGreen)
                        cell:addChild(numLable, 2)
                        
                        posY = resSp:getPositionY() - iconSize / 2 - spaceY
                    end
                end
            end
            
            local mineResLb = GetTTFLabel(getlocal("alienMines_scout_resources_desc_1"), 20)
            mineResLb:setAnchorPoint(ccp(0, 1))
            mineResLb:setPosition(ccp(10, posY))
            cell:addChild(mineResLb)
            posY = mineResLb:getPositionY() - mineResLb:getContentSize().height - 10
            
            showResources(1, self.output)
            
            if self.report.islandOwner > 0 then
                local gatherLb = GetTTFLabel(getlocal("gather_output_defend"), 20)
                gatherLb:setAnchorPoint(ccp(0, 1))
                gatherLb:setPosition(ccp(10, posY))
                gatherLb:setColor(G_ColorYellowPro)
                cell:addChild(gatherLb)
                posY = gatherLb:getPositionY() - gatherLb:getContentSize().height - 10
                showResources(2, self.report.resource)
            end
        elseif idx == 1 then
            local titleBg, titleLb = G_createReportTitle(cellWidth - 20, getlocal("alliance_challenge_enemy_info"))
            titleBg:setAnchorPoint(ccp(0.5, 0))
            titleBg:setPosition(ccp(cellWidth / 2, cellHeight - titleBg:getContentSize().height))
            cell:addChild(titleBg)

            local shipTab = self.report.defendShip
            
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
            local tskinList = self.report.tskinList
            for k = 1, 6 do
                local tankIconBgPosX = (k > 3) and _posX2 or _posX1
                local tankIconBgPosY = _posY - _tankIconSize / 2 - ((k - 1) % 3) * (_tankIconSize + _tankIconSpaceY)

                local v
                if shipTab then
                    v = shipTab[k]
                end
                if v and v.key and v.name and v.num then
                    local skinId = tskinList[tankSkinVoApi:convertTankId(v.key)]
                    local icon = tankVoApi:getTankIconSp(v.key, skinId, nil, false)
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

function alienMinesReportDetailDialog:returnReportHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 2
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getReportCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth, cellHeight = self.tvWidth, self:getReportCellHeight(idx + 1)
        if idx == 0 then
            local _resourceData = self.report.resource
            if (self.report.resource.u or self.report.resource.r) then
                _resourceData = FormatItem(self.report.resource)
            end
            G_reportResourceLayout(cell, cellWidth, cellHeight, _resourceData, getlocal("resource_gather_pro"), self.layerNum)
        elseif idx == 1 then
            local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("reportRewardTitleBg2.png", CCRect(4, 4, 1, 1), function()end)
            contentBg:setContentSize(CCSizeMake(cellWidth, cellHeight))
            contentBg:setAnchorPoint(ccp(0.5, 0.5))
            contentBg:setPosition(cellWidth / 2, cellHeight / 2)
            cell:addChild(contentBg)
            
            local alienPoint = self.report.alienPoint
            local aAlienPoint = self.report.aAlienPoint
            local msgStr1 = getlocal("alienMines_return_alien_point", {alienPoint})
            local msgStr2 = getlocal("alienMines_return_alliance_alien_point", {aAlienPoint})
            local msgTab = {msgStr1, msgStr2}
            local _posY = contentBg:getContentSize().height - 10
            for k, v in pairs(msgTab) do
                local resourceLabel = GetTTFLabelWrap(v, 22, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                resourceLabel:setAnchorPoint(ccp(0, 0.5))
                resourceLabel:setPosition(10, _posY - resourceLabel:getContentSize().height / 2)
                contentBg:addChild(resourceLabel)
                _posY = resourceLabel:getPositionY() - resourceLabel:getContentSize().height / 2 - 10
                if k == 1 then
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(cellWidth - 20, 2))
                    lineSp:setPosition(contentBg:getContentSize().width / 2, _posY)
                    lineSp:setOpacity(255 * 0.06)
                    contentBg:addChild(lineSp)
                end
                _posY = _posY - 10
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

function alienMinesReportDetailDialog:dispose()
    self.layerNum = nil
    self.eid = nil
    self.report = nil
    self = nil
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
end
