acChunjiepanshengTask={}

function acChunjiepanshengTask:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.id=1
	nc.bgLayer=nil
	nc.parent=parent
	nc.tvH = 190
	return nc
end

function acChunjiepanshengTask:init(layerNum,id)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.id=id

	self.version=acChunjiepanshengVoApi:getVersion( )

	self.titleStr2=getlocal("activity_chunjiepansheng_day" .. self.id .. "_ver" .. self.version)
	local num = acChunjiepanshengVoApi:getNumOfDay()
	if self.id+1>num then
		self.titleStr3=getlocal("activity_chunjiepansheng_day" .. 1 .. "_ver" .. self.version)
	else
		self.titleStr3=getlocal("activity_chunjiepansheng_day" .. self.id+1 .. "_ver" .. self.version)
	end
	if self.id-1==0 then
		self.titleStr1=getlocal("activity_chunjiepansheng_day" .. num .. "_ver" .. self.version)
	else
		self.titleStr1=getlocal("activity_chunjiepansheng_day" .. self.id-1 .. "_ver" .. self.version)
	end

	self.taskList=acChunjiepanshengVoApi:getDayOfTask(self.id)
	self.cellNum=SizeOfTable(self.taskList)
	
	
	self:initInfo()
	self:initTableView()

	base:addNeedRefresh(self)
	return self.bgLayer
end

function acChunjiepanshengTask:initInfo()
	local strSize2 = 21
	local strSize3 = 25
	local strSize4 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =32
        strSize4 =25
    end
	local capInSet = CCRect(20, 20, 10, 10);
	local function nilFunc(hd,fn,idx)
	end
	local upLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	upLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth-120, 90))
	upLayer:ignoreAnchorPointForPosition(false)
	upLayer:setTouchPriority(-(self.layerNum-1)*20-4)
	upLayer:setAnchorPoint(ccp(0,1))
	upLayer:setPosition(ccp(0,G_VisibleSizeHeight))
	self.bgLayer:addChild(upLayer)
	upLayer:setVisible(false)

	local infoLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	infoLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, 100))
	infoLayer:ignoreAnchorPointForPosition(false)
	infoLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	infoLayer:setAnchorPoint(ccp(0,0))
	infoLayer:setPosition(ccp(30,G_VisibleSizeHeight-260))
	self.bgLayer:addChild(infoLayer)
	infoLayer:setOpacity(0)

	local widTh=infoLayer:getContentSize().width/2
	local heiTh=infoLayer:getContentSize().height/2+10
	local titleTb={
		{str=self.titleStr1,lbSize=strSize2,pos=ccp(widTh-200,heiTh)},
		{str=self.titleStr2,lbSize=strSize3,pos=ccp(widTh,heiTh)},
		{str=self.titleStr3,lbSize=strSize2,pos=ccp(widTh+200,heiTh)}
				}

	for k,v in pairs(titleTb) do
		local titleLb=GetTTFLabel(v.str,v.lbSize)
		-- titleLb:setAnchorPoint(ccp(0.5,0.5))
		titleLb:setPosition(v.pos)
		infoLayer:addChild(titleLb,1)
		if k~=2 then
			titleLb:setColor(G_ColorGray)
		end
	end
	

	local bgSpImage="groupSelf.png"
	if self.version==4 then
		bgSpImage="orangeMask.png"
	end
	local bgSp=CCSprite:createWithSpriteFrameName(bgSpImage)
	bgSp:setPosition(ccp(widTh,heiTh));
	if self.version==4 then
	else
		bgSp:setScaleY((32+20)/bgSp:getContentSize().height)
	end
	bgSp:setScaleX(600/bgSp:getContentSize().width)
	infoLayer:addChild(bgSp)

	local orangeLine
	if self.version==3 then
		orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
	else
		orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
	end
	orangeLine:setAnchorPoint(ccp(0.5,0))
	orangeLine:setPosition(ccp(infoLayer:getContentSize().width/2,27));
	infoLayer:addChild(orangeLine,3)
	if self.version==4 then
		orangeLine:setPositionY(38)
	end


	local taskLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	taskLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, 180))
	taskLayer:ignoreAnchorPointForPosition(false)
	taskLayer:setTouchPriority(-(self.layerNum-1)*20-4)
	taskLayer:setAnchorPoint(ccp(0,0))
	taskLayer:setPosition(ccp(30,G_VisibleSizeHeight-440))
	self.bgLayer:addChild(taskLayer)
	taskLayer:setOpacity(0)

	local redLine
	if self.version==3 then
		redLine=CCSprite:createWithSpriteFrameName("acChunjianpansheng_redLine3.png")
	else
		redLine=CCSprite:createWithSpriteFrameName("acChunjianpansheng_redLine.png")
	end
	redLine:setPosition(ccp(taskLayer:getContentSize().width/2,taskLayer:getContentSize().height/2));
	redLine:setScaleX(taskLayer:getContentSize().width/redLine:getContentSize().width)
	redLine:setScaleY(taskLayer:getContentSize().height/redLine:getContentSize().height)
	taskLayer:addChild(redLine)


	local taskLb=GetTTFLabelWrap(getlocal("activity_chunjiepansheng_task"),strSize4,CCSizeMake(G_VisibleSizeWidth-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    taskLb:setAnchorPoint(ccp(0.5,0.5))
	taskLb:setColor(G_ColorYellowPro)
	taskLb:setPosition(ccp(taskLayer:getContentSize().width/2,taskLayer:getContentSize().height+3))
	taskLayer:addChild(taskLb,1)

	local picStr="acChunjiepansheng_caidai.png"
	local ccrect=CCRect(85,26,2,2)
    if self.version and self.version==3 then
        picStr="acChunjiepansheng_caidai3.png"
    elseif self.version and self.version==4 then
    	taskLb:setPositionY(taskLayer:getContentSize().height-5)
    	picStr="acChunjiepansheng_caidai_v4.png"
    	ccrect=CCRect(43,34,2,2)
    end
	local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName(picStr,ccrect,nilFunc)
	if self.version and self.version==4 then
    	pointBg:setContentSize(CCSizeMake(400,55))
    else
    	pointBg:setContentSize(CCSizeMake(450,60))
    end
    pointBg:setPosition(ccp(taskLayer:getContentSize().width/2,taskLayer:getContentSize().height-5))
    taskLayer:addChild(pointBg)
    local adaStrSize = 25
	if G_getCurChoseLanguage() == "ko" and G_isIOS() == false then
		adaStrSize = 22
	end
	local desTvH=taskLayer:getContentSize().height-10-taskLb:getContentSize().height-80
	local desStr = getlocal("activity_chunjiepansheng_taskdesTitle".. self.id .. "_ver" .. self.version)
	local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-240, 70),desStr,adaStrSize,kCCTextAlignmentLeft)
    taskLayer:addChild(desTv)
    desTv:setPosition(ccp(15,desTvH))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desTv:setMaxDisToBottomOrTop(100)

    local numTaskOfOver=acChunjiepanshengVoApi:getTaskProgress(self.id)
	local taskStr=numTaskOfOver .. "/" .. self.cellNum
	local progressStr=getlocal("activity_chunjiepansheng_taskProgress",{taskStr})
	local adaSize = 0
	if G_getCurChoseLanguage() == "ar" then
		adaSize = 100
	end
    local progressLb=GetTTFLabelWrap(progressStr,25,CCSizeMake(G_VisibleSizeWidth-200-adaSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    progressLb:setAnchorPoint(ccp(0,0.5))
	progressLb:setColor(G_ColorGreen)
	local adaH = 0
	if G_getCurChoseLanguage() == "ko" and G_isIOS() == false then
		adaH = 10
	end	
	progressLb:setPosition(ccp(15,desTvH/2+adaH))
	taskLayer:addChild(progressLb)
	self.progressLb=progressLb

	local giftW=taskLayer:getContentSize().width-90
	local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
	guangSp1:setPosition(giftW,taskLayer:getContentSize().height/2-10)
	taskLayer:addChild(guangSp1)

	local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
	guangSp2:setPosition(giftW,taskLayer:getContentSize().height/2-10)
	taskLayer:addChild(guangSp2)

	guangSp1:setScale(1.2)
	guangSp2:setScale(1.2)

	guangSp1:setVisible(false)
	guangSp2:setVisible(false)

	self.guangSp1=guangSp1
	self.guangSp2=guangSp2


	local function touchReward()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		
		local flag = acChunjiepanshengVoApi:isCanGetCurReward(self.id,self.cellNum)

		local reward = acChunjiepanshengVoApi:getDayOfTaskReward(self.id)
		local rewardItem=FormatItem(reward)

		if flag==2 then
			local function callback()
				acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
				for k,v in pairs(rewardItem) do
					if v.type~="p" then
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
				end

				self.guangSp1:setVisible(false)
				self.guangSp2:setVisible(false)
				self.guangSp1:stopAllActions()
				self.guangSp2:stopAllActions()
				
				G_showRewardTip(rewardItem,nil,nil,false)

				self:refreshLibaoLb()
			end
			local action=3
			local day=self.id
			acChunjiepanshengVoApi:getSocketReward(action,day,nil,callback)
			return
		end
		
		acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_canReward1"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)
	end
	local scale=1.5
	local rewardSp
	if self.version==4 then
		scale=1.2
		rewardSp = LuaCCSprite:createWithSpriteFrameName("packs6.png",touchReward)
	else
		rewardSp = LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",touchReward)
	end
	rewardSp:setTouchPriority(-(self.layerNum-1)*20-5)
	if self.version==4 then
		rewardSp:setPosition(giftW+20,taskLayer:getContentSize().height/2-10)
	else
		rewardSp:setPosition(giftW,taskLayer:getContentSize().height/2-10)
	end
	taskLayer:addChild(rewardSp)
	rewardSp:setScale(scale)


	local libaoLb=GetTTFLabelWrap("",22,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    libaoLb:setAnchorPoint(ccp(0.5,0.5))
	libaoLb:setColor(G_ColorGreen)
	libaoLb:setPosition(ccp(rewardSp:getContentSize().width/2,5))
	rewardSp:addChild(libaoLb,2)
	libaoLb:setScale(1/scale)
	self.libaoLb=libaoLb

	local titleBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
	titleBg:setScaleX(120/titleBg:getContentSize().width*1/scale)
	titleBg:setScaleY(1/scale)
	titleBg:setPosition(ccp(rewardSp:getContentSize().width/2,5))
	titleBg:setOpacity(160)
	rewardSp:addChild(titleBg)

	self:refreshLibaoLb()


	local downLayer =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	downLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, 40))
	downLayer:ignoreAnchorPointForPosition(false)
	downLayer:setTouchPriority(-(self.layerNum-1)*20-4)
	downLayer:setAnchorPoint(ccp(0,0))
	downLayer:setPosition(ccp(0,0))
	self.bgLayer:addChild(downLayer,6)
	downLayer:setVisible(false)

end
function acChunjiepanshengTask:initTableView()
	local function nilFunc()
    end
    local logBg
    if self.version==4 then
    	logBg =LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_taskListBg_v4.png",CCRect(5,5,1,1),nilFunc)
    else
    	logBg =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
	end
    logBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSizeHeight-470))
    logBg:ignoreAnchorPointForPosition(false);
    logBg:setTouchPriority(-(self.layerNum-1)*20-3)
    logBg:setAnchorPoint(ccp(0,0));
    self.bgLayer:addChild(logBg)
    if self.version==4 then
    	logBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-26,G_VisibleSizeHeight-455))
    	logBg:setPosition(13, 20)
    	-- logBg:setOpacity(180)
    else
    	logBg:setPosition(25, 35)
    	logBg:setOpacity(180)
	end


	local function callback( ... )
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    if self.version==4 then
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSizeHeight-470),nil)
    	self.tv:setPosition(ccp(15,30))
    else
	    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight-480),nil)
	    self.tv:setPosition(ccp(30,40))
	end
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

end

function acChunjiepanshengTask:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		 return self.cellNum
  	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if self.version==4 then
			tmpSize=CCSizeMake(G_VisibleSizeWidth-30,self.tvH)
		else
			tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.tvH)
		end
		return  tmpSize
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local capInSet = CCRect(20, 20, 20, 20)
		local function cellClick()
		end
		local backSpStr
		if self.version==3 then
			backSpStr="acChunjiepansheng_orangeBg3.png"
		else
			backSpStr="acChunjiepansheng_orangeBg.png"
		end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(backSpStr,capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-70, self.tvH-45))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(5,0)
		cell:addChild(backSprie,1)

		if self.version==4 then
			backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, self.tvH-45))
			backSprie:setOpacity(0)
			local orangeMask=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_yellowTitleBg.png",CCRect(105,16,1,1),function()end)
			orangeMask:setContentSize(CCSizeMake(500,orangeMask:getContentSize().height))
			orangeMask:setAnchorPoint(ccp(0,0.5))
			orangeMask:setPosition(0,self.tvH-24)
			cell:addChild(orangeMask,1)

			local taskStr=getlocal("task") .. idx+1
			local taskTitleLb=GetTTFLabelWrap(taskStr,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			taskTitleLb:setAnchorPoint(ccp(0,0.5))
			taskTitleLb:setColor(G_ColorYellowPro)
			taskTitleLb:setPosition(ccp(20,self.tvH-25))
			cell:addChild(taskTitleLb,2)

			local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_line_v4.png",CCRect(0,0,2,2),function()end)
			-- local lineSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_line_v4.png")
			lineSp:setContentSize(CCSizeMake(backSprie:getContentSize().width-20,4))
			-- lineSp:setScaleX((backSprie:getContentSize().width-10)/lineSp:getContentSize().width)
			lineSp:setAnchorPoint(ccp(0,0))
			lineSp:setPosition(5+20/2,0)
			cell:addChild(lineSp,1)
		else
			local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
		    orangeMask:setScaleX(backSprie:getContentSize().width/orangeMask:getContentSize().width)
		    orangeMask:setScaleY(45/orangeMask:getContentSize().height)
		    orangeMask:setPosition(G_VisibleSizeWidth/2,self.tvH-24)
		    cell:addChild(orangeMask,1)

		    local taskStr=getlocal("task") .. idx+1
			local taskTitleLb=GetTTFLabelWrap(taskStr,28,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			taskTitleLb:setAnchorPoint(ccp(0.5,0.5))
			taskTitleLb:setColor(G_ColorYellowPro)
			taskTitleLb:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.tvH-25))
			cell:addChild(taskTitleLb,2)
		end

		if idx==0 then
			self:cellIdx0(backSprie,idx+1)
		else
			self:cellNotIdx0(backSprie,idx+1)
		end

		return cell
  	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
  	elseif fn=="ccTouchMoved" then
		self.isMoved=true
  	elseif fn=="ccTouchEnded"  then
  	end
end

function acChunjiepanshengTask:cellIdx0(backSprie,index)

	local desH=backSprie:getContentSize().height/2
	local desW=130
	local adaSize = 0
	if G_getCurChoseLanguage() == "ar" then
		adaSize = 100
	end
	local titleStr--=getlocal("activity_chunjiepansheng_taskTitle" .. self.id)
	local version=acChunjiepanshengVoApi:getVersion()
	if version and version==3 and self.id==7 then
		titleStr=getlocal("activity_chunjiepansheng_taskTitle" .. self.id .. "_ver" .. version)
	else
		titleStr=getlocal("activity_chunjiepansheng_taskTitle" .. self.id)
	end

	local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(G_VisibleSizeWidth-330-adaSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0,0.5))
    if version and version==4 then
		-- titleLb:setColor(G_ColorYellowPro)
	else
		titleLb:setColor(G_ColorYellowPro)
	end
	titleLb:setPosition(ccp(desW,desH))
	backSprie:addChild(titleLb)

	local rewardItem=FormatItem(self.taskList[index][3])

	local function touchReward()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		
		acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_canReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)

	end
	local rewardSp
	if version and version==4 then
		rewardSp = LuaCCSprite:createWithSpriteFrameName("packs1.png",touchReward)
	else
		rewardSp = LuaCCSprite:createWithSpriteFrameName("friendBtn.png",touchReward)
	end
	rewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
	rewardSp:setAnchorPoint(ccp(0,0.5))
	rewardSp:setPosition(15,desH)
	backSprie:addChild(rewardSp)
	rewardSp:setScale(1.1)

	
	-- local descStr=getlocal("activity_chunjiepansheng_" .. self.version .. "_desc" .. index,{self.taskList[index][2]})
	-- local desLb=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
 --    desLb:setAnchorPoint(ccp(0,0.5))
	-- desLb:setPosition(ccp(130,desH-20))
	-- backSprie:addChild(desLb)

	local cost = self.taskList[index][4]
	local typeTb=self.taskList[index][1]
	-- return 1:已结束 2:能领取 3:已领取 4:前往
	local flag = acChunjiepanshengVoApi:getTaskState(self.id,index,typeTb[1],typeTb[2])
	-- print("day++++++++++falg",self.id,flag)
	if flag==4 or flag==2 then
		local function purLibao()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end

			local function buyLibao()
				if playerVoApi:getGems()<cost then
		            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
		            return
		        end

				local action=2
				local day=self.id
				local tid=index
				local function callback()
					acChunjiepanshengVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
					for k,v in pairs(rewardItem) do
						if v.type~="p" then
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
					end

					G_showRewardTip(rewardItem,nil,nil,false)

					playerVoApi:setGems(playerVoApi:getGems()-cost)
					self:refreshTvAndProgress()
					-- eventDispatcher:dispatchEvent("chunjiepansheng.addTaskPoint")
				end
				acChunjiepanshengVoApi:getSocketReward(action,day,tid,callback)
			end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),false,buyLibao)
		end
		local purItem
		local purItemScale=0.8
		if self.version==4 then
			purItemScale=0.6
			purItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",purLibao,nil,getlocal("buy"),24/purItemScale)
		else
			purItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",purLibao,nil,getlocal("buy"),25)
		end
		purItem:setAnchorPoint(ccp(0.5,0.5))
		purItem:setScale(purItemScale)
		local purBtn=CCMenu:createWithItem(purItem);
		purBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		purBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH-20))
		backSprie:addChild(purBtn)

		
		local costLabel
		if self.version==4 then
			costLabel = GetTTFLabel(tostring(cost),30)
		else
		
			costLabel = GetTTFLabel(tostring(cost),25)
		end
		costLabel:setAnchorPoint(ccp(0,0))
		costLabel:setPosition(purItem:getContentSize().width/2-25,purItem:getContentSize().height+5)
		costLabel:setColor(G_ColorYellowPro)
		purItem:addChild(costLabel)
		costLabel:setScale(1/0.8)

		local tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
		tenGem:setAnchorPoint(ccp(0,0.5))
		tenGem:setPosition(costLabel:getContentSize().width,costLabel:getContentSize().height/2)
		costLabel:addChild(tenGem)
		if self.version==4 then
			tenGem:setScale(1.3)
		end
	elseif flag==3 then
		local alreadyLb=GetTTFLabelWrap(getlocal("hasBuy"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		alreadyLb:setAnchorPoint(ccp(0.5,0.5))
		alreadyLb:setColor(G_ColorGreen)
		alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,desH))
		backSprie:addChild(alreadyLb)
	elseif flag==1 then
		local endLb=GetTTFLabelWrap(getlocal("dailyAnswer_tab1_question_title3"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		endLb:setAnchorPoint(ccp(0.5,0.5))
		endLb:setColor(G_ColorRed)
		endLb:setPosition(ccp(backSprie:getContentSize().width-90,desH))
		backSprie:addChild(endLb)
	elseif flag==5 then
		local noStartLb=GetTTFLabelWrap(getlocal("local_war_stage_1"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noStartLb:setAnchorPoint(ccp(0.5,0.5))
		noStartLb:setColor(G_ColorRed)
		noStartLb:setPosition(ccp(backSprie:getContentSize().width-90,desH))
		backSprie:addChild(noStartLb)
	end




	
end

function acChunjiepanshengTask:cellNotIdx0(backSprie,index)
	local strSize2 = 21
	local strWidthSize2 = 20
	local lbWidthSize2 = CCSizeMake(250,0)
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strWidthSize2 =90
        lbWidthSize2 =CCSizeMake(140,0)
    end
	local typeTb=self.taskList[index][1]
	local titleStr1
	local titleStr2
	local tkNum = acChunjiepanshengVoApi:getTypeTaskProgress(self.id,typeTb[1])
	local lbSize=CCSizeMake(G_VisibleSizeWidth-100,0)

	if tkNum>typeTb[2] then
		tkNum=typeTb[2]
	end
	-- return 1:已结束 2:能领取 3:已领取 4:前往
	local flag,flag2 = acChunjiepanshengVoApi:getTaskState(self.id,index,typeTb[1],typeTb[2])
	

	if typeTb[1]=="gb" then
		-- titleStr1=getlocal("activity_chunjiepansheng_gb_title",{typeTb[2]})
		local version=acChunjiepanshengVoApi:getVersion()
		if version and version==3 then
			titleStr1=getlocal("activity_chunjiepansheng_gb_title_ver"..version,{typeTb[2]})
		else
			titleStr1=getlocal("activity_chunjiepansheng_gb_title",{typeTb[2]})
		end
		titleStr2=getlocal("activity_baifudali_totalMoney") .. tkNum
		lbSize=CCSizeMake(180,0)
		if G_getCurChoseLanguage() == "ar" then
			lbSize = CCSizeMake(120,0)
		end
	else
		-- 在api写一个方法，知道完成多少次了
		titleStr1=getlocal("activity_chunjiepansheng_" .. typeTb[1] .. "_title",{tkNum,typeTb[2]})
		if flag==3 or flag2~=nil then
			titleStr1=getlocal("activity_chunjiepansheng_" .. typeTb[1] .. "_title",{typeTb[2],typeTb[2]})
		end
	end
	local version=acChunjiepanshengVoApi:getVersion()
	local lbStarWidth=15
	local strsizeH = 25
	if G_isAsia() ~= true and tonumber(index) == 2  then
		strsizeH = 18
	end
	local titleLb=GetTTFLabelWrap(titleStr1,strsizeH,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0,1))
    if version and version==4 then
		-- titleLb:setColor(G_ColorYellowPro)
	else
		titleLb:setColor(G_ColorYellowPro)
	end
	titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-10))
	backSprie:addChild(titleLb)

	if typeTb[1]=="gb" then
		local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
		titleLb:addChild(iconGold)
		iconGold:setPosition(titleLb:getContentSize().width+10,titleLb:getContentSize().height/2)

		local titleLb=GetTTFLabelWrap(titleStr2,25,lbWidthSize2,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    titleLb:setAnchorPoint(ccp(0,1))
	    if version and version==4 then
			-- titleLb:setColor(G_ColorYellowPro)
		else
			titleLb:setColor(G_ColorYellowPro)
		end
		local adapos = 0
		if G_getCurChoseLanguage() == "ar" then
			adapos = 100
		end
		titleLb:setPosition(ccp(backSprie:getContentSize().width/2+strWidthSize2-adapos,backSprie:getContentSize().height-15))
		backSprie:addChild(titleLb)

		local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
		titleLb:addChild(iconGold)
		iconGold:setAnchorPoint(ccp(0.5,0.5))
		iconGold:setPosition(titleLb:getContentSize().width+5,titleLb:getContentSize().height/2)
	end
	local desH=self.tvH  - titleLb:getContentSize().height-20-lbStarWidth-17
	local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize2-3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    if version and version==4 then
		-- desLb:setColor(G_ColorYellowPro)
	else
		desLb:setColor(G_ColorYellowPro)
	end
	desLb:setPosition(ccp(lbStarWidth,desH/2))
	backSprie:addChild(desLb)

	local rewardItem=FormatItem(self.taskList[index][3],nil,true)
	local taskW=0
	local version=acChunjiepanshengVoApi:getVersion()
	for k,v in pairs(rewardItem) do
		local icon
		if version and version==4 then
			local function showNewPropDialog()
            	G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
        	end
            icon = G_getItemIcon(v,100,false,self.layerNum+1,showNewPropDialog)
		else
			icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil,version)
		end
		icon:setTouchPriority(-(self.layerNum-1)*20-3)
		backSprie:addChild(icon)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(k*100+20, desH/2)
		local scale=80/icon:getContentSize().width
		icon:setScale(scale)
		taskW=k*100


		local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(icon:getContentSize().width-5, 5)
		numLabel:setScale(1/scale)
		icon:addChild(numLabel,1)
	end

	-- local taskSp=GetBgIcon("acChunjiepansheng_tanskPoint.png",nil,"equipBg_blue.png")
	-- taskSp:setPosition(ccp(taskW+100,desH/2))
	-- taskSp:setAnchorPoint(ccp(0,0.5))
	-- backSprie:addChild(taskSp)
	-- taskSp:setScale(80/taskSp:getContentSize().width)


	if flag==4 then
		local function goTiantang()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end

			G_goToDialog(typeTb[1],4,true)
		end
		local goItem
		local goItemScale=0.8
		if self.version==4 then
			goItemScale=0.6
			goItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),24/goItemScale)
		else
			goItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25)
		end
		goItem:setScale(goItemScale)
		local goBtn=CCMenu:createWithItem(goItem);
		goBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		goBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(goBtn)
	elseif flag==3 then
		local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		alreadyLb:setAnchorPoint(ccp(0.5,0.5))
		alreadyLb:setColor(G_ColorGreen)
		alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(alreadyLb)
	elseif flag==2 then
		local function rewardTiantang()
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end

			local action=2
			local day=self.id
			local tid=index
			local function callback()
				for k,v in pairs(rewardItem) do
					if v.type~="p" then
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
				end
				G_showRewardTip(rewardItem,nil,nil,false)
				self:refreshTvAndProgress()
			end
			acChunjiepanshengVoApi:getSocketReward(action,day,tid,callback,flag2)
		end
		local rewardItem
		local rewardItemScale=0.8
		if self.version==4 then
			rewardItemScale=0.6
			rewardItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),24/rewardItemScale)
		else
			rewardItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
		end
		rewardItem:setScale(rewardItemScale)
		local rewardBtn=CCMenu:createWithItem(rewardItem);
		rewardBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(rewardBtn)
	elseif flag==1 then
		local endLb=GetTTFLabelWrap(getlocal("dailyAnswer_tab1_question_title3"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		endLb:setAnchorPoint(ccp(0.5,0.5))
		endLb:setColor(G_ColorRed)
		endLb:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(endLb)
	elseif flag==5 then
		local noStartLb=GetTTFLabelWrap(getlocal("local_war_stage_1"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noStartLb:setAnchorPoint(ccp(0.5,0.5))
		noStartLb:setColor(G_ColorRed)
		noStartLb:setPosition(ccp(backSprie:getContentSize().width-90,desH/2))
		backSprie:addChild(noStartLb)
	end
	


end

-- 领奖时刷新
function acChunjiepanshengTask:refreshTvAndProgress()

	self:refresh()

	local numTaskOfOver=acChunjiepanshengVoApi:getTaskProgress(self.id)
	local taskStr=numTaskOfOver .. "/".. self.cellNum
	local version=acChunjiepanshengVoApi:getVersion()
	local progressStr--=getlocal("activity_chunjiepansheng_taskProgress",{taskStr})
	if version and version==3 then
		progressStr=getlocal("activity_chunjiepansheng_taskProgress_ver"..version,{taskStr})
	else
		progressStr=getlocal("activity_chunjiepansheng_taskProgress",{taskStr})
	end

	
	self.progressLb:setString(progressStr)

	self:refreshLibaoLb()
end

-- 刷新礼包lb
function acChunjiepanshengTask:refreshLibaoLb()
	local flag = acChunjiepanshengVoApi:isCanGetCurReward(self.id,self.cellNum)
	local libaoStr=""
	local color
	if flag==1 then
		libaoStr=getlocal("activity_chunjiepansheng_click_kan")
		color=G_ColorWhite
	elseif flag==2 then
		libaoStr=getlocal("daily_scene_get")
		color=G_ColorGreen
	elseif flag==3 then
		libaoStr=getlocal("activity_hadReward")
		color=G_ColorGreen
	elseif flag==4 then
		libaoStr=getlocal("dailyAnswer_tab1_question_title3")
		color=G_ColorRed
	end
	self.libaoLb:setString(libaoStr)
	self.libaoLb:setColor(color)

	if flag==2 then
		self.guangSp1:setVisible(true)
		self.guangSp2:setVisible(true)
		local rotateBy = CCRotateBy:create(4,360)
	    local reverseBy = rotateBy:reverse()
	    self.guangSp1:runAction(CCRepeatForever:create(rotateBy))
	    self.guangSp2:runAction(CCRepeatForever:create(reverseBy))
	end
end

function acChunjiepanshengTask:refresh()
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end


function acChunjiepanshengTask:tick()
end

function acChunjiepanshengTask:dispose()
	base:removeFromNeedRefresh(self)
	self.bgLayer=nil
	self.parent=nil
end