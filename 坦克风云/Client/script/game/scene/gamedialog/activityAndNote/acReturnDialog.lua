acReturnDialog=commonDialog:new()

function acReturnDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	return nc
end

function acReturnDialog:resetTab()
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v	
		if index==0 then
			tabBtnItem:setPosition(139,G_VisibleSizeHeight/2)
		elseif index==1 then
			tabBtnItem:setPosition(340,G_VisibleSizeHeight/2)
		else
			tabBtnItem:setPosition(ccp(999333,0))
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
end

function acReturnDialog:initTableView()
	local function callback()
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
		self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
		self.panelLineBg:setAnchorPoint(ccp(0,0))
		self.panelLineBg:setPosition(ccp(15,15))
		self:initBg()
		self:tabClick(0,false)
	end
	local hd= LuaEventHandler:createHandler(function(...) do return end end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	acReturnVoApi:init(callback)
end

function acReturnDialog:initBg()
	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(acReturnVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-125))
	self.bgLayer:addChild(timeLb)
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+50))
	self.bgLayer:addChild(girlImg,2)
	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(420,(G_VisibleSizeHeight/2-85)*0.6))
	girlDescBg:setAnchorPoint(ccp(0,0))
	girlDescBg:setPosition(200,G_VisibleSizeHeight/2+50)
	self.bgLayer:addChild(girlDescBg,1)
	local girlDesc=GetTTFLabelWrap(getlocal("activity_oldUserReturn_desc"),25,CCSizeMake(girlDescBg:getContentSize().width-85,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	girlDesc:setPosition(girlDescBg:getContentSize().width/2+40,girlDescBg:getContentSize().height/2)
	girlDescBg:addChild(girlDesc)

    local function showInfo()
        local tabStr={"\n",getlocal("activity_oldUserReturn_info4"),getlocal("activity_oldUserReturn_stayReward"),"\n",getlocal("activity_oldUserReturn_info3"),getlocal("activity_oldUserReturn_allSeverTitle"),"\n",getlocal("activity_oldUserReturn_info2"),getlocal("activity_oldUserReturn_rewardTitle"),"\n",getlocal("activity_oldUserReturn_info1"),"\n"};
        local tabColor ={nil,G_ColorWhite,G_ColorGreen,nil,G_ColorWhite,G_ColorGreen,nil,G_ColorWhite,G_ColorGreen,nil,G_ColorWhite,nil};
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-140));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn)
end

function acReturnDialog:tabClick(idx,isEffect)
	if(isEffect)then
		PlayEffect(audioCfg.mouseClick)
	end
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	if(idx==0)then
		if(self.acTab1==nil)then
			self.acTab1=acReturnDialogTab1:new()
			self.layerTab1=self.acTab1:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab1)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(0,0))
			self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
		end
	elseif(idx==1)then
		if(self.acTab2==nil)then
			self.acTab2=acReturnDialogTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
		end
	end
end

function acReturnDialog:dispose()
	self.layerTab1=nil
	self.layerTab2=nil
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    --CCTextureCache:sharedTextureCache():removeTextureForKeyForce("public/accessoryImage.pvr.ccz")
end