acZnkhFiveAnniversaryTabOne = {}

function acZnkhFiveAnniversaryTabOne:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    return nc
end

function acZnkhFiveAnniversaryTabOne:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function acZnkhFiveAnniversaryTabOne:initUI()
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBg:getContentSize().height))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 160)
    self.bgLayer:addChild(timeBg)
    local timeStr1 = acZnkhFiveAnniversaryVoApi:getTimeStr()
    local timeStr2 = acZnkhFiveAnniversaryVoApi:getRewardTimeStr()
    local lbRollView, timeLb, rewardLb = G_LabelRollView(CCSizeMake(timeBg:getContentSize().width - 60, 30), timeStr1, 21, kCCTextAlignmentCenter, G_ColorGreen, nil, timeStr2, G_ColorYellowPro, 2, 2, 2, nil)
    lbRollView:setPosition(30, timeBg:getContentSize().height - 37)
    timeBg:addChild(lbRollView)
    self.timeLb = timeLb
    self.rewardTimeLb = rewardLb
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("activity_znkh2018_tab1_tipsDesc1", {acZnkhFiveAnniversaryVoApi:getRankNum()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc2", {acZnkhFiveAnniversaryVoApi:getRankRecharge()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc3", {acZnkhFiveAnniversaryVoApi:getLuckyNum()}), 
            getlocal("activity_znkh2018_tab1_tipsDesc4"), 
            getlocal("activity_znkh2018_tab1_tipsDesc5"), 
            getlocal("activity_znkh2018_tab1_tipsDesc6"), 
            getlocal("activity_znkh2018_tab1_tipsDesc7"), 
        }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(timeBg:getContentSize().width - 8 - infoBtn:getContentSize().width / 2, timeBg:getContentSize().height / 2))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    timeBg:addChild(infoMenu)
    
    local upTitleBg = CCSprite:createWithSpriteFrameName("acZnkh2018_titleBg.png")
    upTitleBg:setAnchorPoint(ccp(0.5, 1))
    upTitleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 225)
    self.bgLayer:addChild(upTitleBg)
    local upTitleLb = GetTTFLabel(getlocal("activity_znkh2018_tab1_title1"), 24, true)
    upTitleLb:setPosition(upTitleBg:getContentSize().width / 2, upTitleBg:getContentSize().height / 2)
    upTitleLb:setColor(G_ColorYellowPro)
    upTitleBg:addChild(upTitleLb)
    
    local centerFrameSize = CCSizeMake(G_VisibleSizeWidth - 60, G_VisibleSizeHeight - 520)
    if G_getIphoneType() == G_iphone4 then
    elseif G_getIphoneType() == G_iphone5 then
        centerFrameSize.height = G_VisibleSizeHeight - 530
    elseif G_getIphoneType() == G_iphoneX then
    	centerFrameSize.height = G_VisibleSizeHeight - 550
    end
    local centerFrameBgOffset = 16
    local centerFrameBgTopPosY = upTitleBg:getPositionY() - upTitleBg:getContentSize().height - 5
    
    local downTitleBg = CCSprite:createWithSpriteFrameName("acZnkh2018_titleBg.png")
    downTitleBg:setAnchorPoint(ccp(0.5, 1))
    downTitleBg:setPosition(G_VisibleSizeWidth / 2, centerFrameBgTopPosY - centerFrameSize.height - 5)
    self.bgLayer:addChild(downTitleBg)
    local downTitleLb = GetTTFLabel(getlocal("activity_znkh2018_tab1_title2"), 24, true)
    downTitleLb:setPosition(downTitleBg:getContentSize().width / 2, downTitleBg:getContentSize().height / 2)
    downTitleLb:setColor(G_ColorYellowPro)
    downTitleBg:addChild(downTitleLb)
    
    local downFrameNode = CCNode:create()
    downFrameNode:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, downTitleBg:getPositionY() - downTitleBg:getContentSize().height - 5 - 15))
    downFrameNode:setAnchorPoint(ccp(0.5, 1))
    downFrameNode:setPosition(G_VisibleSizeWidth / 2, downTitleBg:getPositionY() - downTitleBg:getContentSize().height - 5)
    self.bgLayer:addChild(downFrameNode)
    local downFrameBg = LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh2018_frame2.png", CCRect(8, 17, 4, 210), function()end)
    local downFrameBgHeight = downFrameBg:getContentSize().height
    if downFrameNode:getContentSize().height >= downFrameBgHeight then
        downFrameBgHeight = downFrameNode:getContentSize().height
    end
    downFrameBg:setContentSize(CCSizeMake(downFrameNode:getContentSize().width, downFrameBgHeight))
    downFrameBg:setAnchorPoint(ccp(0.5, 0.5))
    downFrameBg:setPosition(downFrameNode:getContentSize().width / 2, downFrameNode:getContentSize().height / 2)
    if downFrameNode:getContentSize().height ~= downFrameBgHeight then
        downFrameBg:setScaleY(downFrameNode:getContentSize().height / downFrameBgHeight)
    end
    downFrameNode:addChild(downFrameBg)
    
    local luckyRewardTb = acZnkhFiveAnniversaryVoApi:getLuckyReward()
    if luckyRewardTb then
        local descLbPosY = downFrameNode:getContentSize().height - 5
        if G_getIphoneType() == G_iphone4 then
        elseif G_getIphoneType() == G_iphone5 then
            descLbPosY = downFrameNode:getContentSize().height - 15
        elseif G_getIphoneType() == G_iphoneX then
        	descLbPosY = downFrameNode:getContentSize().height - 20
        end
        local downFrameBgOffset = 9
        local descLb = GetTTFLabelWrap(getlocal("activity_znkh2018_tab1_desc2"), 20, CCSize(downFrameNode:getContentSize().width - downFrameBgOffset - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
        descLb:setAnchorPoint(ccp(0.5, 1))
        descLb:setPosition((downFrameNode:getContentSize().width - downFrameBgOffset) / 2, descLbPosY)
        descLb:setColor(G_ColorYellowPro)
        downFrameNode:addChild(descLb)
        local rewardTb = FormatItem(luckyRewardTb, nil, true)
        local iconSize = 90
        local iconSpaceX = 35
        local rewardSize = SizeOfTable(rewardTb)
        local firstPosX = (downFrameNode:getContentSize().width - (iconSize * rewardSize + (rewardSize - 1) * iconSpaceX)) / 2 + iconSize / 2 - downFrameBgOffset
        for k, v in pairs(rewardTb) do
            local function showNewPropDialog()
                G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
            end
            local icon, scale
            if propCfg[v.key] and propCfg[v.key].useGetHeadFrame then
            	icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
            else
            	icon = LuaCCSprite:createWithSpriteFrameName(v.iconImage or v.pic, showNewPropDialog)
            end
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
            icon:setPosition(firstPosX + (k - 1) * (iconSize + iconSpaceX), iconSize / 2 + 20)
            downFrameNode:addChild(icon, 1)
            local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
            downFrameNode:addChild(numBg, 2)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            downFrameNode:addChild(numLb, 2)
            local iconBg = CCSprite:createWithSpriteFrameName("acZnkh2018_effect1_ieBg" .. (v.extend or "") .. ".png")
            if iconBg then
	            G_setBlendFunc(iconBg, GL_ONE, GL_ONE)
	            iconBg:setPosition(icon:getPositionX(), icon:getPositionY() - iconBg:getContentSize().height / 2)
	            downFrameNode:addChild(iconBg)
        	end
            local iconEffect = CCSprite:createWithSpriteFrameName("acZnkh2018_effect1_ie" .. (v.extend or "") .. ".png")
            if iconEffect then
	            G_setBlendFunc(iconEffect, GL_ONE, GL_ONE)
	            iconEffect:setPosition(icon:getPosition())
	            downFrameNode:addChild(iconEffect)
	            iconEffect:runAction(CCRepeatForever:create(CCRotateBy:create(10, 360)))
	        end
        end
    end
    
    --‘5周年’相对于中间边框的中心坐标点
    local fiveAnniversaryPos = ccp(centerFrameSize.width / 2, centerFrameSize.height / 2 - 25)
    local showPageIndex = 1
    local pageList = {}
    local listNum = 0
    local rankRewardTb = acZnkhFiveAnniversaryVoApi:getRankReward()
    if rankRewardTb then
        listNum = SizeOfTable(rankRewardTb)
        for i, v in pairs(rankRewardTb) do
            local pageBg = LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh2018_frame1.png", CCRect(16, 16, 12, 12), function()end)
            pageBg:setContentSize(centerFrameSize)
            pageBg:setAnchorPoint(ccp(0.5, 1))
            if showPageIndex == i then
                pageBg:setPosition(G_VisibleSizeWidth / 2, centerFrameBgTopPosY)
            end
            self.bgLayer:addChild(pageBg)
            
            local descLbPosY = centerFrameSize.height - 5
            if G_getIphoneType() == G_iphone4 then
            elseif G_getIphoneType() == G_iphone5 then
                descLbPosY = centerFrameSize.height - 15
            elseif G_getIphoneType() == G_iphoneX then
            	descLbPosY = centerFrameSize.height - 15
            end
            local descLb = GetTTFLabelWrap(getlocal("activity_znkh2018_tab1_desc1", {listNum}), 20, CCSize(centerFrameSize.width - centerFrameBgOffset - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
            descLb:setAnchorPoint(ccp(0.5, 1))
            descLb:setPosition((centerFrameSize.width - centerFrameBgOffset) / 2, descLbPosY)
            descLb:setColor(G_ColorYellowPro)
            pageBg:addChild(descLb)
            
            local lbBgPosY = pageBg:getContentSize().height - 50
            if G_getIphoneType() == G_iphone4 then
            elseif G_getIphoneType() == G_iphone5 then
                lbBgPosY = pageBg:getContentSize().height - 70
            elseif G_getIphoneType() == G_iphoneX then
            	lbBgPosY = pageBg:getContentSize().height - 70
            end
            local lbBg = CCSprite:createWithSpriteFrameName("acZnkh2018_line3.png")
            lbBg:setPosition(pageBg:getContentSize().width / 2, lbBgPosY)
            lbBg:setScaleX(3)
            lbBg:setScaleY(1.5)
            pageBg:addChild(lbBg)
            local label = GetTTFLabel(getlocal("rankOne", {i}), 25, true)
            label:setPosition(pageBg:getContentSize().width / 2, lbBgPosY)
            pageBg:addChild(label)
            local rPointSp = CCSprite:createWithSpriteFrameName("acZnkh2018_line1.png")
            rPointSp:setPosition(label:getPositionX() + label:getContentSize().width / 2 + 30, label:getPositionY())
            pageBg:addChild(rPointSp)
            local rLineSp = CCSprite:createWithSpriteFrameName("acZnkh2018_line2.png")
            rLineSp:setAnchorPoint(ccp(0, 0.5))
            rLineSp:setPosition(rPointSp:getPositionX() + rPointSp:getContentSize().width / 2 + 5, rPointSp:getPositionY())
            pageBg:addChild(rLineSp)
            local lPointSp = CCSprite:createWithSpriteFrameName("acZnkh2018_line1.png")
            lPointSp:setPosition(label:getPositionX() - label:getContentSize().width / 2 - 30, label:getPositionY())
            pageBg:addChild(lPointSp)
            local lLineSp = CCSprite:createWithSpriteFrameName("acZnkh2018_line2.png")
            lLineSp:setFlipX(true)
            lLineSp:setAnchorPoint(ccp(1, 0.5))
            lLineSp:setPosition(lPointSp:getPositionX() - lPointSp:getContentSize().width / 2 - 5, lPointSp:getPositionY())
            pageBg:addChild(lLineSp)
            
            local rewardTb = FormatItem(v[2], nil, true)
            if rewardTb then
                local iconSize = 90
                local iconSpaceX, iconSpaceY = 95, 35
                if G_getIphoneType() == G_iphone4 then
                elseif G_getIphoneType() == G_iphone5 then
                    iconSpaceY = 100
                elseif G_getIphoneType() == G_iphoneX then
                	iconSpaceY = 130
                end
                local firstPos = ccp(fiveAnniversaryPos.x - iconSize - iconSpaceX, fiveAnniversaryPos.y + iconSize + iconSpaceY)
                for k, item in pairs(rewardTb) do
                    local function showNewPropDialog()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
                    end
                    local icon, scale 
                    if propCfg[item.key] and propCfg[item.key].useGetHeadFrame then
                    	icon, scale = G_getItemIcon(item, 100, false, self.layerNum, showNewPropDialog)
                	else
                    	icon = LuaCCSprite:createWithSpriteFrameName(item.iconImage or item.pic, showNewPropDialog)
                	end
                	icon:setScale(iconSize / icon:getContentSize().height)
                	scale = icon:getScale()
                    icon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                    local index = (k >= 5) and (k + 1) or k
                    icon:setPosition(firstPos.x + ((index - 1) % 3) * (iconSize + iconSpaceX), firstPos.y - math.floor((index - 1) / 3) * (iconSize + iconSpaceY))
                    pageBg:addChild(icon, 1)
                    local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 20)
		            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
		            numBg:setAnchorPoint(ccp(0, 1))
		            numBg:setRotation(180)
		            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
		            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
		            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
		            pageBg:addChild(numBg, 2)
		            numLb:setAnchorPoint(ccp(1, 0))
		            numLb:setPosition(numBg:getPosition())
		            pageBg:addChild(numLb, 2)
                    local iconBg = CCSprite:createWithSpriteFrameName("acZnkh2018_effect1_ieBg" .. (item.extend or "") .. ".png")
                    if iconBg then
	                    G_setBlendFunc(iconBg, GL_ONE, GL_ONE)
	                    iconBg:setPosition(icon:getPositionX(), icon:getPositionY() - iconBg:getContentSize().height / 2)
	                    pageBg:addChild(iconBg)
                	end
                    local iconEffect = CCSprite:createWithSpriteFrameName("acZnkh2018_effect1_ie" .. (item.extend or "") .. ".png")
                    if iconEffect then
	                    G_setBlendFunc(iconEffect, GL_ONE, GL_ONE)
			            iconEffect:setPosition(icon:getPosition())
			            pageBg:addChild(iconEffect)
			            iconEffect:runAction(CCRepeatForever:create(CCRotateBy:create(10, 360)))
			        end
		            local particleSystem = CCParticleSystemQuad:create("public/5year.plist")
		            particleSystem:setPosition(icon:getPosition())
	                particleSystem:setAutoRemoveOnFinish(true)
	                pageBg:addChild(particleSystem, 5)
                end
            end
            
            pageList[i] = pageBg
        end
        local pageTurning = false
        local function onPage(flag)
            if pageTurning == true then
                do return end
            end
            pageTurning = true
            local pageBg = pageList[showPageIndex]
            showPageIndex = showPageIndex + flag
            if showPageIndex <= 0 then
                showPageIndex = listNum
            end
            if showPageIndex > listNum then
                showPageIndex = 1
            end
            local newPageBg = pageList[showPageIndex]
            
            local cPos = ccp(pageBg:getPosition())
            newPageBg:setPosition(cPos.x + flag * G_VisibleSizeWidth, cPos.y)
            pageBg:runAction(CCMoveTo:create(0.3, ccp(cPos.x - flag * G_VisibleSizeWidth, cPos.y)))
            local arry = CCArray:create()
            arry:addObject(CCMoveTo:create(0.3, cPos))
            arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - flag * 50, cPos.y)))
            arry:addObject(CCMoveTo:create(0.06, cPos))
            arry:addObject(CCCallFunc:create(function()
                    pageTurning = false
            end))
            newPageBg:runAction(CCSequence:create(arry))
        end
        -- local leftArrowSp = LuaCCSprite:createWithSpriteFrameName("hellChallengeArrow2.png", function() onPage( - 1) end)
        -- local rightArrowSp = LuaCCSprite:createWithSpriteFrameName("hellChallengeArrow2.png", function() onPage(1) end)
        -- leftArrowSp:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        -- rightArrowSp:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        local leftArrowSp = CCSprite:createWithSpriteFrameName("hellChallengeArrow2.png")
        local rightArrowSp = CCSprite:createWithSpriteFrameName("hellChallengeArrow2.png")
        leftArrowSp:setFlipX(true)
        leftArrowSp:setPosition(40, centerFrameBgTopPosY - centerFrameSize.height / 2)
        rightArrowSp:setPosition(G_VisibleSizeWidth - 40, centerFrameBgTopPosY - centerFrameSize.height / 2)
        self.bgLayer:addChild(leftArrowSp)
        self.bgLayer:addChild(rightArrowSp)
        local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage( - 1) end)
        local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() onPage(1) end)
        leftTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        rightTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        leftTouchArrow:setContentSize(CCSizeMake(leftArrowSp:getContentSize().width + 40, leftArrowSp:getContentSize().height + 60))
        rightTouchArrow:setContentSize(CCSizeMake(rightArrowSp:getContentSize().width + 40, rightArrowSp:getContentSize().height + 60))
        leftTouchArrow:setPosition(leftArrowSp:getPositionX() - 20, leftArrowSp:getPositionY())
        rightTouchArrow:setPosition(rightArrowSp:getPositionX() + 20, rightArrowSp:getPositionY())
        leftTouchArrow:setOpacity(0)
        rightTouchArrow:setOpacity(0)
        self.bgLayer:addChild(leftTouchArrow)
        self.bgLayer:addChild(rightTouchArrow)
        
        local function runArrowAction(arrowSp, flag)
            local posX, posY = arrowSp:getPosition()
            local posX2 = posX + flag * 20
            local arry1 = CCArray:create()
            arry1:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
            arry1:addObject(CCFadeIn:create(0.5))
            local spawn1 = CCSpawn:create(arry1)
            
            local arry2 = CCArray:create()
            arry2:addObject(CCMoveTo:create(0.5, ccp(posX2, posY)))
            arry2:addObject(CCFadeOut:create(0.5))
            local spawn2 = CCSpawn:create(arry2)
            
            arrowSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(spawn2, spawn1)))
        end
        runArrowAction(leftArrowSp, - 1)
        runArrowAction(rightArrowSp, 1)
        
        local pageLayer = CCLayer:create()
        pageLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, centerFrameSize.height))
        pageLayer:setPosition((G_VisibleSizeWidth - pageLayer:getContentSize().width) / 2, centerFrameBgTopPosY - pageLayer:getContentSize().height)
        local touchArray = {}
        local beganPos
        local function touchHandler(fn, x, y, touch)
            if fn == "began" then
                if x >= 0 and x <= G_VisibleSizeWidth and y >= centerFrameBgTopPosY - centerFrameSize.height and y <= centerFrameBgTopPosY then
                    table.insert(touchArray, touch)
                    if SizeOfTable(touchArray) > 1 then
                        touchArray = {}
                        return false
                    else
                        beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                        return true
                    end
                end
                return false
            elseif fn == "moved" then
            elseif fn == "ended" then
                if beganPos then
                    local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                    local moveDisTmp = ccpSub(curPos, beganPos)
                    if moveDisTmp.x > 50 then
                        onPage( - 1)
                    elseif moveDisTmp.x < - 50 then
                        onPage(1)
                    end
                end
                beganPos = nil
                touchArray = {}
            else
                touchArray = {}
            end
        end
        pageLayer:setTouchEnabled(true)
        pageLayer:setBSwallowsTouches(true)
        pageLayer:registerScriptTouchHandler(touchHandler, false, - (self.layerNum - 1) * 20 - 1, true)
        self.bgLayer:addChild(pageLayer)
    end
    
    
end

function acZnkhFiveAnniversaryTabOne:updateAcTime()
    if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acZnkhFiveAnniversaryVoApi:getTimeStr())
    end
    if self.rewardTimeLb and tolua.cast(self.rewardTimeLb, "CCLabelTTF") then
        self.rewardTimeLb:setString(acZnkhFiveAnniversaryVoApi:getRewardTimeStr())
    end
end

function acZnkhFiveAnniversaryTabOne:tick()
    self:updateAcTime()
end

function acZnkhFiveAnniversaryTabOne:dispose()
    self = nil
end