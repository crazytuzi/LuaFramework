serverWarTeamDialogSubTab11={}

function serverWarTeamDialogSubTab11:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.countDown=nil
	self.timeLb=nil

	self.applyBtn=nil
	self.fightBtn=nil
	self.rewardInfoBtn=nil
	self.flowerInfoBtn=nil
	self.enterBattleBtn=nil
	self.donateBtn=nil
	self.statusDescLb=nil
	self.descTv=nil

	self.tipSp1=nil
	self.tipSp2=nil
	self.tipSp3=nil
	self.tipSp4=nil
	self.tipSp5=nil

	return nc
end

function serverWarTeamDialogSubTab11:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	-- self:initTick()
	self:initUp()
	self:initDown()
	self:initBtn()
	base:addNeedRefresh(self)
	return self.bgLayer
end

function serverWarTeamDialogSubTab11:initTick()
	-- self.status=serverWarTeamVoApi:checkStatus()
	-- if(self.status<=11)then
	-- 	local startTime=serverWarTeamVoApi.startTime + serverWarTeamCfg.preparetime*86400
	-- 	self.countDown=startTime-base.serverTime
	-- elseif(self.status==20)then
	-- 	local nextTime
	-- 	local timeTb=serverWarTeamVoApi:getBattleTimeList()
	-- 	for i=1,#timeTb do
	-- 		local roundStatus=serverWarTeamVoApi:getRoundStatus(i)
	-- 		if(roundStatus<30)then
	-- 			self.curRoundID=i
	-- 			self.roundStatus=roundStatus
	-- 			if(roundStatus<20)then
	-- 				nextTime=timeTb[i]
	-- 			else
	-- 				nextTime=timeTb[i] + serverWarTeamCfg.warTime
	-- 			end
	-- 			break
	-- 		end
	-- 	end
	-- 	-- if nextTime then
	-- 		self.countDown=nextTime-base.serverTime
	-- 	-- end
	-- end
end

function serverWarTeamDialogSubTab11:initUp()
	local tmpStr,nextTime=serverWarTeamVoApi:getWarStatusAndNextTime()
	-- print("tmpStr,nextTime",tmpStr,nextTime)
	-- if(self.status==10)then
	-- 	tmpStr=getlocal("serverwar_startCountDown")
	-- elseif(self.status==20)then
	-- 	if(self.roundStatus<20)then
	-- 		tmpStr=getlocal("serverwar_battleCountDown")
	-- 	else
	-- 		tmpStr=getlocal("serverwar_battle_ing")
	-- 	end
	-- else
	-- 	tmpStr=getlocal("activity_heartOfIron_over")
	-- end
	self.timeTime = GetTTFLabel(tmpStr,28)
	self.timeTime:setAnchorPoint(ccp(0.5,1))
	self.timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-220))
	self.bgLayer:addChild(self.timeTime)

	self.timeLb=GetTTFLabel(0,25)
	self.timeLb:setAnchorPoint(ccp(0.5,1))
	self.timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-250))
	self.bgLayer:addChild(self.timeLb)
	if nextTime then
		self.timeLb:setVisible(true)
		self.timeLb:setString(GetTimeStr(nextTime-base.serverTime))
	else
		self.timeLb:setVisible(false)
	end

	local function showInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		local warTimeMin=math.ceil(serverWarTeamCfg.warTime/60)
		local prepareDay=serverWarTeamCfg.preparetime
		local serverList=serverWarTeamVoApi:getServerList()
		local canSignUpNum=math.ceil(serverWarTeamCfg.sevbattleAlliance/SizeOfTable(serverList))
		local contentTb={getlocal("serverwarteam_help_content61"),getlocal("serverwarteam_help_content6"),getlocal("serverwarteam_help_title6"),"\n",getlocal("serverwarteam_help_content5",{warTimeMin,warTimeMin}),getlocal("serverwarteam_help_title5"),"\n",getlocal("serverwarteam_help_content4"),getlocal("serverwarteam_help_title4"),"\n",getlocal("serverwarteam_help_content3"),getlocal("serverwarteam_help_title3"),"\n",getlocal("serverwarteam_help_content21"),getlocal("serverwarteam_help_content2",{prepareDay,canSignUpNum}),getlocal("serverwarteam_help_title2"),"\n",getlocal("serverwarteam_help_content1"),getlocal("serverwarteam_help_title1")}
		local colorTb={G_ColorRed,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil,G_ColorRed,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil}
		smallDialog:showTableViewSureWithColorTb("PanelHeaderPopup.png",CCSizeMake(600,750),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("help"),contentTb,colorTb,true,self.layerNum+1)
	end

	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,G_VisibleSizeHeight-220))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn,3);
	
	-- local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
	-- lineSP:setAnchorPoint(ccp(0.5,0.5))
	-- lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
	-- lineSP:setScaleY(1.2)
	-- lineSP:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-300))
	-- self.bgLayer:addChild(lineSP)

	local girlImg=CCSprite:createWithSpriteFrameName("NewCharacter02.png")
	girlImg:setScale(240/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0,1))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight-290))
	self.bgLayer:addChild(girlImg,1)

	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("LanguageSelectBtn.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(400,150))
	girlDescBg:setRotation(180)
	girlDescBg:setAnchorPoint(ccp(1,0))
	girlDescBg:setPosition(200,G_VisibleSizeHeight-350)
	self.bgLayer:addChild(girlDescBg)

	local descStr=serverWarTeamVoApi:getWarStatusDesc()
	self.descTv,self.statusDescLb=G_LabelTableView(CCSizeMake(360,130),descStr,25,kCCTextAlignmentLeft)
	self.descTv:setPosition(230,G_VisibleSizeHeight-490)
	self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(self.descTv)
end

function serverWarTeamDialogSubTab11:initDown()
	local tvSize=CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-630)
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... ) end)
	tvBg:setTouchPriority(-(self.layerNum-1)*20)
	tvBg:setAnchorPoint(ccp(0,1))
	tvBg:setContentSize(tvSize)
	tvBg:setPosition(ccp(30,G_VisibleSizeHeight-525))
	self.bgLayer:addChild(tvBg,2)

	self.cellTb={}
	self.cellHeightTb={}

	local sizeWidth = 380
	if G_getCurChoseLanguage() == "ar" then
		sizeWidth = 280
	end

	local serverList=serverWarTeamVoApi:getServerList()
	local serverListStr=""
	for k,v in pairs(serverList) do
		if(v[2])then
			serverListStr=serverListStr..v[2].."     "
		end
		if(k%2==0 and k~=#serverList)then
			serverListStr=serverListStr.."\n"
		end
	end
	local strSize2 = 22
	local strWidth2 = 170
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =28
        strWidth2 =150
    end
	local serverListLb=GetTTFLabelWrap(serverListStr,strSize2,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	serverListLb:setAnchorPoint(ccp(0,0.5))
	serverListLb:setColor(G_ColorYellowPro)
	serverListLb:setPosition(ccp(200,(serverListLb:getContentSize().height+50)/2+5))
	local serverDescLb=GetTTFLabel(getlocal("server",{""}),strSize2)
	serverDescLb:setAnchorPoint(ccp(0,0.5))
	serverDescLb:setPosition(ccp(10,(serverListLb:getContentSize().height+50)/2+5))
	local cell1=CCTableViewCell:new()
	cell1:autorelease()
	cell1:addChild(serverListLb)
	cell1:addChild(serverDescLb)
	table.insert(self.cellTb,cell1)
	table.insert(self.cellHeightTb,serverListLb:getContentSize().height+50)

	

	local conditionLb=GetTTFLabelWrap(getlocal("serverwarteam_condition",{math.ceil(serverWarTeamCfg.sevbattleAlliance/SizeOfTable(serverList))}),25,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionLb:setAnchorPoint(ccp(0,0.5))
	conditionLb:setColor(G_ColorYellowPro)
	conditionLb:setPosition(ccp(200,(conditionLb:getContentSize().height+50)/2+5))
	local conditionDescLb=GetTTFLabelWrap(getlocal("serverwar_conditionDesc",{""}),strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	conditionDescLb:setAnchorPoint(ccp(0,0.5))
	conditionDescLb:setPosition(ccp(10,(conditionLb:getContentSize().height+50)/2+5))
	local cell2=CCTableViewCell:new()
	cell2:autorelease()
	cell2:addChild(conditionLb)
	cell2:addChild(conditionDescLb)
	table.insert(self.cellTb,cell2)
	table.insert(self.cellHeightTb,conditionLb:getContentSize().height+50)

	local timeLb=GetTTFLabel(activityVoApi:getActivityTimeStr(serverWarTeamVoApi.startTime,serverWarTeamVoApi.endTime),25)
	timeLb:setAnchorPoint(ccp(0,0.5))
	timeLb:setColor(G_ColorYellowPro)
	timeLb:setPosition(ccp(200,(timeLb:getContentSize().height+50)/2+5))
	local timeDescLb=GetTTFLabelWrap(getlocal("serverwar_opentime",{""}),strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	timeDescLb:setAnchorPoint(ccp(0,0.5))
	timeDescLb:setPosition(ccp(10,(timeLb:getContentSize().height+50)/2+5))
	local cell3=CCTableViewCell:new()
	cell3:autorelease()
	cell3:addChild(timeLb)
	cell3:addChild(timeDescLb)
	table.insert(self.cellTb,cell3)
	table.insert(self.cellHeightTb,timeLb:getContentSize().height+50)

	local roundNum=serverWarTeamVoApi:getRoundNum()
	local winConditionLb=GetTTFLabelWrap(getlocal("serverwarteam_winCondition",{roundNum}),25,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	winConditionLb:setAnchorPoint(ccp(0,0.5))
	winConditionLb:setColor(G_ColorYellowPro)
	winConditionLb:setPosition(ccp(200,(winConditionLb:getContentSize().height+50)/2+5))
	local winConditionDescLb=GetTTFLabelWrap(getlocal("serverwar_winConditionDesc",{""}),strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
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

function serverWarTeamDialogSubTab11:eventHandler(handler,fn,idx,cel)
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

function serverWarTeamDialogSubTab11:initBtn()
	local wSpace=200
	local height=65
	
	-- local function fightHandler(tag,object)
	-- 	if G_checkClickEnable()==false then
 --            do
 --                return
 --            end
 --        else
 --            base.setWaitTime=G_getCurDeviceMillTime()
 --        end
 --        PlayEffect(audioCfg.mouseClick)
        
 --        -- --打开竞技场
 --        -- if self.parent and self.parent.close then
 --        -- 	self.parent:close()
 --        -- end
 --        -- G_openArenaDialog(self.layerNum+1)

 --        --打开个人战力面板
 --        for k,v in pairs(base.commonDialogOpened_WeakTb) do
 --            base.commonDialogOpened_WeakTb[k]:close()
 --        end
 --        base.commonDialogOpened_WeakTb={}
 --        playerVoApi:showPowerGuideDialog(self.layerNum+1)
	-- end
	-- self.fightBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",fightHandler,nil,getlocal("serverwar_fight"),25)
	-- local fightMenu = CCMenu:createWithItem(self.fightBtn)
	-- fightMenu:setPosition(ccp(G_VisibleSizeWidth/2-wSpace,height))
	-- fightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	-- self.bgLayer:addChild(fightMenu,3)

	-- self.tipSp1 = CCSprite:createWithSpriteFrameName("IconTip.png")
	-- self.tipSp1:setPosition(ccp(self.fightBtn:getContentSize().width-10,self.fightBtn:getContentSize().height-10))
	-- self.tipSp1:setTag(11)
	-- self.tipSp1:setVisible(false)
	-- self.fightBtn:addChild(self.tipSp1)
	-- if serverWarTeamVoApi:checkStatus()<20 then
	-- 	self.fightBtn:setEnabled(true)
	-- else
	-- 	self.fightBtn:setEnabled(false)
	-- end


	local function applyHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
     --    -- serverWarTeamVoApi:showSetBattleMemDialog(self.layerNum+1)
    	-- local function applyCallback()
     --        self:tick()
     --    end
     --    serverWarTeamVoApi:serverWarTeamApply(applyCallback)
        serverWarTeamVoApi:showApplyDialog(self.layerNum+1)
	end
	-- self.applyBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",applyHandler,nil,getlocal("serverwarteam_set_battle_menber"),25)
	self.applyBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",applyHandler,nil,getlocal("serverwarteam_apply"),25)
	local applyMenu = CCMenu:createWithItem(self.applyBtn)
	applyMenu:setPosition(ccp(G_VisibleSizeWidth/2-wSpace,height))
	applyMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(applyMenu,3)
	-- if serverWarTeamVoApi:canSetOrApply()>=0 then
	-- 	self.applyBtn:setEnabled(true)
	-- else
	-- 	self.applyBtn:setEnabled(false)
	-- end

	-- self.tipSp4 = CCSprite:createWithSpriteFrameName("IconTip.png")
	-- self.tipSp4:setPosition(ccp(self.applyBtn:getContentSize().width-10,self.applyBtn:getContentSize().height-10))
	-- self.tipSp4:setTag(11)
	-- self.tipSp4:setVisible(false)
	-- self.applyBtn:addChild(self.tipSp4)


	local function showRewardInfo(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function getShopAndBetInfoHandler()
        	local function showRewardInfoDialog()
		        local td = serverWarTeamRewardInfoDialog:new()
			    local tbArr={}
			    local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverwar_reward_info"),true,self.layerNum+1)
			    sceneGame:addChild(vd,self.layerNum+1)

			    -- self.tipSp2:setVisible(false)
			end
			serverWarTeamVoApi:formatRankList(showRewardInfoDialog)
		end
	    serverWarTeamVoApi:getShopAndBetInfo(getShopAndBetInfoHandler)
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
        PlayEffect(audioCfg.mouseClick)
        
        local function getWarInfoHandler()
			local function getShopAndBetInfoHandler()
	            --去献花
		        local function gotoHandler()
		        	local status=serverWarTeamVoApi:checkStatus()
		        	if status and status<30 then
						serverWarTeamOutScene:show(self.layerNum+1)
				        return true
				    end
			    end
			    --领取奖励回调
			    local function rewardHandler()
			    	if self then
			    		self:tick()
			    	end
			    end
		        smallDialog:showTeamSendFlowerInfoDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("serverwar_flower_info"),gotoHandler,rewardHandler)
        	
		        -- self.tipSp3:setVisible(false)
	        end
	        serverWarTeamVoApi:getShopAndBetInfo(getShopAndBetInfoHandler)
		end
		serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
	end
	local strSize3 = 25
	if G_getCurChoseLanguage() =="ru" then
		strSize3 =18
	end
	-- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
 --        strSize3 =25
 --    end
	self.flowerInfoBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showFlowerInfo,nil,getlocal("serverwar_flower_info"),strSize3)
	local flowerInfoMenu = CCMenu:createWithItem(self.flowerInfoBtn)
	flowerInfoMenu:setPosition(ccp(G_VisibleSizeWidth/2+wSpace,height))
	flowerInfoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(flowerInfoMenu,3)

	self.tipSp3 = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp3:setPosition(ccp(self.flowerInfoBtn:getContentSize().width-10,self.flowerInfoBtn:getContentSize().height-10))
	self.tipSp3:setTag(11)
	self.tipSp3:setVisible(false)
	self.flowerInfoBtn:addChild(self.tipSp3)





	local function enterBattleHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if serverWarTeamVoApi:getIsSetFleet()==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_enter_battle"),nil,self.layerNum+1)
            do return end
        end

       	local roundIndex=serverWarTeamVoApi:getCurrentRoundIndex()
       	if roundIndex and roundIndex>0 then
       		local battleID=serverWarTeamVoApi:getBattleID(roundIndex)
       		if battleID then
		        -- local battleVo=serverWarTeamVoApi:getCurrentBattle()
		        local battleVo=serverWarTeamVoApi:getBattleVoByID(roundIndex,battleID)
		        if(battleVo==nil)then
					do return end
				elseif(battleVo.alliance1==nil or battleVo.alliance2==nil) then
					local selfAlliance=allianceVoApi:getSelfAlliance()
					if selfAlliance and selfAlliance.aid then
						local selfID=base.curZoneID.."-"..selfAlliance.aid
						if (battleVo.alliance1 and battleVo.alliance1.id and battleVo.alliance1.id==selfID) or (battleVo.alliance2 and battleVo.alliance2.id and battleVo.alliance2.id==selfID) then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_win_direct"),30)
						end
					end
					do return end
		        elseif(battleVo.winnerID==nil)then
			        serverWarTeamVoApi:showMap(self.layerNum+1,battleVo)
		        else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4011"),30)
					do return end
			    end
			end
		end
	end
	self.enterBattleBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",enterBattleHandler,nil,getlocal("serverwarteam_enter_battlefield"),25)
	local enterBattleMenu = CCMenu:createWithItem(self.enterBattleBtn)
	enterBattleMenu:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-313))
	enterBattleMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(enterBattleMenu,3)
	self.enterBattleBtn:setScale(0.8)
	
	self.tipSp5 = CCSprite:createWithSpriteFrameName("IconTip.png")
	self.tipSp5:setPosition(ccp(self.enterBattleBtn:getContentSize().width-10,self.enterBattleBtn:getContentSize().height-10))
	self.tipSp5:setTag(11)
	self.tipSp5:setVisible(false)
	self.enterBattleBtn:addChild(self.tipSp5)


	local function showDonateHandler(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if allianceVoApi:isHasAlliance()==true then
            if serverWarTeamVoApi:canJoinServerWarTeam(nil,false)==false then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_donate"),nil,self.layerNum+1)
                do return end
            end
            if serverWarTeamVoApi:canJoinBattleLvLimit()==false then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_donate1",{serverWarTeamCfg.joinlv}),nil,self.layerNum+1)
                do return end
            end
        else
            do return end
        end

        local roundIndex=serverWarTeamVoApi:getCurrentRoundIndex()
        tipStatus=serverWarTeamVoApi:donateTipStatus(roundIndex)
        if tipStatus==0 then
        	smallDialog:showActivateDefendersDialog("PanelHeaderPopup.png",CCSizeMake(550,870),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("serverwarteam_activate_defenders"),nil)
        else
        	do return end
        end
	end
	
	self.donateBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",showDonateHandler,nil,getlocal("serverwarteam_activate_defenders"),25)
	local donateMenu = CCMenu:createWithItem(self.donateBtn)
	donateMenu:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-313))
	donateMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(donateMenu,3)
	self.donateBtn:setScale(0.8)


	self.enterBattleBtn:setEnabled(false)
	self.enterBattleBtn:setVisible(false)
	self.donateBtn:setEnabled(false)
	self.donateBtn:setVisible(true)

	self:tick()
	
end

function serverWarTeamDialogSubTab11:tick()
	if self then
		-- if self.countDown and self.timeLb and self.countDown>=0 then
		-- 	self.countDown=self.countDown-1
		-- 	self.timeLb:setString(GetTimeStr(self.countDown))
		-- end
		-- if(self.countDown and self.countDown<=0)then
		-- 	self:initTick()
		-- 	local tmpStr
		-- 	if(self.status==10)then
		-- 		tmpStr=getlocal("serverwar_startCountDown")
		-- 	elseif(self.status==20)then
		-- 		if(self.roundStatus<20)then
		-- 			tmpStr=getlocal("serverwar_battleCountDown")
		-- 		else
		-- 			tmpStr=getlocal("serverwar_battle_ing")
		-- 		end
		-- 	else
		-- 		tmpStr=getlocal("activity_heartOfIron_over")
		-- 	end
		-- 	self.timeTime:setString(tmpStr)
		-- end


		local tmpStr,nextTime=serverWarTeamVoApi:getWarStatusAndNextTime()
		if self.timeTime and tmpStr then
			self.timeTime:setString(tmpStr)
		end
		if self.timeLb then
			if nextTime then
				self.timeLb:setVisible(true)
				self.timeLb:setString(GetTimeStr(nextTime-base.serverTime))
			else
				self.timeLb:setVisible(false)
			end
		end

		local rewardPoint=serverWarTeamVoApi:getRewardPoint()
		local isRewardRank=serverWarTeamVoApi:getIsRewardRank()
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

		local isShow=serverWarTeamVoApi:getIsCanRewardBet()
		if isShow==true then
			if self.tipSp3 and self.tipSp3:isVisible()==false then
				self.tipSp3:setVisible(true)
			end
		else
			if self.tipSp3 and self.tipSp3:isVisible()==true then
				self.tipSp3:setVisible(false)
			end
		end

		-- if self.applyBtn then
		-- 	if serverWarTeamVoApi:canSetOrApply()>=0 then
		-- 		self.applyBtn:setEnabled(true)
		-- 	else
		-- 		self.applyBtn:setEnabled(false)
		-- 	end

		-- 	if self.tipSp4 then
		-- 		if serverWarTeamVoApi:isShowSetMemTip()==true then
		-- 			self.tipSp4:setVisible(true)
		-- 		else
		-- 			self.tipSp4:setVisible(false)
		-- 		end
		-- 	end
		-- end

		if self.enterBattleBtn and self.donateBtn then
			local status=serverWarTeamVoApi:getEnterBattleStatus()
			if status==1 then
				self.enterBattleBtn:setEnabled(false)
				self.enterBattleBtn:setVisible(false)
				self.donateBtn:setEnabled(true)
				self.donateBtn:setVisible(true)
				self.tipSp5:setVisible(false)
			elseif status==2 then
				self.enterBattleBtn:setEnabled(false)
				self.enterBattleBtn:setVisible(true)
				self.donateBtn:setEnabled(false)
				self.donateBtn:setVisible(false)
				self.tipSp5:setVisible(false)
			elseif status==3 then
				self.enterBattleBtn:setEnabled(true)
				self.enterBattleBtn:setVisible(true)
				self.donateBtn:setEnabled(false)
				self.donateBtn:setVisible(false)
				-- self.tipSp5:setVisible(true)
				if serverWarTeamVoApi:getIsSetFleet()==true then
					self.tipSp5:setVisible(true)
				else
					self.tipSp5:setVisible(false)
				end
			else
				self.enterBattleBtn:setEnabled(false)
				self.enterBattleBtn:setVisible(false)
				self.donateBtn:setEnabled(false)
				self.donateBtn:setVisible(true)
				self.tipSp5:setVisible(false)
			end
		end

		if self.statusDescLb then
			local descStr=serverWarTeamVoApi:getWarStatusDesc()
			self.statusDescLb:setString(descStr)
		end
	end
end

function serverWarTeamDialogSubTab11:dispose()
	base:removeFromNeedRefresh(self)
	self.countDown=nil
	self.timeLb=nil

	self.applyBtn=nil
	self.fightBtn=nil
	self.rewardInfoBtn=nil
	self.flowerInfoBtn=nil
	self.enterBattleBtn=nil
	self.donateBtn=nil
	self.statusDescLb=nil
	self.descTv=nil

	self.tipSp1=nil
	self.tipSp2=nil
	self.tipSp3=nil
	self.tipSp4=nil
	self.tipSp5=nil
end

