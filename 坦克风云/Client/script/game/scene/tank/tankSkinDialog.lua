tankSkinDialog = commonDialog:new()

function tankSkinDialog:new(tankId)
    local nc = {
        tankId = tankId, --默认显示的坦克皮肤
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tankSkinDialog:initTableView()
    spriteController:addPlist("public/tankSkin/tankSkin_images1.plist")
    spriteController:addTexture("public/tankSkin/tankSkin_images1.png")
    spriteController:addPlist("public/tankSkin/tankSkin_image2.plist")
    spriteController:addTexture("public/tankSkin/tankSkin_image2.png")
    spriteController:addPlist("public/acydcz_images.plist")
    spriteController:addTexture("public/acydcz_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/decorate_special.plist")
    spriteController:addTexture("public/decorate_special.png")
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    spriteController:addPlist("public/tankSkin/tskin_effect.plist")
    spriteController:addTexture("public/tankSkin/tskin_effect.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self.tankViewSize = CCSizeMake(G_VisibleSizeWidth, 290)
    self.skinViewSize = CCSizeMake(G_VisibleSizeWidth - 60, 156)
    self.touchArr = {}
    self.moveMinDis = 100
    self.turnInterval = 0.3
    self.displayNum = 3
    self.attriFontSize, self.attriFontWidth = 22, 300
    
    self.mainLayer = CCLayer:create()
    self.mainLayer:setTouchEnabled(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.mainLayer:registerScriptTouchHandler(tmpHandler, false, -(self.layerNum - 1) * 20 - 4, false)
    self.bgLayer:addChild(self.mainLayer)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local tankViewBg = CCSprite:create("public/tankSkin/tankSkinBg.jpg")
    tankViewBg:setAnchorPoint(ccp(0.5, 1))
    tankViewBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 135)
    self.mainLayer:addChild(tankViewBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local btnScale, btnFontSize, priority, btnPosY, tipPosOffy = 0.7, 22, -(self.layerNum - 1) * 20 - 4, 70, 5
    local iphoneType = G_getIphoneType()
    if iphoneType == G_iphone5 or iphoneType == G_iphoneX then
        btnPosY = 120
        tipPosOffy = 40
    end
    
    local viewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function ()end)
    viewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 495))
    viewBg:setAnchorPoint(ccp(0.5, 1))
    viewBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 425)
    self.mainLayer:addChild(viewBg)
    self.viewBg = viewBg
    
    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(viewBg:getContentSize().width / 2, viewBg:getContentSize().height - 160)
    viewBg:addChild(titleBg, 2)
    
    local titleLb = GetTTFLabel(getlocal("decoratePrompt"), 24, true)
    titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
    titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)
    
    local tipFontSize = 22
    if G_getCurChoseLanguage()=="ko" then
        tipFontSize=18
        btnPosY = btnPosY + 10
    end
    local tipLb = GetTTFLabelWrap(getlocal("tankSkin_tip"), tipFontSize, CCSizeMake(self.tankViewSize.width-30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipLb:setAnchorPoint(ccp(0.5, 0.5))
    tipLb:setPosition(viewBg:getContentSize().width / 2, tipLb:getContentSize().height / 2 + tipPosOffy)
    tipLb:setColor(G_ColorYellowPro)
    self.viewBg:addChild(tipLb)
    
    --获取皮肤
    local function acquireSkin()
        -- local tankId, skinId = self:getSelectSkin()
        --跳转坦克皮肤商店页面
        activityAndNoteDialog:closeAllDialog()
        local td = allShopVoApi:showAllPropDialog(self.layerNum, "tskin")
    end
    self.acquireBtn = G_createBotton(self.viewBg, ccp(self.viewBg:getContentSize().width * 0.5, btnPosY), {getlocal("accessory_get"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", acquireSkin, btnScale, priority)

    self.acquireTypeLb = GetTTFLabelWrap(getlocal("tankSkin_acquireType1"), tipFontSize, CCSizeMake(self.tankViewSize.width-30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.acquireTypeLb:setAnchorPoint(ccp(0.5, 0.5))
    self.acquireTypeLb:setPosition(self.viewBg:getContentSize().width / 2, btnPosY)
    self.acquireTypeLb:setColor(G_ColorYellowPro)
    self.viewBg:addChild(self.acquireTypeLb)
    --升级皮肤
    local function upgradeSkin()
        local tankId, skinId = self:getSelectSkin()
        local propId, cost = tankSkinVoApi:getUpgradeSkinCost(skinId)
        local num = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(propId)))
        
        local function realUpgrade()
            local function upgradeCallBack()
                bagVoApi:useItemNumId(tonumber(RemoveFirstChar(propId)), cost)
                self:playUpgradeOrUseEffect()
                self:refreshBtns()
                self:refreshTankSkinDetail()
                self:refreshAttributes()
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateUpSucess"), 28)
                eventDispatcher:dispatchEvent("tankWarehouseScene.initTanks")
            end
            tankSkinVoApi:upgradeTankSkin(skinId, upgradeCallBack)
        end
        
        if num < cost then --升级消耗的道具不足，则补充道具用来升级
            local buyNum = cost - num
            local confirmStr = getlocal("tankSkin_upgrade_second_tip", {propCfg[propId].gemCost * buyNum, buyNum})
            G_supplyPropConfirmHandler(propId, buyNum, confirmStr, realUpgrade, self.layerNum + 1)
        else
            realUpgrade()
        end
    end
    self.upgradeBtn, self.upgradeMenu = G_createBotton(self.viewBg, ccp(self.viewBg:getContentSize().width * 0.5 - 150, btnPosY), {getlocal("upgradeBuild"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", upgradeSkin, btnScale, priority)
    --使用皮肤
    local function useSkin()
        local function useCallBack()
            self:playUpgradeOrUseEffect()
            self:refreshBtns()
            self:resetSkinDisplayTb()
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateUseSucess"), 28)
            eventDispatcher:dispatchEvent("tankWarehouseScene.initTanks")
        end
        local tankId, skinId = self:getSelectSkin()
        tankSkinVoApi:useTankSkin(1, skinId, useCallBack)
    end
    self.useBtn = G_createBotton(self.viewBg, ccp(self.viewBg:getContentSize().width * 0.5 + 150, btnPosY), {getlocal("use"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", useSkin, btnScale, priority)
    --卸掉皮肤
    local function removeSkin()
        local function removeCallBack()
            self:refreshBtns()
            self:resetSkinDisplayTb()
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_troop_setTip7"), 28)
            eventDispatcher:dispatchEvent("tankWarehouseScene.initTanks")
        end
        local tankId, skinId = self:getSelectSkin()
        tankSkinVoApi:useTankSkin(2, skinId, removeCallBack)
    end
    self.removeBtn = G_createBotton(self.viewBg, ccp(self.viewBg:getContentSize().width * 0.5 + 150, btnPosY), {getlocal("accessory_unware"), btnFontSize}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", removeSkin, btnScale, priority)
    
    --切换按钮
    local priority, arrowScale, moveSpace, moveTime = -(self.layerNum - 1) * 20 - 4, 0.8, 10, 0.5
    local function leftTankHandler()
        self:rightTankPage()
    end
    local function rightTankHandler()
        self:leftTankPage()
    end
    self.leftTankArrowBtn = G_createBotton(tankViewBg, ccp(40, tankViewBg:getContentSize().height / 2), nil, "leftBtnGreen.png", "leftBtnGreen.png", "leftBtnGreen.png", leftTankHandler, arrowScale, priority)
    self.rightTankArrowBtn = G_createBotton(tankViewBg, ccp(tankViewBg:getContentSize().width - 40, tankViewBg:getContentSize().height / 2), nil, "leftBtnGreen.png", "leftBtnGreen.png", "leftBtnGreen.png", rightTankHandler, arrowScale, priority)
    self.rightTankArrowBtn:setRotation(180)
    self.leftTankArrowBtn:runAction(G_actionArrow(1, moveSpace, moveTime))
    self.rightTankArrowBtn:runAction(G_actionArrow(-1, moveSpace, moveTime))
    
    local function leftSkinHandler()
        self:rightSkinPage()
    end
    local function rightSkinHandler()
        self:leftSkinPage()
    end
    self.leftSkinArrowBtn = G_createBotton(self.viewBg, ccp(60, self.viewBg:getContentSize().height - 60), nil, "leftBtnGreen.png", "leftBtnGreen.png", "leftBtnGreen.png", leftSkinHandler, arrowScale, priority)
    self.rightSkinArrowBtn = G_createBotton(self.viewBg, ccp(self.viewBg:getContentSize().width - 60, self.viewBg:getContentSize().height - 60), nil, "leftBtnGreen.png", "leftBtnGreen.png", "leftBtnGreen.png", rightSkinHandler, arrowScale, priority)
    self.rightSkinArrowBtn:setRotation(180)
    self.leftSkinArrowBtn:runAction(G_actionArrow(1, moveSpace, moveTime))
    self.rightSkinArrowBtn:runAction(G_actionArrow(-1, moveSpace, moveTime))
    
    self.selectedTabIndex = 1
    self.oldSelectedTabIndex = self.selectedTabIndex
    
    self.tankGroupTb = tankSkinVoApi:getTankGroup()
    self.tankTypeTb = {"1", "2", "4", "8"}
    local tabTb = {getlocal("tanke"), getlocal("jianjiche"), getlocal("zixinghuopao"), getlocal("huojianche")}
    if self.tankId then
        self.tankId = tonumber(self.tankId) or tonumber(RemoveFirstChar(self.tankId))
        local tankType = tankCfg[self.tankId].type
        for k, v in pairs(self.tankTypeTb) do
            if tonumber(v) == tonumber(tankType) then
                self.selectedTabIndex = k
                do break end
            end
        end
    end
    
    local function tabClick(idx)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.oldSelectedTabIndex ~= idx then
            self:tabClick(idx)
        end
    end
    self.tabBtnTb = {}
    local tabBtn = CCMenu:create()
    for k, v in pairs(tabTb) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 1))
        tabBtnItem:setPosition(20 + (k - 1) * (tabBtnItem:getContentSize().width + 4), G_VisibleSizeHeight - 85)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(k)
        
        local lbFontSize = 24
        if k == 3 and not G_isAsia() then
            lbFontSize = 18
        end
        local lb = GetTTFLabelWrap(v, lbFontSize, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
        tabBtnItem:addChild(lb, 1)
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.tabBtnTb[k] = tabBtnItem
        if k == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabBtn, 1)
    
    self:tabClick(self.selectedTabIndex)
    
    local tabLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 1, 2, 1), function()end)
    tabLineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, 7))
    tabLineSp:setAnchorPoint(ccp(0.5, 1))
    tabLineSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 135))
    self.bgLayer:addChild(tabLineSp, 1)
    
    local function showTotalAttributeView()
        if self.detailBtn == nil then
            do return end
        end
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function realShow()
            local tankId = self:getSelectSkin()
            tankInfoDialog:create(sceneGame, tankId, self.layerNum + 1)
        end
        G_touchedItem(self.detailBtn, realShow, 0.9)
    end
    local detailBtn = LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png", showTotalAttributeView)
    detailBtn:setScale((G_VisibleSizeWidth - 20) / G_VisibleSizeWidth)
    detailBtn:setPosition(G_VisibleSizeWidth / 2, 45)
    detailBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(detailBtn, 6)
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
    local detailLb = GetTTFLabelWrap(getlocal("decorateAllattr"), 22, CCSizeMake(200, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    detailLb:setPosition(getCenterPoint(detailBtn))
    detailBtn:addChild(detailLb)
    
    --规则说明
    local function touchTip()
        local tabStr = {}
        local textFormatTb = {}
        for k = 1, 3 do
            table.insert(tabStr, getlocal("tskin_rule"..k))
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    G_addMenuInfo(self.mainLayer, self.layerNum, ccp(G_VisibleSizeWidth - 40, tankViewBg:getPositionY() - 40), nil, nil, 1, nil, touchTip, true)
    
    --放大镜
    local magnifierNode = CCNode:create()
    magnifierNode:setAnchorPoint(ccp(0.5, 0.5))
    self.mainLayer:addChild(magnifierNode, 12)
    self.magnifierNode = magnifierNode
    
    --查看各等级皮肤属性
    local function overviewAttributeHandler(...)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tankId, skinId = self:getSelectSkin()
        tankSkinVoApi:showSkinAttributeOverview(skinId, self.layerNum + 1)
    end
    local circelCenter = getCenterPoint(magnifierNode)
    local radius, rt, rtimes = 10, 2, 2
    local magnifierSp = LuaCCSprite:createWithSpriteFrameName("ydcz_magnifier.png", overviewAttributeHandler)
    magnifierSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    magnifierSp:setPosition(circelCenter)
    magnifierNode:addChild(magnifierSp)
    
    local acArr = CCArray:create()
    local moveTo = CCMoveTo:create(0.5, ccp(magnifierNode:getContentSize().width / 2, radius))
    local function rotateBy()
        G_requireLua("componet/CircleBy")
        self.circelAc = CircleBy:create(magnifierSp, rt, circelCenter, radius, rtimes)
    end
    local function removeRotateBy()
        if self.circelAc and self.circelAc.stop then
            self.circelAc:stop()
        end
    end
    local moveTo2 = CCMoveTo:create(0.5, ccp(magnifierNode:getContentSize().width / 2, magnifierNode:getContentSize().height / 2))
    local delay = CCDelayTime:create(1)
    acArr:addObject(moveTo)
    acArr:addObject(CCCallFunc:create(rotateBy))
    acArr:addObject(CCDelayTime:create(rt))
    acArr:addObject(CCCallFunc:create(removeRotateBy))
    acArr:addObject(moveTo2)
    acArr:addObject(delay)
    local seq = CCSequence:create(acArr)
    magnifierSp:runAction(CCRepeatForever:create(seq))
    self:refreshMagnifier(true)
    
    --预览装配坦克皮肤在战斗中的效果
    local function overviewHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tankId, skinId = self:getSelectSkin()
        local battleData = tankSkinVoApi:returnTankData(tankId, skinId)
        if not battleData then
            print " ===== e r r o r :battleData is nil ======"
            do return end
        end

        battleScene:initData(battleData,nil,nil,self.layerNum + 1)
    end
    local overViewSp = LuaCCSprite:createWithSpriteFrameName("tskin_overview.png", overviewHandler)
    overViewSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    overViewSp:setPosition(20 + overViewSp:getContentSize().width / 2, 10 + tankViewBg:getPositionY() - self.tankViewSize.height + overViewSp:getContentSize().height / 2)
    self.mainLayer:addChild(overViewSp, 5)
end

function tankSkinDialog:tabClick(idx)
    local tankList = self.tankGroupTb[tonumber(self.tankTypeTb[idx])]
    if tankList == nil or SizeOfTable(tankList) == 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("tankSkin_notank"), 28)
        do return end
    end
    self.selectedTabIndex = idx
    for k, tabBtnItem in pairs(self.tabBtnTb) do
        if k == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        else
            tabBtnItem:setEnabled(true)
        end
    end
    self.oldSelectedTabIndex = self.selectedTabIndex
    self:initTankPageLayer(idx)
end

function tankSkinDialog:touchEvent(fn, x, y, touch)
    if self.tankShowTouchRect == nil or self.skinShowTouchRect == nil then
        do return end
    end
    if fn == "began" then
        if SizeOfTable(self.touchArr) >= 1 then
            return 0
        end
        
        if touch then
            if self.tankShowTouchRect:containsPoint(ccp(x, y)) == false and self.skinShowTouchRect:containsPoint(ccp(x, y)) == false then
                return 0
            end
        else
            return 0
        end
        self.isMoved = false
        self.touchArr[touch] = touch
        local touchIndex = 0
        for k, v in pairs(self.touchArr) do
            local temTouch = tolua.cast(v, "CCTouch")
            if self and temTouch then
                if touchIndex == 0 then
                    self.firstOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                    self.secondOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
            end
            touchIndex = touchIndex + 1
        end
        if touchIndex == 1 then
            self.secondOldPos = nil
            self.lastTouchDownPoint = self.firstOldPos
        end
        if SizeOfTable(self.touchArr) > 1 then
            self.multiTouch = true
        else
            self.multiTouch = false
        end
        return 1
    elseif fn == "moved" then
        
    elseif fn == "ended" then
        if self.touchArr[touch] ~= nil then
            self.touchArr[touch] = nil
            local touchIndex = 0
            for k, v in pairs(self.touchArr) do
                local temTouch = tolua.cast(v, "CCTouch")
                if self and temTouch then
                    if touchIndex == 0 then
                        self.firstOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                    else
                        self.secondOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                    end
                end
                touchIndex = touchIndex + 1
            end
            if touchIndex == 1 then
                self.secondOldPos = nil
            end
            if SizeOfTable(self.touchArr) > 1 then
                self.multiTouch = true
            else
                self.multiTouch = false
            end
        end
        
        if self.multiTouch == true then --双点触摸
        else --单点触摸
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local moveDisTmp = ccpSub(curPos, self.lastTouchDownPoint)
            if self.tankShowTouchRect:containsPoint(self.lastTouchDownPoint) == true and self.tankShowTouchRect:containsPoint(ccp(x, y)) == true then
                if moveDisTmp.x > self.moveMinDis then
                    self:leftTankPage()
                elseif moveDisTmp.x < -self.moveMinDis then
                    self:rightTankPage()
                end
            elseif self.skinShowTouchRect:containsPoint(self.lastTouchDownPoint) == true and self.skinShowTouchRect:containsPoint(ccp(x, y)) == true then
                if moveDisTmp.x > self.moveMinDis then
                    self:leftSkinPage()
                elseif moveDisTmp.x < -self.moveMinDis then
                    self:rightSkinPage()
                end
            end
        end
    else
        self.touchArr = nil
        self.touchArr = {}
    end
end

function tankSkinDialog:getSelectSkin()
    local tankId = self.tankList[self.tankPage]
    local skinId = self.skinList[self.skinPage]
    return tankId, skinId
end

--刷新按钮状态
function tankSkinDialog:refreshBtns()
    if self.upgradeBtn == nil or self.acquireBtn == nil or self.removeBtn == nil or self.useBtn == nil then
        do return end
    end
    local tankId, skinId = self:getSelectSkin()
    local scfg = tankSkinCfg.skinCfg[skinId]
    if tankSkinVoApi:isSkinOwned(skinId) == false then --如果还没有拥有该皮肤则显示获取按钮
        self.upgradeBtn:setEnabled(false)
        self.upgradeBtn:setVisible(false)
        self.acquireBtn:setEnabled(true)
        self.acquireBtn:setVisible(true)
    elseif tankSkinVoApi:isSkinMaxLv(skinId) == true then --皮肤已升级到最高等级
        self.acquireBtn:setEnabled(false)
        self.acquireBtn:setVisible(false)
        self.upgradeBtn:setEnabled(false)
        self.upgradeBtn:setVisible(true)
        local upgradeLb = tolua.cast(self.upgradeBtn:getChildByTag(101), "CCLabelTTF")
        if upgradeLb then
            upgradeLb:setString(getlocal("alliance_lvmax"))
        end
        if self.upgradeCostView then
            self.upgradeCostView:setVisible(false)
        end
    else
        self.upgradeBtn:setEnabled(true)
        self.upgradeBtn:setVisible(true)
        local upgradeLb = tolua.cast(self.upgradeBtn:getChildByTag(101), "CCLabelTTF")
        if upgradeLb then
            upgradeLb:setString(getlocal("upgradeBuild"))
        end
        self.acquireBtn:setEnabled(false)
        self.acquireBtn:setVisible(false)
        local iconWidth = 50
        local costSp, costLb
        local propId, costNum = tankSkinVoApi:getUpgradeSkinCost(skinId)
        local num = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(propId)))
        -- print("propId,num---->>", propId, num)
        local costStr = num.."/"..costNum
        if self.upgradeCostView == nil then
            local upgradeCostView = CCNode:create()
            upgradeCostView:setAnchorPoint(ccp(0.5, 0))
            upgradeCostView:setContentSize(CCSizeMake(1, 1))
            upgradeCostView:setPosition(self.viewBg:getContentSize().width * 0.5 - 150, self.upgradeMenu:getPositionY() + iconWidth / 2)
            self.viewBg:addChild(upgradeCostView, 2)
            costSp = CCSprite:createWithSpriteFrameName(propCfg[propId].icon)
            costSp:setScale(iconWidth / costSp:getContentSize().width)
            costSp:setAnchorPoint(ccp(0, 0.5))
            costSp:setTag(11)
            upgradeCostView:addChild(costSp)
            costLb = GetTTFLabel(costStr, 22)
            costLb:setAnchorPoint(ccp(0, 0.5))
            costLb:setTag(12)
            upgradeCostView:addChild(costLb)
            self.upgradeCostView = upgradeCostView
        else
            self.upgradeCostView:setVisible(true)
            costSp, costLb = tolua.cast(self.upgradeCostView:getChildByTag(11), "CCSprite"), tolua.cast(self.upgradeCostView:getChildByTag(12), "CCLabelTTF")
        end
        if costSp and costLb then
            local width = iconWidth + costLb:getContentSize().width + 5
            costSp:setPosition(-width / 2, iconWidth / 2)
            costLb:setPosition(costSp:getPositionX() + iconWidth + 5, iconWidth / 2)
            costLb:setString(costStr)
            if num >= costNum then
                costLb:setColor(G_ColorYellowPro)
            else
                costLb:setColor(G_ColorRed)
            end
        end
    end
    if tankSkinVoApi:isSkinOwned(skinId) == false then --没有该皮肤则不可使用
        self.removeBtn:setEnabled(false)
        self.removeBtn:setVisible(false)
        self.useBtn:setEnabled(false)
        self.useBtn:setVisible(false)
    elseif tankSkinVoApi:isHasUsed(tankId, skinId) == true then --皮肤正在使用
        self.removeBtn:setEnabled(true)
        self.removeBtn:setVisible(true)
        self.useBtn:setEnabled(false)
        self.useBtn:setVisible(false)
    else
        self.removeBtn:setEnabled(false)
        self.removeBtn:setVisible(false)
        self.useBtn:setEnabled(true)
        self.useBtn:setVisible(true)
    end
    if self.leftTankArrowBtn and self.rightTankArrowBtn and self.leftSkinArrowBtn and self.rightSkinArrowBtn then
        if self.maxTankPage == 1 then
            self.leftTankArrowBtn:setVisible(false)
            self.leftTankArrowBtn:setEnabled(false)
            self.rightTankArrowBtn:setVisible(false)
            self.rightTankArrowBtn:setEnabled(false)
        else
            self.leftTankArrowBtn:setVisible(true)
            self.leftTankArrowBtn:setEnabled(true)
            self.rightTankArrowBtn:setVisible(true)
            self.rightTankArrowBtn:setEnabled(true)
        end
        if self.maxSkinPage <= 3 then
            self.leftSkinArrowBtn:setVisible(false)
            self.leftSkinArrowBtn:setEnabled(false)
            self.rightSkinArrowBtn:setVisible(false)
            self.rightSkinArrowBtn:setEnabled(false)
        else
            self.leftSkinArrowBtn:setVisible(true)
            self.leftSkinArrowBtn:setEnabled(true)
            self.rightSkinArrowBtn:setVisible(true)
            self.rightSkinArrowBtn:setEnabled(true)
        end
    end
    if scfg and scfg.special and scfg.special == 1 then --特殊涂装不显示获取按钮
        self.acquireBtn:setEnabled(false)
        self.acquireBtn:setVisible(false)
        self.acquireTypeLb:setVisible(false)
        if self.acquireTypeLb and tolua.cast(self.acquireTypeLb,"CCLabelTTF") and tankSkinVoApi:isSkinOwned(skinId) == false then
            self.acquireTypeLb:setVisible(true)
        end
    else
        self.acquireTypeLb:setVisible(false)
    end
end

function tankSkinDialog:initTankPageLayer(idx)
    if self.tankLayer then
        self.tankLayer:removeFromParentAndCleanup(true)
        self.tankLayer = nil
    end
    local tankLayer = CCLayer:create()
    self.mainLayer:addChild(tankLayer, 3)
    self.tankLayer = tankLayer
    
    --被选中坦克显示的区域
    local tankPageClipper = CCClippingNode:create()
    tankPageClipper:setContentSize(self.tankViewSize)
    tankPageClipper:setAnchorPoint(ccp(0.5, 1))
    tankPageClipper:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 135)
    local stencil = CCDrawNode:getAPolygon(self.tankViewSize, 1, 1)
    tankPageClipper:setStencil(stencil)
    self.tankLayer:addChild(tankPageClipper)
    self.tankPageClipper = tankPageClipper
    
    self.tankList = self.tankGroupTb[tonumber(self.tankTypeTb[idx])]
    self.tankPage, self.maxTankPage = 1, SizeOfTable(self.tankList)
    for k, v in pairs(self.tankList) do
        if tonumber(v) == self.tankId then
            self.tankPage = k
            do break end
        end
    end
    self.tankShowTouchRect = CCRect(0, tankPageClipper:getPositionY() - self.tankViewSize.height, G_VisibleSizeWidth, self.tankViewSize.height)
    
    self.tankPosY = 130
    self.leftTankPosX = -self.tankViewSize.width / 2
    self.centerTankPosX = self.tankViewSize.width / 2
    self.rightTankPosX = 3 * self.tankViewSize.width / 2
    
    self.tankSpTb = {}
    local defaultSkinId = "s1"
    for k, v in pairs(self.tankList) do
        local skinPic = tankSkinVoApi:getSkinPic(defaultSkinId)
        local tankSp = CCSprite:createWithSpriteFrameName(skinPic)
        if k == self.tankPage then
            tankSp:setPosition(self.centerTankPosX, self.tankPosY)
        else
            tankSp:setPosition(10000, 0)
            tankSp:setVisible(false)
        end
        self.tankPageClipper:addChild(tankSp)
        self.tankSpTb[k] = tankSp
    end
    
    local skinNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("decorate_title.png", CCRect(200, 15, 1, 1), function() end)
    skinNameBg:setAnchorPoint(ccp(0.5, 1))
    skinNameBg:setContentSize(CCSizeMake(580, 45))
    skinNameBg:setPosition(ccp(self.tankViewSize.width / 2, self.tankViewSize.height))
    self.tankPageClipper:addChild(skinNameBg, 2)
    local skinNameLb = GetTTFLabel(tankSkinVoApi:getSkinNameStr(defaultSkinId), 25, true)
    skinNameLb:setPosition(skinNameBg:getContentSize().width / 2, skinNameBg:getContentSize().height / 2)
    skinNameLb:setColor(G_ColorYellowPro)
    skinNameBg:addChild(skinNameLb)
    self.skinNameLb = skinNameLb
    
    local skinVo = tankSkinVoApi:getSkinById(defaultSkinId)
    local lv = 1
    if skinVo then
        lv = skinVo.lv
    end
    local skinLevelSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
    skinLevelSp:setAnchorPoint(ccp(0, 0.5))
    skinLevelSp:setScale(1.2)
    skinLevelSp:setPosition(self.tankViewSize.width - 100, skinLevelSp:getContentSize().height / 2 + 20)
    self.tankPageClipper:addChild(skinLevelSp, 2)
    local skinLevelLb = GetTTFLabel(tostring(lv), 30, true)
    skinLevelLb:setAnchorPoint(ccp(0, 0.5))
    skinLevelLb:setPosition(skinLevelSp:getPositionX() + skinLevelSp:getContentSize().width * skinLevelSp:getScale() + 5, skinLevelSp:getPositionY())
    skinLevelLb:setColor(G_ColorYellowPro)
    self.tankPageClipper:addChild(skinLevelLb, 2)
    self.skinLevelLb = skinLevelLb
    self.skinLevelSp = skinLevelSp
    
    self:initSkinLayer()
end

function tankSkinDialog:initSkinLayer()
    if self.skinLayer then
        self.skinLayer:removeFromParentAndCleanup(true)
        self.skinLayer = nil
    end
    local skinLayer = CCLayer:create()
    self.mainLayer:addChild(skinLayer, 3)
    self.skinLayer = skinLayer
    --被选中坦克显示的区域
    local skinPageClipper = CCClippingNode:create()
    skinPageClipper:setContentSize(self.skinViewSize)
    skinPageClipper:setAnchorPoint(ccp(0.5, 1))
    skinPageClipper:setPosition(G_VisibleSizeWidth / 2, self.viewBg:getPositionY())
    local stencil = CCDrawNode:getAPolygon(self.skinViewSize, 1, 1)
    skinPageClipper:setStencil(stencil)
    self.skinLayer:addChild(skinPageClipper)
    self.skinPageClipper = skinPageClipper
    
    self.skinShowTouchRect = CCRect(0, skinPageClipper:getPositionY() - self.skinViewSize.height, G_VisibleSizeWidth, self.skinViewSize.height)
    
    self.skinSpTb = {}
    self.skinTurning = false
    
    self.skinList = tankSkinVoApi:getSkinListByTankId(tonumber(self.tankList[self.tankPage]))
    self.skinPage, self.maxSkinPage = 1, SizeOfTable(self.skinList)
    if self.maxSkinPage < 3 then
        self.displayNum = self.maxSkinPage
    end
    local usedFlag,ownFlag,ownSkinIdx = false,false
    local tankId = self:getSelectSkin()
    for k, v in pairs(self.skinList) do
        usedFlag = tankSkinVoApi:isHasUsed(tankId, v)
        if usedFlag == true then
            self.skinPage = k
            do break end
        end
        if ownFlag == false then
            ownFlag = tankSkinVoApi:isSkinOwned(v)
            if ownFlag == true then
               ownSkinIdx = k
            end
        end
    end
    if usedFlag == false and ownFlag == true then
        self.skinPage = ownSkinIdx
    end
    
    self.skinCount = SizeOfTable(self.skinList)
    local maxScale, midScale, minScale = 0.65, 0.5, 0.35
    local skinPosY = self.skinViewSize.height / 2 - 10
    local displayCfg = {}
    if self.skinCount == 1 then
        displayCfg = {{ccp(self.skinViewSize.width / 2, skinPosY), maxScale}}
    elseif self.skinCount == 2 then
        displayCfg = {
            {ccp(self.skinViewSize.width / 2 - 100, skinPosY), maxScale},
            {ccp(self.skinViewSize.width / 2 + 100, skinPosY), maxScale},
        }
    else
        displayCfg = {
            {ccp(self.skinViewSize.width / 2 - 200, skinPosY), 0.6, midScale},
            {ccp(self.skinViewSize.width / 2, skinPosY), 1, maxScale},
            {ccp(self.skinViewSize.width / 2 + 200, skinPosY), 0.6, midScale},
        }
    end
    self.displayCfg = displayCfg
    self.leftDisplayCfg = {ccp(self.skinViewSize.width / 2 - 400, skinPosY), 0.4, minScale}
    self.rightDisplayCfg = {ccp(self.skinViewSize.width / 2 + 400, skinPosY), 0.4, minScale}
    for k, v in pairs(self.skinList) do
        local skinSp
        if self.skinCount <= 3 then
            local function showSkinDetail()
                if self.skinPage == k then
                    do return end
                end
                for skinIndex, v in pairs(self.skinSpTb) do
                    if skinIndex == k then
                        local skinSp = tolua.cast(v, "LuaCCSprite")
                        if skinSp then
                            skinSp:setOpacity(255)
                        else
                            skinSp:setOpacity(255 * 0.6)
                        end
                    end
                end
                self.skinPage = k
                self:refreshTankSkinDetail(true)
            end
            skinSp = LuaCCSprite:createWithSpriteFrameName(tankSkinVoApi:getSkinPic(v), showSkinDetail)
            skinSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        else
            skinSp = CCSprite:createWithSpriteFrameName(tankSkinVoApi:getSkinPic(v))
        end
        skinSp:setPosition(10000, 0)
        skinSp:setVisible(false)
        if tankSkinVoApi:isSkinOwned(v) == false then --如果没有该皮肤则上锁显示
            local lockSp = CCSprite:createWithSpriteFrameName("aitroops_lock.png")
            lockSp:setPosition(getCenterPoint(skinSp))
            lockSp:setScale(0.8)
            skinSp:addChild(lockSp)
        end
        self.skinPageClipper:addChild(skinSp)
        self.skinSpTb[k] = skinSp
    end
    self:resetSkinDisplayTb()
    
    self:refreshTankSkinDetail(true)
end

function tankSkinDialog:resetSkinDisplayTb()
    self.displayTb = {}
    local page = self.skinPage - math.floor(self.displayNum / 2)
    if page < 1 then
        page = page + self.maxSkinPage
    end
    local tankId = self.tankList[self.tankPage]
    for k = 1, self.displayNum do
        self.displayTb[k] = page
        local skinSp = tolua.cast(self.skinSpTb[page], "CCSprite")
        if skinSp then
            skinSp:setPosition(self.displayCfg[k][1])
            local scale = self.displayCfg[k][2]
            skinSp:setScale(scale)
            skinSp:setVisible(true)
            if self.skinCount > 3 then
                skinSp:setOpacity(255 * (self.displayCfg[k][3] or 1))
            end
            local skinId = self.skinList[page]
            local equipFlag = tankSkinVoApi:isHasUsed(tankId, skinId)
            local skinEquipBg, skinEquipLb = skinSp:getChildByTag(201), skinSp:getChildByTag(202)
            if equipFlag == true then
                if tolua.cast(skinEquipBg, "CCSprite") == nil and tolua.cast(skinEquipLb, "CCLabelTTF") == nil then
                    --已装配皮肤的标识
                    skinEquipBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
                    skinEquipBg:setScaleX(200 / skinEquipBg:getContentSize().width)
                    skinEquipBg:setScaleY(80 / skinEquipBg:getContentSize().height)
                    skinEquipBg:setTag(201)
                    skinEquipBg:setPosition(getCenterPoint(skinSp))
                    skinSp:addChild(skinEquipBg)
                    skinEquipLb = GetTTFLabel(getlocal("tankSkin_equiped"), 30)
                    skinEquipLb:setTag(202)
                    skinEquipLb:setColor(G_ColorGreen)
                    skinEquipLb:setPosition(skinEquipBg:getPosition())
                    skinSp:addChild(skinEquipLb)
                end
                skinEquipBg:setOpacity(255 * (self.displayCfg[k][3] or 1))
                skinEquipLb:setOpacity(255 * (self.displayCfg[k][3] or 1))
            else
                if tolua.cast(skinEquipBg, "CCSprite") and tolua.cast(skinEquipLb, "CCLabelTTF") then
                    skinEquipBg:removeFromParentAndCleanup(true)
                    skinEquipBg = nil
                    skinEquipLb:removeFromParentAndCleanup(true)
                    skinEquipLb = nil
                end
            end
        end
        page = page + 1
        if page > self.maxSkinPage then
            page = 1
        end
    end
end

function tankSkinDialog:refreshTankSkinDetail(newSkinFlag)
    local tankId, skinId = self:getSelectSkin()
    if self.skinNameLb and tolua.cast(self.skinNameLb, "CCLabelTTF") then
        self.skinNameLb:setString(tankSkinVoApi:getSkinNameStr(skinId))
    end
    local tankSp = self.tankSpTb[self.tankPage]
    if tankSp and tolua.cast(tankSp, "CCSprite") then
        local skinPic = tankSkinVoApi:getSkinPic(skinId)
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(skinPic)
        if frame then
            tankSp:setDisplayFrame(frame)
        end
    end
    local skinVo = tankSkinVoApi:getSkinById(skinId)
    if self.skinLevelLb and tolua.cast(self.skinLevelLb, "CCLabelTTF") and self.skinLevelSp and tolua.cast(self.skinLevelSp, "CCSprite") then
        if skinVo then
            self.skinLevelLb:setString(tostring(skinVo.lv))
            -- local width = self.skinLevelLb:getContentSize().width + self.skinLevelSp:getContentSize().width * self.skinLevelSp:getScale() + 5
            -- self.skinLevelLb:setPosition((self.tankViewSize.width - width) / 2, 20)
            -- self.skinLevelSp:setPosition(self.skinLevelLb:getPositionX() + self.skinLevelLb:getContentSize().width + 5, self.skinLevelLb:getPositionY())
            self.skinLevelLb:setVisible(true)
            self.skinLevelSp:setVisible(true)
        else
            self.skinLevelLb:setVisible(false)
            self.skinLevelSp:setVisible(false)
        end
    end
    if self.attriTv and newSkinFlag == true then
        self.attriTv:removeFromParentAndCleanup(true)
        self.attriTv = nil
    end
    if self.attriTv == nil then
        local tvContentHeight = self:getAttributeContentHeight()
        self.attriTvWidth, self.attriTvHeight = self.viewBg:getContentSize().width, 120
        local iphoneType = G_getIphoneType()
        if iphoneType == G_iphone5 or iphoneType == G_iphoneX then
            self.attriTvHeight = 180
        end
        if tvContentHeight < self.attriTvHeight then
            self.attriTvHeight = tvContentHeight
        end
        local function callBack(...)
            return self:attEventHandler(...)
        end
        local hd = LuaEventHandler:createHandler(callBack)
        self.attriTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.attriTvWidth, self.attriTvHeight), nil)
        self.attriTv:setPosition(ccp(0, self.viewBg:getContentSize().height - self.skinViewSize.height - self.attriTvHeight - 58))
        self.attriTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
        if tvContentHeight > self.attriTvHeight then
            self.attriTv:setMaxDisToBottomOrTop(120)
        else
            self.attriTv:setMaxDisToBottomOrTop(0)
        end
        self.viewBg:addChild(self.attriTv)
        
        local attriLineSp, skinTimeTipLb = tolua.cast(self.viewBg:getChildByTag(101), "LuaCCScale9Sprite"), tolua.cast(self.viewBg:getChildByTag(102), "CCLabelTTF")
        if attriLineSp == nil then
            attriLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            attriLineSp:setTag(101)
            self.viewBg:addChild(attriLineSp)
        end
        attriLineSp:setPosition(self.viewBg:getContentSize().width / 2, self.attriTv:getPositionY() - 2)
    end
    self:refreshSkinTimerLb(newSkinFlag) --刷新使用期限
    self:refreshBtns()
end

function tankSkinDialog:refreshAttributes()
    if self.attriTv and tolua.cast(self.attriTv, "LuaCCTableView") then
        self.attriTv:reloadData()
    end
end

function tankSkinDialog:refreshSkinTimerLb(newSkinFlag)
    local timerStr, timerLbColor = "", G_ColorWhite
    if skinVo and skinVo.et and skinVo.et > 0 then
        if skinVo.et > 0 then
            if base.serverTime > skinVo.et then --皮肤已过期
                timerStr = getlocal("expireDesc")
                timerLbColor = G_ColorRed
            else
                timerStr = G_formatActiveDate(skinVo.et - base.serverTime)
                timerLbColor = G_ColorGreen
            end
        else
            timerStr = getlocal("foreverTime")
            timerLbColor = G_ColorGreen
        end
    else
        timerStr = getlocal("foreverTime")
        timerLbColor = G_ColorGreen
    end
    if self.skinTimerLb == nil then
        local timerFontSize=22
        if G_getCurChoseLanguage()=="ko" then
            timerFontSize=18
        end
        local skinTimeTipLb = GetTTFLabel(getlocal("use_deadline"), timerFontSize)
        skinTimeTipLb:setAnchorPoint(ccp(0, 0.5))
        self.skinTimeTipLb = skinTimeTipLb
        self.viewBg:addChild(skinTimeTipLb)
        skinTimerLb = GetTTFLabel(timerStr, timerFontSize)
        skinTimerLb:setAnchorPoint(ccp(0, 0.5))
        self.viewBg:addChild(skinTimerLb)
        self.skinTimerLb = skinTimerLb
    end
    if self.skinTimeTipLb and tolua.cast(self.skinTimeTipLb, "CCLabelTTF") and self.skinTimerLb and tolua.cast(self.skinTimerLb, "CCLabelTTF") then
        self.skinTimerLb:setString(timerStr)
        self.skinTimerLb:setColor(timerLbColor)
        if newSkinFlag then
            local width = self.skinTimeTipLb:getContentSize().width + self.skinTimerLb:getContentSize().width
            self.skinTimeTipLb:setPosition((self.viewBg:getContentSize().width - width) / 2, self.attriTv:getPositionY() - self.skinTimeTipLb:getContentSize().height / 2 - 20)
            self.skinTimerLb:setPosition(self.skinTimeTipLb:getPositionX() + self.skinTimeTipLb:getContentSize().width, self.skinTimeTipLb:getPositionY())
        end
    end
end

function tankSkinDialog:attEventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.attriTvWidth, self:getAttributeContentHeight())
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake((G_VisibleSizeWidth - 40) / (G_VisibleSizeWidth - 30) * G_VisibleSizeWidth, G_VisibleSizeHeight - 90 - 300 - 60 - 10 - 50 - 170 - 30))
        
        local cellWidth, cellHeight = self.attriTvWidth, self:getAttributeContentHeight()
        local tankId, skinId = self:getSelectSkin()
        local cfg = tankSkinCfg.skinCfg[skinId]
        if cfg == nil then
            do return cell end
        end
        local curLvAttriTb, nextLvAttriTb = {}, {}
        local skinVo = tankSkinVoApi:getSkinById(skinId)
        if skinVo then
            local lv = skinVo.lv
            local nextLv = lv + 1
            if nextLv > cfg.lvMax then
                nextLv = cfg.lvMax
            end
            curLvAttriTb = tankSkinVoApi:getAttributeBySkinId(skinId, lv)
            nextLvAttriTb = tankSkinVoApi:getAttributeBySkinId(skinId, nextLv)
        else
            curLvAttriTb = tankSkinVoApi:getAttributeBySkinId(skinId, 1)
            nextLvAttriTb = tankSkinVoApi:getAttributeBySkinId(skinId, 2)
        end
        local attriKeys = G_clone(cfg.attType)
        if cfg.restrain and cfg.restrain > 0 then --有克制关系
            table.insert(attriKeys, "restrain")
        end
        local attriLbPosX, attriLbPosY = 80, cellHeight - self.attriOffy
        local attriValuePosX = attriLbPosX + self.attriFontWidth + 40
        for k, v in pairs(attriKeys) do
            local attriNameStr = ""
            if v == "restrain" then
                attriNameStr = tankSkinVoApi:getAttributeNameStr(v, cfg.restrain)
            else
                attriNameStr = tankSkinVoApi:getAttributeNameStr(v)
            end
            local attriLb = GetTTFLabelWrap(attriNameStr, self.attriFontSize, CCSizeMake(self.attriFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            attriLb:setAnchorPoint(ccp(0, 0.5))
            attriLb:setPosition(attriLbPosX, attriLbPosY - attriLb:getContentSize().height / 2)
            cell:addChild(attriLb)
            
            local valueSuffix = ""
            if v ~= "first" and v ~= "antifirst" then
                valueSuffix = "%"
            end
            local curValue = curLvAttriTb[v] or 0

            local curValueStr = (tostring(curValue) .. valueSuffix)
            local curValueLb = GetTTFLabel(curValueStr, self.attriFontSize)
            curValueLb:setAnchorPoint(ccp(0, 0.5))
            curValueLb:setPosition(attriValuePosX, attriLb:getPositionY())
            cell:addChild(curValueLb)
            if skinVo and skinVo.lv < cfg.lvMax then
                local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
                arrowSp:setAnchorPoint(ccp(0, 0.5))
                arrowSp:setPosition(attriValuePosX + 60, curValueLb:getPositionY())
                cell:addChild(arrowSp)
                local nextValue = nextLvAttriTb[v] or 0
                local nextValueStr = (tostring(nextValue) .. valueSuffix)
                local nextValueLb = GetTTFLabel(nextValueStr, self.attriFontSize)
                nextValueLb:setAnchorPoint(ccp(0, 0.5))
                nextValueLb:setColor(G_ColorGreen)
                nextValueLb:setPosition(arrowSp:getPositionX() + arrowSp:getContentSize().width + 10, attriLb:getPositionY())
                cell:addChild(nextValueLb)
            end
            attriLbPosY = attriLbPosY - attriLb:getContentSize().height - self.attriOffy
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccScrollEnable" then
    end
end

function tankSkinDialog:getAttributeContentHeight()
    if self.attriContentHeight == nil then
        self.attriOffy = 10
        local iphoneType = G_getIphoneType()
        if iphoneType == G_iphone5 or iphoneType == G_iphoneX then
            self.attriOffy = 30
        end
        self.attriContentHeight = 2 * self.attriOffy
        local tankId, skinId = self:getSelectSkin()
        local cfg = tankSkinCfg.skinCfg[skinId]
        for k, v in pairs(cfg.attType) do
            local attriNameStr = tankSkinVoApi:getAttributeNameStr(v)
            local attriLb = GetTTFLabelWrap(attriNameStr, self.attriFontSize, CCSizeMake(self.attriFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            self.attriContentHeight = self.attriContentHeight + attriLb:getContentSize().height
        end
        self.attriContentHeight = self.attriContentHeight + (SizeOfTable(cfg.attType) - 1) * self.attriOffy
        if cfg.restrain and cfg.restrain > 0 then --有克制关系
            local attriNameStr = tankSkinVoApi:getAttributeNameStr("restrain", cfg.restrain)
            local attriLb = GetTTFLabelWrap(attriNameStr, self.attriFontSize, CCSizeMake(self.attriFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            self.attriContentHeight = self.attriContentHeight + attriLb:getContentSize().height + self.attriOffy
        end
    end
    return self.attriContentHeight
end

function tankSkinDialog:leftTankPage()
    if self.maxTankPage <= 1 then
        do return end
    end
    if self.tankTurning == true then
        do return end
    end
    local nextPage = self.tankPage - 1
    if nextPage <= 0 then
        nextPage = self.maxTankPage
    end
    self.tankTurning = true
    self:refreshMagnifier(false)
    local newItem = self.tankSpTb[nextPage]
    local item = self.tankSpTb[self.tankPage]
    newItem:setPosition(self.leftTankPosX, self.tankPosY)
    item:setPosition(self.centerTankPosX, self.tankPosY)
    newItem:setVisible(true)
    local function turnEnd()
        self.tankTurning = false
        self.tankPage = nextPage
        item:setPosition(10000, 0)
        item:setVisible(false)
        self:refreshMagnifier(true)
        self:initSkinLayer()
    end
    local mvTo1 = CCMoveTo:create(self.turnInterval, ccp(self.rightTankPosX, self.tankPosY))
    local mvTo2 = CCMoveTo:create(self.turnInterval, ccp(self.centerTankPosX, self.tankPosY))
    local callFunc = CCCallFuncN:create(turnEnd)
    
    local acArr = CCArray:create()
    acArr:addObject(mvTo1)
    acArr:addObject(callFunc)
    local seq = CCSequence:create(acArr)
    item:runAction(seq)
    
    local acArr1 = CCArray:create()
    acArr1:addObject(mvTo2)
    local seq1 = CCSequence:create(acArr1)
    newItem:runAction(seq1)
end

function tankSkinDialog:rightTankPage()
    if self.maxTankPage <= 1 then
        do return end
    end
    if self.tankTurning == true then
        do return end
    end
    local nextPage = self.tankPage + 1
    if nextPage > self.maxTankPage then
        nextPage = 1
    end
    self.tankTurning = true
    self:refreshMagnifier(false)
    local newItem = self.tankSpTb[nextPage]
    local item = self.tankSpTb[self.tankPage]
    newItem:setPosition(self.rightTankPosX, self.tankPosY)
    item:setPosition(self.centerTankPosX, self.tankPosY)
    newItem:setVisible(true)
    local function turnEnd()
        self.tankTurning = false
        self.tankPage = nextPage
        item:setPosition(10000, 0)
        item:setVisible(false)
        self:refreshMagnifier(true)
        self:initSkinLayer()
    end
    local mvTo1 = CCMoveTo:create(self.turnInterval, ccp(self.leftTankPosX, self.tankPosY))
    local mvTo2 = CCMoveTo:create(self.turnInterval, ccp(self.centerTankPosX, self.tankPosY))
    local callFunc = CCCallFuncN:create(turnEnd)
    
    local acArr = CCArray:create()
    acArr:addObject(mvTo1)
    acArr:addObject(callFunc)
    local seq = CCSequence:create(acArr)
    item:runAction(seq)
    
    local acArr1 = CCArray:create()
    acArr1:addObject(mvTo2)
    local seq1 = CCSequence:create(acArr1)
    newItem:runAction(seq1)
end

function tankSkinDialog:leftSkinPage()
    if self.maxSkinPage <= 3 then
        do return end
    end
    if self.skinTurning == true then
        do return end
    end
    local nextPage = self.skinPage - 1
    if nextPage <= 0 then
        nextPage = self.maxSkinPage
    end
    local leftPage = self.skinPage - math.ceil(self.displayNum / 2)
    if leftPage < 1 then
        leftPage = leftPage + self.maxSkinPage
    end
    
    self.skinTurning = true
    
    local leftItem = self.skinSpTb[leftPage]
    leftItem:setPosition(self.leftDisplayCfg[1])
    leftItem:setScale(self.leftDisplayCfg[2])
    leftItem:setVisible(true)
    table.insert(self.displayTb, 1, leftPage)
    for k = 1, self.displayNum + 1 do
        local page = self.displayTb[k]
        local skinSp = tolua.cast(self.skinSpTb[page], "CCSprite")
        local targetPos, targetScale, fadeRate
        if k == (self.displayNum + 1) then
            targetPos, targetScale, fadeRate = self.rightDisplayCfg[1], self.rightDisplayCfg[2], (self.rightDisplayCfg[3] or 1)
        else
            targetPos, targetScale, fadeRate = self.displayCfg[k][1], self.displayCfg[k][2], (self.displayCfg[k][3] or 1)
        end
        local function moveCallBack()
            if k == (self.displayNum + 1) then
                self.skinPage = nextPage
                self:resetSkinDisplayTb()
                skinSp:setPosition(10000, 0)
                skinSp:setVisible(false)
                self.skinTurning = false
                self:refreshTankSkinDetail(true)
            end
        end
        self:runSkinPageAction(skinSp, targetPos, targetScale, fadeRate, moveCallBack)
    end
end

function tankSkinDialog:rightSkinPage()
    if self.maxSkinPage <= 3 then
        do return end
    end
    if self.skinTurning == true then
        do return end
    end
    local nextPage = self.skinPage + 1
    if nextPage > self.maxSkinPage then
        nextPage = 1
    end
    local rightPage = self.skinPage + math.ceil(self.displayNum / 2)
    if rightPage > self.maxSkinPage then
        rightPage = rightPage - self.maxSkinPage
    end
    
    self.skinTurning = true
    
    local rightItem = self.skinSpTb[rightPage]
    rightItem:setPosition(self.rightDisplayCfg[1])
    rightItem:setScale(self.rightDisplayCfg[2])
    rightItem:setVisible(true)
    table.insert(self.displayTb, rightPage)
    for k = 1, self.displayNum + 1 do
        local page = self.displayTb[k]
        local skinSp = tolua.cast(self.skinSpTb[page], "CCSprite")
        local targetPos, targetScale, fadeRate
        if k == 1 then
            targetPos, targetScale, fadeRate = self.leftDisplayCfg[1], self.leftDisplayCfg[2], (self.leftDisplayCfg[3] or 1)
        else
            targetPos, targetScale, fadeRate = self.displayCfg[k - 1][1], self.displayCfg[k - 1][2], (self.displayCfg[k - 1][3] or 1)
        end
        local function moveCallBack()
            if k == 1 then
                self.skinPage = nextPage
                self:resetSkinDisplayTb()
                skinSp:setPosition(10000, 0)
                skinSp:setVisible(false)
                self.skinTurning = false
                self:refreshTankSkinDetail(true)
            end
        end
        self:runSkinPageAction(skinSp, targetPos, targetScale, fadeRate, moveCallBack)
    end
end

function tankSkinDialog:runSkinPageAction(sp, pos, scale, fadeRate, callback)
    local acArr = CCArray:create()
    local moveTo = CCMoveTo:create(self.turnInterval, pos)
    local scaleTo = CCScaleTo:create(self.turnInterval, scale)
    local fadeTo = CCFadeTo:create(self.turnInterval, 255 * fadeRate)
    acArr:addObject(moveTo)
    acArr:addObject(scaleTo)
    acArr:addObject(fadeTo)
    local swpanAc = CCSpawn:create(acArr)
    local function moveCallBack()
        if callback then
            callback()
        end
    end
    local func = CCCallFunc:create(moveCallBack)
    local seq = CCSequence:createWithTwoActions(swpanAc, func)
    sp:runAction(seq)
    local skinEquipBg, skinEquipLb = sp:getChildByTag(201), sp:getChildByTag(202)
    if skinEquipBg and skinEquipLb and tolua.cast(skinEquipBg, "CCSprite") and tolua.cast(skinEquipLb, "CCLabelTTF") then
        local fadeTo1 = CCFadeTo:create(self.turnInterval, 255 * fadeRate)
        skinEquipBg:runAction(fadeTo1)
        local fadeTo2 = CCFadeTo:create(self.turnInterval, 255 * fadeRate)
        skinEquipLb:runAction(fadeTo2)
    end
end

--刷新放大镜的显示
function tankSkinDialog:refreshMagnifier(visible)
    if self.magnifierNode then
        self.magnifierNode:setVisible(visible)
        local magnifierPos = ccp(self.tankViewSize.width / 2 + 100, G_VisibleSizeHeight - 135 - 290 + 80)
        if visible == false then
            self.magnifierNode:setPosition(9999, magnifierPos.y)
        else
            self.magnifierNode:setPosition(magnifierPos)
        end
    end
end

--升级皮肤或者使用皮肤的特效
function tankSkinDialog:playUpgradeOrUseEffect()
    local tankId, skinId = self:getSelectSkin()
    local tankSp = tolua.cast(self.tankSpTb[self.tankPage], "CCSprite")
    if tankSp == nil then
        do return end
    end
    self:removeUpgradeOrUseEffect()
    
    local tankPos = tankSp:getParent():convertToWorldSpace(ccp(tankSp:getPosition()))
    
    local actionLayer = CCLayer:create()
    self.mainLayer:addChild(actionLayer)
    self.actionLayer = actionLayer
    local tankEffectLayer = CCLayer:create()
    self.mainLayer:addChild(tankEffectLayer, 4)
    self.tankEffectLayer = tankEffectLayer
    local frameLayer = CCLayer:create()
    self.mainLayer:addChild(frameLayer, 5)
    self.frameLayer = frameLayer
    local lightPos, framePos = ccp(320, G_VisibleSizeHeight - 328), ccp(322, G_VisibleSizeHeight - 278)
    local lightCircleSp1 = CCSprite:createWithSpriteFrameName("tskin_lightcircle.png")
    lightCircleSp1:setPosition(lightPos)
    lightCircleSp1:setScale(3.06)
    lightCircleSp1:setOpacity(0)
    self.actionLayer:addChild(lightCircleSp1)
    local blendFunc1 = ccBlendFunc:new()
    blendFunc1.src = GL_ONE
    blendFunc1.dst = GL_ONE
    lightCircleSp1:setBlendFunc(blendFunc1)
    local function lightAction1()
        lightCircleSp1:setOpacity(255 * 0.2)
        local fadeAcArr = CCArray:create()
        local fadeTo1 = CCFadeTo:create(0.06, 255)
        local fadeTo2 = CCFadeTo:create(0.14, 0)
        local function lightEnd()
            lightCircleSp1:stopAllActions()
            lightCircleSp1:removeFromParentAndCleanup(true)
            lightCircleSp1 = nil
        end
        fadeAcArr:addObject(fadeTo1)
        fadeAcArr:addObject(fadeTo2)
        fadeAcArr:addObject(CCCallFunc:create(lightEnd))
        local fadeSeq = CCSequence:create(fadeAcArr)
        lightCircleSp1:runAction(fadeSeq)
        lightCircleSp1:runAction(CCScaleTo:create(0.2, 2.12))
    end
    lightCircleSp1:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.07), CCCallFunc:create(lightAction1)))
    
    local lightCircleSp2 = CCSprite:createWithSpriteFrameName("tskin_lightcircle.png")
    lightCircleSp2:setPosition(lightPos)
    lightCircleSp2:setScale(2.94)
    lightCircleSp2:setOpacity(255 * 0.2)
    self.actionLayer:addChild(lightCircleSp2)
    local blendFunc2 = ccBlendFunc:new()
    blendFunc2.src = GL_ONE
    blendFunc2.dst = GL_ONE
    lightCircleSp2:setBlendFunc(blendFunc2)
    local fadeAcArr = CCArray:create()
    local fadeTo1 = CCFadeTo:create(0.07, 255)
    local fadeTo2 = CCFadeTo:create(0.13, 0)
    local fadeTo3 = CCFadeTo:create(0.27, 255 * 0.7)
    local fadeTo4 = CCFadeTo:create(0.4, 0)
    local function lightEnd()
        lightCircleSp2:stopAllActions()
        lightCircleSp2:removeFromParentAndCleanup(true)
        lightCircleSp2 = nil
    end
    fadeAcArr:addObject(fadeTo1)
    fadeAcArr:addObject(fadeTo2)
    fadeAcArr:addObject(fadeTo3)
    fadeAcArr:addObject(fadeTo4)
    fadeAcArr:addObject(CCCallFunc:create(lightEnd))
    local fadeSeq = CCSequence:create(fadeAcArr)
    lightCircleSp2:runAction(fadeSeq)
    lightCircleSp2:runAction(CCScaleTo:create(0.2, 1.97))
    
    local function playUpFrame()
        local frameSp = CCSprite:createWithSpriteFrameName("tskin_saoguang1.png")
        local frameArr = CCArray:create()
        for k = 1, 12 do
            local nameStr = "tskin_saoguang"..k..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            frameArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(frameArr)
        animation:setDelayPerUnit(0.07)
        local animate = CCAnimate:create(animation)
        frameSp:setAnchorPoint(ccp(0.5, 0.5))
        frameSp:setPosition(framePos)
        frameSp:setScale(2)
        self.frameLayer:addChild(frameSp)
        
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        frameSp:setBlendFunc(blendFunc)
        
        local function frameEnd()
            frameSp:stopAllActions()
            frameSp:removeFromParentAndCleanup(true)
            frameSp = nil
        end
        frameSp:runAction(CCSequence:createWithTwoActions(animate, CCCallFunc:create(frameEnd)))
    end
    self.frameLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.07), CCCallFunc:create(playUpFrame)))
    
    local acTankSp = CCSprite:createWithSpriteFrameName(tankSkinVoApi:getSkinPic(skinId))
    acTankSp:setPosition(tankPos)
    acTankSp:setOpacity(0)
    self.tankEffectLayer:addChild(acTankSp)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    acTankSp:setBlendFunc(blendFunc)
    local tankAcArr = CCArray:create()
    local tankFadeTo1 = CCFadeTo:create(0.13, 255 * 0.7)
    local tankFadeTo2 = CCFadeTo:create(0.67, 0)
    local function tankFadeEnd()
        acTankSp:stopAllActions()
        acTankSp:removeFromParentAndCleanup(true)
        acTankSp = nil
        self:removeUpgradeOrUseEffect()
    end
    tankAcArr:addObject(CCDelayTime:create(0.47))
    tankAcArr:addObject(tankFadeTo1)
    tankAcArr:addObject(tankFadeTo2)
    tankAcArr:addObject(CCCallFunc:create(tankFadeEnd))
    local tankSeq = CCSequence:create(tankAcArr)
    acTankSp:runAction(tankSeq)
end

function tankSkinDialog:removeUpgradeOrUseEffect()
    if self.actionLayer then
        self.actionLayer:stopAllActions()
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer = nil
    end
    if self.tankEffectLayer then
        self.tankEffectLayer:stopAllActions()
        self.tankEffectLayer:removeFromParentAndCleanup(true)
        self.tankEffectLayer = nil
    end
    if self.frameLayer then
        self.frameLayer:stopAllActions()
        self.frameLayer:removeFromParentAndCleanup(true)
        self.frameLayer = nil
    end
end

function tankSkinDialog:dispose()
    spriteController:removePlist("public/tankSkin/tankSkin_images1.plist")
    spriteController:removeTexture("public/tankSkin/tankSkin_images1.png")
    spriteController:removePlist("public/tankSkin/tankSkin_image2.plist")
    spriteController:removeTexture("public/tankSkin/tankSkin_image2.png")
    spriteController:removePlist("public/decorate_special.plist")
    spriteController:removeTexture("public/decorate_special.png")
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    spriteController:removePlist("public/acydcz_images.plist")
    spriteController:removeTexture("public/acydcz_images.png")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
    spriteController:removePlist("public/tankSkin/tskin_effect.plist")
    spriteController:removeTexture("public/tankSkin/tskin_effect.png")
    self.skinTimeTipLb, self.skinTimerLb = nil, nil
    self.attriContentHeight = nil
    self.attriTvWidth, self.attriTvHeight = nil, nil
    self.displayCfg = nil
    self.rightDisplayCfg, self.leftDisplayCfg = nil, nil
    self.displayTb = nil
    self.skinTurning, self.tankTurning = nil, nil
    self.skinPage, self.maxSkinPage = nil, nil
    self.tankPage, self.maxTankPage = nil, nil
    self.turnInterval = nil
    self.tankSpTb = nil
    self.skinSpTb = nil
    self.skinLevelSp, self.skinLevelLb = nil, nil
    self.attriTv = nil
    self.tankId = nil
    self.mainLayer, self.skinLayer = nil, nil
    self.tankPageClipper, self.skinPageClipper = nil, nil
    self.tankList, self.skinList = nil, nil
    self.tankGroupTb = nil
    self.detailBtn = nil
    self.leftTankArrowBtn, self.rightTankArrowBtn = nil, nil
    self.leftSkinArrowBtn, self.rightSkinArrowBtn = nil, nil
    self.upgradeBtn, self.upgradeMenu = nil, nil
    self.removeBtn = nil
    self.useBtn = nil
    self.acquireBtn = nil
    self.magnifierNode = nil
    self.acquireTypeLb = nil
    if self.circelAc and self.circelAc.stop then
        self.circelAc:stop()
        self.circelAc = nil
    end
    self:removeUpgradeOrUseEffect()
end
