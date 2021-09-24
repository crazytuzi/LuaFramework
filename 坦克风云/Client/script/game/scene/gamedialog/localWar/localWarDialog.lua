-- require "luascript/script/game/scene/gamedialog/localWar/localWarDialog"
-- require "luascript/script/game/scene/gamedialog/localWar/localWarDialogTab2"
require "luascript/script/config/gameconfig/localWar/localWarMapCfg"

localWarDialog=commonDialog:new()

function localWarDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.detailBtn=nil
	self.signupBtn=nil
	self.joinBattleBtn=nil
	self.reportBtn=nil
	self.detailMenu=nil
	self.signupMenu=nil
	self.joinBattleMenu=nil
	self.reportMenu=nil
	self.statusTimeLb=nil
	self.timeLb=nil
	self.status=nil
	self.statusLb=nil
	self.cdLb=nil
	self.statusSprie=nil
	self.protectedSp=nil
	self.ownNameLb=nil
	self.ownLeaderNameLb=nil
	self.addBuffLb=nil
	self.serverTimeLb=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWarCityIcon.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
	spriteController:addPlist("public/acNewYearsEva.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
	return nc
end

function localWarDialog:initTableView()
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))

	self:initLayer()
end

function localWarDialog:initLayer()
	-- -- local kingCityLb=GetTTFLabelWrap(getlocal("local_war_king_city"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
 --    local kingCityLb=GetTTFLabel(getlocal("local_war_king_city"),30)
 --    kingCityLb:setAnchorPoint(ccp(0.5,0.5))
	-- kingCityLb:setColor(G_ColorYellowPro)
	-- kingCityLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-200))
	-- self.bgLayer:addChild(kingCityLb,1)

	-- local function cTouch()
 --    end
	-- -- local mapSp=CCSprite:create("story/CheckpointBg.jpg")
	-- local mapSp=CCSprite:create("public/localWar/localWarMapScene.jpg")
 --    mapSp:setAnchorPoint(ccp(0.5,0.5))
 --    mapSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	-- mapSp:setScaleX(0.45)
	-- mapSp:setScaleY(0.24)
	-- self.bgLayer:addChild(mapSp,1)
	-- local bordBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegionalWarDialogBg.png",CCRect(20,20,10,10),cTouch)
	-- bordBg:setContentSize(CCSizeMake(mapSp:getContentSize().width*0.45,mapSp:getContentSize().height*0.24))
	-- bordBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	-- self.bgLayer:addChild(bordBg,5)
    

	local baseScale=1.3
	-- local basePic=localWarMapCfg.cityCfg[localWarMapCfg.capitalID].icon
	-- local baseSp=CCSprite:createWithSpriteFrameName(basePic)
 --    baseSp:setAnchorPoint(ccp(0.5,0.5))
 --    baseSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	-- self.bgLayer:addChild(baseSp,2)
	-- baseSp:setScale(baseScale)
	local lbWidth=250
	
	local checkStatus,tStr,lbColor,endTime=localWarVoApi:checkStatus()
	local cdTime=0
	if endTime>0 and endTime>=base.serverTime then
		cdTime=endTime-base.serverTime
	end
	local statusStr=""
	if checkStatus==0 then
		statusStr=getlocal("local_war_stage_1")
	elseif checkStatus==10 then
		statusStr=getlocal("local_war_stage_2")
	elseif checkStatus==20 then
		statusStr=getlocal("local_war_stage_3")
	elseif checkStatus==21 then
		statusStr=getlocal("local_war_stage_4")
	else
		statusStr=getlocal("local_war_stage_5")
	end
	-- self.statusLb=GetTTFLabelWrap(statusStr,25,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- self.cdLb=GetTTFLabel(G_getTimeStr(cdTime),25)
	-- local spWidth=self.statusLb:getContentSize().width+20
	-- if self.statusLb:getContentSize().width<self.cdLb:getContentSize().width then
	-- 	spWidth=self.cdLb:getContentSize().width+20
	-- end
 --    self.statusSprie=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),cTouch)
 --    self.statusSprie:setContentSize(CCSizeMake(spWidth,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
 --    self.statusSprie:setPosition(getCenterPoint(baseSp))
 --    baseSp:addChild(self.statusSprie,3)
 --    self.statusLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.statusSprie:getContentSize().height-self.statusLb:getContentSize().height/2-10))
 --    self.statusLb:setColor(G_ColorYellowPro)
	-- self.statusSprie:addChild(self.statusLb,1)
	-- self.cdLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.cdLb:getContentSize().height/2+10))
	-- self.statusSprie:addChild(self.cdLb,1)
	-- self.statusSprie:setScale(1/baseScale)
	
	-- self.protectedSp=CCSprite:createWithSpriteFrameName("ShieldingShape.png")
	-- self.protectedSp:setAnchorPoint(ccp(0.5,0.5))
	-- self.protectedSp:setPosition(getCenterPoint(baseSp))
	-- baseSp:addChild(self.protectedSp,2)
	-- self.protectedSp:setScale(2.5)


	local function showOffice()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        
    	localWarVoApi:showOfficeDialog(self.layerNum+1)
	end
	local officeBg=LuaCCSprite:createWithFileName("public/localWar/localWarBg1.jpg",showOffice)
	officeBg:setPosition(ccp(officeBg:getContentSize().width/2+40,self.bgLayer:getContentSize().height-officeBg:getContentSize().height/2-110))
	officeBg:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(officeBg,1)
	local function cTouch()
    end
    local bordBg1=LuaCCScale9Sprite:createWithSpriteFrameName("RegionalWarDialogBg.png",CCRect(20,20,10,10),cTouch)
	bordBg1:setContentSize(CCSizeMake(officeBg:getContentSize().width,officeBg:getContentSize().height))
	bordBg1:setPosition(getCenterPoint(officeBg))
	officeBg:addChild(bordBg1,2)
	local gloryLb=GetTTFLabelWrap(getlocal("local_war_glory"),25,CCSizeMake(officeBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	gloryLb:setPosition(officeBg:getContentSize().width/2,45)
	officeBg:addChild(gloryLb,2)

	local function showReward()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        localWarVoApi:showRewardDialog(self.layerNum+1)
	end
	local rewardBg=LuaCCSprite:createWithFileName("public/localWar/localWarBg2.jpg",showReward)
	rewardBg:setPosition(ccp(self.bgLayer:getContentSize().width-rewardBg:getContentSize().width/2-40,self.bgLayer:getContentSize().height-officeBg:getContentSize().height/2-110))
	rewardBg:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(rewardBg,1)
	local function cTouch()
    end
	local bordBg2=LuaCCScale9Sprite:createWithSpriteFrameName("RegionalWarDialogBg.png",CCRect(20,20,10,10),cTouch)
	bordBg2:setContentSize(CCSizeMake(rewardBg:getContentSize().width,officeBg:getContentSize().height))
	bordBg2:setPosition(getCenterPoint(rewardBg))
	rewardBg:addChild(bordBg2,2)
	local rewardLb=GetTTFLabelWrap(getlocal("award"),25,CCSizeMake(rewardBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	rewardLb:setPosition(officeBg:getContentSize().width/2,45)
	rewardBg:addChild(rewardLb,2)


	local isAddBuff=0
    local ownCity=localWarVoApi:getOwnCityInfo()
    if ownCity and ownCity.wcount and tonumber(ownCity.wcount) and tonumber(ownCity.wcount)>0 then
        isAddBuff=1
    end
	local addHeight=0
	local addHeight2=0
	if isAddBuff==1 then
		addHeight=10
		addHeight2=25
	end
	local ownName=getlocal("fight_content_null")
	local ownLeaderName=getlocal("fight_content_null")
	if ownCityInfo then
		if ownCityInfo.name then
			ownName=ownCityInfo.name
		end
		if ownCityInfo.kingname then
			ownLeaderName=ownCityInfo.kingname
		end
	end
	local status,timeStr,color=localWarVoApi:checkStatus()
	local lbPosX=self.bgLayer:getContentSize().width/2
	local lbNum=4
	-- local lbHeight=self.bgLayer:getContentSize().height-680
	local lbHeight=self.bgLayer:getContentSize().height-540
	local sHeight=110
	local spaceY=lbHeight/4
	local lbSpaceY=3
	if G_isIphone5()==true then
		if isAddBuff==1 then
			lbSpaceY=6
		else
			lbSpaceY=8
		end
	end
	local lbTab={
		{getlocal("local_war_king_city_belongs"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*3+spaceY/3*2+lbSpaceY),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{ownName,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*3+spaceY/3-lbSpaceY),self.bgLayer,1,G_ColorYellowPro},
		{getlocal("local_war_office_1"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*2+spaceY/3*2+lbSpaceY+10+addHeight),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{ownLeaderName,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*2+spaceY/3-lbSpaceY+15+addHeight),self.bgLayer,1,G_ColorYellowPro},
		{getlocal("local_war_bid_time"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*1+spaceY/3*2+lbSpaceY+addHeight2),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{timeStr,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*1+spaceY/3-lbSpaceY+addHeight2),self.bgLayer,1,color},
		{statusStr,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY/3*2+lbSpaceY),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{cdTime,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY/3-lbSpaceY-5),self.bgLayer,1,color},
		{getlocal("to_server_time"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY*1+15-lbSpaceY+addHeight2),self.bgLayer,1,G_ColorGreen},
	}
	for k,v in pairs(lbTab) do
		local adaCH = 0
		if G_getIphoneType() == G_iphoneX then
			adaCH = 40
		end
		local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
		local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
		if k==2 then
			lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+adaCH))
			self.ownNameLb=lb
		elseif k == 3 then
			lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+adaCH))
		elseif k==4 then
			self.ownLeaderNameLb=lb
			lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+adaCH))
		elseif k==5 then
			self.statusTimeLb=lb
			lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+adaCH))
		elseif k==6 then
			self.timeLb=lb
			if G_isGlobalServer()==true then
				lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+10))
			end
			lb:setPosition(ccp(lb:getPositionX(),lb:getPositionY()+adaCH))
		elseif k==7 then
			self.statusLb=lb
		elseif k==8 then
			self.cdLb=lb
		elseif k==9 then
			self.serverTimeLb=lb
			if G_isGlobalServer()==true then
			else
				lb:setVisible(false)
			end
		end
	end

	-- for i=1,3 do
	-- 	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	-- 	lineSp:setAnchorPoint(ccp(0.5,0.5))
	-- 	lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
	-- 	lineSp:setScaleY(1.2)
	-- 	lineSp:setPosition(ccp(lbPosX,sHeight+spaceY*i))
	-- 	self.bgLayer:addChild(lineSp,2) 
	-- end
	local adaH = 0
	if G_getIphoneType() == G_iphoneX then
		adaH = 40
	end
	local lbBg1=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    lbBg1:setPosition(ccp(lbPosX,sHeight+spaceY*3+spaceY/3*2+lbSpaceY-5))
    -- lbBg1:setScale(scale)
    lbBg1:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(lbBg1)

    local lbBg2=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    lbBg2:setScaleY(0.8)
    lbBg2:setPosition(ccp(lbPosX,sHeight+spaceY*2+spaceY/3*2+lbSpaceY+10+addHeight+adaH))
    self.bgLayer:addChild(lbBg2)

    local lbBg3=CCSprite:createWithSpriteFrameName("orangeMask.png")
    lbBg3:setPosition(ccp(lbPosX,sHeight+spaceY*1+spaceY/3*2+lbSpaceY+5+addHeight2+adaH))
    self.bgLayer:addChild(lbBg3)
    local goldLineSp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	goldLineSp:setPosition(ccp(lbBg3:getContentSize().width/2,lbBg3:getContentSize().height+adaH))
	lbBg3:addChild(goldLineSp)

	if isAddBuff==1 then
		local lbH
		if G_isGlobalServer()==true then
			lbH=sHeight+spaceY*1+spaceY/3-lbSpaceY-20
			if G_isIphone5()==true then
				lbH=lbH-20
			end
			if self.serverTimeLb then
				self.serverTimeLb:setPositionY(self.serverTimeLb:getPositionY()+3)
			end
		else
			lbH=sHeight+spaceY*1+spaceY/3-lbSpaceY-10
			if G_isIphone5()==true then
				lbH=lbH-10
			end
		end
		self.addBuffLb=GetAllTTFLabel(getlocal("local_war_add_buff_desc"),25,ccp(0.5,0.5),ccp(lbPosX,lbH),self.bgLayer,1,G_ColorWhite)
	end

	local lbBg4=CCSprite:createWithSpriteFrameName("groupSelf.png")
	lbBg4:setPosition(ccp(lbPosX+20,sHeight+spaceY*0+spaceY/3*2+lbSpaceY))
	lbBg4:setScaleY(45/lbBg4:getContentSize().height)
	lbBg4:setScaleX(600/lbBg4:getContentSize().width)
	self.bgLayer:addChild(lbBg4)
	local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp1:setScaleX((lbBg4:getContentSize().width)/lineSp1:getContentSize().width)
	lineSp1:setScaleY(1.2)
	lineSp1:setPosition(ccp(lbBg4:getContentSize().width/2,lbBg4:getContentSize().height))
	lbBg4:addChild(lineSp1,2)
	local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp2:setScaleX((lbBg4:getContentSize().width)/lineSp2:getContentSize().width)
	lineSp2:setScaleY(1.2)
	lineSp2:setPosition(ccp(lbBg4:getContentSize().width/2,0))
	lbBg4:addChild(lineSp2,2)



	local function onClickShowHistory()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        
        local function getKingCitylogCallback()
        	localWarVoApi:showHistoryDialog(self.layerNum+1)
        end
        localWarVoApi:getKingCitylog(getKingCitylogCallback)
    end
    local historyItem=GetButtonItem("worldBtnCollection.png","worldBtnCollection_Down.png","worldBtnCollection_Down.png",onClickShowHistory,2,nil,nil)
    local historyMenu=CCMenu:createWithItem(historyItem);
    historyMenu:setPosition(ccp(self.bgLayer:getContentSize().width-50,sHeight+spaceY*3+spaceY/3*2))
    historyMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(historyMenu)


	local btnHeight=70
	local function onClickDetail()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        
        localWarVoApi:showDetailDialog(self.layerNum+1)
    end
    self.detailBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickDetail,2,getlocal("playerInfo"),25)
    self.detailMenu=CCMenu:createWithItem(self.detailBtn);
    self.detailMenu:setPosition(ccp(180,btnHeight))
    self.detailMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.detailMenu)

    local function onClickSignup()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        localWarVoApi:showBidDialog(self.layerNum+1)
    end
    self.signupBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickSignup,2,getlocal("local_war_bid"),25)
    self.signupMenu=CCMenu:createWithItem(self.signupBtn);
    self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-180,btnHeight))
    self.signupMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.signupMenu)
    
	local function onClickJoinBattle()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        if localWarVoApi:canJoinBattle()==true then
	        require "luascript/script/game/gamemodel/localWar/localWarFightVoApi"
	        localWarFightVoApi:showMap(self.layerNum+1)
	    end
    end
    self.joinBattleBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClickJoinBattle,3,getlocal("allianceWar_enterBattle"),25)
    self.joinBattleMenu=CCMenu:createWithItem(self.joinBattleBtn);
    self.joinBattleMenu:setPosition(ccp(self.bgLayer:getContentSize().width-180,btnHeight))
    self.joinBattleMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.joinBattleMenu)

    local function onClickReport()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        localWarVoApi:showReportDialog(self.layerNum+1)
    end
    self.reportBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClickReport,4,getlocal("local_war_history_report"),25)
    self.reportMenu=CCMenu:createWithItem(self.reportBtn);
    self.reportMenu:setPosition(ccp(self.bgLayer:getContentSize().width-180,btnHeight))
    self.reportMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.reportMenu)

    self:tick()
end

function localWarDialog:refresh()

end

function localWarDialog:tick()
	local status,timeStr,color,endTime=localWarVoApi:checkStatus()
	if self.statusLb and self.cdLb then
		local cdTime=0
		if endTime>0 and endTime>=base.serverTime then
			cdTime=endTime-base.serverTime
		end
		local statusStr=""
		if status<30 then
			if status==0 then
				statusStr=getlocal("local_war_stage_1")
			elseif status==10 then
				statusStr=getlocal("local_war_stage_2")
			elseif status==20 then
				statusStr=getlocal("local_war_stage_3")
			else
				statusStr=getlocal("local_war_stage_4")
			end
			if self.protectedSp then
				self.protectedSp:setVisible(false)
			end
		else
			statusStr=getlocal("local_war_stage_5")
			if self.protectedSp then
				self.protectedSp:setVisible(true)
			end
		end
		self.statusLb:setString(statusStr)
		self.cdLb:setString(G_getTimeStr(cdTime))
		local spWidth=self.statusLb:getContentSize().width+20
		if self.statusLb:getContentSize().width<self.cdLb:getContentSize().width then
			spWidth=self.cdLb:getContentSize().width+20
		end
		if self.statusSprie then
		    self.statusSprie:setContentSize(CCSizeMake(spWidth,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
		end
	end
	
	if self and self.detailBtn and self.signupBtn and self.joinBattleBtn and self.reportBtn then
		if self.status~=status then
			if self.status~=nil then
				local function getApplyCallback()
				end
				localWarVoApi:getApplyData(getApplyCallback,false)
			end
			self.status=status
			local statusTimeStr=""
			local btnHeight=70
			if status==0 then
				self.detailBtn:setVisible(false)
				self.detailBtn:setEnabled(false)
				self.signupBtn:setVisible(false)
				self.signupBtn:setEnabled(false)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)

				statusTimeStr=getlocal("local_war_bid_time")
			elseif status<20 then
				self.detailBtn:setVisible(true)
				self.detailBtn:setEnabled(true)
				self.signupBtn:setVisible(true)
				self.signupBtn:setEnabled(true)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)

				self.detailMenu:setPosition(ccp(180,btnHeight))
				self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-180,btnHeight))
				statusTimeStr=getlocal("local_war_bid_time")
			elseif status<30 then
				self.detailBtn:setVisible(true)
				self.detailBtn:setEnabled(true)
				self.signupBtn:setVisible(true)
				self.signupBtn:setEnabled(true)
				self.joinBattleBtn:setVisible(true)
				self.joinBattleBtn:setEnabled(true)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)

				self.detailMenu:setPosition(ccp(120,btnHeight))
				self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnHeight))
				self.joinBattleMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
				statusTimeStr=getlocal("local_war_fight_time")
			elseif status>=30 then
				self.detailBtn:setVisible(true)
				self.detailBtn:setEnabled(true)
				self.signupBtn:setVisible(true)
				self.signupBtn:setEnabled(false)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(true)
				self.reportBtn:setEnabled(true)

				self.detailMenu:setPosition(ccp(120,btnHeight))
				self.reportMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnHeight))
				self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
				statusTimeStr=getlocal("local_war_occupied_time")
			end
			if self.statusTimeLb then
				self.statusTimeLb:setString(statusTimeStr)
			end
			if self.timeLb then
				self.timeLb:setString(timeStr)
				self.timeLb:setColor(color)
			end
		end
	end

	if self then
		local ownCityInfo=localWarVoApi:getOwnCityInfo()
		local ownName=getlocal("fight_content_null")
		local ownLeaderName=getlocal("fight_content_null")
		if ownCityInfo then
			if ownCityInfo.name then
				ownName=ownCityInfo.name
			end
			if ownCityInfo.kingname then
				ownLeaderName=ownCityInfo.kingname
			end
		end
		if self.ownNameLb then
			self.ownNameLb:setString(ownName)
		end
		if self.ownLeaderNameLb then
			self.ownLeaderNameLb:setString(ownLeaderName)
		end
	end
end

function localWarDialog:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.detailBtn=nil
	self.signupBtn=nil
	self.joinBattleBtn=nil
	self.reportBtn=nil
	self.detailMenu=nil
	self.signupMenu=nil
	self.joinBattleMenu=nil
	self.reportMenu=nil
	self.statusTimeLb=nil
	self.timeLb=nil
	self.status=nil
	self.statusLb=nil
	self.cdLb=nil
	self.statusSprie=nil
	self.protectedSp=nil
	self.ownNameLb=nil
	self.ownLeaderNameLb=nil
	self.addBuffLb=nil
	self.serverTimeLb=nil

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWarCityIcon.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWarCityIcon.png")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
	
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/heroRecruitImage.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")

	if G_isCompressResVersion()==true then
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.png")
	else
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.pvr.ccz")
	end

	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
end


