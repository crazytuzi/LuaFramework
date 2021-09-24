localWarDialogTab1={}

function localWarDialogTab1:new()
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

	return nc
end

function localWarDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initLayer()
	return self.bgLayer
end

function localWarDialogTab1:initLayer()
	-- local kingCityLb=GetTTFLabelWrap(getlocal("local_war_king_city"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local kingCityLb=GetTTFLabel(getlocal("local_war_king_city"),30)
    kingCityLb:setAnchorPoint(ccp(0.5,0.5))
	kingCityLb:setColor(G_ColorYellowPro)
	kingCityLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-200))
	self.bgLayer:addChild(kingCityLb,1)

	local function cTouch()
    end
	-- local mapSp=CCSprite:create("story/CheckpointBg.jpg")
	local mapSp=CCSprite:create("public/localWar/localWarMapScene.jpg")
    mapSp:setAnchorPoint(ccp(0.5,0.5))
    mapSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	mapSp:setScaleX(0.45)
	mapSp:setScaleY(0.24)
	self.bgLayer:addChild(mapSp,1)
	local bordBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegionalWarDialogBg.png",CCRect(20,20,10,10),cTouch)
	bordBg:setContentSize(CCSizeMake(mapSp:getContentSize().width*0.45,mapSp:getContentSize().height*0.24))
	bordBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	self.bgLayer:addChild(bordBg,5)
    

	local baseScale=1.3
	local basePic=localWarMapCfg.cityCfg[localWarMapCfg.capitalID].icon
	local baseSp=CCSprite:createWithSpriteFrameName(basePic)
    baseSp:setAnchorPoint(ccp(0.5,0.5))
    baseSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	self.bgLayer:addChild(baseSp,2)
	baseSp:setScale(baseScale)
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
	self.statusLb=GetTTFLabelWrap(statusStr,25,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.cdLb=GetTTFLabel(G_getTimeStr(cdTime),25)
	local spWidth=self.statusLb:getContentSize().width+20
	if self.statusLb:getContentSize().width<self.cdLb:getContentSize().width then
		spWidth=self.cdLb:getContentSize().width+20
	end
    self.statusSprie=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),cTouch)
    self.statusSprie:setContentSize(CCSizeMake(spWidth,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
    self.statusSprie:setPosition(getCenterPoint(baseSp))
    baseSp:addChild(self.statusSprie,3)
    self.statusLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.statusSprie:getContentSize().height-self.statusLb:getContentSize().height/2-10))
    self.statusLb:setColor(G_ColorYellowPro)
	self.statusSprie:addChild(self.statusLb,1)
	self.cdLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.cdLb:getContentSize().height/2+10))
	self.statusSprie:addChild(self.cdLb,1)
	self.statusSprie:setScale(1/baseScale)
	
	self.protectedSp=CCSprite:createWithSpriteFrameName("ShieldingShape.png")
	self.protectedSp:setAnchorPoint(ccp(0.5,0.5))
	self.protectedSp:setPosition(getCenterPoint(baseSp))
	baseSp:addChild(self.protectedSp,2)
	self.protectedSp:setScale(2.5)



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
	local status,timeStr,color=localWarVoApi:checkStatus()
	local lbPosX=self.bgLayer:getContentSize().width/2
	local lbHeight=self.bgLayer:getContentSize().height-680
	local sHeight=110
	local spaceY=lbHeight/3
	local lbSpaceY=3
	local lbTab={
		{getlocal("local_war_king_city_belongs"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+lbHeight/3*2+spaceY/3*2+lbSpaceY),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{ownName,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+lbHeight/3*2+spaceY/3-lbSpaceY),self.bgLayer,1,G_ColorYellowPro},
		{getlocal("local_war_office_1"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+lbHeight/3*1+spaceY/3*2+lbSpaceY),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{ownLeaderName,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+lbHeight/3*1+spaceY/3-lbSpaceY),self.bgLayer,1,G_ColorYellowPro},
		{getlocal("local_war_bid_time"),25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY/3*2+lbSpaceY),self.bgLayer,1,G_ColorWhite,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
		{timeStr,25,ccp(0.5,0.5),ccp(lbPosX,sHeight+spaceY/3-lbSpaceY),self.bgLayer,1,color},
	}
	for k,v in pairs(lbTab) do
		local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
		local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
		if k==2 then
			self.ownNameLb=lb
		elseif k==4 then
			self.ownLeaderNameLb=lb
		elseif k==5 then
			self.statusTimeLb=lb
		elseif k==6 then
			self.timeLb=lb
		end
	end

	for i=1,2 do
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,0.5))
		lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
		lineSp:setScaleY(1.2)
		lineSp:setPosition(ccp(lbPosX,sHeight+lbHeight/3*i))
		self.bgLayer:addChild(lineSp,2) 
	end

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
    historyMenu:setPosition(ccp(self.bgLayer:getContentSize().width-80,sHeight+lbHeight/3*2+spaceY/2))
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

function localWarDialogTab1:refresh()

end

function localWarDialogTab1:tick()
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

function localWarDialogTab1:dispose()
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
end
