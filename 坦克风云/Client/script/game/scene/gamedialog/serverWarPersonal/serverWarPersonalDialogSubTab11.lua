serverWarPersonalDialogSubTab11={}

function serverWarPersonalDialogSubTab11:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.countDown=nil
	self.timeLb=nil

	self.fightBtn=nil
	self.rewardInfoBtn=nil
	self.flowerInfoBtn=nil

	self.tipSp1=nil
	self.tipSp2=nil
	self.tipSp3=nil
	return nc
end

function serverWarPersonalDialogSubTab11:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initTick()
	self:initUp()
	self:initDown()
	self:initBtn()
	base:addNeedRefresh(self)
	return self.bgLayer
end

function serverWarPersonalDialogSubTab11:initTick()
	self.status=serverWarPersonalVoApi:checkStatus()
	if(self.status==10)then
		local startTime=serverWarPersonalVoApi.startTime + serverWarPersonalCfg.preparetime*86400
		self.countDown=startTime-base.serverTime
	elseif(self.status==20)then
		local nextTime
		local timeTb=serverWarPersonalVoApi:getBattleTimeList()
		for i=0,#timeTb - 1 do
			local roundStatus=serverWarPersonalVoApi:getRoundStatus(i)
			if(roundStatus<30)then
				self.curRoundID=i
				self.roundStatus=roundStatus
				if(roundStatus<20)then
					nextTime=timeTb[i+1]
				else
					nextTime=timeTb[i+1] + serverWarPersonalCfg.battleTime*3
				end
				break
			end
		end
		self.countDown=nextTime-base.serverTime
	end
end

function serverWarPersonalDialogSubTab11:initUp()
	local tmpStr
	local adaH = 0
	if G_getIphoneType() == G_iphoneX then
		adaH  = 100
	end	
	if(self.status==10)then
		tmpStr=getlocal("serverwar_startCountDown")
	elseif(self.status==20)then
		if(self.roundStatus<20)then
			tmpStr=getlocal("serverwar_battleCountDown")
		else
			tmpStr=getlocal("serverwar_battle_ing")
		end
	else
		tmpStr=getlocal("activity_heartOfIron_over")
	end
	self.timeTime = GetTTFLabel(tmpStr,28)
	self.timeTime:setAnchorPoint(ccp(0.5,1))
	self.timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-220-adaH/3))
	self.bgLayer:addChild(self.timeTime)

	if(self.countDown)then
		self.timeLb=GetTTFLabel(GetTimeStr(self.countDown),25)
		self.timeLb:setAnchorPoint(ccp(0.5,1))
		self.timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-250-adaH/3))
		self.bgLayer:addChild(self.timeLb)
	end

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local contentTb={getlocal("serverwar_help_content6"),getlocal("serverwar_help_title6"),"\n",getlocal("serverwar_help_content51"),getlocal("serverwar_help_content5"),getlocal("serverwar_help_title5"),"\n",getlocal("serverwar_help_content4"),getlocal("serverwar_help_title4"),"\n",getlocal("serverwar_help_content3"),getlocal("serverwar_help_title3"),"\n",getlocal("serverwar_help_content21"),getlocal("serverwar_help_content2"),getlocal("serverwar_help_title2"),"\n",getlocal("serverwar_help_content1"),getlocal("serverwar_help_title1")}
		local colorTb={nil,G_ColorGreen,nil,G_ColorRed,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,G_ColorRed,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil}
		smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(600,750),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("help"),contentTb,colorTb,true,self.layerNum+1)
	end

	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,G_VisibleSizeHeight-220-adaH/3))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn,3);
	
	local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setAnchorPoint(ccp(0.5,0.5))
	lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
	lineSP:setScaleY(1.2)
	lineSP:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-300-adaH/3-adaH/3))
	self.bgLayer:addChild(lineSP)

	local girlImg=CCSprite:createWithSpriteFrameName("NewCharacter02.png")
	girlImg:setScale(240/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0,1))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight-290-adaH))
	self.bgLayer:addChild(girlImg,1)

	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("LanguageSelectBtn.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(400,150))
	girlDescBg:setRotation(180)
	girlDescBg:setAnchorPoint(ccp(1,0))
	girlDescBg:setPosition(200,G_VisibleSizeHeight-350-adaH)
	self.bgLayer:addChild(girlDescBg)

	local girlDesc=G_LabelTableView(CCSizeMake(360,130),getlocal("serverwar_tip1"),25,kCCTextAlignmentLeft)
	girlDesc:setPosition(230,G_VisibleSizeHeight-490-adaH)
	girlDesc:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(girlDesc)
end

function serverWarPersonalDialogSubTab11:initDown()
	local adaH = 525
	local tvSize=CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-630)
	if G_getIphoneType() == G_iphoneX then
		tvSize.height = tvSize.height - 100
		adaH = 525 + 100
	end
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... ) end)
	tvBg:setTouchPriority(-(self.layerNum-1)*20)
	tvBg:setAnchorPoint(ccp(0,1))
	tvBg:setContentSize(tvSize)
	tvBg:setPosition(ccp(30,G_VisibleSizeHeight-adaH))
	self.bgLayer:addChild(tvBg,2)

	self.cellTb={}
	self.cellHeightTb={}

	local serverList=serverWarPersonalVoApi:getServerList()
	local serverListStr=""
	for k,v in pairs(serverList) do
		if(v[2])then
			serverListStr=serverListStr..v[2].."     "
		end
		if(k%2==0 and k~=#serverList)then
			serverListStr=serverListStr.."\n"
		end
	end
	local serverListLb=GetTTFLabelWrap(serverListStr,25,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	serverListLb:setAnchorPoint(ccp(0,0.5))
	serverListLb:setColor(G_ColorYellowPro)
	serverListLb:setPosition(ccp(200,(serverListLb:getContentSize().height+50)/2+5))
	local serverDescLb=GetTTFLabel(getlocal("server",{""}),28)
	serverDescLb:setAnchorPoint(ccp(0,0.5))
	serverDescLb:setPosition(ccp(10,(serverListLb:getContentSize().height+50)/2+5))
	local cell1=CCTableViewCell:new()
	cell1:autorelease()
	cell1:addChild(serverListLb)
	cell1:addChild(serverDescLb)
	table.insert(self.cellTb,cell1)
	table.insert(self.cellHeightTb,serverListLb:getContentSize().height+50)

	local conditionLb=GetTTFLabelWrap(getlocal("serverwar_condition",{16/#serverList}),25,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionLb:setAnchorPoint(ccp(0,0.5))
	conditionLb:setColor(G_ColorYellowPro)
	conditionLb:setPosition(ccp(200,(conditionLb:getContentSize().height+50)/2+5))
	local conditionDescLb=GetTTFLabelWrap(getlocal("serverwar_conditionDesc",{""}),28,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionDescLb:setAnchorPoint(ccp(0,0.5))
	conditionDescLb:setPosition(ccp(10,(conditionLb:getContentSize().height+50)/2+5))
	local cell2=CCTableViewCell:new()
	cell2:autorelease()
	cell2:addChild(conditionLb)
	cell2:addChild(conditionDescLb)
	table.insert(self.cellTb,cell2)
	table.insert(self.cellHeightTb,conditionLb:getContentSize().height+50)

	local timeLb=GetTTFLabel(activityVoApi:getActivityTimeStr(serverWarPersonalVoApi.startTime,serverWarPersonalVoApi.endTime),25)
	timeLb:setAnchorPoint(ccp(0,0.5))
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(ccp(200,(timeLb:getContentSize().height+50)/2+5))
	local timeDescLb=GetTTFLabelWrap(getlocal("serverwar_opentime",{""}),28,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	timeDescLb:setAnchorPoint(ccp(0,0.5))
	timeDescLb:setPosition(ccp(10,(timeLb:getContentSize().height+50)/2+5))
	local cell3=CCTableViewCell:new()
	cell3:autorelease()
	cell3:addChild(timeLb)
	cell3:addChild(timeDescLb)
	table.insert(self.cellTb,cell3)
	table.insert(self.cellHeightTb,timeLb:getContentSize().height+50)

	local winConditionLb=GetTTFLabelWrap(getlocal("serverwar_winCondition"),25,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	winConditionLb:setAnchorPoint(ccp(0,0.5))
	winConditionLb:setColor(G_ColorYellowPro)
	winConditionLb:setPosition(ccp(200,(winConditionLb:getContentSize().height+50)/2+5))
	local winConditionDescLb=GetTTFLabelWrap(getlocal("serverwar_winConditionDesc",{""}),28,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	winConditionDescLb:setAnchorPoint(ccp(0,0.5))
	winConditionDescLb:setPosition(ccp(10,(winConditionLb:getContentSize().height+50)/2+5))
	local cell4=CCTableViewCell:new()
	cell4:autorelease()
	cell4:addChild(winConditionLb)
	cell4:addChild(winConditionDescLb)
	table.insert(self.cellTb,cell4)
	table.insert(self.cellHeightTb,winConditionLb:getContentSize().height+50)

	for k,v in pairs(self.cellTb) do
		local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSP:setAnchorPoint(ccp(0.5,0))
		lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
		lineSP:setScaleY(1.2)
		lineSP:setPosition(ccp(tvSize.width/2,0))
		v:addChild(lineSP)
	end

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvSize.width,tvSize.height-20),nil)
	tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	tableView:setPosition(ccp(0,10))
	tvBg:addChild(tableView)
	tableView:setMaxDisToBottomOrTop(60)
end

function serverWarPersonalDialogSubTab11:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.cellHeightTb[idx+1])
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		return self.cellTb[idx+1]
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function serverWarPersonalDialogSubTab11:initBtn()
	local wSpace=200
	local height=65
	local function fightHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        --打开竞技场
        if self.parent and self.parent.close then
        	self.parent:close()
        end
        G_openArenaDialog(self.layerNum+1)
	end
	self.fightBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",fightHandler,nil,getlocal("serverwar_fight"),25)
	local fightMenu = CCMenu:createWithItem(self.fightBtn)
	fightMenu:setPosition(ccp(G_VisibleSizeWidth/2-wSpace,height))
	fightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(fightMenu,3)

	self.tipSp1 = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp1:setPosition(ccp(self.fightBtn:getContentSize().width-10,self.fightBtn:getContentSize().height-10))
	self.tipSp1:setTag(11)
	self.tipSp1:setVisible(false)
	self.fightBtn:addChild(self.tipSp1)

	if serverWarPersonalVoApi:checkStatus()<20 then
		self.fightBtn:setEnabled(true)
	else
		self.fightBtn:setEnabled(false)
	end

	local function showRewardInfo(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function showRewardInfoDialog()
	        local td = serverWarPersonalRewardInfoDialog:new()
		    local tbArr={}
		    local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverwar_reward_info"),true,self.layerNum+1)
		    sceneGame:addChild(vd,self.layerNum+1)

		    -- self.tipSp2:setVisible(false)
		end
	    serverWarPersonalVoApi:formatRankList(showRewardInfoDialog)
	end
	self.rewardInfoBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showRewardInfo,nil,getlocal("serverwar_reward_info"),25)
	local rewardInfoMenu = CCMenu:createWithItem(self.rewardInfoBtn)
	rewardInfoMenu:setPosition(ccp(G_VisibleSizeWidth/2,height))
	rewardInfoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(rewardInfoMenu,3)

	self.tipSp2 = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp2:setPosition(ccp(self.rewardInfoBtn:getContentSize().width-10,self.rewardInfoBtn:getContentSize().height-10))
	self.tipSp2:setTag(11)
	self.tipSp2:setVisible(false)
	self.rewardInfoBtn:addChild(self.tipSp2)


	local function showFlowerInfo(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        	
        local function getScheduleInfoHandler()
            --去献花
	        local function gotoHandler()
	        	local status=serverWarPersonalVoApi:checkStatus()
	        	if status and status<30 then
	        		local goType
		        	if status<20 then
		        		goType=0
		        	elseif status==20 then
		        		if serverWarPersonalVoApi:getRoundStatus(0)<30 then
		        			goType=0
		        		else
		        			goType=1
		        		end
		        	end
			        if goType==nil or (goType and goType<0) then
			            do return false end
			        end
			        local scene
			        if goType==0 then
			            scene=serverWarPersonalTeamScene
			        elseif goType>0 then
			            scene=serverWarPersonalKnockOutScene
			        end
			        local function callback()
			            scene:show(self.layerNum+1)
			        end
			        serverWarPersonalVoApi:getScheduleInfo(callback)
			        return true
			    end
		    end
		    --领取奖励回调
		    local function rewardHandler()
		    	if self then
		    		self:tick()
		    	end
		    end
	        smallDialog:showSendFlowerInfoDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("serverwar_flower_info"),gotoHandler,rewardHandler)
        	
	        -- self.tipSp3:setVisible(false)
        end
        serverWarPersonalVoApi:getScheduleInfo(getScheduleInfoHandler)
	end
	self.flowerInfoBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showFlowerInfo,nil,getlocal("serverwar_flower_info"),25)
	local flowerInfoMenu = CCMenu:createWithItem(self.flowerInfoBtn)
	flowerInfoMenu:setPosition(ccp(G_VisibleSizeWidth/2+wSpace,height))
	flowerInfoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(flowerInfoMenu,3)

	self.tipSp3 = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp3:setPosition(ccp(self.flowerInfoBtn:getContentSize().width-10,self.flowerInfoBtn:getContentSize().height-10))
	self.tipSp3:setTag(11)
	self.tipSp3:setVisible(false)
	self.flowerInfoBtn:addChild(self.tipSp3)

end

function serverWarPersonalDialogSubTab11:tick()
	if self then
		if self.countDown and self.timeLb and self.countDown>=0 then
			self.countDown=self.countDown-1
			self.timeLb:setString(GetTimeStr(self.countDown))
		end
		if(self.countDown and self.countDown<=0)then
			self:initTick()
			local tmpStr
			if(self.status==10)then
				tmpStr=getlocal("serverwar_startCountDown")
			elseif(self.status==20)then
				if(self.roundStatus<20)then
					tmpStr=getlocal("serverwar_battleCountDown")
				else
					tmpStr=getlocal("serverwar_battle_ing")
				end
			else
				tmpStr=getlocal("activity_heartOfIron_over")
			end
			self.timeTime:setString(tmpStr)
		end
		local rewardPoint=serverWarPersonalVoApi:getRewardPoint()
		local isRewardRank=serverWarPersonalVoApi:getIsRewardRank()
		if rewardPoint and rewardPoint>0 then
			if isRewardRank==true then
				if self.tipSp2 and self.tipSp2:isVisible()==true then
					self.tipSp2:setVisible(false)
				end
			else
				if self.tipSp2 and self.tipSp2:isVisible()==false then
					self.tipSp2:setVisible(true)
				end
			end
		end

		local betList=serverWarPersonalVoApi:getBetList()
		if betList and SizeOfTable(betList)>0 then
			local isShow=false
			for k,v in pairs(betList) do
				if v and v.roundID then
					local roundStatus=serverWarPersonalVoApi:getRoundStatus(v.roundID)
	                if roundStatus and roundStatus>=30 then --结束
	                    if v.hasGet and v.hasGet==1 then
	                    else
	                    	if self.tipSp3 and self.tipSp3:isVisible()==false then
								self.tipSp3:setVisible(true)
							end
							isShow=true
	                    end
	                end
				end
			end
			if isShow==false then
				if self.tipSp3 and self.tipSp3:isVisible()==true then
					self.tipSp3:setVisible(false)
				end
			end
		end

		if self.fightBtn then
			if serverWarPersonalVoApi:checkStatus()<20 then
				if self.fightBtn:isEnabled()==false then
					self.fightBtn:setEnabled(true)
				end
			else
				if self.fightBtn:isEnabled()==true then
					self.fightBtn:setEnabled(false)
				end
			end
		end
	end
end

function serverWarPersonalDialogSubTab11:dispose()
	base:removeFromNeedRefresh(self)
	self.countDown=nil
	self.timeLb=nil

	self.fightBtn=nil
	self.rewardInfoBtn=nil
	self.flowerInfoBtn=nil

	self.tipSp1=nil
	self.tipSp2=nil
	self.tipSp3=nil
end

