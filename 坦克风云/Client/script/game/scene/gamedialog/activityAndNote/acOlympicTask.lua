acOlympicTask={}

function acOlympicTask:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.id=1
	nc.bgLayer=nil
	nc.parent=parent
	nc.tvH=190
	nc.taskBg=nil
	nc.lineSp=nil
	nc.desTv=nil
	nc.progressBar=nil
	return nc
end

function acOlympicTask:init(layerNum,id)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.id=id
	self.version=acOlympicCollectVoApi:getVersion()
	self.taskList=acOlympicCollectVoApi:getDayOfTask(self.id)
	self.cellNum=SizeOfTable(self.taskList)

	return self.bgLayer
end

function acOlympicTask:realShow()
	self:initInfo()
	self:initTableView()
	base:addNeedRefresh(self)
end
function acOlympicTask:initInfo()
	local strSize2=21
	local strSize3=25
	local strSize4=20
	local strSize5 = 16
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        strSize2=25
        strSize3=32
        strSize4=25
        strSize5 = 22
    end
	local capInSet=CCRect(20, 20, 10, 10)
	local function nilFunc()
	end
   	local bgPic="event_bluebg.png"
    local cur,max=acOlympicCollectVoApi:getDayTaskProgress(self.id)
    if cur>=max then
        bgPic="event_goldbg.png"
    end
    local bgSp=CCSprite:createWithSpriteFrameName(bgPic)
    local bgSize=bgSp:getContentSize()
    bgSp:setAnchorPoint(ccp(0,0.5))
	bgSp:setPosition(ccp(25,G_VisibleSizeHeight-100-bgSize.height/2))
    self.bgLayer:addChild(bgSp)
	local pic,name,desc,openDay=acOlympicCollectVoApi:getDayOfEvent(self.id)
	local eventIcon=CCSprite:createWithSpriteFrameName(pic)
	eventIcon:setPosition(ccp(bgSize.width/2,bgSize.height/2))
	bgSp:addChild(eventIcon)

    local function bgClick()
    end
    local desBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    desBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-160,120))
    desBgSp:setAnchorPoint(ccp(0,0.5))
    desBgSp:setPosition(ccp(bgSp:getPositionX()+bgSize.width+10,bgSp:getPositionY()))
    self.bgLayer:addChild(desBgSp)

    local desTv,desLabel=G_LabelTableView(CCSizeMake(desBgSp:getContentSize().width-20,desBgSp:getContentSize().height-20),desc,22,kCCTextAlignmentLeft)
    desBgSp:addChild(desTv)
    desTv:setPosition(ccp(10,10))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desTv:setMaxDisToBottomOrTop(100)
    self.desTv=desTv

    local taskBgW=G_VisibleSizeWidth-30
    local taskBgH=100
    local barHeight=20
    local numTaskOfOver,allNum=acOlympicCollectVoApi:getDayTaskProgress(self.id)
	local taskStr=numTaskOfOver .. "/" .. allNum
	local progressStr=getlocal("activity_aoyunjizhang_task_pro",{name,taskStr})
	local colorTab={nil,G_ColorGreen}
    local progressLb,lbHeight=G_getRichTextLabel(progressStr,colorTab,strSize4,taskBgW-150,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    if barHeight+30+lbHeight>taskBgH then
    	taskBgH=barHeight+30+lbHeight
    end
	local taskBg=LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27,29,2,2),nilFunc)
    taskBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,taskBgH))
    taskBg:ignoreAnchorPointForPosition(false)
    taskBg:setTouchPriority(-(self.layerNum-1)*20-3)
    taskBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(taskBg)
    self.taskBg=taskBg
	local taskBgSize=taskBg:getContentSize()
	self.taskBgSize=taskBgSize
    taskBg:setPosition(G_VisibleSizeWidth/2,desBgSp:getPositionY()-desBgSp:getContentSize().height/2-taskBgSize.height)
    local barWidth=taskBgSize.width-150
    local pSprite=AddProgramTimer(taskBg,ccp(15+barWidth/2,taskBgSize.height-barHeight-10),110,nil,nil,"AllBarBg.png","xpBar.png",824)
    pSprite:setScaleX(barWidth/pSprite:getContentSize().width)
    pSprite:setScaleY(barHeight/pSprite:getContentSize().height)
    local progressSp=tolua.cast(taskBg:getChildByTag(824),"CCSprite")
    progressSp:setScaleX((barWidth+5)/progressSp:getContentSize().width)
    progressSp:setScaleY((barHeight+10)/progressSp:getContentSize().height)
    local percent=0
    if allNum>0 then
        percent=(numTaskOfOver/allNum)*100
    end
    pSprite:setPercentage(percent)
    self.progressBar=pSprite
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0,1))
    lineSp:setScaleX((taskBgSize.width-150)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(10,taskBgSize.height-45))
    taskBg:addChild(lineSp)
    self.lineSp=lineSp
    -- local progressLb=GetTTFLabelWrap(progressStr,25,CCSizeMake(taskBgSize.width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    progressLb:setAnchorPoint(ccp(0,1))
	-- progressLb:setColor(G_ColorGreen)
	progressLb:setPosition(ccp(15,lineSp:getPositionY()-10))
	taskBg:addChild(progressLb)
	self.progressLb=progressLb

	local giftW=taskBgSize.width-80
	local guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
	guangSp1:setPosition(giftW,taskBg:getContentSize().height/2)
	taskBg:addChild(guangSp1)

	local guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
	guangSp2:setPosition(giftW,taskBg:getContentSize().height/2)
	taskBg:addChild(guangSp2)

	guangSp1:setScale(0.8)
	guangSp2:setScale(0.8)

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
		
		local flag=acOlympicCollectVoApi:isCanGetCurReward(self.id,self.cellNum)

		local reward=acOlympicCollectVoApi:getDayOfTaskReward(self.id)
		local rewardItem=FormatItem(reward)

		if flag==2 then
			local function callback()
				acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
				for k,v in pairs(rewardItem) do
					if v.type~="p" then
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
				end

				self.guangSp1:setVisible(false)
				self.guangSp2:setVisible(false)
				self.guangSp1:stopAllActions()
				self.guangSp2:stopAllActions()
				
				G_showRewardTip(rewardItem)

				self:refreshLibaoLb()
				acOlympicCollectVoApi:setRefresh(true)
			end
			local action=3
			local day=self.id
			acOlympicCollectVoApi:getSocketReward(action,day,nil,callback)
			return
		end
		
		acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_aoyunjizhang_canReward1"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)
	end
	local scale=1
	local rewardSp=LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",touchReward)
	rewardSp:setTouchPriority(-(self.layerNum-1)*20-5)
	rewardSp:setPosition(giftW,taskBg:getContentSize().height/2+10)
	taskBg:addChild(rewardSp,5)
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
end
function acOlympicTask:initTableView()
	local function callback( ... )
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight-self.taskBgSize.height-250),nil)
    self.tv:setPosition(ccp(30,40))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acOlympicTask:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		 return self.cellNum
  	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.tvH)
		return  tmpSize
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local capInSet=CCRect(20, 20, 20, 20)
		local function cellClick()
		end
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-70, self.tvH-45))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(5,0)
		cell:addChild(backSprie,1)

		local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
	    orangeMask:setScaleX(backSprie:getContentSize().width/orangeMask:getContentSize().width)
	    orangeMask:setScaleY(45/orangeMask:getContentSize().height)
	    orangeMask:setPosition(G_VisibleSizeWidth/2,self.tvH-24)
	    cell:addChild(orangeMask,1)

	    local taskStr=getlocal("small_event_title")..idx+1
		local taskTitleLb=GetTTFLabelWrap(taskStr,28,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		taskTitleLb:setAnchorPoint(ccp(0.5,0.5))
		-- taskTitleLb:setColor(G_ColorYellowPro)
		taskTitleLb:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.tvH-25))
		cell:addChild(taskTitleLb,2)
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

function acOlympicTask:cellIdx0(backSprie,index)
	local strSize2 = 14
	local subWidth =360
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =22
        subWidth =340
    end
	local desH=backSprie:getContentSize().height/2
	local desW=130
	local titleStr
	local version=acOlympicCollectVoApi:getVersion()
	local pic,name,desc,openDay=acOlympicCollectVoApi:getDayOfEvent(self.id)
	local rewardItem=FormatItem(self.taskList[index][3])
	titleStr=getlocal("activity_aoyunjizhang_taskTitle",{name})
	local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(G_VisibleSizeWidth-340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(desW,backSprie:getContentSize().height-10))
	backSprie:addChild(titleLb)

	local score=0
	for k,v in pairs(rewardItem) do
		if v.key=="p3324" then
			score=v.num
			do break end
		end
	end
	local taskDesc=getlocal("activity_aoyunjizhang_taskDesc",{"<rayimg>"..score.."<rayimg>"})
	local colorTab={nil,G_ColorGreen}
	local descLb,lbHeight=G_getRichTextLabel(taskDesc,colorTab,strSize2,G_VisibleSizeWidth-subWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    descLb:setAnchorPoint(ccp(0,1))
	descLb:setPosition(ccp(desW,titleLb:getPositionY()-titleLb:getContentSize().height-10))
	backSprie:addChild(descLb)

	local function touchReward()
		if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end	
			acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_aoyunjizhang_canReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem)
		end
	end
	local rewardSp=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",touchReward)
	rewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
	rewardSp:setAnchorPoint(ccp(0,0.5))
	rewardSp:setPosition(15,desH)
	backSprie:addChild(rewardSp)
	rewardSp:setScale(1.1)

	local cost=self.taskList[index][4]
	local typeTb=self.taskList[index][1]
	-- return 1:已结束 2:能领取 3:已领取 4:前往
	local flag=acOlympicCollectVoApi:getTaskState(self.id,index,typeTb[1],typeTb[2])
	-- print("day++++++++++falg",self.id,flag)
	if flag==4 or flag==2 then
		local function purLibao()
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				if playerVoApi:getGems()<cost then
		            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
		            return
		        end

				local action=2
				local day=self.id
				local tid=index
				local function callback()
					acOlympicCollectVoApi:showSmallDialog(true,true,self.layerNum+1,getlocal("activity_chunjiepansheng_getReward"),"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardItem,true)
					for k,v in pairs(rewardItem) do
						if v.type~="p" then
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
					end
					G_showRewardTip(rewardItem)
					playerVoApi:setGems(playerVoApi:getGems()-cost)
					self:refreshTvAndProgress()
					-- eventDispatcher:dispatchEvent("chunjiepansheng.addTaskPoint")
				end
				acOlympicCollectVoApi:getSocketReward(action,day,tid,callback)
			end
		end
		local purItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",purLibao,nil,getlocal("buy"),25)
		purItem:setAnchorPoint(ccp(0.5,0.5))
		purItem:setScale(0.8)
		local purBtn=CCMenu:createWithItem(purItem);
		purBtn:setTouchPriority(-(self.layerNum-1)*20-3);
		purBtn:setPosition(ccp(backSprie:getContentSize().width-90,desH-20))
		backSprie:addChild(purBtn)
		
		local costLabel=GetTTFLabel(tostring(cost),25)
		costLabel:setAnchorPoint(ccp(0,0))
		costLabel:setPosition(purItem:getContentSize().width/2-25,purItem:getContentSize().height+5)
		costLabel:setColor(G_ColorYellowPro)
		purItem:addChild(costLabel)
		costLabel:setScale(1/0.8)

		local tenGem=CCSprite:createWithSpriteFrameName("IconGold.png")
		tenGem:setAnchorPoint(ccp(0,0.5))
		tenGem:setPosition(costLabel:getContentSize().width,costLabel:getContentSize().height/2)
		costLabel:addChild(tenGem)
	elseif flag==3 then
		local alreadyLb=GetTTFLabelWrap(getlocal("hasBuy"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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

function acOlympicTask:cellNotIdx0(backSprie,index)
	local strSize2=21
	local strWidthSize2=20
	local lbWidth=250
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        strSize2=22
        strWidthSize2=90
        lbWidth=180
    end
	local typeTb=self.taskList[index][1]
	local titleStr1
	local titleStr2
	local tkNum=acOlympicCollectVoApi:getTypeTaskProgress(self.id,typeTb[1])
	-- return 1:已结束 2:能领取 3:已领取 4:前往
	local flag,taskType=acOlympicCollectVoApi:getTaskState(self.id,index,typeTb[1],typeTb[2])
	local lbSize=CCSizeMake(G_VisibleSizeWidth-100,0)
	if tkNum>typeTb[2] or flag==2 or flag==3 then
		tkNum=typeTb[2]
	end
	local colorTab={}
	local isRichLabel=G_isShowRichLabel()
	if typeTb[1]=="gb" then
		-- titleStr1=getlocal("activity_chunjiepansheng_gb_title",{typeTb[2]})
		colorTab={nil,G_ColorYellowPro}
		local version=acOlympicCollectVoApi:getVersion()
		if version and version==3 then
			if isRichLabel==true then
				titleStr1=getlocal("activity_chunjiepansheng_gb_title_ver"..version,{"<rayimg>"..typeTb[2].."<rayimg>"})
			else
				titleStr1=getlocal("activity_chunjiepansheng_gb_title_ver"..version,{typeTb[2]})
			end
		else
			if isRichLabel==true then
				titleStr1=getlocal("activity_chunjiepansheng_gb_title",{"<rayimg>"..typeTb[2].."<rayimg>"})
			else
				titleStr1=getlocal("activity_chunjiepansheng_gb_title",{typeTb[2]})
			end
		end
		if isRichLabel==true then
			titleStr2=getlocal("activity_baifudali_totalMoney") .. "<rayimg>"..tkNum.."<rayimg>"
		else
			titleStr2=getlocal("activity_baifudali_totalMoney") .. tkNum
		end
		lbSize=CCSizeMake(180,0)
	else
		-- 在api写一个方法，知道完成多少次了
		if isRichLabel==true then
			titleStr1=getlocal("activity_chunjiepansheng_" .. typeTb[1] .. "_title",{"<rayimg>"..tkNum,typeTb[2].."<rayimg>"})
		else
			titleStr1=getlocal("activity_chunjiepansheng_" .. typeTb[1] .. "_title",{tkNum,typeTb[2]})
		end
		colorTab={nil,G_ColorYellowPro,nil}
	end
	local lbStarWidth=15
	local realTextW
	if isRichLabel==true then
		if typeTb[1]=="gb" then
			titleStr1=titleStr1.."<rayimg>IconGold.png<rayimg>"
		end
	else
		local titleLb=GetTTFLabel(titleStr1,strSize2)
		realTextW=titleLb:getContentSize().width
	end
    local titleLb,lbHeight=G_getRichTextLabel(titleStr1,colorTab,strSize2,backSprie:getContentSize().width-200,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-10))
	backSprie:addChild(titleLb)
	if typeTb[1]=="gb" then
		if realTextW then
			local titleW=titleLb:getContentSize().width
			if realTextW>titleW then
				realTextW=titleW
			end
			local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp:setAnchorPoint(ccp(0,0))
			goldSp:setPosition(titleLb:getPositionX()+realTextW,titleLb:getPositionY()-lbHeight-3)
			backSprie:addChild(goldSp)
		end
		local realTextW2
		if isRichLabel==true then
			titleStr2=titleStr2.."<rayimg>IconGold.png<rayimg>"
		else
			local titleLb2=GetTTFLabel(titleStr2,strSize2)
			realTextW2=titleLb2:getContentSize().width
		end
    	local titleLb2,lbHeight2=G_getRichTextLabel(titleStr2,colorTab,strSize2,lbWidth,kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter,0)
	    titleLb2:setAnchorPoint(ccp(1,1))
		titleLb2:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height-10))
		backSprie:addChild(titleLb2)
		if realTextW2 then
			local titleW2=titleLb2:getContentSize().width
			if realTextW2>titleW2 then
				realTextW2=titleW2
			end
			local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp:setAnchorPoint(ccp(0,0))
			goldSp:setPosition(titleLb2:getPositionX()+realTextW2/2,titleLb2:getPositionY()-lbHeight2-3)
			backSprie:addChild(goldSp)
		end
	end
	local desH=self.tvH-lbHeight-20-lbStarWidth-17
	local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize2-3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
	-- desLb:setColor(G_ColorYellowPro)
	desLb:setPosition(ccp(lbStarWidth,desH/2))
	backSprie:addChild(desLb)

	local rewardItem=FormatItem(self.taskList[index][3],nil,true)
	local taskW=0
	for k,v in pairs(rewardItem) do
		local icon=G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv)
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

	if flag==4 then
		local function goTiantang()
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
				    do
				        return
				    end
				else
				    base.setWaitTime=G_getCurDeviceMillTime()
				end

				G_goToDialog(typeTb[1],4,true)
			end
		end
		local goItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25)
		goItem:setScale(0.8)
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
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
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
					G_showRewardTip(rewardItem)

					self:refreshTvAndProgress()
				end
				acOlympicCollectVoApi:getSocketReward(action,day,tid,callback,taskType)
			end
		end
		local rewardItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
		rewardItem:setScale(0.8)
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

--领奖时刷新
function acOlympicTask:refreshTvAndProgress()
	local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	self:refresh()
	local pic,name,desc,openDay=acOlympicCollectVoApi:getDayOfEvent(self.id)
	local numTaskOfOver,allNum=acOlympicCollectVoApi:getDayTaskProgress(self.id)
	local taskStr=numTaskOfOver .. "/".. allNum
	local progressStr=getlocal("activity_aoyunjizhang_task_pro",{name,taskStr})
	local colorTab={nil,G_ColorGreen}
	if self.progressLb and self.taskBg and self.lineSp and self.progressBar then
		self.progressLb:removeFromParentAndCleanup(true)
		self.progressLb=nil
    	local progressLb,lbHeight=G_getRichTextLabel(progressStr,colorTab,strSize2,G_VisibleSizeWidth-180,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
    	self.progressLb=progressLb
	    progressLb:setAnchorPoint(ccp(0,1))
		progressLb:setPosition(ccp(15,self.lineSp:getPositionY()-10))
		self.taskBg:addChild(progressLb)
		self.progressLb=progressLb
	    local percent=0
	    if allNum>0 then
	        percent=(numTaskOfOver/allNum)*100
	    end
		self.progressBar:setPercentage(percent)
	end
	acOlympicCollectVoApi:setRefresh(true)
	self:refreshLibaoLb()
end

-- 刷新礼包lb
function acOlympicTask:refreshLibaoLb()
	local flag=acOlympicCollectVoApi:isCanGetCurReward(self.id,self.cellNum)
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
	if flag ==1 then
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		else
			print("by flag 1 to change~~~~~")
			self.libaoLb:setFontSize(16)
		end
	elseif flag==2 then
		self.guangSp1:setVisible(true)
		self.guangSp2:setVisible(true)
		local rotateBy = CCRotateBy:create(4,360)
	    local reverseBy = rotateBy:reverse()
	    self.guangSp1:runAction(CCRepeatForever:create(rotateBy))
	    self.guangSp2:runAction(CCRepeatForever:create(reverseBy))
	end
end

function acOlympicTask:refresh()
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acOlympicTask:tick()
end

function acOlympicTask:dispose()
	base:removeFromNeedRefresh(self)
	self.bgLayer=nil
	self.parent=nil
	self.progressLb=nil
	self.guangSp1=nil
	self.guangSp2=nil
	self.libaoLb=nil
	self.taskBg=nil
	self.lineSp=nil
	self.desTv=nil
	self.progressBar=nil
	self.tv=nil
end