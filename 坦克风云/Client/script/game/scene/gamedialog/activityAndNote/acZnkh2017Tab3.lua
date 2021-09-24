acZnkh2017Tab3 ={}
function acZnkh2017Tab3:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.isRunning=false
    self.time=0
    self.rspeed=12.5 --角度旋转速度
    self.arspeed=2 --旋转加速度
    self.drspeed=4 --旋转减速度
    self.pointRotation=0
    self.lotteryIdx=0
    self.lastTurnSp=nil
    return nc
end

function acZnkh2017Tab3:init()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acZnkh2017_images.plist")
    spriteController:addTexture("public/acZnkh2017_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self.bgLayer=CCLayer:create()
    self:initHead()
	return self.bgLayer
end

function acZnkh2017Tab3:initHead()
    local ln,gems=acZnkh2017VoApi:getLnAndGems()
    local cfg=acZnkh2017VoApi:getActiveCfg()

    local addH=0
    local startH=self.bgLayer:getContentSize().height-175
    if G_isIphone5()==true then
        startH=self.bgLayer:getContentSize().height-200
        addH=-20
    end
    local activeScoreLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab3_des1",{cfg.needMoney}),25,CCSizeMake(G_VisibleSizeWidth-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    activeScoreLb:setAnchorPoint(ccp(0,1))
    activeScoreLb:setPosition(40,startH)
    self.bgLayer:addChild(activeScoreLb)

    local pos=ccp(self.bgLayer:getContentSize().width-80,startH-activeScoreLb:getContentSize().height/2)

    local tabStr={" ",getlocal("activity_znkh2017_tip2"),getlocal("activity_znkh2017_tip1",{cfg.needMoney})," "}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,0.9,nil)

    local lineH=startH-activeScoreLb:getContentSize().height-10+addH
    local lineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    self.bgLayer:addChild(lineSp)
    lineSp:setPosition(G_VisibleSizeWidth/2,lineH)

    local costH=lineH-10+addH
    local costLb=GetTTFLabel(getlocal("activity_znkh2017_tab3_cost",{gems}),25)
    costLb:setAnchorPoint(ccp(0,1))
    costLb:setPosition(40,costH)
    self.bgLayer:addChild(costLb)
    costLb:setColor(G_ColorYellowPro)

    local goldIconSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIconSp:setAnchorPoint(ccp(0,0.5))
    goldIconSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+5,costLb:getPositionY()-costLb:getContentSize().height/2)
    self.bgLayer:addChild(goldIconSp)

    local desLbH=costH-costLb:getContentSize().height-5
    local worseNum=cfg.needMoney-(gems%cfg.needMoney)
    if worseNum==0 then
        worseNum=cfg.needMoney
    end
    local desLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab3_des2",{worseNum}),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    desLb:setAnchorPoint(ccp(0.5,1))
    desLb:setPosition(G_VisibleSizeWidth/2,desLbH)
    self.bgLayer:addChild(desLb)

    local lineH=desLbH-desLb:getContentSize().height-10
    local function touchHandler()
        -- print("---------??touchHandler")
        -- if self.isRunning==true then --跳过动画
        --     self:realShowReward()
        -- end
    end
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchHandler)
    bottomBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,lineH-40))
    bottomBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
    bottomBg:setTouchPriority(-(self.layerNum-1)*20-1)
    bottomBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(bottomBg)

    local uplineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    bottomBg:addChild(uplineSp)
    uplineSp:setPosition(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height-5)
    local downlineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    bottomBg:addChild(downlineSp)
    downlineSp:setPosition(bottomBg:getContentSize().width/2,5)

    -- local function nilFunc()
    -- end
    -- local shadeLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    -- shadeLayer:setContentSize(CCSizeMake(bottomBg:getContentSize().width-10,bottomBg:getContentSize().height-10))
    -- shadeLayer:setPosition(getCenterPoint(bottomBg))
    -- shadeLayer:setVisible(false)
    -- bottomBg:addChild(shadeLayer,7)
    -- self.shadeLayer=shadeLayer

    --初始化抽奖页面
    self.turnSpTb={}
    self.rewardSpTb={}
    local rewardlist=acZnkh2017VoApi:getLotteryPool()
    local turnTableBg=CCSprite:createWithSpriteFrameName("acZnkh2017_turnbg.png")
    turnTableBg:setScale(570/turnTableBg:getContentSize().width)
    turnTableBg:setPosition(getCenterPoint(bottomBg))
    bottomBg:addChild(turnTableBg)

    for i=1,8 do
        local angler=i*45
        local lotterySp=CCSprite:createWithSpriteFrameName("acZnkh2017_turn.png")
        lotterySp:setAnchorPoint(ccp(1,0))
        lotterySp:setRotation(angler)
        lotterySp:setPosition(getCenterPoint(bottomBg))
        bottomBg:addChild(lotterySp)

        local rewardItem=rewardlist[i]
        if rewardItem then
            local rnode=CCNode:create()
            rnode:setAnchorPoint(ccp(0.5,0.5))
            rnode:setRotation(angler-22.5)
            rnode:setPosition(getCenterPoint(bottomBg))
            bottomBg:addChild(rnode,2)

            local rewardSp,scale=G_getItemIcon(rewardItem,90,true,self.layerNum+1)
            rewardSp:setPosition(rnode:getContentSize().width/2,180)
            rewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
            rnode:addChild(rewardSp)
            self.rewardSpTb[i]=rewardSp

            local numLb=GetTTFLabel("x"..FormatNumber(rewardItem.num),23)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(ccp(rewardSp:getContentSize().width-5,0))
            rewardSp:addChild(numLb,4)
            self.scale=scale
        end
        local turnSp=CCSprite:createWithSpriteFrameName("acZnkh2017_shade.png")
        turnSp:setAnchorPoint(ccp(1,0))
        turnSp:setOpacity(150)
        turnSp:setRotation(i*45)
        turnSp:setPosition(getCenterPoint(bottomBg))
        bottomBg:addChild(turnSp,3)
        self.turnSpTb[i]=turnSp
    end
    local ballSp=CCSprite:createWithSpriteFrameName("acZnkh2017_ball.png")
    ballSp:setPosition(getCenterPoint(bottomBg))
    bottomBg:addChild(ballSp,6)
    self.ballSp=ballSp

    local pointSp=CCNode:create()
    pointSp:setContentSize(CCSizeMake(1,1))
    pointSp:setAnchorPoint(ccp(0.5,0.5))
    pointSp:setPosition(getCenterPoint(bottomBg))
    pointSp:setRotation(338.5)
    bottomBg:addChild(pointSp,7)
    self.pointSp=pointSp
    self.bottomBg=bottomBg

    self:checkRewardArea() --初始化位置
    self:runAction()

    local arrowSp=CCSprite:createWithSpriteFrameName("acZnkh2017_arrow.png")
    arrowSp:setPosition(ccp(pointSp:getContentSize().width/2,120))
    pointSp:addChild(arrowSp)

    --初始化抽奖页面结束

    local function touchLottery()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local ln,gems=acZnkh2017VoApi:getLnAndGems()
        local totalNum=math.floor(gems/cfg.needMoney)
        if ln>=totalNum then
            local worseNum=cfg.needMoney-(gems%cfg.needMoney)
            if worseNum==0 then
                worseNum=cfg.needMoney
            end
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_znkh2017_tab3_des2",{worseNum}),30)
            do return end
        end
        local function refreshFunc(rewardItem)
            self.lotteryLb:setString(getlocal("activity_znkh2017_lottery_num",{(ln+1) .. "/" .. totalNum}))
            -- rewardItem
            local reward=rewardItem[1]
            if reward then
                self.lotteryIdx=acZnkh2017VoApi:getLotteryIdx(reward)
            end
            if self.lotteryIdx then
                -- print("self.lotteryIdx-------->",self.lotteryIdx)
                self:stopAction()
                self:hideLotteryBtn()
                self.isRunning=true
                self:addForbidLayer()
            end
        end
        acZnkh2017VoApi:socketZnkh2017(refreshFunc,5,nil,nil,ln+1,nil)
    end
    local lotteryItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchLottery,nil,getlocal("activity_wheelFortune_subTitle_1"),25)
    -- rewardItem:setScale(0.8)
    local lotteryBtn=CCMenu:createWithItem(lotteryItem);
    lotteryBtn:setTouchPriority(-(self.layerNum-1)*20-8);
    lotteryBtn:setPosition(ccp(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height/2-20))
    bottomBg:addChild(lotteryBtn,10)
    self.lotteryBtn=lotteryBtn

    local totalNum=math.floor(gems/cfg.needMoney)
    local lotteryLb=GetTTFLabelWrap(getlocal("activity_znkh2017_lottery_num",{ln .. "/" .. totalNum}),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    bottomBg:addChild(lotteryLb,10)
    lotteryLb:setAnchorPoint(ccp(0.5,0.5))
    lotteryLb:setPosition(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height/2+35)
    self.lotteryLb=lotteryLb


    local function confirmHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:resetRewardPosition()
    end
    local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmHandler,nil,getlocal("confirm"),25)
    -- rewardItem:setScale(0.8)
    local confirmBtn=CCMenu:createWithItem(confirmItem);
    confirmBtn:setTouchPriority(-(self.layerNum-1)*20-8);
    confirmBtn:setPosition(ccp(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height/2-100))
    bottomBg:addChild(confirmBtn,10)
    confirmBtn:setVisible(false)
    self.confirmBtn=confirmBtn

    local promptLb=GetTTFLabelWrap(getlocal("daily_lotto_tip_10"),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0.5,0.5))
    promptLb:setPosition(confirmItem:getContentSize().width/2,220)
    confirmItem:addChild(promptLb,10)
end

function acZnkh2017Tab3:addForbidLayer()
    if self.bottomBg then
        local function touchHandler()
            if self.isRunning==true then --跳过动画
                self:realShowReward()
            end
        end
        local shadeLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
        shadeLayer:setContentSize(CCSizeMake(self.bottomBg:getContentSize().width-10,self.bottomBg:getContentSize().height-10))
        shadeLayer:setPosition(getCenterPoint(self.bottomBg))
        shadeLayer:setTouchPriority(-(self.layerNum-1)*20-4)
        shadeLayer:setOpacity(0)
        self.bottomBg:addChild(shadeLayer,7)
        self.shadeLayer=shadeLayer
    end
end

function acZnkh2017Tab3:removeForbidLayer()
    if self.shadeLayer then
        self.shadeLayer:removeFromParentAndCleanup(true)
        self.shadeLayer=nil
    end
end

function acZnkh2017Tab3:hideLotteryBtn()
    if self.lotteryBtn and self.lotteryLb then
        self.lotteryBtn:setVisible(false)
        self.lotteryLb:setVisible(false)
    end
end

function acZnkh2017Tab3:showLotteryBtn()
    if self.lotteryBtn and self.lotteryLb then
        self.lotteryBtn:setVisible(true)
        self.lotteryLb:setVisible(true)
        self.confirmBtn:setVisible(false)
    end
end

function acZnkh2017Tab3:realShowReward()
    if self.confirmBtn then
        self.confirmBtn:setVisible(true)
    end
    self:stop()
    if self.lotteryIdx then
        if self.shadeLayer then
            -- self.shadeLayer:setVisible(true)
            self.shadeLayer:setOpacity(255)
        end
        local rewardSp=self.rewardSpTb[self.lotteryIdx]
        local turnSp=self.turnSpTb[self.lotteryIdx]
        if rewardSp==nil or turnSp==nil then
            do return end
        end
        turnSp:stopAllActions()
        rewardSp:stopAllActions()
        turnSp:setVisible(false)
        if self.lastTurnSp and self.lastTurnSp~=turnSp  then
            self.lastTurnSp:setVisible(true)
        end
        self.lastTurnSp=turnSp
        local pointRotation=self.lotteryIdx*45-22.5
        rewardSp:setRotation(-pointRotation)
        rewardSp:setScale(self.scale)
        rewardSp:setPosition(ccp(0,0))
        local rnode=rewardSp:getParent()
        if rnode then
            self.bottomBg:reorderChild(rnode,10)
        end
        if self.pointSp then
            self.pointSp:setRotation(pointRotation)
            -- self.ballSp:setRotation(pointRotation-10)
        end
        local rewardlist=acZnkh2017VoApi:getLotteryPool()
        local rewardItem=rewardlist[self.lotteryIdx]
        if rewardItem then
            local finalRewardSp,scale=G_getItemIcon(rewardItem,90,true,self.layerNum+1)
            finalRewardSp:setPosition(getCenterPoint(self.bottomBg))
            finalRewardSp:setTouchPriority(-(self.layerNum-1)*20-9)
            self.bottomBg:addChild(finalRewardSp,12)
            self.finalRewardSp=finalRewardSp
        end
    end
end

function acZnkh2017Tab3:playRewardEffect()
    if self.lotteryIdx then
        -- local moveTo=CCMoveTo:create(0.5,ccp(self.pointSp:getPositionX(),self.pointSp:getPositionY()+100))
        local function showReward()
            if self.shadeLayer then
                -- self.shadeLayer:setVisible(true)
                self.shadeLayer:setOpacity(255)
            end
            local rewardSp=self.rewardSpTb[self.lotteryIdx]
            if rewardSp==nil then
                do return end
            end
            local acArr=CCArray:create()
            local spawnArr=CCArray:create()
            local scale=rewardSp:getScale()
            local maxScale=1.5*scale
            local scaleTo=CCScaleTo:create(0.3,maxScale)
            acArr:addObject(scaleTo)
            local moveBy=CCMoveBy:create(0.3,ccp(0,-180))
            local rotateAc=CCRotateTo:create(0.3,-(self.lotteryIdx*45-22.5))
            spawnArr:addObject(moveBy)
            spawnArr:addObject(rotateAc)
            local spawnAc=CCSpawn:create(spawnArr)
            acArr:addObject(spawnAc)
            local scaleTo2=CCScaleTo:create(0.3,scale)
            acArr:addObject(scaleTo2)
            local function callback()
                -- if self.confirmBtn then
                --     self.confirmBtn:setVisible(true)
                -- end
                self:realShowReward()
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            if self.bottomBg then
                local rnode=rewardSp:getParent()
                if rnode then
                    self.bottomBg:reorderChild(rnode,10)
                end
            end
            rewardSp:runAction(seq)
        end
        local turnSp=self.turnSpTb[self.lotteryIdx]
        if turnSp then
            local blinkAc=CCBlink:create(1,2)
            local function callback()
                turnSp:setVisible(false)
                showReward()
            end
            local callFunc=CCCallFunc:create(callback)
            local seq=CCSequence:createWithTwoActions(blinkAc,callFunc)
            turnSp:runAction(seq)
        end
    end
end

function acZnkh2017Tab3:resetRewardPosition()
    -- if self.shadeLayer then
    --     self.shadeLayer:setVisible(false)
    -- end
    self:removeForbidLayer()
    if self.confirmBtn then
        self.confirmBtn:setVisible(false)
    end
    if self.lotteryIdx then
        if self.finalRewardSp then
            self.finalRewardSp:removeFromParentAndCleanup(true)
            self.finalRewardSp=nil
        end
        local acArr=CCArray:create()
        local moveBy=CCMoveBy:create(0.2,ccp(0,180))
        local rotateAc=CCRotateTo:create(0.2,0)
        acArr:addObject(moveBy)
        acArr:addObject(rotateAc)
        local spawnAc=CCSpawn:create(acArr)
        local function callback()
            local rewardSp=self.rewardSpTb[self.lotteryIdx]
            if self.bottomBg and rewardSp then
                local rnode=rewardSp:getParent()
                if rnode then
                    self.bottomBg:reorderChild(rnode,2)
                end
            end
            self:runAction()
            self:showLotteryBtn()

            local rewardlist=acZnkh2017VoApi:getLotteryPool()
            local rewardItem=rewardlist[self.lotteryIdx]
            G_showRewardTip({rewardItem})

            self:clearLottery()
        end
        local callFunc=CCCallFunc:create(callback)
        local seq=CCSequence:createWithTwoActions(spawnAc,callFunc)
        local rewardSp=self.rewardSpTb[self.lotteryIdx]
        if rewardSp then
            rewardSp:runAction(seq)
        end
    end
end

function acZnkh2017Tab3:stop()
    self.isEnd=false
    self.isRunning=false
    if self.pointSp then
        local angle=self:getEndRotation()
        self.pointSp:setRotation(angle)
    end
    -- self:runAction()
end

function acZnkh2017Tab3:clearLottery()
    self.lotteryIdx=nil
    self.time=0
    self.rspeed=12.5
end

function acZnkh2017Tab3:getEndRotation()
    if self.lotteryIdx==0 then
        return 0
    end
    return (self.lotteryIdx*45-22.5)
end

function acZnkh2017Tab3:checkRewardArea()
    if self.pointSp==nil then
        do return end
    end
    if self.lastTurnSp then
        self.lastTurnSp:setVisible(true)
    end
    self.pointRotation=self.pointSp:getRotation()
    self:resetPointRotation()
    for i=1,8 do
        local angle=i*45
        if (self.pointRotation>(angle-45) and self.pointRotation<=angle) then
            local turnSp=self.turnSpTb[i]
            if turnSp and turnSp:isVisible()==true then
                turnSp:setVisible(false)
                self.lastTurnSp=turnSp
            end
            do return end
        end
    end
end

function acZnkh2017Tab3:runAction()
    if self.pointSp then
        -- if self.lastTurnSp then
        --     self.lastTurnSp:setVisible(true)
        -- end
        local delay=CCDelayTime:create(1)
        local function checkArea()
            local idx=math.random(1,8)
            local turnSp=self.turnSpTb[idx]
            if turnSp and turnSp:isVisible()==true then
                turnSp:setVisible(false)
            end
            if self.lastTurnSp and self.lastTurnSp~=turnSp then
                self.lastTurnSp:setVisible(true)
            end
            self.lastTurnSp=turnSp
            local pointRotation=idx*45-22.5
            self.pointSp:setRotation(pointRotation)
        end
        local callFunc=CCCallFunc:create(checkArea)
        local seq=CCSequence:createWithTwoActions(delay,callFunc)
        self.pointSp:runAction(CCRepeatForever:create(seq))
    end
end

function acZnkh2017Tab3:stopAction()
    if self.pointSp then
        self.pointSp:stopAllActions()
        -- local angle=self.pointSp:getRotation()
        -- if angle>360 then
        --     angle=angle%360
        -- end  
    end
end

function acZnkh2017Tab3:resetPointRotation()
    if self.pointRotation and self.pointRotation>360 then
        self.pointRotation=self.pointRotation%360
    end
end

function acZnkh2017Tab3:addTV()
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acZnkh2017Tab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,200)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end


function acZnkh2017Tab3:refresh()
	-- if self.tv then
	-- 	local recordPoint=self.tv:getRecordPoint()
	-- 	self.tv:reloadData()
	-- 	self.tv:recoverToRecordPoint(recordPoint)
	-- end
end

function acZnkh2017Tab3:tick()
end

function acZnkh2017Tab3:fastTick()
    if self.isRunning==true then
        self.time=self.time+1
        self.pointRotation=self.pointRotation+self.rspeed
        self.pointSp=tolua.cast(self.pointSp,"CCNode")
        self.pointSp:setRotation(self.pointRotation)
        -- self.ballSp:setRotation(self.pointRotation-10)
        --print("self.pointRotation",self.pointRotation)
        if self.time>=0 and self.time<=50 and self.time%10==0 then --加速时段
            self.rspeed=self.rspeed+self.arspeed
        elseif self.time>50 and self.time<=160 and self.time%10==0 then
            self.rspeed=self.rspeed-self.drspeed
            if self.rspeed<self.arspeed then
                self.rspeed=3.5
                self.isEnd=true
            end
        end
        self:resetPointRotation()
        self:checkRewardArea()
        if self.isEnd==true then
            local stopRotation=self:getEndRotation()
            local subRotation=stopRotation-self.pointRotation
            if subRotation>=10 and subRotation<=22.5 then
                self.rspeed=2.5
            elseif subRotation>=2.5 and subRotation<10 then
                self.rspeed=1.5
            elseif subRotation>=0 and subRotation<2.5 then
                self.rspeed=0
                self:stop()
                self:playRewardEffect()
                do return end
            end
        end
    end
end

function acZnkh2017Tab3:dispose( )
    self.layerNum=nil
    self.rewardSpTb={}
    self.turnSpTb={}
    self.finalRewardSp=nil
    self.bottomBg=nil
    self.shadeLayer=nil
    self.pointSp=nil
    spriteController:removePlist("public/acZnkh2017_images.plist")
    spriteController:removeTexture("public/acZnkh2017_images.png")
end