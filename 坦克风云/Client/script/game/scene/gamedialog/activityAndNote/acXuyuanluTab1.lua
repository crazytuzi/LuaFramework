acXuyuanluTab1={


}

function acXuyuanluTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil
    self.TodayNum =nil

    return nc

end

function acXuyuanluTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    
    self.TodayNum = acXuyuanluVoApi:getGoldTimesToday()
    self:initTableView()

    return self.bgLayer
end

function acXuyuanluTab1:initTableView()

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2+60,self.bgLayer:getContentSize().height-205))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acXuyuanluVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+60, self.bgLayer:getContentSize().height-240))
        self.bgLayer:addChild(timeLabel,5)
    end
    local version = acXuyuanluVoApi:getAcVersion()
    if version and version==2 then

        local characterSp
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            characterSp = CCSprite:create("public/guide.png")
        else
            characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
        end
        characterSp:setAnchorPoint(ccp(0,0))
        characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 450))
        self.bgLayer:addChild(characterSp,5)

        
        
        local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
        girlDescBg:setContentSize(CCSizeMake(400,160))
        girlDescBg:setAnchorPoint(ccp(0,0))
        girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 440))
        self.bgLayer:addChild(girlDescBg,4)

        local descTv=G_LabelTableView(CCSize(300,140),getlocal("activity_xuyuanlu_goldContent"),25,kCCTextAlignmentCenter)
        descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        descTv:setAnchorPoint(ccp(0,0))
        descTv:setPosition(ccp(80,10))
        girlDescBg:addChild(descTv,2)
        descTv:setMaxDisToBottomOrTop(50)
    else
        local backSprite = CCSprite:createWithSpriteFrameName("wishingSp.png")
        backSprite:setScaleX((self.bgLayer:getContentSize().width-50)/backSprite:getContentSize().width)
        backSprite:setAnchorPoint(ccp(0,1))
        backSprite:setPosition(25,self.bgLayer:getContentSize().height-165)
        self.bgLayer:addChild(backSprite)

        local lightSp1 = CCSprite:createWithSpriteFrameName("NewYearLantern.png")
        -- lightSp1:setScale(0.8)
        lightSp1:setAnchorPoint(ccp(0.5,1))
        lightSp1:setPosition(80,self.bgLayer:getContentSize().height-165)
        self.bgLayer:addChild(lightSp1)

        -- local fireWorkSp =CCSprite:createWithSpriteFrameName("NewYearFireworks.png")
        -- fireWorkSp:setAnchorPoint(ccp(0.5,1))
        -- fireWorkSp:setPosition(180,self.bgLayer:getContentSize().height-175)
        -- self.bgLayer:addChild(fireWorkSp)

        local lightSp2 = CCSprite:createWithSpriteFrameName("NewYearLantern.png")
        lightSp2:setScale(0.6)
        lightSp2:setAnchorPoint(ccp(0.5,1))
        lightSp2:setPosition(180,self.bgLayer:getContentSize().height-165)
        self.bgLayer:addChild(lightSp2)

        local descTv=G_LabelTableView(CCSize(350,140),getlocal("activity_xuyuanlu_goldContent"),25,kCCTextAlignmentCenter)
        descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        descTv:setAnchorPoint(ccp(0,0))
        descTv:setPosition(ccp(220,self.bgLayer:getContentSize().height-420))
        self.bgLayer:addChild(descTv,2)
        descTv:setMaxDisToBottomOrTop(50)

       actTime:setColor(G_ColorYellow)

    end
    
    

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        local times = acXuyuanluVoApi:getGoldTimesCfg()
        tabStr = {"\n",getlocal("activity_xuyuanlu_goldTip4"),"\n",getlocal("activity_xuyuanlu_goldTip3"),"\n",getlocal("activity_xuyuanlu_goldTip2",{times[1]}),"\n",getlocal("activity_xuyuanlu_goldTip1",{acXuyuanluVoApi:getMaxGoldWishTimes()}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-175))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(lineSprite,6)

    self.canWishNumLb = GetTTFLabelWrap(getlocal("activity_xuyuanlu_todayNum",{}),25,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.canWishNumLb:setAnchorPoint(ccp(0.5,1))
    local widPos=200
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="fr" then
        widPos=350
    end
    self.canWishNumLb:setPosition(self.bgLayer:getContentSize().width-widPos,self.bgLayer:getContentSize().height - 460)
    self.bgLayer:addChild(self.canWishNumLb)

    local scale = 1.2

    self.stoveSp=CCSprite:createWithSpriteFrameName("WishingStove.png")
    self.stoveSp:setAnchorPoint(ccp(0.5,0.5))
    self.stoveSp:setPosition(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-350)/2)
    self.bgLayer:addChild(self.stoveSp)
    if G_isIphone5()==true then
        self.stoveSp:setScale(scale)
    end

    -- self.fireICon = CCSprite:createWithSpriteFrameName("WishingFireIcon.png")
    -- self.fireICon:setPosition(ccp(0.5,0.5))
    -- self.fireICon:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
    -- self.stoveSp:addChild(self.fireICon)

    -- self.particleS = CCParticleSystemQuad:create("public/WishingFire.plist")
    -- if G_isIphone5()==true then
    --     self.particleS:setScale(scale)
    -- end
    -- self.particleS.positionType=kCCPositionTypeFree
    -- self.particleS:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
    -- self.stoveSp:addChild(self.particleS)
    -- self.particleS:setVisible(false)

    local btnX = self.bgLayer:getContentSize().width-120
    local btnY = 80

    local function history( ... )
        PlayEffect(audioCfg.mouseClick)
        acXuyuanluHistory:create(self.layerNum+1)
    end

    local historyBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",history,11,getlocal("activity_xuyuanlu_goldHistoryBtn"),25)
    local historyMenu = CCMenu:createWithItem(historyBtn);
    historyMenu:setPosition(ccp(btnX-180,btnY))
    historyMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(historyMenu,3)

    local function wishHandler( ... )
        PlayEffect(audioCfg.mouseClick)
        local goldCost = acXuyuanluVoApi:getGoldCost()
        if acXuyuanluVoApi:getGoldHadWishTimes()>=acXuyuanluVoApi:getMaxGoldWishTimes() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_xuyuanlu_tenOver",{acXuyuanluVoApi:getMaxGoldWishTimes()}),28) 
            do return end
        elseif acXuyuanluVoApi:getTodayLeftGoldWishNum()<=0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_xuyuanlu_todayNil"),28) 
            do return end
        elseif playerVoApi:getGems() < goldCost then
            GemsNotEnoughDialog(nil,nil,goldCost-playerVoApi:getGems(),self.layerNum+1,goldCost)
            do return end
        end

        local function wishCallback(fn,data)


            
            local ret,sData = base:checkServerData(data)
            if ret==true then

                if sData.data.xuyuanlu.history then
                    acXuyuanluVoApi:setGoldHistory(sData.data.xuyuanlu.history)
                end
                if sData.data.xuyuanlu.rewardGems then

                    if acXuyuanluVoApi:checkIsChat()==true and  (sData.data.xuyuanlu.rewardGems-goldCost)/goldCost>=acXuyuanluVoApi:getSpeakVate() then
                        local message={key="activity_tankjianianhua_rewardChatSystemMessage",param={playerVoApi:getPlayerName(),sData.data.xuyuanlu.rewardGems}}
                        chatVoApi:sendSystemMessage(message)
                    end

                    acXuyuanluVoApi:addGoldHadWishTimes()

                    if acXuyuanluVoApi:getGoldHadWishTimes()>=acXuyuanluVoApi:getMaxGoldWishTimes() then
                        local message={key="activity_tankjianianhua_GoldChatSystemMessage",param={playerVoApi:getPlayerName(),acXuyuanluVoApi:getMaxGoldWishTimes()}}
                        chatVoApi:sendSystemMessage(message)
                    end
                    
                    playerVoApi:setGems(playerVoApi:getGems()+sData.data.xuyuanlu.rewardGems-goldCost)
                    acXuyuanluVoApi:updateShow()

                    self.wishBtn:setEnabled(false)
                    historyBtn:setEnabled(false)
                    if self.particleS then
                        self.particleS:removeFromParentAndCleanup(true)
                        self.particleS = nil 
                    end
                    self.particleS = CCParticleSystemQuad:create("public/WishingFire.plist")
                    if G_isIphone5()==true then
                        self.particleS:setScale(scale)
                    end
                    self.particleS.positionType=kCCPositionTypeFree
                    self.particleS:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
                    self.stoveSp:addChild(self.particleS)
                    --self.particleS:setVisible(true)

                    
                    if self.goldIcon then
                        self.goldIcon:removeFromParentAndCleanup(true)
                        self.goldIcon = nil 
                    end
                    local function endHandler()
                        if self and self.particleS then
                            --self.particleS:setVisible(false)
                            self:updateGold()
                            self:updateCanWish()
                            -- if self.particleS then
                            --     self.particleS:removeFromParentAndCleanup(true)
                            --     self.particleS = nil 
                            -- end
                            if self.goldIcon then
                                self.goldIcon:removeFromParentAndCleanup(true)
                                self.goldIcon = nil 
                            end
                            local function goldClick()
                                if self.goldIcon then
                                    self.goldIcon:removeFromParentAndCleanup(true)
                                    self.goldIcon = nil 
                                end
                                if self.particleS then
                                    self.particleS:removeFromParentAndCleanup(true)
                                    self.particleS = nil 
                                end

                                self.wishBtn:setEnabled(true)
                                historyBtn:setEnabled(true)

                                local str =getlocal("activity_xuyuanlu_wishReward",{sData.data.xuyuanlu.rewardGems})
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28) 
                            end
                            self.goldIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",goldClick)
                            self.goldIcon:setAnchorPoint(ccp(0.5,0.5))
                            self.goldIcon:setTouchPriority(-(self.layerNum-1)*20-5)
                            self.goldIcon:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
                            self.stoveSp:addChild(self.goldIcon,10)

                            local function showIconAction()
                                local mvTo=CCMoveTo:create(0.5,ccp(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height))
                                local mvBack=CCMoveTo:create(0.5,ccp(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30))
                                local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
                                self.goldIcon:runAction(CCRepeatForever:create(seq))
                            end
                            local fadeIn=CCFadeIn:create(0.3)
                            --arrow:setOpacity(0)
                            local ffunc=CCCallFuncN:create(showIconAction)
                            local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
                            self.goldIcon:runAction(fseq)

                        end
                    end
                    local callFunc=CCCallFunc:create(endHandler)
                    local delay=CCDelayTime:create(2)
                    local acArr=CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    sceneGame:runAction(seq)
                end
            end
        end

        socketHelper:activityXuyuanluGoldWish(wishCallback)
    	

    end

    self.wishBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",wishHandler,11,getlocal("activity_xuyuanlu_wishing"),25)
    local wishMenu = CCMenu:createWithItem(self.wishBtn);
    wishMenu:setPosition(ccp(btnX,btnY))
    wishMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(wishMenu,3)

    self.goldCostLb = GetTTFLabel("",25)
    self.goldCostLb:setAnchorPoint(ccp(1,0.5))
    self.goldCostLb:setPosition(btnX,btnY+60)
    self.bgLayer:addChild(self.goldCostLb)

    self.goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setAnchorPoint(ccp(0,0.5))
    self.goldSp:setPosition(btnX+10,btnY+60)
    self.bgLayer:addChild(self.goldSp)

    local lbPosH = btnY+30
    if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="fr" then
        lbPosH = lbPosH+20
    end
    self.wishGetLb=GetTTFLabelWrap(getlocal("activity_xuyuanlu_wishCenGet"),25,CCSizeMake(self.bgLayer:getContentSize().width-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.wishGetLb:setAnchorPoint(ccp(0,0))
    self.wishGetLb:setPosition(40,lbPosH)
    self.bgLayer:addChild(self.wishGetLb)

    self.canGetGoldLb = GetTTFLabel("",25)
    self.canGetGoldLb:setAnchorPoint(ccp(0,0.5))
    self.canGetGoldLb:setPosition(40,btnY)
    self.bgLayer:addChild(self.canGetGoldLb)
    self.canGetGoldLb:setColor(G_ColorYellow)

    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp1:setAnchorPoint(ccp(0,0.5))
    self.goldSp1:setPosition(40+self.canGetGoldLb:getContentSize().width+10,btnY)
    self.bgLayer:addChild(self.goldSp1)

    self:updateCanWish()
    self:updateGold()

    

    


end
function acXuyuanluTab1:updateGold()

	if self.goldCostLb then
		local goldCost = acXuyuanluVoApi:getGoldCost()
		self.goldCostLb:setString(tostring(goldCost))
		if playerVoApi:getGems() < goldCost then
			self.goldCostLb:setColor(G_ColorRed)
		else
			self.goldCostLb:setColor(G_ColorYellow)
		end

	end
	if self.canGetGoldLb and self.goldSp1 then
		local getgold1,getgold2 = acXuyuanluVoApi:getCanGetGoldNum()
		self.canGetGoldLb:setString(getgold1.."~"..getgold2)
		self.goldSp1:setPosition(40+self.canGetGoldLb:getContentSize().width+10,80)
	end
    if acXuyuanluVoApi:getGoldHadWishTimes()>=acXuyuanluVoApi:getMaxGoldWishTimes() then
        if self.goldCostLb then
            self.goldCostLb:setVisible(false)
        end
        if self.canGetGoldLb then
            self.canGetGoldLb:setVisible(false)
        end
        if self.goldSp1 then
            self.goldSp1:setVisible(false)
        end
        if self.goldSp then
            self.goldSp:setVisible(false)
        end
        if self.wishGetLb then
            self.wishGetLb:setVisible(false)
        end
    else
       if self.goldCostLb then
            self.goldCostLb:setVisible(true)
        end
        if self.canGetGoldLb then
            self.canGetGoldLb:setVisible(true)
        end
        if self.goldSp1 then
            self.goldSp1:setVisible(true)
        end
        if self.goldSp then
            self.goldSp:setVisible(true)
        end
        if self.wishGetLb then
            self.wishGetLb:setVisible(true)
        end
    end
end
function acXuyuanluTab1:updateCanWish()
	
	if self.canWishNumLb then
		local canWish= acXuyuanluVoApi:getTodayLeftGoldWishNum()
		if canWish and canWish>=0 then
			self.canWishNumLb:setString(getlocal("activity_xuyuanlu_todayNum",{canWish}))
		end
	end
end

function acXuyuanluTab1:tick()
  local todayNum = acXuyuanluVoApi:getGoldTimesToday()
  if todayNum ~= self.TodayNum then
    self:updateCanWish()
    self:updateGold()
    self.TodayNum = todayNum
  end
end

function acXuyuanluTab1:dispose()
    self.goldIcon=nil
	self.particleS=nil
    self.stoveSp=nil
    self.TodayNum=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self = nil
end
