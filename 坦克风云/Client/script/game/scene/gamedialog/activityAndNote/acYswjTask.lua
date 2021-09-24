acYswjTask={}

function acYswjTask:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	nc.parent=nil
    nc.isEnd=false
    nc.cellHeight=157

	return nc
end

function acYswjTask:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self.taskList=acYswjVoApi:getTaskList()
	self.cellNum=SizeOfTable(self.taskList)
	self.rewardList={}
	for k,v in pairs(self.taskList) do
		self.rewardList[v.type]=FormatItem(v.reward,nil,true)
	end

    self.isEnd=acYswjVoApi:isEnd()
    if G_isIphone5() then
    	self.cellHeight=157
    else
    	self.cellHeight=150
    end
	self:initTableView()
	base:addNeedRefresh(self)

	return self.bgLayer
end

function acYswjTask:initTableView()
    local tvH=G_VisibleSizeHeight-190
	local function eventHandler(...)
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,tvH),nil)
    self.tv:setPosition(ccp(25,30))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tv,2)
    if self.cellNum*self.cellHeight<=(G_VisibleSizeHeight-170) then
    	self.tv:setMaxDisToBottomOrTop(0)
	else
    	self.tv:setMaxDisToBottomOrTop(120)
    end

end

function acYswjTask:eventHandler(handler,fn,idx,cel)
  	if fn=="numberOfCellsInTableView" then
  		 return self.cellNum
  	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
		return  tmpSize
  	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local task=self.taskList[idx+1]
		if task==nil then
			do return end
		end
		local cellWidth=G_VisibleSizeWidth-50
		local cellHeight=self.cellHeight
		local mtype=task.type --任务的类型
		local state,cur,needNum=acYswjVoApi:getTaskState(task)
		local rewardlist=self.rewardList[mtype]
		local desc=acYswjVoApi:getTaskDesc(mtype,needNum)
		local function cellClick()
		end
	    local taskBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20,20,10,10),cellClick)
	    taskBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
	    taskBg:setTouchPriority(-(self.layerNum-1)*20-1)
	    taskBg:setPosition(cellWidth/2,cellHeight/2)
	    cell:addChild(taskBg)

    	local fontSize=21
		local lbWidth=cellWidth-100
	    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
	        fontSize=25
	    end
		local lbStarWidth=15
		local descLb=GetTTFLabelWrap(desc,fontSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(ccp(10,cellHeight-10))
		descLb:setColor(G_ColorYellowPro)
		taskBg:addChild(descLb)
		local descHeight=descLb:getContentSize().height

		local rewardLb=GetTTFLabelWrap(getlocal("award"),fontSize,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    rewardLb:setAnchorPoint(ccp(0,0.5))
		rewardLb:setPosition(ccp(10,(cellHeight-descHeight)/2))
		taskBg:addChild(rewardLb)
		local tmpLb=GetTTFLabel(getlocal("award"),fontSize)
		local realW=tmpLb:getContentSize().width
		if realW>rewardLb:getContentSize().width then
			realW=rewardLb:getContentSize().width
		end

		local iconSize=80
		local startX=rewardLb:getPositionX()+realW
		for k,v in pairs(rewardlist) do
			local icon,scale=G_getItemIcon(v,iconSize,true,self.layerNum+1,nil,self.tv)
			icon:setTouchPriority(-(self.layerNum-1)*20-3)
			taskBg:addChild(icon)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(startX+(k-1)*(iconSize+10)+20,(cellHeight-descHeight)/2)

			local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
			numLabel:setAnchorPoint(ccp(1,0))
			numLabel:setPosition(icon:getContentSize().width-5,5)
			numLabel:setScale(1/scale)
			icon:addChild(numLabel,1)
		end
		if state==2 then --未完成
			local taskStr=cur .."/"..needNum
			local progressLb=GetTTFLabelWrap(taskStr,fontSize,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		    progressLb:setAnchorPoint(ccp(0.5,0.5))
			progressLb:setPosition(ccp(cellWidth-90,cellHeight/2+30))
			taskBg:addChild(progressLb)

			if G_getCurChoseLanguage() =="ru" then
				local unfinishedLb=GetTTFLabelWrap(getlocal("local_war_incomplete"),25,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
				unfinishedLb:setAnchorPoint(ccp(1,0.5))
				-- unfinishedLb:setColor(G_ColorGreen)
				unfinishedLb:setPosition(ccp(cellWidth-10,cellHeight/2-30))
				taskBg:addChild(unfinishedLb)
			else
	 			local unfinishedLb=GetTTFLabelWrap(getlocal("local_war_incomplete"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				unfinishedLb:setAnchorPoint(ccp(0.5,0.5))
				-- unfinishedLb:setColor(G_ColorGreen)
				unfinishedLb:setPosition(ccp(cellWidth-90,cellHeight/2-30))
				taskBg:addChild(unfinishedLb)
			end
		elseif state==1 then --可领取
			local function rewardHandler()
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
					    do
					        return
					    end
					else
					    base.setWaitTime=G_getCurDeviceMillTime()
					end
					local function callback()
						self:refresh()
						local flag=acYswjVoApi:isAllTaskRewarded()
						if flag==true then
							acYswjVoApi:sendRewardNotice()
						end
					end
					acYswjVoApi:yswjRequest("active.yunshiwajue.taskreward",{tid=tonumber(task.tid)},callback)
				end
			end
			local rewardItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
			rewardItem:setScale(0.8)
			local rewardBtn=CCMenu:createWithItem(rewardItem)
			rewardBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			rewardBtn:setPosition(ccp(cellWidth-90,cellHeight/2))
			taskBg:addChild(rewardBtn)
			if self.isEnd==true then
				rewardItem:setEnabled(false)
			end
		elseif state==3 then --已领取
			local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			alreadyLb:setAnchorPoint(ccp(0.5,0.5))
			alreadyLb:setColor(G_ColorGreen)
			alreadyLb:setPosition(ccp(cellWidth-90,cellHeight/2))
			taskBg:addChild(alreadyLb)
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

function acYswjTask:refresh()
	if self.tv then
		self.taskList=acYswjVoApi:getTaskList()
		-- local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		-- self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acYswjTask:updateUI()
	self:refresh()
end

function acYswjTask:tick()
    local isEnd=acYswjVoApi:isEnd()
    if isEnd~=self.isEnd and isEnd==true then
    	self.isEnd=isEnd
    	self:refresh()
    end
end

function acYswjTask:dispose()
	base:removeFromNeedRefresh(self)
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.parent=nil
    self.isEnd=false
    self.cellHeight=157
end