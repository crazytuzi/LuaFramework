acZnsdDialog = commonDialog:new()

function acZnsdDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acZnsdDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self.jlPlayerFlag = false
    self.keepTick = false
    self.url = G_downloadUrl("active/acZnsdBg.jpg")
    
    self.phoneType = G_getIphoneType()
    
    local function addRes()
        spriteController:addPlist("public/acJnqdImage.plist")
        spriteController:addTexture("public/acJnqdImage.png")
        spriteController:addPlist("public/vr_rechargeImages.plist")
        spriteController:addTexture("public/vr_rechargeImages.png")
    end
    G_addResource8888(addRes)
    
    local function realInitMainLayer()
        self:initMainLayer()
        self.keepTick = true
    end
    acZnjlVoApi:znjlGet(realInitMainLayer)
end

function acZnsdDialog:initMainLayer()
    --背景裁切层
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85))
    clipper:setAnchorPoint(ccp(0, 0))
    clipper:setPosition(0, 0)
    local stencil = CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1)
    clipper:setStencil(stencil) --遮罩
    self.bgLayer:addChild(clipper)
    self.clipper = clipper
    
    local function onLoadIcon(fn, mainBg)
        if self then
            if self.bgLayer and tolua.cast(self.bgLayer, "LuaCCScale9Sprite") and self.clipper and tolua.cast(self.clipper, "CCClippingNode") then
                -- local mainBgOffsetY = 85
                -- if self.phoneType == G_iphone5 then
                --     mainBgOffsetY = 50
                -- elseif self.phoneType == G_iphoneX then
                --     mainBgOffsetY = 0
                -- end
                mainBg:setAnchorPoint(ccp(0.5, 1))
                mainBg:setPosition(G_VisibleSizeWidth / 2, self.clipper:getContentSize().height)
                self.clipper:addChild(mainBg)
            end
        end
    end
    
    local webImage = LuaCCWebImage:createWithURL(self.url, onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local mainLayer = CCLayer:create()
    mainLayer:setPosition(0, 0)
    self.bgLayer:addChild(mainLayer, 4)
    self.mainLayer = mainLayer

    local timeBgHeight = 35
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBgHeight))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setOpacity(0)
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85)
    self.mainLayer:addChild(timeBg)
    
    local timeStr1 = acZnjlVoApi:getTimeStr()
    local timeStr2 = acZnjlVoApi:getRewardTimeStr()
    local lbRollView, timeLb, rewardLb = G_LabelRollView(CCSizeMake(timeBg:getContentSize().width - 30, 30), timeStr1, 20, kCCTextAlignmentCenter, G_ColorGreen, nil, timeStr2, G_ColorYellowPro3, 2, 2, 2, nil)
    lbRollView:setPosition(15, 3)--timeBg:getContentSize().height * 0.3)
    timeBg:addChild(lbRollView)
    self.timeLb = timeLb
    self.rTimeLb = rewardLb

    local function touchTip()
        local tabStr = {}
        for k = 1, 5 do
            local str = getlocal("activity_znsd_rule"..k)
            table.insert(tabStr, str)
        end
        local titleStr = getlocal("activity_ruleLabel")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    G_addMenuInfo(timeBg, self.layerNum, ccp(G_VisibleSizeWidth - 35, -30), nil, nil, 0.8, nil, touchTip, true)

    local topPosy = G_VisibleSizeHeight - 85 - timeBgHeight
    local topTitleHeight = 60
    local diskSpHeight = 534
    local middlePosy = G_VisibleSizeHeight - 85 - 720
    local downSpPosy = 25
    if self.phoneType == G_iphone5 then
        downSpPosy = 50
    elseif self.phoneType == G_iphoneX then
        downSpPosy = 70
    end

    local titleSp = CCSprite:createWithSpriteFrameName("acJnsdTitle.png")
    titleSp:setPosition(G_VisibleSizeWidth * 0.5, topPosy - topTitleHeight * 0.5)
    self.mainLayer:addChild(titleSp)

    for k = 1, 2 do
        local titleFlySp = CCSprite:createWithSpriteFrameName("vfirstrTitleFly.png")
        titleFlySp:setPosition(titleSp:getContentSize().width * 0.5 + (2 * k - 3) * (titleSp:getContentSize().width * 0.5 + titleFlySp:getContentSize().width * 0.4), titleSp:getContentSize().height * 0.5)
        if k == 2 then
            titleFlySp:setFlipX(true)
        end
        titleSp:addChild(titleFlySp)
    end

    local valueTipLb = GetTTFLabel(getlocal("xsjx_worth"), 24, true)
    valueTipLb:setAnchorPoint(ccp(0, 0.5))
    valueTipLb:setPosition(G_VisibleSizeWidth * 0.5 + 20, topPosy - topTitleHeight - diskSpHeight * 0.5)
    self.mainLayer:addChild(valueTipLb)
    --G_vrgoldnumber
    local rewardValue = acZnjlVoApi:getRewardValue()
    local valueLbScale = 0.8
    local valueLb = GetBMLabel(rewardValue, G_vrgoldnumber, 22)
    valueLb:setScale(valueLbScale)
    valueLb:setAnchorPoint(ccp(0.5, 1))
    valueLb:setPosition(G_VisibleSizeWidth * 0.5,topPosy - topTitleHeight - diskSpHeight * 0.5 - 36)
    self.mainLayer:addChild(valueLb)

    local sdTipLb1 = GetTTFLabelWrap(getlocal("activity_znsd_tip1"), 20, CCSizeMake(G_VisibleSizeWidth - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    sdTipLb1:setAnchorPoint(ccp(0.5,1))
    sdTipLb1:setColor(ccc3(255,222,190))
    sdTipLb1:setPosition(G_VisibleSizeWidth *0.5,topPosy - topTitleHeight - diskSpHeight - 20)
    self.mainLayer:addChild(sdTipLb1)

    local jlPlayerStr = acZnjlVoApi:getJlPlayerShowStr()
    local jlPlayerLb = GetTTFLabelWrap(jlPlayerStr, 22, CCSizeMake(G_VisibleSizeWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    jlPlayerLb:setAnchorPoint(ccp(0.5, 1))
    jlPlayerLb:setColor(G_ColorYellowPro3)
    jlPlayerLb:setPosition(G_VisibleSizeWidth / 2, topPosy - topTitleHeight - diskSpHeight - 50 )
    self.mainLayer:addChild(jlPlayerLb, 2)
    self.jlPlayerLb = jlPlayerLb

    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("acJnsdBorder.png", CCRect(25, 25, 1, 1), function()end)
    downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,210))
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setPosition(G_VisibleSizeWidth * 0.5,downSpPosy)
    self.mainLayer:addChild(downBg)
    local downBgWidth,downBgHeight = downBg:getContentSize().width,downBg:getContentSize().height

    for i=1,2 do
        local downTitleBg = CCSprite:createWithSpriteFrameName("acJnsdTitleBg.png")
        downTitleBg:setPosition(downBgWidth * 0.5 + (2 * i - 3) * downTitleBg:getContentSize().width * 0.5, downBgHeight + downTitleBg:getContentSize().height * 0.5)
        if i == 2 then
            downTitleBg:setFlipX(true)
        end
        downBg:addChild(downTitleBg)
    end
    local downTitle = GetTTFLabel(getlocal("activity_znjl_dailyReward"),24,true)
    downTitle:setPosition(downBgWidth * 0.5, downBgHeight + 32)
    downTitle:setColor(G_ColorYellowPro2)
    downBg:addChild(downTitle)
    
    local downTipLb = GetTTFLabel(getlocal("activity_znsd_tip2",{acZnjlVoApi:IsRechargeReturnNum()}),20)
    downTipLb:setAnchorPoint(ccp(0.5,1))
    downTipLb:setColor(ccc3(251,189,81))
    if downBgWidth - 10 < downTipLb:getContentSize().width then
        downTipLb:setScale((downBgWidth - 10)/ downTipLb:getContentSize().width)
    end
    downTipLb:setPosition( downBgWidth * 0.5, downBgHeight - 12)
    downBg:addChild(downTipLb)
    self.downTipLb = downTipLb

    local rewardList = acZnjlVoApi:getLuckyReward()
    local r=diskSpHeight * 0.5 - 64  --半径
    local rewardNum=#rewardList
    local angleOffset=2 * math.pi/rewardNum     --偏移角度
    local centerPosx,centerPosy = G_VisibleSizeWidth * 0.5, topPosy - topTitleHeight - diskSpHeight * 0.5 - 2
    for k, v in pairs(rewardList) do
        local angle=angleOffset*(k - 1)
        local relativeX=math.sin(angle)*r       --相对于圆心的x
        local relativeY=math.cos(angle)*r  
        local realPos = ccp(centerPosx + relativeX,centerPosy + relativeY)

        local function showPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
        end
        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
        rewardSp:setScale(75 / rewardSp:getContentSize().width)
        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        rewardSp:setAnchorPoint(ccp(0.5, 0.5))
        rewardSp:setPosition(realPos)
        self.mainLayer:addChild(rewardSp, 3)
        
        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 22)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setScale(1 / scale)
        numLb:setPosition(ccp(rewardSp:getContentSize().width - 5, 2))
        rewardSp:addChild(numLb, 3)
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
        numBg:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
        numBg:setOpacity(150)
        rewardSp:addChild(numBg, 2)
    end


    local iconSize, iconSpaceX, iconSpaceY = 80, 40, 10
    local firstPosX = (downBgWidth - 4 * iconSize - 3 * iconSpaceX) / 2
    local dailyRewardList = acZnjlVoApi:getDailyReward()
    for k, v in pairs(dailyRewardList) do
        local posX = firstPosX + (k - 1) % 4 * (iconSize + iconSpaceX)
        local posY = 164
        
        local function showPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
        end
        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
        rewardSp:setScale(iconSize / rewardSp:getContentSize().width)
        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        rewardSp:setAnchorPoint(ccp(0, 1))
        rewardSp:setPosition(posX, posY)
        downBg:addChild(rewardSp)
        
        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 22)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setScale(1 / scale)
        numLb:setPosition(ccp(rewardSp:getContentSize().width - 5, 2))
        rewardSp:addChild(numLb, 3)
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
        numBg:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
        numBg:setOpacity(150)
        rewardSp:addChild(numBg, 2)
    end

    local function getRewardHandler()
        local flag = acZnjlVoApi:hasReward()
        if flag == true then
            do return end
        end
        local function callback()
            self:refresh()
            local rewardList = acZnjlVoApi:getDailyReward()
            --加奖励
            for k, v in pairs(rewardList) do
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            end
            --奖励展示
            G_showRewardTip(rewardList, true)
        end
        acZnjlVoApi:getRewardRequest(callback)
    end
    self.getItem, self.getMenu = G_createBotton(downBg, ccp(downBgWidth * 0.5, 40), {getlocal("daily_scene_get"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", getRewardHandler, 0.7, -(self.layerNum - 1) * 20 - 4, 3)

    local function onConfirmRecharge()
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    self.rechargeItem, self.rechargeMenu = G_createBotton(downBg, ccp(downBgWidth * 0.5, 40), {getlocal("recharge"), 25}, "creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png", onConfirmRecharge, 0.7, -(self.layerNum - 1) * 20 - 4, 3)

    self:refresh()
end

function acZnsdDialog:refresh()
    if acZnjlVoApi:isRewardTime() == true then --领奖时间不可以领取每日福利
        if self.getItem then
            self.getItem:setEnabled(false)
            self.rechargeItem:setEnabled(false)

            local strLb = tolua.cast(self.getItem:getChildByTag(101), "CCLabelTTF")
            if strLb then
                strLb:setString(getlocal("serverwarteam_all_end"))
            end
        end
    else
        if self.getItem then
            local btnStr = ""
            local flag,rewardFlag = acZnjlVoApi:hasReward()
            -- print("rewardFlag===========>>>>>>",rewardFlag,flag)
            self.rechargeItem:setEnabled(true)
            self.rechargeItem:setVisible(true)
            self.getItem:setEnabled(false)
            self.getItem:setVisible(false)
            if flag == true then
                self.getItem:setEnabled(false)
                self.getItem:setVisible(true)
                self.rechargeItem:setEnabled(false)
                self.rechargeItem:setVisible(false)
                btnStr = getlocal("activity_hadReward")
            elseif rewardFlag == 2 then
                self.getItem:setEnabled(true)
                self.getItem:setVisible(true)
                self.rechargeItem:setEnabled(false)
                self.rechargeItem:setVisible(false)
                btnStr = getlocal("daily_scene_get")
            end
            local strLb = tolua.cast(self.getItem:getChildByTag(101), "CCLabelTTF")
            if strLb then
                strLb:setString(btnStr)
            end
        end
        if self.downTipLb then
            self.downTipLb:setString(getlocal("activity_znsd_tip2",{acZnjlVoApi:IsRechargeReturnNum()}))
        end
    end
end

function acZnsdDialog:refreshJlPlayerLb()
    if self.jlPlayerLb then
        local jlPlayerStr = acZnjlVoApi:getJlPlayerShowStr()
        self.jlPlayerLb:setString(jlPlayerStr)
    end
end

function acZnsdDialog:tick()
    if self.keepTick == false then
        do return end
    end
    if acZnjlVoApi:isEnd() == true then
        self:close()
        do return end
    end
    if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acZnjlVoApi:getTimeStr())
    end
    if self.rTimeLb and tolua.cast(self.rTimeLb, "CCLabelTTF") then
        self.rTimeLb:setString(acZnjlVoApi:getRewardTimeStr())
    end
    
    if acZnjlVoApi:isToday() == false then
        acZnjlVoApi:resetDailyReward()
        self:refresh()
    end
    --领奖时间不能参与活动，所以需要刷新一下按钮
    if acZnjlVoApi:isRewardTime() == true then
        self:refresh()
    end
    --可以拉取锦鲤的名单
    local jlPlayer = acZnjlVoApi:getJlPlayer()
    if acZnjlVoApi:canPullJlPlayer() == true and jlPlayer == nil and self.jlPlayerFlag ~= true then
        self.jlPlayerFlag = true
        local function callback()
            self:refreshJlPlayerLb() --刷新锦鲤名单的显示
        end
        acZnjlVoApi:znjlGet(callback)
    end
end

function acZnsdDialog:dispose()
    self.downTipLb = nil
    self.timeLb = nil
    self.rTimeLb = nil
    self.jlPlayerLb = nil
    self.jlPlayerFlag = nil
    self.clipper = nil
    self.keepTick = nil
    spriteController:removePlist("public/acJnqdImage.plist")
    spriteController:removeTexture("public/acJnqdImage.png")
    spriteController:removePlist("public/vr_rechargeImages.plist")
    spriteController:removeTexture("public/vr_rechargeImages.png")
end
