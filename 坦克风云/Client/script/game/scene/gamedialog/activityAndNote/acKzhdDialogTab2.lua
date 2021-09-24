acKzhdDialogTab2={}

function acKzhdDialogTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.cellHight=110
	return nc
end

function acKzhdDialogTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer1()
	return self.bgLayer
end
function acKzhdDialogTab2:initLayer1(  )
	local startH=G_VisibleSize.height-160

	-- local bgSp1=CCSprite:createWithSpriteFrameName("groupSelf.png")
	-- bgSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2+25,startH-29))
	-- bgSp1:setScaleY(45/bgSp1:getContentSize().height)
	-- bgSp1:setScaleX(800/bgSp1:getContentSize().width)
	-- self.bgLayer:addChild(bgSp1)

	-- local titleLb1=GetTTFLabelWrap(getlocal("local_war_help_title9"),25,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- titleLb1:setPosition(self.bgLayer:getContentSize().width/2,startH-29)
	-- self.bgLayer:addChild(titleLb1,1)

	local titleTb1={getlocal("local_war_help_title9"),28,G_ColorWhite}
	local titleLbSize1=CCSizeMake(300,0)
	local titleBg1,titleL1=G_createNewTitle(titleTb1,titleLbSize1)
	self.bgLayer:addChild(titleBg1)
	titleBg1:setPosition(self.bgLayer:getContentSize().width/2,startH-29-15)

	local upSpHeight=200
	local upBgH=startH-60
	local function nilFunc()
	end
	local bgWidth=G_VisibleSize.width-30
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),nilFunc)
	upBg:setContentSize(CCSizeMake(bgWidth,upSpHeight))
	upBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(upBg)
	upBg:setAnchorPoint(ccp(0.5,1))
	upBg:setPosition(self.bgLayer:getContentSize().width/2,upBgH)
	self.upBg=upBg
	self:initUP()

	local startH2=upBgH-upBg:getContentSize().height
	-- local bgSp2=CCSprite:createWithSpriteFrameName("groupSelf.png")
	-- bgSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+25,startH2-29))
	-- bgSp2:setScaleY(45/bgSp2:getContentSize().height)
	-- bgSp2:setScaleX(800/bgSp2:getContentSize().width)
	-- self.bgLayer:addChild(bgSp2)

	-- local titleLb2=GetTTFLabelWrap(getlocal("activity_kzhd_way"),25,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- titleLb2:setPosition(self.bgLayer:getContentSize().width/2,startH2-29)
	-- self.bgLayer:addChild(titleLb2,1)

	local titleTb2={getlocal("activity_kzhd_way"),28,G_ColorWhite}
	local titleLbSize2=CCSizeMake(300,0)
	local titleBg2,titleL2=G_createNewTitle(titleTb2,titleLbSize2)
	self.bgLayer:addChild(titleBg2)
	titleBg2:setPosition(self.bgLayer:getContentSize().width/2,startH2-29-15)

	local downBgH=startH2-60
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),nilFunc)
	downBg:setContentSize(CCSizeMake(bgWidth,downBgH-30))
	self.bgLayer:addChild(downBg)
	downBg:setAnchorPoint(ccp(0.5,1))
	downBg:setPosition(self.bgLayer:getContentSize().width/2,downBgH)
	self.downBg=downBg
	self:initDown()

	self:addForbid()
end

function acKzhdDialogTab2:addForbid()
	local function forbidClick()
	end
	local capInSet = CCRect(20, 20, 10, 10)
	local upforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
	self.bgLayer:addChild(upforbidSp)
	upforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	upforbidSp:setAnchorPoint(ccp(0.5,0))
	upforbidSp:setPosition(G_VisibleSizeWidth/2,self.downBg:getPositionY())
	upforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	upforbidSp:setVisible(false)

	local downForbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
	self.bgLayer:addChild(downForbidSp)
	downForbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.downBg:getPositionY()-self.downBg:getContentSize().height))
	downForbidSp:setAnchorPoint(ccp(0.5,0))
	downForbidSp:setPosition(G_VisibleSizeWidth/2,0)
	downForbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	downForbidSp:setVisible(false)
end

function acKzhdDialogTab2:initUP()
	local strSize2,poy2 =18,10
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2,poy2 = 22,20
	end
	local desLb,lbHeight=G_getRichTextLabel(getlocal("activity_kzhd_des4"),{G_ColorWhite,G_ColorRed,G_ColorWhite},strSize2,self.upBg:getContentSize().width-60,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	desLb:setAnchorPoint(ccp(0,1))
	desLb:setPosition(30,self.upBg:getContentSize().height-poy2)
	self.upBg:addChild(desLb,1)

	local poolReward,poolflicker=acKzhdVoApi:getPoolList()
	local reardTv
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return #poolReward
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(105,100)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local function showNewPropInfo()
	            G_showNewPropInfo(self.layerNum+1,true,true,nil,poolReward[idx + 1])
	            return false
	        end
			local rewardIcon=G_getItemIcon(poolReward[idx + 1],100,true,self.layerNum + 1,showNewPropInfo,reardTv)
			rewardIcon:setScale(80/rewardIcon:getContentSize().width)
			rewardIcon:setTouchPriority(-(self.layerNum-1)*20-4)
			rewardIcon:setAnchorPoint(ccp(0,0))
			rewardIcon:setPosition(0,0)
			cell:addChild(rewardIcon)
			if(poolReward[idx + 1].num)then
				local numLb=GetTTFLabel("x"..FormatNumber(poolReward[idx + 1].num),25)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(rewardIcon:getContentSize().width - 10,10)
				rewardIcon:addChild(numLb)
			end

			local index=poolReward[idx + 1].index
			if index and poolflicker[index] then
				local flickerIdxTb = {y=3,b=1,p=2,g=4}
				local colorType=poolflicker[index]
	        	G_addRectFlicker2(rewardIcon,1.15,1.15,flickerIdxTb[colorType],colorType)
			end

			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	reardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(self.upBg:getContentSize().width-60,100),nil)
	reardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	reardTv:setPosition(30,25)
	self.upBg:addChild(reardTv)
	reardTv:setMaxDisToBottomOrTop(80)


end

function acKzhdDialogTab2:initDown()
	self.taskList=acKzhdVoApi:getTask()
	self.taskNum=SizeOfTable(self.taskList)
	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.downBg:getContentSize().width,self.downBg:getContentSize().height-10),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(0,5)
	self.downBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

function acKzhdDialogTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.taskNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(610,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=610

		local taskInfo=self.taskList[idx+1]

		local desStr1=getlocal("new_task_type_" .. taskInfo.sType)
		local desLb1=GetTTFLabelWrap(desStr1,24,CCSizeMake(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb1:setAnchorPoint(ccp(0,0.5))
		desLb1:setPosition(30,self.cellHight/2+20)
		cell:addChild(desLb1)
		desLb1:setColor(G_ColorYellowPro)

		local desStr2=getlocal("activity_daily_rDes",{taskInfo.haveNum .. "/" .. taskInfo.needNum})
		local desLb2=GetTTFLabelWrap(desStr2,20,CCSizeMake(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb2:setAnchorPoint(ccp(0,0.5))
		desLb2:setPosition(30,self.cellHight/2-20)
		cell:addChild(desLb2)

		if taskInfo.index>10000 then
			local desLb3=GetTTFLabelWrap(getlocal("activity_wanshengjiedazuozhan_complete"),24,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			desLb3:setAnchorPoint(ccp(0.5,0.5))
			desLb3:setPosition(cellWidth-60,self.cellHight/2)
			cell:addChild(desLb3)
			desLb3:setColor(G_ColorGray)
		else
			local function gotoCallback()
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				    if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end
				    PlayEffect(audioCfg.mouseClick)
					activityAndNoteDialog:closeAllDialog()
					G_goToDialog2(taskInfo.sType,4,nil)
				end
				
			end
			local goToMenuItem=GetButtonItem("gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png",gotoCallback,11,nil,25,12)
			local gotoBtn=CCMenu:createWithItem(goToMenuItem)
			gotoBtn:setTag(203)
			gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
			gotoBtn:setPosition(cellWidth-60,self.cellHight/2)
			cell:addChild(gotoBtn)

		end

		local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake((cellWidth-4),2))
        lineSp:setRotation(180)
        lineSp:setPosition(cellWidth/2,0)
        cell:addChild(lineSp)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end


function acKzhdDialogTab2:refresh()
	self.taskList=acKzhdVoApi:getTask()
	self.taskNum=SizeOfTable(self.taskList)
	self.tv:reloadData()
end


function acKzhdDialogTab2:fastTick()
end

function acKzhdDialogTab2:updateAcTime()
end

function acKzhdDialogTab2:dispose()
end