worldWarDialogPageSign={}
function worldWarDialogPageSign:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function worldWarDialogPageSign:init(layerNum,worldWarDialogTab1)
	self.layerNum=layerNum
	self.worldWarDialogTab1=worldWarDialogTab1
	self.bgLayer=CCLayer:create()
	self:initListener()
	self:initContent()
	return self.bgLayer
end

function worldWarDialogPageSign:initListener()
	local function onSignListener(event,data)
		local signStatus=worldWarVoApi:getSignStatus()
		if(signStatus~=nil)then
			local lb=tolua.cast(self.bgLayer:getChildByTag(100 + signStatus),"CCLabelTTF")
			lb:setColor(G_ColorYellowPro)
			lb:setString(getlocal("serverwarteam_signup_success"))
		end
	end
	self.signListener=onSignListener
	eventDispatcher:addEventListener("worldwar.signup",onSignListener)
end

function worldWarDialogPageSign:initContent()

	local otherSiz = 22
	local flowerDetSize = 20
	local subPos = 0
	local subPos2 = 0
	local strSize2 = 25
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		otherSiz =25
		flowerDetSize=25
	end
	if G_getCurChoseLanguage() =="en" then
		subPos =-35
	elseif G_getCurChoseLanguage() =="thai" then
		subPos2 =-25
	end
	if G_getCurChoseLanguage() =="ru" then
		strSize2 =18
		otherSiz =17
	end
	local titleLb=GetTTFLabel(getlocal("world_war_zone"),33)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 250)
	self.bgLayer:addChild(titleLb)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setScale(0.95)
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 280))
	self.bgLayer:addChild(lineSp)

	local picWidth=250
	local picHeight=350
	local function onClickNB()
		self:clickSign(1)
	end
	local function onClickSB()
		self:clickSign(2)
	end
	for i=1,2 do
		local callback,posX
		local posX
		local pic
		if(i==1)then
			callback=onClickNB
			posX=G_VisibleSizeWidth/4 + 10
		else
			callback=onClickSB
			posX=G_VisibleSizeWidth*3/4 - 10
		end
		local posY=G_VisibleSizeHeight - 300
		pic=LuaCCSprite:createWithSpriteFrameName("ww_poster_"..i..".png",callback)
		pic:setTouchPriority(-(self.layerNum-1)*20-2)
		pic:setPosition(posX,posY)
		pic:setScaleX(picWidth/pic:getContentSize().width)
		pic:setScaleY(picHeight/pic:getContentSize().height)
		pic:setAnchorPoint(ccp(0.5,1))
		self.bgLayer:addChild(pic)
		local picBg=LuaCCScale9Sprite:createWithSpriteFrameName("ww_bg"..i..".png",CCRect(70,30,10,10),callback)
		picBg:setContentSize(CCSizeMake(picWidth + 6,picHeight + 6))
		picBg:setAnchorPoint(ccp(0.5,1))
		picBg:setPosition(posX,posY + 3)
		self.bgLayer:addChild(picBg,1)

		local gradualBg=CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
		gradualBg:setScaleX(picWidth/gradualBg:getContentSize().width)
		gradualBg:setPosition(posX,posY - gradualBg:getContentSize().height/2)
		self.bgLayer:addChild(gradualBg)

		local titleBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
		titleBg:setScaleX((picWidth - 40)/titleBg:getContentSize().width)
		titleBg:setScaleY(35/titleBg:getContentSize().height)
		titleBg:setPosition(posX,posY - 50)
		self.bgLayer:addChild(titleBg)

		local titleLb=GetTTFLabel(getlocal("world_war_group_"..i),25)
		if(i==1)then
			titleLb:setColor(G_ColorPurple)
		else
			titleLb:setColor(G_ColorBlue)
		end
		titleLb:setPosition(posX,posY - 50)
		self.bgLayer:addChild(titleLb)

		local logo=CCSprite:createWithSpriteFrameName("ww_logo_"..i..".png")
		logo:setPosition(posX,posY)
		self.bgLayer:addChild(logo,3)

		local totalSiz = 16
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
			totalSiz =22
		end
		local totalLb=GetTTFLabel(getlocal("world_war_suggestPower",{FormatNumber(worldWarCfg["fightingSuggest"..i])}),totalSiz)
		totalLb:setColor(G_ColorGreen)
		totalLb:setPosition(posX,posY - 80)
		self.bgLayer:addChild(totalLb)

		gradualBg=CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
		gradualBg:setScaleX(picWidth/gradualBg:getContentSize().width)
		gradualBg:setPosition(posX,posY - picHeight + gradualBg:getContentSize().height/2)
		gradualBg:setFlipY(true)
		self.bgLayer:addChild(gradualBg)

		local descLb
		if(worldWarVoApi:getSignStatus()==i)then
			descLb=GetTTFLabelWrap(getlocal("serverwarteam_signup_success"),22,CCSizeMake(picWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			descLb:setColor(G_ColorYellowPro)
		else
			descLb=GetTTFLabelWrap(getlocal("world_war_signBtnDesc"..i),22,CCSizeMake(picWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		end
		descLb:setAnchorPoint(ccp(0.5,0))
		descLb:setTag(100 + i)
		descLb:setPosition(posX,posY - picHeight + 8)
		self.bgLayer:addChild(descLb)
	end

	local infoBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function()end)
	infoBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 300 - picHeight - 120))
	infoBg:setAnchorPoint(ccp(0.5,0))
	infoBg:setPosition(G_VisibleSizeWidth/2,110)
	self.bgLayer:addChild(infoBg)

	local infoHeight=infoBg:getContentSize().height
	local infoWidth=infoBg:getContentSize().width
	local maxX=0

	local conditionLb1 = GetTTFLabelWrap(getlocal("serverwar_conditionDesc",{""}),strSize2,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionLb1:setAnchorPoint(ccp(0,0.5))
	conditionLb1:setPosition(10,infoHeight*7/8)
	infoBg:addChild(conditionLb1)
	maxX=conditionLb1:getContentSize().width

	lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(infoWidth/2,infoHeight*3/4))
	infoBg:addChild(lineSp)

	local signTimeLb1 = GetTTFLabelWrap(getlocal("world_war_signtime")..":",strSize2,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	signTimeLb1:setAnchorPoint(ccp(0,0.5))
	signTimeLb1:setPosition(10,infoHeight*5/8)
	infoBg:addChild(signTimeLb1)
	if(signTimeLb1:getContentSize().width>maxX)then
		maxX=signTimeLb1:getContentSize().width
	end

	lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(infoWidth/2,infoHeight/2))
	infoBg:addChild(lineSp)

	local battleTimeLb1 = GetTTFLabelWrap(getlocal("serverwar_battleTime")..":",strSize2,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	battleTimeLb1:setAnchorPoint(ccp(0,0.5))
	battleTimeLb1:setPosition(10,infoHeight*3/8)
	infoBg:addChild(battleTimeLb1)
	if(battleTimeLb1:getContentSize().width>maxX)then
		maxX=battleTimeLb1:getContentSize().width
	end

	lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(infoWidth/2,infoHeight/4))
	infoBg:addChild(lineSp)

	local descLb1 = GetTTFLabelWrap(getlocal("serverwar_winConditionDesc",{""}),strSize2,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb1:setAnchorPoint(ccp(0,0.5))
	descLb1:setPosition(10,infoHeight/8)
	infoBg:addChild(descLb1)
	if(descLb1:getContentSize().width>maxX)then
		maxX=descLb1:getContentSize().width
	end
	adaptX = 20
	if G_getCurChoseLanguage() == "cn" then
		adaptX = -60;
	end
	local conditionLb2 = GetTTFLabel(getlocal("world_war_condition",{getlocal("military_rank_"..worldWarCfg.signRank)}),otherSiz)
	conditionLb2:setColor(G_ColorYellowPro)
	conditionLb2:setAnchorPoint(ccp(0,0.5))
	conditionLb2:setPosition(adaptX + maxX+subPos,infoHeight*7/8)
	infoBg:addChild(conditionLb2)

	local signTimeLb2 = GetTTFLabel(G_getDataTimeStr(worldWarVoApi:getStarttime(),true).." - "..G_getDataTimeStr(worldWarVoApi:getStarttime() + worldWarCfg.signuptime*86400 - 1,true),otherSiz)
	signTimeLb2:setColor(G_ColorYellowPro)
	signTimeLb2:setAnchorPoint(ccp(0,0.5))
	signTimeLb2:setPosition(adaptX + maxX,infoHeight*5/8)
	infoBg:addChild(signTimeLb2)

	local battleTimeLb2 = GetTTFLabel(G_getDataTimeStr(worldWarVoApi:getStarttime() + worldWarCfg.signuptime*86400,true,true).." - "..G_getDataTimeStr(worldWarVoApi:getStarttime() + worldWarCfg.signuptime*86400 + worldWarCfg.pmatchdays*86400 + (#(worldWarVoApi:getBattleTimeList(1)))/2*86400 - 1,true,true),otherSiz)
	battleTimeLb2:setColor(G_ColorYellowPro)
	battleTimeLb2:setAnchorPoint(ccp(0,0.5))
	battleTimeLb2:setPosition(adaptX + maxX,infoHeight*3/8)
	infoBg:addChild(battleTimeLb2)

	local descLb2 = GetTTFLabel(getlocal("world_war_winCondition"),otherSiz)
	descLb2:setColor(G_ColorYellowPro)
	descLb2:setAnchorPoint(ccp(0,0.5))
	descLb2:setPosition(adaptX + maxX+subPos2,infoHeight/8)
	infoBg:addChild(descLb2)

	local function onClickInfo()
		PlayEffect(audioCfg.mouseClick)
		worldWarVoApi:showIntroduceDialog(self.layerNum + 1)
	end
	local descItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickInfo,2,getlocal("activity_baseLeveling_ruleTitle"),25)
	local descBtn=CCMenu:createWithItem(descItem)
	descBtn:setPosition(G_VisibleSizeWidth/6,60)
	descBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(descBtn)

	local function onClickFlower()
		local roundStatus=worldWarVoApi:getRoundStatus(1,1)
		if(roundStatus==0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_notKOMatch"),30)
			do return end
		end
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        	
        local function getScheduleInfoHandler1()
        	local function getScheduleInfoHandler2()
	            --去献花
		        local function gotoHandler()
		        	local status=worldWarVoApi:checkStatus()
		        	if status and status<30 then
		        		-- local goType
			        	-- if status<20 then
			        	-- 	goType=0
			        	-- elseif status==20 then
			        	-- 	if worldWarVoApi:getRoundStatus(0)<30 then
			        	-- 		goType=0
			        	-- 	else
			        	-- 		goType=1
			        	-- 	end
			        	-- end
				        -- if goType==nil or (goType and goType<0) then
				        --     do return false end
				        -- end
				        -- local scene
				        -- if goType==0 then
				        --     scene=serverWarPersonalTeamScene
				        -- elseif goType>0 then
				        --     scene=serverWarPersonalKnockOutScene
				        -- end
				        local goType=2
				        local function callback()
				            -- scene:show(self.layerNum+1)
				            if self.worldWarDialogTab1 then
				            	self.worldWarDialogTab1:switchSubTab(goType)
				            end
				        end
				        -- worldWarVoApi:getScheduleInfo(callback)
				        worldWarVoApi:getWarInfo(callback)
				        return true
				    end
			    end
			    --领取奖励回调
			    local function rewardHandler()
			    	-- if self then
			    	-- 	self:tick()
			    	-- end
			    end
		        smallDialog:showWorldWarFlowerInfoDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("world_war_flower_info"),gotoHandler,rewardHandler)
	        	
		        -- self.tipSp3:setVisible(false)
		    end
	        worldWarVoApi:getScheduleInfo(2,getScheduleInfoHandler2)
        end
        worldWarVoApi:getScheduleInfo(1,getScheduleInfoHandler1)
	end
	local flowerItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickFlower,2,getlocal("world_war_flower_info"),flowerDetSize)
	local flowerBtn=CCMenu:createWithItem(flowerItem)
	flowerBtn:setPosition(G_VisibleSizeWidth/2,60)
	flowerBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(flowerBtn)

	self.tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp:setPosition(ccp(flowerItem:getContentSize().width-10,flowerItem:getContentSize().height-10))
	self.tipSp:setTag(11)
	self.tipSp:setVisible(false)
	flowerItem:addChild(self.tipSp)

	local function onClickReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(worldWarVoApi:getSignStatus()~=nil)then
			worldWarVoApi:showRewardInfoDialog(self.layerNum+1,worldWarVoApi:getSignStatus() - 1)
		else
			worldWarVoApi:showRewardInfoDialog(self.layerNum+1)
		end
	end
	local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickReward,2,getlocal("award"),25)
	local rewardBtn=CCMenu:createWithItem(rewardItem)
	rewardBtn:setPosition(G_VisibleSizeWidth*5/6,60)
	rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(rewardBtn)
end

function worldWarDialogPageSign:clickSign(type)
	if(worldWarVoApi:getSignStatus()==nil)then
		local canSign=worldWarVoApi:checkCanSign()
		if(canSign==0)then
			worldWarVoApi:showSignDialog(type,self.layerNum+1)
		elseif(canSign==1)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_signRank",{playerVoApi:getRankName(worldWarCfg.signRank)}),30)
		elseif(canSign==2)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_notInSigntime"),30)
		end
	end
end

function worldWarDialogPageSign:tick()
	local initFlag=worldWarVoApi:getInitFlag()
	if self and self.tipSp and initFlag and initFlag==1 then
		local isShow=worldWarVoApi:isShowBetRewardTip()
		if isShow==true then
			if self.tipSp:isVisible()==false then
				self.tipSp:setVisible(true)
			end
		else
			if self.tipSp:isVisible()==true then
				self.tipSp:setVisible(false)
			end
		end
	end
end

function worldWarDialogPageSign:dispose()
	eventDispatcher:removeEventListener("worldwar.signup",self.signListener)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end