armorMatrixTPSmallDialog = smallDialog:new()

function armorMatrixTPSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function armorMatrixTPSmallDialog:showTPDialog(id, tankPos, layerNum, isUpgrade)
    local sd = armorMatrixTPSmallDialog:new()
    sd:initTPDialog(id, tankPos, layerNum, isUpgrade)
    return sd
end

function armorMatrixTPSmallDialog:initTPDialogUI(id, tankPos, isUpgrade)
    if self.bgLayer and tolua.cast(self.bgLayer, "CCNode") then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    
    local mid, level = armorMatrixVoApi:getMidAndLevelById(id)
    if mid == nil then --突破成功后，参数id的含义就变成了 part
        mid, id, level = armorMatrixVoApi:getEquipedData(tankPos, id)
    end
    local cfg = armorMatrixVoApi:getCfgByMid(mid)
    local armorCfg = armorMatrixVoApi:getArmorCfg()
    local isMaxLevel = false
    if level >= armorCfg.upgradeMaxLv[cfg.quality] then
        isMaxLevel = true
    end
    
    if isUpgrade == true and isMaxLevel == true then
        self.bgSize = CCSizeMake(550, 385)
    else
        self.bgSize = CCSizeMake(550, 635)
    end
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png", CCRect(130, 50, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local function onCloseBtn()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtn = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn.png", onCloseBtn)
    closeBtn:setPosition(ccp(0, 0))
    closeBtn:setAnchorPoint(CCPointMake(0, 0))
    local closeMenu = CCMenu:createWithItem(closeBtn)
    closeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    closeMenu:setPosition(ccp(self.bgSize.width - closeBtn:getContentSize().width, self.bgSize.height - closeBtn:getContentSize().height))
    self.bgLayer:addChild(closeMenu, 2)
    
    local titleLb = GetTTFLabelWrap(getlocal(cfg.name), 35, CCSizeMake(self.bgSize.width - 160, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgSize.height - 50))
    local color = armorMatrixVoApi:getColorByQuality(cfg.quality)
    titleLb:setColor(color)
    self.bgLayer:addChild(titleLb, 1)
    
    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 85))
    self.bgLayer:addChild(lineSprite, 1)
    lineSprite:setScaleX((self.bgSize.width - 60) / lineSprite:getContentSize().width)
    
    local startH = self.bgSize.height - 100
    
    local iconSp = armorMatrixVoApi:getArmorMatrixIcon(mid, 100, 90, function()end, level)
    iconSp:setAnchorPoint(ccp(0, 0.5))
    iconSp:setPosition(30, startH - 60)
    local scale = 120 / iconSp:getContentSize().width
    iconSp:setScale(scale)
    self.bgLayer:addChild(iconSp)
    armorMatrixVoApi:addLightEffect(iconSp, mid)
    
    local lvLabel = tolua.cast(iconSp:getChildByTag(2001), "CCLabelTTF")
    if lvLabel then
        lvLabel:setScale(1 / scale)
    end
    local lvBg = tolua.cast(iconSp:getChildByTag(2002), "CCSprite")
    if(lvBg)then
        lvBg:setScaleX((iconSp:getContentSize().width - 20) / lvBg:getContentSize().width * 1 / scale)
        lvBg:setScaleY(lvLabel:getContentSize().height / lvBg:getContentSize().height * 1 / scale)
    end
    
    local lineSp = CCSprite:createWithSpriteFrameName("amPointLine.png")
    lineSp:setScaleX(1 / scale * 350 / lineSp:getContentSize().width)
    iconSp:addChild(lineSp)
    lineSp:setAnchorPoint(ccp(0, 0.5))
    lineSp:setPosition(120, iconSp:getContentSize().height / 2)
    lineSp:setScaleY(1 / scale)
    
    local attrStr, value = armorMatrixVoApi:getAttrAndValue(mid, level)
    local iconDesLb1 = GetTTFLabel(attrStr, 25)
    iconDesLb1:setAnchorPoint(ccp(0, 0.5))
    iconDesLb1:setPosition(120, iconSp:getContentSize().height / 2 + 30)
    iconSp:addChild(iconDesLb1)
    iconDesLb1:setScale(1 / scale)
    
    local valueLb = GetTTFLabel("+" .. value .. "%", 25)
    valueLb:setAnchorPoint(ccp(0, 0.5))
    valueLb:setPosition(ccp(iconDesLb1:getContentSize().width + 10, iconDesLb1:getContentSize().height / 2))
    iconDesLb1:addChild(valueLb, 1)
    valueLb:setColor(G_ColorYellowPro)
    
    local iconDesLb2 = GetTTFLabelWrap(getlocal("armorMatrix_deploy_des", {tankPos}), 25, CCSizeMake(self.bgSize.width - 220, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    iconDesLb2:setAnchorPoint(ccp(0, 0.5))
    iconDesLb2:setPosition(120, iconSp:getContentSize().height / 2 - 30)
    iconSp:addChild(iconDesLb2)
    iconDesLb2:setScale(1 / scale)
    
    startH = startH - 130
    
    local desBgH = 100
    local desBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png", CCRect(50, 50, 1, 1), function()end)
    desBgSp:setContentSize(CCSizeMake(self.bgSize.width - 60, desBgH))
    desBgSp:ignoreAnchorPointForPosition(false)
    desBgSp:setAnchorPoint(ccp(0.5, 1))
    desBgSp:setPosition(ccp(self.bgSize.width / 2, startH))
    self.bgLayer:addChild(desBgSp)
    
    local descStr
    if isMaxLevel == true then
        if cfg.quality == 4 then
            local attValue = 0
            for k, v in pairs(armorCfg.matrixList) do
                if (cfg.quality + 1) == v.quality and v.part == cfg.part then
                    attValue = v.att[1] - value
                    break
                end
            end
            descStr = getlocal("armorMatrix_fullLevel_breakThrough_desc", { tostring(attValue), attrStr })
        else
            descStr = getlocal("armorMatrix_full_level")
        end
    else
        descStr = armorMatrixVoApi:getDescByMid(mid, level)
    end
    local desLb = GetTTFLabelWrap(descStr, 25, CCSizeMake(desBgSp:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    desBgSp:addChild(desLb)
    desLb:setAnchorPoint(ccp(0, 0.5))
    desLb:setPosition(15, desBgSp:getContentSize().height / 2)
    
    if isUpgrade == true and isMaxLevel == true then
    else
        startH = startH - desBgH - 10
        
        local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png")
        self.bgLayer:addChild(lineSp2)
        lineSp2:setPosition(self.bgSize.width / 2, startH)
        lineSp2:setScaleX((self.bgSize.width - 60) / lineSp2:getContentSize().width)
        
        local cmLabel = GetTTFLabel(getlocal("alien_tech_consume_material"), 25)
        local cmBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
        cmBg:setPosition(ccp(self.bgSize.width / 2 + 20, startH - cmLabel:getContentSize().height / 2 - 10))
        cmBg:setScaleY((cmLabel:getContentSize().height + 20) / cmBg:getContentSize().height)
        cmBg:setScaleX(self.bgSize.width / cmBg:getContentSize().width)
        self.bgLayer:addChild(cmBg)
        cmLabel:setColor(G_ColorGreen2)
        cmLabel:setPosition(self.bgSize.width / 2, startH - cmLabel:getContentSize().height / 2 - 10)
        self.bgLayer:addChild(cmLabel, 1)
        
        startH = cmLabel:getPositionY() - cmLabel:getContentSize().height / 2 - 10
        
        startH = startH - 10
        local itemPosTb = {}
        local isCanTP = true
        local itemTb
        if isUpgrade then
            local consumeTb = armorCfg["upgradeResource" .. cfg.quality][cfg.part]
            local tempTb = consumeTb[level + 1] or consumeTb[SizeOfTable(consumeTb)]
            if tempTb[2] > 0 then
                local pid = armorCfg.orangeUpgradeItemId
                itemTb = FormatItem({p = {[pid] = tempTb[2]}})
            end
            if itemTb == nil then
                itemTb = {}
            end
            local expItem = {name = getlocal("armorMatrix_name_exp"), num = tempTb[1], pic = "armorMatrixExp.png", desc = "armorMatrix_desc_exp", bgname = "equipBg_purple.png", type = "am", key = "exp"}
            table.insert(itemTb, 1, expItem)
        else
            itemTb = FormatItem(cfg.breakthrough.rw)
        end
        local iconSize = 100
        local itemCount = SizeOfTable(itemTb)
        local itemSpace = 80
        local iconStartX = (self.bgSize.width - (iconSize * itemCount + (itemCount - 1) * itemSpace)) / 2 + iconSize / 2
        for k, v in pairs(itemTb) do
            local icon
            if (v.type == "am" and v.key ~= "exp") or v.type == "se" or v.type == "pl" then
                icon = G_getItemIcon(v, iconSize, true, self.layerNum, nil, self.tv, nil, nil, nil, nil, true, true)
            else
                icon = G_getItemIcon(v, iconSize, false, self.layerNum, function() G_showNewPropInfo(self.layerNum + 1, true, true, nil, v) end)
            end
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            icon:setPosition(iconStartX + (k - 1) * (iconSize + itemSpace), startH - iconSize / 2)
            self.bgLayer:addChild(icon, 1)
            table.insert(itemPosTb, { x = icon:getPositionX(), y = icon:getPositionY() })
            local ownNum = 0
            if isUpgrade and v.id == nil then
                local armorMatrixInfo = armorMatrixVoApi:getArmorMatrixInfo()
                ownNum = armorMatrixInfo.exp or 0
            else
                ownNum = bagVoApi:getItemNumId(v.id)
            end
            local numLb = GetTTFLabel(FormatNumber(ownNum) .. "/" .. FormatNumber(v.num), 24)
            numLb:setAnchorPoint(ccp(0.5, 1))
            numLb:setPosition(icon:getPositionX(), icon:getPositionY() - iconSize / 2)
            if ownNum < v.num then
                numLb:setColor(G_ColorRed)
                isCanTP = false
            end
            v.needNum = v.num
            v.num = ownNum
            self.bgLayer:addChild(numLb, 1)
            if k == itemCount then
                startH = startH - iconSize - numLb:getContentSize().height
            end
        end
        
        startH = startH - 20
        
        local animFrame = { {10, 0.08}, {29, 0.08}, {10, 0.08} }
        local function createAnim(animId, callback, delayTimePlay)
            local animKey = "am_breakThroughEffect"
            local firstFrameSp = CCSprite:createWithSpriteFrameName(animKey .. animId .. "_1.png")
            local blendFunc = ccBlendFunc:new()
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE_MINUS_SRC_COLOR
            firstFrameSp:setBlendFunc(blendFunc)
            local frameArray = CCArray:create()
            for i = 1, animFrame[animId][1] do
                local frameName = animKey .. animId .. "_" .. i .. ".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
                if frame then
                    frameArray:addObject(frame)
                end
            end
            local animation = CCAnimation:createWithSpriteFrames(frameArray, animFrame[animId][2])
            local animate = CCAnimate:create(animation)
            local animArray = CCArray:create()
            if type(delayTimePlay) == "number" and delayTimePlay > 0 then
                firstFrameSp:setVisible(false)
                animArray:addObject(CCDelayTime:create(delayTimePlay))
                animArray:addObject(CCCallFunc:create(function() firstFrameSp:setVisible(true) end))
            end
            animArray:addObject(animate)
            animArray:addObject(CCCallFunc:create(function() if callback then callback() end end))
            local seq = CCSequence:create(animArray)
            return firstFrameSp, seq
        end
        
        local function breakthroughEffect(callback)
            local bgLayerPos = {
                x = self.bgLayer:getPositionX() - self.bgSize.width / 2, 
                y = self.bgLayer:getPositionY() - self.bgSize.height / 2
            }
            for k, v in pairs(itemPosTb) do
                local animSp, animSeq
                animSp, animSeq = createAnim(1, function()
                        animSp:removeFromParentAndCleanup(true)
                        animSp = nil
                end)
                -- animSp:setPosition(v.x, v.y)
                animSp:setPosition(bgLayerPos.x + v.x, bgLayerPos.y + v.y)
                -- self.bgLayer:addChild(animSp, 10)
                self.dialogLayer:addChild(animSp, 10)
                animSp:runAction(animSeq)
            end
            local animSp, animSeq
            animSp, animSeq = createAnim(2, function()
                    animSp:removeFromParentAndCleanup(true)
                    animSp = nil
            end, animFrame[1][1] * animFrame[1][2])
            -- animSp:setPosition(iconSp:getPositionX() + iconSp:getContentSize().width * scale / 2, iconSp:getPositionY())
            animSp:setPosition(bgLayerPos.x + iconSp:getPositionX() + iconSp:getContentSize().width * scale / 2, bgLayerPos.y + iconSp:getPositionY())
            animSp:setScale(120 / 88)
            -- self.bgLayer:addChild(animSp, 10)
            self.dialogLayer:addChild(animSp, 10)
            animSp:runAction(animSeq)
            
            local delayTime = animFrame[1][1] * animFrame[1][2] + 6 * animFrame[2][2]
            self.bgLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(function()
                    if callback then
                        callback()
                    end
            end)))
        end
        
        local btnScale = 0.8
        local function onButtonFunc()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if isCanTP == false then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage9033"), 30)
                do return end
            end
            local oldNum = playerVoApi:getPlayerPower()
            if isUpgrade then
                -- print("cjl ------->>> 升级")
                local function refreshCalback()
                    local newNum = playerVoApi:getPlayerPower()
                    G_showNumberChange(oldNum, newNum) -- 战斗力变化提示
                    for k, v in pairs(itemTb) do
                    	if not (isUpgrade and v.id == nil) then
                    		bagVoApi:useItemNumId(v.id, v.needNum)
                    	end
                    end
                    self:initTPDialogUI(id, tankPos, isUpgrade)
                end
                armorMatrixVoApi:armorUpgrade(id, 1, refreshCalback)
            else
                local function onSureTP()
                    -- print("cjl ------->>> 突破")
                    armorMatrixVoApi:armorMatrixTP(id, function()
                        local newNum = playerVoApi:getPlayerPower()
                        G_showNumberChange(oldNum, newNum) -- 战斗力变化提示
                    	for k, v in pairs(itemTb) do
	                    	if not (isUpgrade and v.id == nil) then
	                    		bagVoApi:useItemNumId(v.id, v.needNum)
	                    	end
	                    end
                        breakthroughEffect(function()
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_evolution_success"), 30)
                            self:initTPDialogUI(cfg.part, tankPos, true)
                        end)
                    end)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureTP, getlocal("dialog_title_prompt"), getlocal("armorMatrix_breakThroughOrange_tips"), nil, self.layerNum + 1)
            end
        end
        local btnStr = getlocal("breakthrough")
        if isUpgrade then
            btnStr = getlocal("hero_upgrade_x", {1})
        end
        local button = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onButtonFunc, 1, btnStr, 24 / btnScale)
        button:setScale(btnScale)
        local btnMenu = CCMenu:createWithItem(button)
        btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        btnMenu:setAnchorPoint(ccp(0.5, 0.5))
        btnMenu:setPosition(ccp(self.bgSize.width / 2, startH - button:getContentSize().height * btnScale / 2))
        self.bgLayer:addChild(btnMenu, 1)
    end
end

function armorMatrixTPSmallDialog:initTPDialog(id, tankPos, layerNum, isUpgrade)
    self.layerNum = layerNum
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self:initTPDialogUI(id, tankPos, isUpgrade)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function armorMatrixTPSmallDialog:dispose()
    self = nil
end