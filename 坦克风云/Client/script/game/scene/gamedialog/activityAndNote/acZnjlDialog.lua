acZnjlDialog = commonDialog:new()

function acZnjlDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acZnjlDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self.jlPlayerFlag = false
    self.keepTick = false
    self.url = G_downloadUrl("active/znjlbg.jpg")
    
    self.phoneType = G_getIphoneType()
    
    local function addRes()
        spriteController:addPlist("public/acznjl_images.plist")
        spriteController:addTexture("public/acznjl_images.png")
    end
    G_addResource8888(addRes)
    
    local function realInitMainLayer()
        self:initMainLayer()
        self.keepTick = true
    end
    acZnjlVoApi:znjlGet(realInitMainLayer)
end

function acZnjlDialog:initMainLayer()
    --背景裁切层
    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 90))
    clipper:setAnchorPoint(ccp(0, 0))
    clipper:setPosition(0, 0)
    local stencil = CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1)
    clipper:setStencil(stencil) --遮罩
    self.bgLayer:addChild(clipper)
    self.clipper = clipper
    
    local function onLoadIcon(fn, mainBg)
        if self then
            if self.bgLayer and tolua.cast(self.bgLayer, "LuaCCScale9Sprite") and self.clipper and tolua.cast(self.clipper, "CCClippingNode") then
                local mainBgOffsetY = 85
                if self.phoneType == G_iphone5 then
                    mainBgOffsetY = 50
                elseif self.phoneType == G_iphoneX then
                    mainBgOffsetY = 0
                end
                mainBg:setAnchorPoint(ccp(0.5, 1))
                mainBg:setPosition(G_VisibleSizeWidth / 2, self.clipper:getContentSize().height + mainBgOffsetY)
                self.clipper:addChild(mainBg)
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage = LuaCCWebImage:createWithURL(self.url, onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local mainLayer = CCLayer:create()
    mainLayer:setPosition(0, 0)
    self.bgLayer:addChild(mainLayer, 4)
    self.mainLayer = mainLayer
    
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 80))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setOpacity(255 * 0.6)
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85)
    self.mainLayer:addChild(timeBg)
    
    local timeStr1 = acZnjlVoApi:getTimeStr()
    local timeStr2 = acZnjlVoApi:getRewardTimeStr()
    local lbRollView, timeLb, rewardLb = G_LabelRollView(CCSizeMake(timeBg:getContentSize().width - 30, 30), timeStr1, 21, kCCTextAlignmentCenter, G_ColorGreen, nil, timeStr2, G_ColorYellowPro3, 2, 2, 2, nil)
    lbRollView:setPosition(15, timeBg:getContentSize().height - 40)
    timeBg:addChild(lbRollView)
    self.timeLb = timeLb
    self.rTimeLb = rewardLb
    
    local function touchTip()
        local tabStr = {}
        for k = 1, 5 do
            local str = getlocal("activity_znjl_rule"..k)
            table.insert(tabStr, str)
        end
        local titleStr = getlocal("activity_ruleLabel")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    G_addMenuInfo(timeBg, self.layerNum, ccp(G_VisibleSizeWidth - 35, timeBg:getContentSize().height / 2 + 5), nil, nil, 1, nil, touchTip, true)
    
    local titleFontSize, smallFontSize = 24, 22
    local jlTitlePosY, dailyTitlePosY = G_VisibleSizeHeight - 155, 280
    local iconSize, iconSpaceX, iconSpaceY = 90, 40, 10
    local offsety1, offsety2, offsety3, offsety4 = 45, 10, 50, 5
    local btnPos = ccp(G_VisibleSizeWidth / 2, 60)
    if self.phoneType == G_iphone5 then
        jlTitlePosY = G_VisibleSizeHeight - 180
        dailyTitlePosY = 330
        iconSpaceY = 30
        offsety1, offsety2, offsety3 = 55, 20, 60
        btnPos = ccp(G_VisibleSizeWidth / 2, 70)
    elseif self.phoneType == G_iphoneX then
        jlTitlePosY = G_VisibleSizeHeight - 220
        dailyTitlePosY = 350
        iconSpaceY = 40
        offsety1, offsety2, offsety3 = 70, 25, 65
        btnPos = ccp(G_VisibleSizeWidth / 2, 70)
    end
    
    local jlTitleLb = GetTTFLabel(getlocal("activity_znjl_jltitle"), titleFontSize, true)
    jlTitleLb:setPosition(G_VisibleSizeWidth / 2, jlTitlePosY)
    jlTitleLb:setColor(G_ColorYellowPro3)
    self.mainLayer:addChild(jlTitleLb)
    
    local jlTipBgSize = CCSizeMake(G_VisibleSizeWidth - 120, 70)
    local jlTipBgPosY = jlTitlePosY - jlTitleLb:getContentSize().height / 2 - offsety1
    local jlTipStr = getlocal("activity_znjl_tip1")
    local jlTipLb = GetTTFLabelWrap(jlTipStr, smallFontSize, CCSizeMake(jlTipBgSize.width - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    local lbWidth, lbHeight = jlTipBgSize.width - 20, jlTipLb:getContentSize().height + 10
    if jlTipBgSize.height > lbHeight then
        jlTipBgSize.height = lbHeight
        jlTipLb:setAnchorPoint(ccp(0, 0.5))
        jlTipLb:setColor(G_ColorYellowPro3)
        jlTipLb:setPosition((G_VisibleSizeWidth - lbWidth) / 2, jlTipBgPosY)
        self.mainLayer:addChild(jlTipLb, 2)
    else
        local jlTipTv = G_LabelTableViewNew(CCSizeMake(lbWidth, jlTipBgSize.height - 10), jlTipStr, smallFontSize, kCCTextAlignmentLeft, G_ColorYellowPro3)
        jlTipTv:setAnchorPoint(ccp(0, 0))
        jlTipTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        jlTipTv:setMaxDisToBottomOrTop(100)
        jlTipTv:setPosition((G_VisibleSizeWidth - lbWidth) / 2, jlTipBgPosY - jlTipBgSize.height / 2 + 5)
        self.mainLayer:addChild(jlTipTv, 2)
    end
    local jlTipBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    jlTipBg:setScaleX(jlTipBgSize.width / jlTipBg:getContentSize().width)
    jlTipBg:setScaleY(jlTipBgSize.height / jlTipBg:getContentSize().height)
    jlTipBg:setPosition(G_VisibleSizeWidth / 2, jlTipBgPosY)
    self.mainLayer:addChild(jlTipBg)
    
    --好礼总价值
    local rewardValueBg = CCSprite:createWithSpriteFrameName("acznjl_rvbg.png")
    rewardValueBg:setAnchorPoint(ccp(0.5, 1))
    rewardValueBg:setPosition(G_VisibleSizeWidth / 2, jlTipBgPosY - jlTipBgSize.height / 2 - offsety4)
    self.mainLayer:addChild(rewardValueBg)
    local valueTipLb = GetTTFLabel(getlocal("xsjx_worth"), 24, true)
    valueTipLb:setAnchorPoint(ccp(0, 0.5))
    rewardValueBg:addChild(valueTipLb)
    local goldSp = CCSprite:createWithSpriteFrameName("iconGoldNew2.png")
    goldSp:setAnchorPoint(ccp(0, 0.5))
    rewardValueBg:addChild(goldSp)
    local rewardValue = acZnjlVoApi:getRewardValue()
    local valueLbScale = 0.6
    local valueLb = GetBMLabel(rewardValue, G_GoldFontSrc, 22)
    valueLb:setAnchorPoint(ccp(0, 0.5))
    valueLb:setScale(valueLbScale)
    rewardValueBg:addChild(valueLb)
    local twidth = valueTipLb:getContentSize().width + goldSp:getContentSize().width + valueLb:getContentSize().width * valueLbScale + 20
    local vtlPosX = (rewardValueBg:getContentSize().width - twidth) / 2
    valueTipLb:setPosition(vtlPosX, rewardValueBg:getContentSize().height / 2)
    goldSp:setPosition(valueTipLb:getPositionX() + valueTipLb:getContentSize().width + 10, rewardValueBg:getContentSize().height / 2)
    valueLb:setPosition(goldSp:getPositionX() + goldSp:getContentSize().width + 10, rewardValueBg:getContentSize().height / 2 - 3)
    
    --幸运锦鲤幸运大奖
    local rewardList = acZnjlVoApi:getLuckyReward()
    local firstPosX, firstPosY = (G_VisibleSizeWidth - 4 * iconSize - 3 * iconSpaceX) / 2, rewardValueBg:getPositionY() - rewardValueBg:getContentSize().height - offsety2
    for k, v in pairs(rewardList) do
        local posX = firstPosX + (k - 1) % 4 * (iconSize + iconSpaceX)
        local posY = firstPosY - math.floor((k - 1) / 4) * (iconSize + iconSpaceY)
        
        local function showPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
        end
        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
        rewardSp:setScale(iconSize / rewardSp:getContentSize().width)
        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        rewardSp:setAnchorPoint(ccp(0, 1))
        rewardSp:setPosition(posX, posY)
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
    local rewardNum = SizeOfTable(rewardList)
    local jlPlayerStr = acZnjlVoApi:getJlPlayerShowStr()
    local jlPlayerLb = GetTTFLabelWrap(jlPlayerStr, smallFontSize, CCSizeMake(jlTipBgSize.width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    jlPlayerLb:setAnchorPoint(ccp(0.5, 0))
    jlPlayerLb:setColor(G_ColorYellowPro3)
    jlPlayerLb:setPosition(G_VisibleSizeWidth / 2, firstPosY - math.ceil(rewardNum / 4) * iconSize - (math.ceil(rewardNum / 4) - 1) * iconSpaceY - offsety3)
    self.mainLayer:addChild(jlPlayerLb, 2)
    self.jlPlayerLb = jlPlayerLb
    
    local tempLb = GetTTFLabel(jlPlayerStr, smallFontSize, true)
    local realW = tempLb:getContentSize().width
    if realW > jlPlayerLb:getContentSize().width then
        realW = jlPlayerLb:getContentSize().width
    end
    
    local jlPlayerBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    jlPlayerBg:setScaleX((realW + 20) / jlPlayerBg:getContentSize().width)
    jlPlayerBg:setScaleY((self.jlPlayerLb:getContentSize().height + 10) / jlPlayerBg:getContentSize().height)
    jlPlayerBg:setPosition(jlPlayerLb:getPositionX(), jlPlayerLb:getPositionY() + self.jlPlayerLb:getContentSize().height / 2)
    self.mainLayer:addChild(jlPlayerBg)
    
    local dailyTitleLb = GetTTFLabel(getlocal("activity_znjl_dailyReward"), titleFontSize, true)
    dailyTitleLb:setPosition(G_VisibleSizeWidth / 2, dailyTitlePosY)
    dailyTitleLb:setColor(G_ColorYellowPro3)
    self.mainLayer:addChild(dailyTitleLb)
    
    local dailyTipBgSize = CCSizeMake(G_VisibleSizeWidth - 120, 60)
    local dailyTipBgPosY = dailyTitlePosY - dailyTitleLb:getContentSize().height / 2 - offsety1
    local dailyTipStr = getlocal("activity_znjl_tip2")
    local dailyTipLb = GetTTFLabelWrap(dailyTipStr, smallFontSize, CCSizeMake(dailyTipBgSize.width - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    local lbWidth, lbHeight = dailyTipBgSize.width - 20, dailyTipLb:getContentSize().height + 10
    if dailyTipBgSize.height > lbHeight then
        dailyTipBgSize.height = lbHeight
        dailyTipLb:setAnchorPoint(ccp(0, 0.5))
        dailyTipLb:setColor(G_ColorYellowPro3)
        dailyTipLb:setPosition((G_VisibleSizeWidth - lbWidth) / 2, dailyTipBgPosY)
        self.mainLayer:addChild(dailyTipLb, 2)
    else
        local dailyTipTv = G_LabelTableViewNew(CCSizeMake(lbWidth, lbHeight), dailyTipStr, smallFontSize, kCCTextAlignmentLeft, G_ColorYellowPro3)
        dailyTipTv:setAnchorPoint(ccp(0, 0))
        dailyTipTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        dailyTipTv:setMaxDisToBottomOrTop(100)
        dailyTipTv:setPosition((G_VisibleSizeWidth - lbWidth) / 2, dailyTipBgPosY - lbHeight / 2)
        self.mainLayer:addChild(dailyTipTv, 2)
    end
    local jlTipBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    jlTipBg:setScaleX(jlTipBgSize.width / jlTipBg:getContentSize().width)
    jlTipBg:setScaleY(jlTipBgSize.height / jlTipBg:getContentSize().height)
    jlTipBg:setPosition(G_VisibleSizeWidth / 2, dailyTipBgPosY)
    self.mainLayer:addChild(jlTipBg)
    
    --每日福利大奖
    local dailyRewardList = acZnjlVoApi:getDailyReward()
    local dailyFirstPosX, dailyFirstPosY = firstPosX, dailyTipBgPosY - dailyTipBgSize.height / 2 - offsety2
    for k, v in pairs(dailyRewardList) do
        local posX = dailyFirstPosX + (k - 1) % 4 * (iconSize + iconSpaceX)
        local posY = dailyFirstPosY - math.floor((k - 1) / 4) * (iconSize + iconSpaceY)
        
        local function showPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, nil, nil, v, nil, nil, nil, nil, true)
        end
        local rewardSp, scale = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
        rewardSp:setScale(iconSize / rewardSp:getContentSize().width)
        rewardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        rewardSp:setAnchorPoint(ccp(0, 1))
        rewardSp:setPosition(posX, posY)
        self.mainLayer:addChild(rewardSp)
        
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
    self.getItem, self.getMenu = G_createBotton(self.mainLayer, btnPos, {getlocal("daily_scene_get"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", getRewardHandler, 0.8, -(self.layerNum - 1) * 20 - 4, 3)
    
    local cloudCfg = {ccp(G_VisibleSizeWidth / 2 + 30, jlTitleLb:getPositionY()), ccp(G_VisibleSizeWidth / 2 + 30, dailyTitleLb:getPositionY()), ccp(155, 90)}
    if self.phoneType == G_iphone5 or self.phoneType == G_iphoneX then
        table.insert(cloudCfg, ccp(155, jlPlayerLb:getPositionY() + 10))
    end
    for k, v in pairs(cloudCfg) do
        local cloudSp = CCSprite:createWithSpriteFrameName("acznjl_cloud.png")
        cloudSp:setScaleX(2)
        cloudSp:setOpacity(255 * 0.5)
        cloudSp:setPosition(v)
        if k == 3 or k == 4 then
            cloudSp:setFlipX(true)
        end
        self.bgLayer:addChild(cloudSp, 2)
    end
    
    self:refresh()
end

function acZnjlDialog:refresh()
    if acZnjlVoApi:isRewardTime() == true then --领奖时间不可以领取每日福利
        if self.getItem then
            self.getItem:setEnabled(false)
            local strLb = tolua.cast(self.getItem:getChildByTag(101), "CCLabelTTF")
            if strLb then
                strLb:setString(getlocal("serverwarteam_all_end"))
            end
        end
    else
        if self.getItem then
            local btnStr = ""
            local flag = acZnjlVoApi:hasReward()
            if flag == true then
                self.getItem:setEnabled(false)
                btnStr = getlocal("activity_hadReward")
            else
                self.getItem:setEnabled(true)
                btnStr = getlocal("daily_scene_get")
            end
            local strLb = tolua.cast(self.getItem:getChildByTag(101), "CCLabelTTF")
            if strLb then
                strLb:setString(btnStr)
            end
        end
    end
end

function acZnjlDialog:refreshJlPlayerLb()
    if self.jlPlayerLb then
        local jlPlayerStr = acZnjlVoApi:getJlPlayerShowStr()
        self.jlPlayerLb:setString(jlPlayerStr)
    end
end

function acZnjlDialog:tick()
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

function acZnjlDialog:dispose()
    self.timeLb = nil
    self.rTimeLb = nil
    self.jlPlayerLb = nil
    self.jlPlayerFlag = nil
    self.clipper = nil
    self.keepTick = nil
    spriteController:removePlist("public/acznjl_images.plist")
    spriteController:removeTexture("public/acznjl_images.png")
end

