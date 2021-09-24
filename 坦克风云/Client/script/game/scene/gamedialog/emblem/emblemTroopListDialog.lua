--军徽部队列表面板
emblemTroopListDialog = commonDialog:new()

function emblemTroopListDialog:new()
    local nc = {
        troopList = nil, 
        troopNum = nil, 
    }
    setmetatable(nc, self)
    self.__index = self
    self.troopList = nil
    self.isShowBuyItem = nil --是否显示购买项
    
    spriteController:addPlist("public/squaredImgs.plist")
    spriteController:addTexture("public/squaredImgs.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

--设置或修改每个Tab页签
function emblemTroopListDialog:resetTab()
    self.panelLineBg:setVisible(false)
end

function emblemTroopListDialog:doUserHandler()
    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 100)
    self.bgLayer:addChild(titleBg, 1)
    local titleLb = GetTTFLabel(getlocal("emblem_troop_strengthReward"), 24, true)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
    titleBg:addChild(titleLb, 1)
    
    local maxStrength, tipStr = emblemTroopVoApi:getTroopCurMaxStrength()
    local barWidth, barHeight = 449, 26
    local barSp = CCSprite:createWithSpriteFrameName(type(tipStr) == "string" and "loadingYellowBar.png" or "loadingGreenBar.png")
    local progressBar = CCProgressTimer:create(barSp)
    progressBar:setMidpoint(ccp(0, 1))
    progressBar:setBarChangeRate(ccp(1, 0))
    progressBar:setType(kCCProgressTimerTypeBar)
    progressBar:setPercentage(0)
    progressBar:setScaleX(barWidth / progressBar:getContentSize().width)
    progressBar:setScaleY(barHeight / progressBar:getContentSize().height)
    local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
    progressBarBg:setContentSize(CCSizeMake(barWidth + 6, barHeight + 5))
    progressBarBg:setPosition(G_VisibleSizeWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 45)
    progressBar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressBar)
    self.bgLayer:addChild(progressBarBg)
    local progressLb = GetTTFLabel("", 22)
    progressLb:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressLb, 1)
    
    local function onRewardBtn()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local contentData = {}
        local cfg = emblemTroopVoApi:getTroopStrengthUnlockCfg()
        for k, v in pairs(cfg) do
            local desc = ""
            if v.reward then
                desc = FormatItem(v.reward)
            elseif v.refineMax then
                desc = getlocal("emblem_troop_unlockReward_desc1", {v.refineMax * 100})
            elseif v.unlock then
                local num = 1
                if type(v.unlock) == "table" then
                    num = SizeOfTable(v.unlock)
                end
                desc = getlocal("emblem_troop_unlockReward_desc2", {num})
            end
            contentData[k] = { v.allstrNeed, desc }
        end
        require "luascript/script/game/scene/gamedialog/emblem/emblemTroopSmallDialog"
        emblemTroopSmallDialog:showStrengthReward(self.layerNum + 1, getlocal("emblem_troop_strengthReward"), contentData, function()
                local _, strFlag = emblemTroopVoApi:getTroopCurMaxStrength()
                if type(tipStr) == "string" then
                    self.progressBar:removeFromParentAndCleanup(true)
                    local bar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("loadingYellowBar.png"))
                    bar:setMidpoint(ccp(0, 1))
                    bar:setBarChangeRate(ccp(1, 0))
                    bar:setType(kCCProgressTimerTypeBar)
                    bar:setPercentage(0)
                    bar:setScaleX(barWidth / bar:getContentSize().width)
                    bar:setScaleY(barHeight / bar:getContentSize().height)
                    bar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
                    progressBarBg:addChild(bar)
                    self.progressBar = bar
                end
                self:updateList()
        end)
    end
    local rewardBtn = GetButtonItem("friendBtn.png", "friendBtnDOwn.png", "friendBtn.png", onRewardBtn, 11)
    rewardBtn:setScale(0.7)
    rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
    local rewardMenu = CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(0, progressBarBg:getContentSize().height / 2))
    rewardMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    progressBarBg:addChild(rewardMenu, 1)
    
    self.progressBar = progressBar
    self.progressLb = progressLb
    self.rewardBtn = rewardBtn
    self:updateUI()
    
    local function onTouchInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = { getlocal("emblem_troop_list_infoTip1"), getlocal("emblem_troop_list_infoTip2") }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onTouchInfo, 12, nil, nil)
    infoItem:setAnchorPoint(ccp(1, 0.5))
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth - 25, titleBg:getPositionY() - titleBg:getContentSize().height / 2))
    infoBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoBtn)
    
    self:initListData()
end

function emblemTroopListDialog:initListData()
    self.troopList = emblemTroopVoApi:getEmblemTroopListWithSort()
    local buyNum = emblemTroopVoApi:getEmblemTroopBuyNum()
    if buyNum > 0 then
        self.isShowBuyItem = true
        table.insert(self.troopList, 1, {buyNum})
    else
        self.isShowBuyItem = nil
    end
    self.troopNum = 0
    if self.troopList then
        self.troopNum = math.ceil(SizeOfTable(self.troopList) / 2)
    end
end

function emblemTroopListDialog:updateUI()
    if self.rewardBtn and tolua.cast(self.rewardBtn, "CCNode") then
        if emblemTroopVoApi:isCanActiveStrengthReward() == true then
            G_addShake(self.rewardBtn)
        else
            self.rewardBtn:stopAllActions()
        end
    end
    local curStrength = emblemTroopVoApi:getTroopListMaxStrength()
    local maxStrength, tipStr = emblemTroopVoApi:getTroopCurMaxStrength()
    local percent = (curStrength / maxStrength) * 100
    if percent > 100 then
        percent = 100
    end
    if self.progressBar and tolua.cast(self.progressBar, "CCProgressTimer") then
        local progressBar = tolua.cast(self.progressBar, "CCProgressTimer")
        progressBar:setPercentage(percent)
    end
    if self.progressLb and tolua.cast(self.progressLb, "CCLabelTTF") then
        local progressLb = tolua.cast(self.progressLb, "CCLabelTTF")
        if type(tipStr) == "string" then
            progressLb:setString(tipStr)
        else
            progressLb:setString(curStrength .. "/" .. maxStrength)
        end
    end
end

--设置对话框里的tableView
function emblemTroopListDialog:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/emblem/emblemTroopImages.plist")
    spriteController:addTexture("public/emblem/emblemTroopImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 260))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 240)
    self.bgLayer:addChild(tvBg)
    
    self.tvWidth, self.tvHeight, self.cellHeight = tvBg:getContentSize().width, tvBg:getContentSize().height - 6, 356 + 20
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(0, 3)
    tvBg:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    
    if self.guideItem and otherGuideMgr:checkGuide(75) == false then
        otherGuideMgr:setGuideStepField(75, self.guideItem, true)
        otherGuideMgr:showGuide(75)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emblemTroopListDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.troopNum
    elseif fn == "tableCellSizeForIndex" then 
        return  CCSizeMake(self.tvWidth, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvWidth, self.cellHeight
        
        local function viewTroop(tag)
            if self and self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if tag == nil or tag == 0 then
                    local costItem = emblemTroopVoApi:getEmblemTroopCostItem()
                    if bagVoApi:getItemNumId(costItem.id) < costItem.num then
                        -- smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("notenoughprop"), 30)
                        local function onSureCallback()
                            activityAndNoteDialog:closeAllDialog()
                            allShopVoApi:showAllPropDialog(3, "gems", nil, 4, costItem.id)
                        end
                        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("emblem_troop_jumpShowTip"), false, onSureCallback)
                        do return end
                    end
                    local equipId = "e901" --暂定
                    local nameStr = getlocal("emblem_name_" .. equipId)
                    local costStr = getlocal("emblem_troop_buyTop", {costItem.num, costItem.name, nameStr})
                    local function onSureLogic()
                        emblemTroopVoApi:emblemTroopShopExchange("i2", 1, function() 
                                bagVoApi:useItemNumId(costItem.id, costItem.num)
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vip_tequanlibao_goumai_success"), 30)
                                self:updateList() 
                        end)
                    end
                    G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), costStr, false, onSureLogic)
                else
                    require "luascript/script/game/scene/gamedialog/emblem/emblemTroopDialog"
                    local td = emblemTroopDialog:new(self, tag)
                    local tbArr = {}
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("emblem_troop"), true, self.layerNum + 1)
                    sceneGame:addChild(dialog, self.layerNum + 1)
                    -- 引导下一步
                    if(otherGuideMgr and otherGuideMgr.isGuiding)then
                        otherGuideMgr:toNextStep()
                    end
                end
            end
        end
        
        local iconSpace = 20
        for i = 1, 2 do
            local index = (idx + 1) * 2
            if i == 1 then
                index = index - 1
            end
            if self.troopList[index] then
                local troopId = self.troopList[index].id
                local iconBg
                local function touchHandler(tag,fn,index)--hd,
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if tag and type(tag) == "function" then
                        tag = index
                    end
                    local function realHandler()
                        viewTroop(tag)
                    end
                    G_touchedItem(iconBg, realHandler, 0.9)
                end
                if self.isShowBuyItem == true and idx == 0 and troopId == nil then
                    iconBg = LuaCCSprite:createWithSpriteFrameName("em_troopBg.png", touchHandler)
                    local equipId = "e901" --暂定
                    local nameBgW = iconBg:getContentSize().width - 18
                    local nameStr = getlocal("emblem_name_" .. equipId)
                    local equipNameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(nameBgW - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                    local nameBgH = equipNameLb:getContentSize().height + 20
                    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("em_troopNameBg.png", CCRect(16, 5, 2, 2), function()end)
                    nameBg:setContentSize(CCSizeMake(nameBgW, nameBgH))
                    nameBg:setAnchorPoint(ccp(0.5, 1))
                    nameBg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height - 20)
                    iconBg:addChild(nameBg)
                    equipNameLb:setAnchorPoint(ccp(0.5, 0.5))
                    equipNameLb:setPosition(nameBgW / 2, nameBgH / 2)
                    nameBg:addChild(equipNameLb)
                    local equipPic = emblemTroopVoApi:getTroopIconPic(equipId, 0)
                    local icon = LuaCCSprite:createWithFileName(equipPic, viewTroop)
                    if icon == nil then
                        icon = LuaCCSprite:createWithFileName("public/emblem/icon/emblemIcon_e2.png", viewTroop)
                    end
                    icon:setAnchorPoint(ccp(0.5, 0.5))
                    icon:setPosition(ccp(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2 + 35))
                    iconBg:addChild(icon)
                    local oneSpace = 15
                    local startX = nil
                    for n = 1, 3 do
                        local colorIcon = CCSprite:createWithSpriteFrameName("emTroop_posColor_0.png")
                        if startX == nil then
                            startX = iconBg:getContentSize().width / 2 - colorIcon:getContentSize().width - oneSpace
                        end
                        colorIcon:setAnchorPoint(ccp(0.5, 0.5))
                        colorIcon:setPosition(ccp(startX, 130))
                        iconBg:addChild(colorIcon)
                        startX = startX + colorIcon:getContentSize().width + oneSpace
                    end
                    local addBtn = CCSprite:createWithSpriteFrameName("believerAddBtn.png")
                    addBtn:setPosition(iconBg:getContentSize().width / 2, 85)
                    addBtn:setColor(ccc3(135, 253, 139))
                    iconBg:addChild(addBtn)
                    
                    local costItem = emblemTroopVoApi:getEmblemTroopCostItem()
                    if costItem then
                        local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), function()end)
                        itemBg:setContentSize(CCSizeMake(iconBg:getContentSize().width - 20, 40))
                        itemBg:setAnchorPoint(ccp(0.5, 0))
                        itemBg:setPosition(iconBg:getContentSize().width / 2, 18)
                        itemBg:setOpacity(255 * 0.6)
                        iconBg:addChild(itemBg)
                        local costItemIcon = CCSprite:createWithSpriteFrameName(costItem.pic)
                        costItemIcon:setScale(itemBg:getContentSize().height / costItemIcon:getContentSize().height)
                        costItemIcon:setPosition(itemBg:getContentSize().width / 2 - 20, itemBg:getContentSize().height / 2)
                        itemBg:addChild(costItemIcon)
                        local costNumLb = GetTTFLabel(tostring(costItem.num), 24)
                        costNumLb:setAnchorPoint(ccp(0, 0.5))
                        costNumLb:setColor(G_ColorYellowPro)
                        costNumLb:setPosition(costItemIcon:getPositionX() + costItemIcon:getContentSize().width * costItemIcon:getScale() / 2 + 10, costItemIcon:getPositionY())
                        itemBg:addChild(costNumLb)
                    end
                else
                    iconBg = emblemTroopVoApi:getTroopIconById(troopId, touchHandler, true, true)
                    local troopVo = emblemTroopVoApi:getEmblemTroopData(troopId)
                    if troopVo then
                        if troopVo:checkIfBattled() == true then
                            local outBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                            outBg:setOpacity(120)
                            outBg:setContentSize(iconBg:getContentSize())
                            outBg:setPosition(getCenterPoint(iconBg))
                            iconBg:addChild(outBg)
                            local lbBg = CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
                            lbBg:setPosition(getCenterPoint(outBg))
                            lbBg:setScaleX((outBg:getContentSize().width - 30) / lbBg:getContentSize().width)
                            outBg:addChild(lbBg)
                            local lb = GetTTFLabelWrap(getlocal("emblem_battle"), 25, CCSizeMake(lbBg:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                            lb:setColor(G_ColorGreen)
                            lb:setPosition(lbBg:getPosition())
                            outBg:addChild(lb)
                        end
                    end
                end
                iconBg:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                iconBg:setPosition(cellW / 2 +  (i == 1 and - 1 or 1) * (iconBg:getContentSize().width + iconSpace) / 2, cellH / 2)
                if self.isShowBuyItem == true then
                    iconBg:setTag(index - 1)
                else
                    iconBg:setTag(index)
                end
                cell:addChild(iconBg)
                if index == 1 and i == 1 then
                    if otherGuideMgr:checkGuide(75) == false then
                        self.guideItem = iconBg
                    end
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

function emblemTroopListDialog:updateList()
    if self then
        self:initListData()
        if self.tv then
            self.tv:reloadData()
        end
        self:updateUI()
    end
end

function emblemTroopListDialog:tick()
end

function emblemTroopListDialog:dispose()
    self.isShowBuyItem = nil
    self.troopList = nil
    self.guideItem = nil
    self = nil
    spriteController:removePlist("public/emblem/emblemTroopImages.plist")
    spriteController:removeTexture("public/emblem/emblemTroopImages.png")
    spriteController:removePlist("public/squaredImgs.plist")
    spriteController:removeTexture("public/squaredImgs.png")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
end