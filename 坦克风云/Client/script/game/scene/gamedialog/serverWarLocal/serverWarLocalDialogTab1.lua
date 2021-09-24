serverWarLocalDialogTab1={}

function serverWarLocalDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.againstRankBtn=nil
	self.signupBtn=nil
	self.joinBattleBtn=nil
	self.rewardBtn=nil
	self.reportBtn=nil
	self.againstRankMenu=nil
	self.signupMenu=nil
	self.joinBattleMenu=nil
	self.rewardMenu=nil
	self.reportMenu=nil
	-- self.statusTimeLb=nil
	-- self.timeLb=nil
	self.status=nil
	self.statusLb=nil
	self.cdLb=nil
	self.statusSprie=nil
	-- self.protectedSp=nil
	self.ownNameLb=nil
	self.ownLeaderNameLb=nil

	return nc
end

function serverWarLocalDialogTab1:init(layerNum,parent)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addTexture("public/serverWarLocal/sceneBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initLayer()
	--下载结算时等待页面的资源
	serverWarLocalVoApi:getSettlementWaitingSprite()
	return self.bgLayer
end

function serverWarLocalDialogTab1:initLayer()
-- 	-- local kingCityLb=GetTTFLabelWrap(getlocal("local_war_king_city"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
--     local kingCityLb=GetTTFLabel(getlocal("local_war_king_city"),30)
--     kingCityLb:setAnchorPoint(ccp(0.5,0.5))
-- 	kingCityLb:setColor(G_ColorYellowPro)
-- 	kingCityLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-200))
-- 	self.bgLayer:addChild(kingCityLb,1)
	
    local mx,my=self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-360
	local mScalex,mScaley=1,1--0.45,0.3
	local function cTouch()
    end
	-- local mapSp=CCSprite:create("story/CheckpointBg.jpg")
	if G_getIphoneType() == G_iphoneX then
		my = my - 220
	end
	local texture=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
	local mapSp=CCSprite:createWithTexture(texture)
	mapSp:setAnchorPoint(ccp(0.5,0.5))
    mapSp:setPosition(ccp(mx,my))
	mapSp:setScaleX(mScalex)
	mapSp:setScaleY(mScaley)
	self.bgLayer:addChild(mapSp,1)
	-- local bordBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegionalWarDialogBg.png",CCRect(20,20,10,10),cTouch)
	-- bordBg:setContentSize(CCSizeMake(mapSp:getContentSize().width*mScalex,mapSp:getContentSize().height*mScaley))
	-- bordBg:setPosition(ccp(mx,my))
	-- self.bgLayer:addChild(bordBg,2)
    

	-- local baseScale=3.5
	-- local baseSp=CCSprite:createWithSpriteFrameName("RegionalStationsIcon.png")
 --    baseSp:setAnchorPoint(ccp(0.5,0.5))
 --    baseSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-400))
	-- self.bgLayer:addChild(baseSp,2)
	-- baseSp:setScale(baseScale)
	local lbWidth=250
	
	local checkStatus,lbColor,endTime=serverWarLocalVoApi:checkStatus()
	local cdTime=-1
	if endTime and endTime>0 and endTime>=base.serverTime then
		cdTime=endTime-base.serverTime
	end
	print("checkStatus-----????",checkStatus)
	local statusStr=""
	if checkStatus==0 then
		statusStr=getlocal("local_war_stage_1")
	elseif checkStatus == 8 then
		statusStr = getlocal("local_war_stage_0")
	elseif checkStatus==10 then
		statusStr=getlocal("local_war_stage_2")
	elseif checkStatus==20 then
		statusStr=getlocal("local_war_stage_3")
	elseif checkStatus==21 then
		statusStr=getlocal("serverWarLocal_status_A_battle")
	elseif checkStatus==22 then
		statusStr=getlocal("serverWarLocal_status_6")
	elseif checkStatus==23 then
		statusStr=getlocal("serverWarLocal_status_B_battle")
	elseif checkStatus==24 then
		statusStr=getlocal("serverWarLocal_status_wait_B")
	else
		statusStr=getlocal("serverWarLocal_status_5")
	end
	self.statusLb=GetTTFLabelWrap(statusStr,25,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	if cdTime<0 then
		self.cdLb=GetTTFLabel("——",25)
	else
		self.cdLb=GetTTFLabel(G_getTimeStr(cdTime),25)
	end
	local spWidth=self.statusLb:getContentSize().width+20
	if self.statusLb:getContentSize().width<self.cdLb:getContentSize().width then
		spWidth=self.cdLb:getContentSize().width+20
	end
	local descLbY = 60
    if G_getIphoneType() == G_iphoneX then
    	descLbY = -120
    end
    self.statusSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),cTouch)
    -- self.statusSprie:setContentSize(CCSizeMake(spWidth,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
    self.statusSprie:setContentSize(CCSizeMake(250,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
    self.statusSprie:setPosition(ccp(mapSp:getContentSize().width/2,mapSp:getContentSize().height-descLbY))
    mapSp:addChild(self.statusSprie,3)
    print ("shuchu",descLbY)
    self.statusLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.statusSprie:getContentSize().height-self.statusLb:getContentSize().height/2-10))
    self.statusLb:setColor(G_ColorYellowPro)
	self.statusSprie:addChild(self.statusLb,1)
	self.cdLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.cdLb:getContentSize().height/2+10))
	self.statusSprie:addChild(self.cdLb,1)
	self.statusSprie:setScaleX(1/mScalex)
	if checkStatus == 8 or checkStatus == 10 then
			local function allianceRankCallBack( )
				local teamTb = serverWarLocalVoApi:getTeamTb( )
				local checkStatus = serverWarLocalVoApi:checkStatus()
				local function showAllAllianceRankInfo( )
							CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
						    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
							CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
						    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
						    	spriteController:addPlist("public/exerwar_images.plist")
							    spriteController:addTexture("public/exerwar_images.png")
							    spriteController:addPlist("public/youhuaUI3.plist")
							    spriteController:addTexture("public/youhuaUI3.png")
							    spriteController:addPlist("public/juntuanCityBtns.plist")
							    spriteController:addTexture("public/juntuanCityBtns.png")
							    spriteController:addPlist("public/newAlliance.plist")
							    spriteController:addPlist("public/believer/believerMain.plist")
							    spriteController:addTexture("public/believer/believerMain.png")
							    spriteController:addTexture("public/newAlliance.png")
							CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
						    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

							require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
							local titleStr = getlocal("allianceRank")
							local subTitleStr = getlocal("serverWarLocal_rankTip",{serverWarLocalVoApi:getThisServersTeamNum()})
							local needTb = {"allianceInfoNow",titleStr,subTitleStr,teamTb}
							local sd = acThrivingSmallDialog:new(self.layerNum + 1,needTb)
						    sd:init()
						    return sd
				end
				if checkStatus == 8 and allianceVoApi:getNeedGetList(10) then
				 	 local function getListHandler(fn,data)
			            if base:checkServerData(data)==true then
			            	 showAllAllianceRankInfo()
						 	 allianceVoApi:setLastListTime(base.serverTime)
					 	end
					 end
					 socketHelper:allianceList(getListHandler,1)
				elseif checkStatus == 10 and not teamTb then
					G_ShowFloatingBoard(getlocal("serverWarLocal_noData"))
					do return end
				else
					showAllAllianceRankInfo()
				end
				 
			end

			local btnScale,priority=0.8,-(self.layerNum-1)*20-2
			local allianceRankBtn=G_createBotton(mapSp,ccp(mapSp:getContentSize().width * 0.5,40),{getlocal("allianceRank")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",allianceRankCallBack,btnScale,priority)
	end

	local adaH = 680
	if G_getIphoneType() == G_iphoneX then
		adaH = 880
	end
	local descStrTb,descColorTb = {},{}
	if checkStatus < 20 then
		descStrTb = {getlocal("serverWarLocal_desc_title"),getlocal("serverWarLocal_info1"),getlocal("local_war_signUpRule"),getlocal("serverWarLocal_help_content0",{serverWarLocalVoApi:getThisServersTeamNum()}),getlocal("local_war_signUpWay"),getlocal("serverWarLocal_help_content1"),getlocal("serverWarLocal_help_content12")}
		descColorTb = {G_ColorYellowPro,G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorRed}
	else
		descStrTb = {getlocal("serverWarLocal_desc_title"),getlocal("serverWarLocal_info1")}
		descColorTb = {G_ColorYellowPro,G_ColorWhite}
	end

	local size=CCSizeMake(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-adaH)
	local lbTv,descLb=G_LabelTableView(size,descStrTb,25,kCCTextAlignmentLeft,descColorTb)

	lbTv:setPosition(ccp(40,120))
	lbTv:setAnchorPoint(ccp(0,0))
	lbTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	lbTv:setMaxDisToBottomOrTop(200)
	self.bgLayer:addChild(lbTv,5)

	local btnHeight,btnScale=70,0.8
	local function onClickAgainstRank()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        serverWarLocalVoApi:showAgainstRankDialog(self.layerNum+1)
    end
    self.againstRankBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickAgainstRank,2,getlocal("serverWarLocal_against_rank"),25/btnScale)
    self.againstRankBtn:setScale(btnScale)
    self.againstRankMenu=CCMenu:createWithItem(self.againstRankBtn);
    self.againstRankMenu:setPosition(ccp(120,btnHeight))
    self.againstRankMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.againstRankMenu)

    local function onClickSignup()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        local signupStatus=serverWarLocalVoApi:canSignupStatus()
        -- print("signupStatus",signupStatus)
        if signupStatus==0 then
        	local function onConfirm( ... )
        		local selfAlliance=allianceVoApi:getSelfAlliance()
        		if selfAlliance and selfAlliance.point and selfAlliance.point>=serverWarLocalCfg.minRegistrationFee then
			        local function bidCallback( ... )
			        	if self.signupBtn then
			        		self.signupBtn:setEnabled(false)
			        	end
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_signup_success"),30)
			        end
			        serverWarLocalVoApi:bid(bidCallback)
			    end
		    end
        	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverWarLocal_signup_sure",{serverWarLocalCfg.minRegistrationFee}),nil,self.layerNum+1)
        end
    end
    self.signupBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickSignup,2,getlocal("serverwarteam_apply"),25/btnScale)
    self.signupBtn:setScale(btnScale)
    self.signupMenu=CCMenu:createWithItem(self.signupBtn);
    self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
    self.signupMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.signupMenu)
    
	local function onClickJoinBattle()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        if serverWarLocalVoApi:canJoinBattle()==true then
	        require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalFightVoApi"
		    serverWarLocalFightVoApi:showMap(self.layerNum+1)
	    end
    end
    self.joinBattleBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onClickJoinBattle,3,getlocal("allianceWar_enterBattle"),25/btnScale)
    self.joinBattleBtn:setScale(btnScale)
    self.joinBattleMenu=CCMenu:createWithItem(self.joinBattleBtn);
    self.joinBattleMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
    self.joinBattleMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.joinBattleMenu)
    self.joinBattleBtn:setEnabled(false)
    self.joinBattleBtn:setVisible(false)

    local function onClickReward()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        serverWarLocalVoApi:showRewardDialog(self.layerNum+1)
    end
    -- self.rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onClickReward,4,getlocal("award"),25)
    self.rewardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickReward,4,getlocal("award"),25/btnScale)
    self.rewardBtn:setScale(btnScale)
    self.rewardMenu=CCMenu:createWithItem(self.rewardBtn);
    self.rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnHeight))
    self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.rewardMenu)

    local function onClickReport()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        serverWarLocalVoApi:showReportDialog(self.layerNum+1)
    end
    self.reportBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onClickReport,5,getlocal("local_war_history_report"),25)
    self.reportBtn:setScale(btnScale)
    self.reportMenu=CCMenu:createWithItem(self.reportBtn);
    self.reportMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
    self.reportMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(self.reportMenu)
    self.reportBtn:setEnabled(false)
    self.reportBtn:setVisible(false)

    self:tick()
end

function serverWarLocalDialogTab1:refresh()

end

function serverWarLocalDialogTab1:tick()
	local status,color,endTime=serverWarLocalVoApi:checkStatus()
	-- print("status",status)
	if self and self.statusLb and self.cdLb then
		local cdTime=-1
		if endTime>0 and endTime>=base.serverTime then
			cdTime=endTime-base.serverTime
		end
		-- print("status,cdTime",status,cdTime)
		local statusStr=""
		if status<30 then
			statusStr=getlocal("local_war_stage_1")
			if status == 8 then
				statusStr = getlocal("local_war_stage_0")
			elseif status==10 then
				statusStr=getlocal("local_war_stage_2")
			elseif status==20 then
				statusStr=getlocal("local_war_stage_3")
			elseif status==21 then
				statusStr=getlocal("serverWarLocal_status_A_battle")
			elseif status==22 then
				statusStr=getlocal("serverWarLocal_status_6")
			elseif status==23 then
				statusStr=getlocal("serverWarLocal_status_B_battle")
			elseif status==24 then
				statusStr=getlocal("serverWarLocal_status_wait_B")
			end
		else
			statusStr=getlocal("serverWarLocal_status_5")
		end
		self.statusLb:setString(statusStr)
		self.statusLb:setColor(color)
		if cdTime<0 then
			self.cdLb:setString("——")
		else
			self.cdLb:setString(G_getTimeStr(cdTime))
		end
		local spWidth=self.statusLb:getContentSize().width+20
		if self.statusLb:getContentSize().width<self.cdLb:getContentSize().width then
			spWidth=self.cdLb:getContentSize().width+20
		end
		if self.statusSprie then
			if self.statusSprie:getContentSize().width<spWidth then
			    self.statusSprie:setContentSize(CCSizeMake(spWidth,self.statusLb:getContentSize().height+self.cdLb:getContentSize().height+20))
			    self.statusLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.statusSprie:getContentSize().height-self.statusLb:getContentSize().height/2-10))
				self.cdLb:setPosition(ccp(self.statusSprie:getContentSize().width/2,self.cdLb:getContentSize().height/2+10))
			end
		end
	end
	if self and self.signupBtn and self.joinBattleBtn and self.reportBtn then
		if self.status~=status then
			self.status=status
			local statusTimeStr=""
			local btnHeight=70
			self.againstRankBtn:setEnabled(true)
			self.rewardBtn:setEnabled(true)
			if status==0 then
				-- self.againstRankBtn:setVisible(false)
				-- self.againstRankBtn:setEnabled(false)
				self.signupBtn:setVisible(false)
				self.signupBtn:setEnabled(false)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)
				-- self.rewardBtn:setVisible(false)
				-- self.rewardBtn:setEnabled(false)

				-- statusTimeStr=getlocal("local_war_bid_time")
			elseif status<20 then
				-- self.againstRankBtn:setVisible(true)
				-- self.againstRankBtn:setEnabled(true)
				self.signupBtn:setVisible(true)
				self.signupBtn:setEnabled(true)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)
				-- self.rewardBtn:setVisible(false)
				-- self.rewardBtn:setEnabled(false)

				-- self.againstRankMenu:setPosition(ccp(180,btnHeight))
				-- self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-180,btnHeight))
				-- statusTimeStr=getlocal("local_war_bid_time")
			elseif status<30 then
				-- self.againstRankBtn:setVisible(true)
				-- self.againstRankBtn:setEnabled(true)
				self.signupBtn:setVisible(false)
				self.signupBtn:setEnabled(false)
				self.joinBattleBtn:setVisible(true)
				self.joinBattleBtn:setEnabled(true)
				self.reportBtn:setVisible(false)
				self.reportBtn:setEnabled(false)
				-- self.rewardBtn:setVisible(false)
				-- self.rewardBtn:setEnabled(false)

				-- self.againstRankMenu:setPosition(ccp(120,btnHeight))
				-- self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnHeight))
				-- self.joinBattleMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
				-- statusTimeStr=getlocal("local_war_fight_time")
				if status==22 then
					self.joinBattleBtn:setEnabled(false)
					self.againstRankBtn:setEnabled(false)
					self.rewardBtn:setEnabled(false)
				end
				if status==24 then
					self.joinBattleBtn:setEnabled(false)
				end
			elseif status>=30 then
				-- self.againstRankBtn:setVisible(true)
				-- self.againstRankBtn:setEnabled(true)
				self.signupBtn:setVisible(false)
				self.signupBtn:setEnabled(false)
				self.joinBattleBtn:setVisible(false)
				self.joinBattleBtn:setEnabled(false)
				self.reportBtn:setVisible(true)
				self.reportBtn:setEnabled(true)
				-- self.rewardBtn:setVisible(true)
				-- self.rewardBtn:setEnabled(true)

				-- self.againstRankMenu:setPosition(ccp(120,btnHeight))
				-- self.rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnHeight))
				-- self.signupMenu:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnHeight))
				-- statusTimeStr=getlocal("local_war_occupied_time")
			end
			-- if self.statusTimeLb then
			-- 	self.statusTimeLb:setString(statusTimeStr)
			-- end
			-- if self.timeLb then
			-- 	self.timeLb:setString(timeStr)
			-- 	self.timeLb:setColor(color)
			-- end
			local groupId=serverWarLocalVoApi:getGroupID()
			if groupId==nil and status>10 then --如果没有参赛资格的军团无法参战
				self.joinBattleBtn:setEnabled(false)
			end
		end
	end

	-- if self then
	-- 	local ownCityInfo=serverWarLocalVoApi:getOwnCityInfo()
	-- 	local ownName=getlocal("fight_content_null")
	-- 	local ownLeaderName=getlocal("fight_content_null")
	-- 	if ownCityInfo then
	-- 		if ownCityInfo.name then
	-- 			ownName=ownCityInfo.name
	-- 		end
	-- 		if ownCityInfo.kingname then
	-- 			ownLeaderName=ownCityInfo.kingname
	-- 		end
	-- 	end
	-- 	if self.ownNameLb then
	-- 		self.ownNameLb:setString(ownName)
	-- 	end
	-- 	if self.ownLeaderNameLb then
	-- 		self.ownLeaderNameLb:setString(ownLeaderName)
	-- 	end
	-- end
end

function serverWarLocalDialogTab1:dispose()
	spriteController:removeTexture("public/serverWarLocal/sceneBg.jpg")
	self.bgLayer=nil
	self.layerNum=nil
	self.againstRankBtn=nil
	self.signupBtn=nil
	self.joinBattleBtn=nil
	self.rewardBtn=nil
	self.reportBtn=nil
	self.againstRankMenu=nil
	self.signupMenu=nil
	self.joinBattleMenu=nil
	self.rewardMenu=nil
	self.reportMenu=nil
	-- self.statusTimeLb=nil
	-- self.timeLb=nil
	self.status=nil
	self.statusLb=nil
	self.cdLb=nil
	self.statusSprie=nil
	-- self.protectedSp=nil
	self.ownNameLb=nil
	self.ownLeaderNameLb=nil
end
