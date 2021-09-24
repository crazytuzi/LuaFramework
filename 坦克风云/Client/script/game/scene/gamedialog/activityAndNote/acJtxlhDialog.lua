acJtxlhDialog = commonDialog:new()

function acJtxlhDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acJtxlhDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 82)
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    spriteController:addPlist("public/acydcz_images.plist")
    spriteController:addTexture("public/acydcz_images.png")
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    
    self.url = G_downloadUrl("active/acJtxlhBg.jpg")
    local function onLoadIcon(fn, mainBg)
        if self then
            if self.bgLayer and tolua.cast(self.bgLayer, "LuaCCScale9Sprite") then
                mainBg:setAnchorPoint(ccp(0.5, 1))
                mainBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 82)
                self.bgLayer:addChild(mainBg)
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage = LuaCCWebImage:createWithURL(self.url, onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local function showLayer()
        if self:isClosed() == true then
            do return end
        end
        self:initMainLayer()
    end
    acJtxlhVoApi:getJtxlhData(showLayer)
end

function acJtxlhDialog:initMainLayer()
    local rewardBgOffestH = -140
    local iphoneType = G_getIphoneType()
    if iphoneType == G_iphone4 then
        rewardBgOffestH = -110
    end
    
    local titleFontSize, titleFontWidth, smallFontSize, leftPosX = 25, 280, 22, 20
    local aRecharge, pRecharge = acJtxlhVoApi:getRecharge()
    local aRechargeNum, aMaxRechargeNum, aRechargeLv, aRgs = tonumber(aRecharge[1] or 0), tonumber(aRecharge[2] or 0), tonumber(aRecharge[3] or 0), aRecharge[4] or {}
    local pRechargeNum, pMaxRechargeNum, pRechargeLv, pRgs = tonumber(pRecharge[1] or 0), tonumber(pRecharge[2] or 0), tonumber(pRecharge[3] or 0), pRecharge[4] or {}
    local giftSize = 60
    local aRewardCfg, pRewardCfg = acJtxlhVoApi:getRewardCfg()
    local rgPercentage = acJtxlhVoApi:getRewardPercentage() --充值进度
    local lineColor = ccc3(84, 84, 84)
    
    local mainLayer = CCLayer:create()
    mainLayer:setPosition(0, 0)
    self.bgLayer:addChild(mainLayer, 2)
    self.mainLayer = mainLayer
    
    --活动时间
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 80))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    -- timeBg:setOpacity(255)
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85)
    mainLayer:addChild(timeBg)
    local timeLb = GetTTFLabel(acJtxlhVoApi:getTimeStr(), 25)
    timeLb:setPosition(ccp(G_VisibleSizeWidth / 2, timeBg:getContentSize().height - 24))
    timeLb:setColor(G_ColorYellowPro)
    timeBg:addChild(timeLb)
    self.timeLb = timeLb
    
    local function touchTip()
        local tabStr = {}
        for k = 1, 3 do
            local str = getlocal("activity_jtxlh_rule"..k)
            table.insert(tabStr, str)
        end
        local titleStr = getlocal("activity_ruleLabel")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    G_addMenuInfo(timeBg, self.layerNum, ccp(G_VisibleSizeWidth - 35, timeBg:getContentSize().height / 2 + 5), nil, nil, 1, nil, touchTip, true)
    
    local aflag = acJtxlhVoApi:getAllianceFlagInfo()
    if aflag then
        local flagWidth = 120
        local scale = flagWidth / 194
        local allianceFlagSp = allianceVoApi:createShowFlag(aflag[1], aflag[2], "ic1", scale, self.layerNum)
        allianceFlagSp:setAnchorPoint(ccp(0.5, 0.5))
        allianceFlagSp:setPosition(50 + flagWidth / 2, G_VisibleSizeHeight - 270)
        self.mainLayer:addChild(allianceFlagSp, 2)
        local flagBottomBg = CCSprite:createWithSpriteFrameName("ydcz_cuplight.png")
        flagBottomBg:setAnchorPoint(ccp(0.5, 0.5))
        flagBottomBg:setPosition(allianceFlagSp:getPositionX(), allianceFlagSp:getPositionY() - 260 * scale / 2 + 5)
        self.mainLayer:addChild(flagBottomBg)
        
        local attrFontSize, attrFontWidth, attrPosX = 18, 170, 45
        if G_getCurChoseLanguage() == "ar" then
            attrFontSize = 15
        end
        local flagAttr = allianceVoApi:getShowFlagAttr(1, aflag[1], true)
        local flagFrameAttr = allianceVoApi:getShowFlagAttr(2, aflag[2], true)
        local flagAttrLb, fttrLbHeight = G_getRichTextLabel(flagAttr, {nil, G_ColorGreen, nil}, attrFontSize, attrFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        flagAttrLb:setAnchorPoint(ccp(0, 1))
        flagAttrLb:setPosition(attrPosX, flagBottomBg:getPositionY() - 15)
        self.mainLayer:addChild(flagAttrLb)
        local flagFrameAttrLb = G_getRichTextLabel(flagFrameAttr, {nil, G_ColorGreen, nil}, attrFontSize, attrFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        flagFrameAttrLb:setAnchorPoint(ccp(0, 1))
        flagFrameAttrLb:setPosition(attrPosX, flagAttrLb:getPositionY() - fttrLbHeight)
        self.mainLayer:addChild(flagFrameAttrLb)
    end
    --军团奖励
    local subPosy = 0
    local titleTb = {getlocal("alliance_total_recharge1"), titleFontSize, G_ColorYellowPro}
    if G_isIOS() == false and G_isAsia() == false then
        subPosy = 5
        titleTb[2] =  titleTb[2] - 2
    end

    local titleLbSize = CCSizeMake(titleFontWidth, 0)
    local allianceTitleBg, titleLb, subHeight = G_createNewTitle(titleTb, titleLbSize, nil, true, "Helvetica-bold")
    allianceTitleBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 175 - subPosy))
    mainLayer:addChild(allianceTitleBg)
    
    self:initAllianceRechargeLayer()
    
    --活动描述
    local descFontSize, descFontWidth = 22, G_VisibleSizeWidth - 280
    local descLb, descHeight = G_getRichTextLabel(getlocal("activity_jtxlh_desc", {aMaxRechargeNum}), {nil, G_ColorYellowPro, nil}, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0, 1))
    descLb:setPosition(220, G_VisibleSizeHeight - 350)
    mainLayer:addChild(descLb, 3)
    local descBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    descBg:setScaleX((descFontWidth + 40) / descBg:getContentSize().width)
    descBg:setScaleY((descHeight + 6) / descBg:getContentSize().height)
    descBg:setPosition(descLb:getPositionX() + descFontWidth / 2, descLb:getPositionY() - descHeight / 2)
    mainLayer:addChild(descBg)
    
    local rewardInfoSize = CCSizeMake(G_VisibleSizeWidth - 30, descLb:getPositionY() - descHeight + rewardBgOffestH)
    local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    rewardBg:setAnchorPoint(ccp(0.5, 1))
    rewardBg:setOpacity(220)
    rewardBg:setContentSize(rewardInfoSize)
    rewardBg:setPosition(G_VisibleSizeWidth / 2, descLb:getPositionY() - descHeight - 10)
    mainLayer:addChild(rewardBg)
    
    --个人奖励
    local subPosy2 = 0
    titleTb = {getlocal("personal_total_recharge1"), titleFontSize, G_ColorYellowPro}
    if G_isIOS() == false and G_isAsia() == false then
        subPosy2 = 5
        titleTb[2] =  titleTb[2] - 2
    end
    local personalTitleBg, titleLb, subHeight = G_createNewTitle(titleTb, titleLbSize, nil, true, "Helvetica-bold")
    personalTitleBg:setPosition(ccp(rewardInfoSize.width / 2, rewardInfoSize.height - 40 - subPosy2))
    rewardBg:addChild(personalTitleBg)
    
    local personalRechargeStr = getlocal("personal_total_recharge2", {pRechargeNum.."/"..pMaxRechargeNum})
    local personalRechargeLb = GetTTFLabelWrap(personalRechargeStr, smallFontSize, CCSize(rewardInfoSize.width - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    personalRechargeLb:setAnchorPoint(ccp(0, 0.5))
    personalRechargeLb:setPosition(120, personalTitleBg:getPositionY() - personalRechargeLb:getContentSize().height / 2 - 10)
    rewardBg:addChild(personalRechargeLb)
    local tmpLb = GetTTFLabel(personalRechargeStr, smallFontSize)
    local realWidth = tmpLb:getContentSize().width
    if realWidth > personalRechargeLb:getContentSize().width then
        realWidth = personalRechargeLb:getContentSize().width
    end
    local pgoldIconSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    local lbWidth = realWidth + pgoldIconSp:getContentSize().width + 5
    personalRechargeLb:setPositionX(rewardInfoSize.width / 2 - lbWidth / 2)
    pgoldIconSp:setAnchorPoint(ccp(0, 0.5))
    pgoldIconSp:setPosition(personalRechargeLb:getPositionX() + realWidth + 5, personalRechargeLb:getPositionY())
    rewardBg:addChild(pgoldIconSp)
    if G_getCurChoseLanguage() == "ar" then
        personalRechargeLb:setPositionX((realWidth - personalRechargeLb:getContentSize().width) / 2)
        pgoldIconSp:setPositionX((rewardBg:getContentSize().width - realWidth) / 2 - pgoldIconSp:getContentSize().width - 5)
    end
    
    local tvWidth, tvHeight = rewardInfoSize.width, rewardInfoSize.height - personalRechargeLb:getContentSize().height - 70
    local perHeight = 100
    local tvTotalHeight = pRechargeLv * perHeight + 50
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(tvWidth, tvTotalHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            --个人充值进度
            local barWidth, barHeight = pRechargeLv * perHeight, 25
            local pRgsTimer = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png"))
            pRgsTimer:setMidpoint(ccp(0, 1))
            pRgsTimer:setBarChangeRate(ccp(1, 0))
            pRgsTimer:setType(kCCProgressTimerTypeBar)
            pRgsTimer:setScaleX((barWidth + 10) / pRgsTimer:getContentSize().width)
            pRgsTimer:setScaleY((barHeight + 10) / pRgsTimer:getContentSize().height)
            local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
            progressBarBg:setContentSize(CCSizeMake(barWidth + 6, barHeight))
            progressBarBg:setPosition(140, (tvTotalHeight - 30) / 2)
            progressBarBg:setRotation(-90)
            pRgsTimer:setPosition(getCenterPoint(progressBarBg))
            progressBarBg:addChild(pRgsTimer)
            cell:addChild(progressBarBg, 2)
            pRgsTimer:setPercentage(rgPercentage[2] or 0)
            
            local rewardLeftPosX, rewardPosY = 180, 10
            local iconWidth = 80
            for ridx = 1, pRechargeLv do
                local rewardList = acJtxlhVoApi:getPersonalReward(ridx)
                for k, v in pairs(rewardList) do
                    local function showPropInfo(...)
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v)
                        return false
                    end
                    local iconSp = G_getItemIcon(v, 100, false, self.layerNum + 1, showPropInfo, self.tv, nil, nil, nil, nil, true)
                    local scale = iconWidth / iconSp:getContentSize().width
                    iconSp:setAnchorPoint(ccp(0, 0.5))
                    iconSp:setScale(scale)
                    iconSp:setPosition(rewardLeftPosX + (k - 1) * (iconWidth + 10), rewardPosY + iconWidth / 2 + 10)
                    iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    cell:addChild(iconSp)
                    local numLb = GetTTFLabel("x"..FormatNumber(v.num), 20)
                    numLb:setAnchorPoint(ccp(1, 0))
                    numLb:setScale(1 / scale)
                    numLb:setPosition(ccp(iconSp:getContentSize().width - 5, 2))
                    iconSp:addChild(numLb, 4)
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    numBg:setAnchorPoint(ccp(1, 0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
                    numBg:setPosition(ccp(iconSp:getContentSize().width - 5, 5))
                    numBg:setOpacity(150)
                    iconSp:addChild(numBg, 3)
                end
                
                local stateStr, stateColor, linePic = "", G_ColorWhite, "acjtxlh_line2.png"
                if pRgs[ridx] and tonumber(pRgs[ridx]) > 0 then --已发放奖励中心
                    stateStr = getlocal("already_sent")
                    stateColor = G_ColorYellowPro
                    linePic = "acjtxlh_line1.png"
                else
                    stateStr = getlocal("emblem_noHad")
                    stateColor = G_ColorGray2
                end
                
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName(linePic, CCRect(22, 9, 1, 1), function ()end)
                lineSp:setAnchorPoint(ccp(0, 0.5));
                lineSp:setPosition(25, rewardPosY + iconWidth + 20)
                lineSp:setContentSize(CCSizeMake(tvWidth - 60, 20))
                cell:addChild(lineSp)
                
                if ridx ~= pRechargeLv then
                    local progressLineSp = CCSprite:createWithSpriteFrameName("reportWhiteLine.png")
                    progressLineSp:setScaleX((barHeight - 3) / progressLineSp:getContentSize().width)
                    progressLineSp:setPosition(ridx * perHeight + 2, progressBarBg:getContentSize().height / 2)
                    progressLineSp:setRotation(90)
                    progressLineSp:setColor(lineColor)
                    progressBarBg:addChild(progressLineSp, 3)
                end
                
                local needRecharge = tonumber(pRewardCfg[ridx].recharge or 0)
                local rechargeLb = GetTTFLabel(needRecharge, 20)
                rechargeLb:setAnchorPoint(ccp(1, 0.5))
                rechargeLb:setPosition(120, lineSp:getPositionY() + rechargeLb:getContentSize().height / 2 + 8)
                cell:addChild(rechargeLb)
                if pRechargeNum >= needRecharge then
                    rechargeLb:setColor(G_ColorGreen)
                else
                    rechargeLb:setColor(G_ColorRed)
                end
                
                local stateLb = GetTTFLabelWrap(stateStr, 18, CCSize(80, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentCenter)
                stateLb:setAnchorPoint(ccp(1, 0.5))
                stateLb:setPosition(120, lineSp:getPositionY() - stateLb:getContentSize().height / 2 - 8)
                stateLb:setColor(stateColor)
                cell:addChild(stateLb)
                
                rewardPosY = rewardPosY + perHeight
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            self.isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            self.isMoved = true
        elseif fn == "ccTouchEnded" then
            
        elseif fn == "ccScrollEnable" then
            if newGuidMgr:isNewGuiding() == true then
                return 0
            else
                return 1
            end
        end
    end
    
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((G_VisibleSizeWidth - tvWidth) / 2, rewardBg:getPositionY() - rewardInfoSize.height + 10)
    self.bgLayer:addChild(self.tv, 5)
    if tvTotalHeight > tvHeight then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    
    self:initButton()
    
    local function refresh(event, data)
        self:initAllianceRechargeLayer()
    end
    self.refreshListener = refresh
    eventDispatcher:addEventListener("active.jtxlh", refresh)
end

function acJtxlhDialog:initAllianceRechargeLayer()
    local smallFontSize = 22
    local aRecharge = acJtxlhVoApi:getRecharge()
    local aRechargeNum, aMaxRechargeNum, aRechargeLv, aRgs = tonumber(aRecharge[1] or 0), tonumber(aRecharge[2] or 0), tonumber(aRecharge[3] or 0), aRecharge[4] or {}
    local rgPercentage = acJtxlhVoApi:getRewardPercentage() --充值进度
    local lineColor = ccc3(84, 84, 84)
    local giftSize = 60
    local aRewardCfg = acJtxlhVoApi:getRewardCfg()
    if self.allianceRechargeLayer then
        self.allianceRechargeLayer:removeFromParentAndCleanup(true)
        self.allianceRechargeLayer = nil
    end
    local rechargeBgWidth, rechargeBgHeight = G_VisibleSizeWidth, 160
    local allianceRechargeLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
    allianceRechargeLayer:setContentSize(CCSizeMake(rechargeBgWidth, rechargeBgHeight))
    allianceRechargeLayer:setAnchorPoint(ccp(0.5, 1))
    allianceRechargeLayer:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 175)
    allianceRechargeLayer:setOpacity(0)
    self.mainLayer:addChild(allianceRechargeLayer, 2)
    self.allianceRechargeLayer = allianceRechargeLayer
    
    local allianceRechargeStr, rechargeLbColor = "", G_ColorWhite
    local agoldIconSp
    local selfAlliance = allianceVoApi:getSelfAlliance()
    if selfAlliance and selfAlliance.aid then --有军团
        allianceRechargeStr = getlocal("alliance_total_recharge2", {aRechargeNum.."/"..aMaxRechargeNum})
        agoldIconSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    else
        allianceRechargeStr = getlocal("personal_noAlliance")
        rechargeLbColor = G_ColorRed
    end
    local allianceRechargeLb = GetTTFLabelWrap(allianceRechargeStr, smallFontSize, CCSize(G_VisibleSizeWidth - 240, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    allianceRechargeLb:setAnchorPoint(ccp(0, 0.5))
    allianceRechargeLb:setPosition(220, rechargeBgHeight - allianceRechargeLb:getContentSize().height / 2 - 5)
    allianceRechargeLb:setColor(rechargeLbColor)
    allianceRechargeLayer:addChild(allianceRechargeLb)
    local tmpLb = GetTTFLabel(allianceRechargeStr, smallFontSize)
    local realWidth = tmpLb:getContentSize().width
    if realWidth > allianceRechargeLb:getContentSize().width then
        realWidth = allianceRechargeLb:getContentSize().width
    end
    if agoldIconSp then
        agoldIconSp:setAnchorPoint(ccp(0, 0.5))
        agoldIconSp:setPosition(allianceRechargeLb:getPositionX() + realWidth + 2, allianceRechargeLb:getPositionY())
        allianceRechargeLayer:addChild(agoldIconSp)
        if G_getCurChoseLanguage() == "ar" then
            agoldIconSp:setPositionX(allianceRechargeLb:getContentSize().width - realWidth + allianceRechargeLb:getPositionX() - agoldIconSp:getContentSize().width)
        end
    end
    local aRgsTimerWidth, aRgsTimerHeight = 360, 25
    local aRgsTimerPosX, aRgsTimerPosY = 220, rechargeBgHeight - 130
    local aRpgTimer = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png"))
    aRpgTimer:setMidpoint(ccp(0, 1))
    aRpgTimer:setBarChangeRate(ccp(1, 0))
    aRpgTimer:setType(kCCProgressTimerTypeBar)
    aRpgTimer:setScaleX((aRgsTimerWidth + 10) / aRpgTimer:getContentSize().width)
    aRpgTimer:setScaleY((aRgsTimerHeight + 10) / aRpgTimer:getContentSize().height)
    local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
    progressBarBg:setContentSize(CCSizeMake(aRgsTimerWidth + 6, aRgsTimerHeight))
    progressBarBg:setAnchorPoint(ccp(0, 0.5))
    progressBarBg:setPosition(aRgsTimerPosX, aRgsTimerPosY)
    aRpgTimer:setPosition(getCenterPoint(progressBarBg))
    progressBarBg:addChild(aRpgTimer)
    allianceRechargeLayer:addChild(progressBarBg)
    aRpgTimer:setPercentage(rgPercentage[1] or 0)
    
    for k = 1, 2 do
        local giftPic = "packs4.png"
        if k == 2 then
            giftPic = "packs5.png"
        end
        local giftSp
        if aRgs[k] and tonumber(aRgs[k]) > 0 then --已发放奖励中心
            giftSp = CCSprite:createWithSpriteFrameName(giftPic)
            local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(20, 20, 10, 10), function ()end)
            lbBg:setScaleX(140 / lbBg:getContentSize().width)
            lbBg:setPosition(getCenterPoint(giftSp))
            giftSp:addChild(lbBg)
            local hasRewardLb = GetTTFLabel(getlocal("already_sent"), 25)
            hasRewardLb:setPosition(getCenterPoint(giftSp))
            giftSp:addChild(hasRewardLb, 3)
        else
            local function showReward()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local rewardList = acJtxlhVoApi:getAllianceReward(k)
                local title = {getlocal("award"), 25, nil, "Helvetica-bold"}
                acJtxlhVoApi:showRewardDialog(title, nil, rewardList, self.layerNum + 1)
            end
            giftSp = LuaCCSprite:createWithSpriteFrameName(giftPic, showReward)
            giftSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        end
        giftSp:setScale(giftSize / giftSp:getContentSize().width)
        giftSp:setPosition(aRgsTimerPosX + k * aRgsTimerWidth / 2, aRgsTimerPosY + giftSize / 2 + aRgsTimerHeight / 2 + 5)
        allianceRechargeLayer:addChild(giftSp)
        local needRecharge = tonumber(aRewardCfg[k].recharge or 0)
        local rechargeLb = GetTTFLabel(needRecharge, smallFontSize)
        rechargeLb:setPosition(giftSp:getPositionX(), aRgsTimerPosY - rechargeLb:getContentSize().height / 2 - aRgsTimerHeight / 2)
        allianceRechargeLayer:addChild(rechargeLb)
        if aRechargeNum >= needRecharge then
            rechargeLb:setColor(G_ColorYellowPro)
        else
            rechargeLb:setColor(G_ColorRed)
        end
        if k == 1 then
            local lineSp = CCSprite:createWithSpriteFrameName("reportWhiteLine.png")
            lineSp:setScaleX((aRgsTimerHeight - 3) / lineSp:getContentSize().width)
            lineSp:setPosition(k * aRgsTimerWidth / 2, progressBarBg:getContentSize().height / 2)
            lineSp:setRotation(90)
            lineSp:setColor(lineColor)
            progressBarBg:addChild(lineSp, 3)
        end
    end
end

function acJtxlhDialog:initButton()
    local rechargeBtnPosX, rechargeBtnPosY = G_VisibleSizeWidth / 2, 70
    local iphoneType = G_getIphoneType()
    if iphoneType == G_iphone4 then
        rechargeBtnPosY = 50
    end
    local btnScale, priority, btnFontSize = 0.8, -(self.layerNum - 1) * 20 - 4
    local selfAlliance = allianceVoApi:getSelfAlliance()
    if selfAlliance == nil or selfAlliance.aid == nil then
        rechargeBtnPosX = G_VisibleSizeWidth / 2 + 150
        --进入军团
        local function enterAllianceHandler()
            local buildVo = buildingVoApi:getBuildiingVoByBId(7)
            if buildVo == nil then
                do return end
            end
            if buildVo.status == -1 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_6"), 28)
                do return end
            end
            self:close()
            allianceVoApi:showAllianceDialog(4)
        end
        local enterItem, enterMenu = G_createBotton(self.mainLayer, ccp(G_VisibleSizeWidth / 2 - 150, rechargeBtnPosY), {getlocal("alliance_email_title3"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", enterAllianceHandler, btnScale, priority)
    end
    --充值
    local function rechargeHandler()
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(4)
    end
    local rechargeItem, rechargeMenu = G_createBotton(self.mainLayer, ccp(rechargeBtnPosX, rechargeBtnPosY), {getlocal("recharge"), btnFontSize}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", rechargeHandler, btnScale, priority)
end

function acJtxlhDialog:tick()
    if acJtxlhVoApi:isEnd() == true then
        self:close()
        do return end
    end
    if self.bgLayer == nil or tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
        do return end
    end
    if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acJtxlhVoApi:getTimeStr())
    end
end

function acJtxlhDialog:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("active.jtxlh", self.refreshListener)
        self.refreshListener = nil
    end
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
    spriteController:removePlist("public/acydcz_images.plist")
    spriteController:removeTexture("public/acydcz_images.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    self.bgLayer = nil
    self.mainLayer = nil
    self.tvWidth, self.tvHeight = nil, nil
    self.tv = nil
    self.allianceRechargeLayer=nil    
end
