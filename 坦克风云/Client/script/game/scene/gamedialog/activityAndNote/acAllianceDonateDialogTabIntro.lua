acAllianceDonateDialogTabIntro={}
function acAllianceDonateDialogTabIntro:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	return nc
end

function acAllianceDonateDialogTabIntro:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-169))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(acAllianceDonateVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-202))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	local acVo=acAllianceDonateVoApi:getAcVo()
	G_updateActiveTime(acVo,self.timeLb)
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	girlImg:setAnchorPoint(ccp(0,1))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight-240))
	self.bgLayer:addChild(girlImg,2)
	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(410,(G_VisibleSizeHeight/2-85)*0.6-60))
	girlDescBg:setAnchorPoint(ccp(0,1))
	girlDescBg:setPosition(200,G_VisibleSizeHeight-270)
	self.bgLayer:addChild(girlDescBg,1)
	local lbWidth
	local lbPos
	if(G_isIphone5())then
		lbWidth=girlDescBg:getContentSize().width-100
		lbPos=girlDescBg:getContentSize().width/2+45
	else
		lbWidth=girlDescBg:getContentSize().width-70
		lbPos=girlDescBg:getContentSize().width/2+22
	end
	local girlDesc=GetTTFLabelWrap(getlocal("activity_allianceDonate_desc"),23,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	girlDesc:setPosition(lbPos,girlDescBg:getContentSize().height/2)
	girlDescBg:addChild(girlDesc)

	local function showInfo()
		local tabStr={"\n",getlocal("activity_allianceDonate_info2"),getlocal("activity_allianceDonate_title"),"\n",getlocal("activity_allianceDonate_info1"),"\n"};
		local tabColor={nil,G_ColorWhite,G_ColorGreen,nil,G_ColorWhite,nil}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-200));
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(infoBtn)

	local infoLayer =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function()end)
	infoLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-270-90-50-girlDescBg:getContentSize().height))
	infoLayer:setAnchorPoint(ccp(0.5,0))
	infoLayer:setPosition(ccp(G_VisibleSizeWidth/2,110))
	self.bgLayer:addChild(infoLayer)	

	self.lbArr={}
	self.cellHeightArr={}

	local lb1=GetTTFLabel(getlocal("activity_contentLabel"),28)
	lb1:setColor(G_ColorGreen)
	lb1:setAnchorPoint(ccp(0,0))
	lb1:setPosition(ccp(5,15))
	table.insert(self.lbArr,lb1)
	table.insert(self.cellHeightArr,lb1:getContentSize().height+15)

	local lb2=GetTTFLabelWrap(getlocal("activity_allianceDonate_content"),25,CCSizeMake(G_VisibleSizeWidth-130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	lb2:setAnchorPoint(ccp(0,0))
	lb2:setPosition(ccp(25,15))
	table.insert(self.lbArr,lb2)
	table.insert(self.cellHeightArr,lb2:getContentSize().height+15)

	local lb3=GetTTFLabel(getlocal("award"),28)
	lb3:setColor(G_ColorGreen)
	lb3:setAnchorPoint(ccp(0,0))
	lb3:setPosition(ccp(5,15))
	table.insert(self.lbArr,lb3)
	table.insert(self.cellHeightArr,lb3:getContentSize().height+15)

	local lb4=GetTTFLabelWrap(getlocal("activity_allianceDonate_reward"),25,CCSizeMake(G_VisibleSizeWidth-130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	lb4:setAnchorPoint(ccp(0,0))
	lb4:setPosition(ccp(25,0))
	table.insert(self.lbArr,lb4)
	table.insert(self.cellHeightArr,lb4:getContentSize().height)

	local function eventHandler( ... )
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(eventHandler)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-80,infoLayer:getContentSize().height-60),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(ccp(10,30))
	self.tv:setMaxDisToBottomOrTop(20)
	infoLayer:addChild(self.tv)

	local function onGetReward()
		local function callback()
			self.rewardItem:setEnabled(false)
			local lb=tolua.cast(self.rewardItem:getChildByTag(518),"CCLabelTTF")
			lb:setString(getlocal("activity_hadReward"))
		end
		acAllianceDonateVoApi:getReward(callback)
	end
	local btnStr
	if(acAllianceDonateVoApi:getHasReward()==true)then
		btnStr=getlocal("activity_hadReward")
	else
		btnStr=getlocal("daily_scene_get")
	end
	self.rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGetReward,2,btnStr,25,518)
	self.rewardItem:setAnchorPoint(ccp(0.5,0))
	local rewardBtn=CCMenu:createWithItem(self.rewardItem)
	rewardBtn:setAnchorPoint(ccp(0.5,0))
	rewardBtn:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(rewardBtn)
	if(acAllianceDonateVoApi:canReward()~=true)then
		self.rewardItem:setEnabled(false)
	end

	return self.bgLayer
end

function acAllianceDonateDialogTabIntro:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-80,self.cellHeightArr[idx+1])
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		cell:addChild(self.lbArr[idx+1])
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acAllianceDonateDialogTabIntro:tick()
	if self.timeLb then
		local acVo = acAllianceDonateVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end


