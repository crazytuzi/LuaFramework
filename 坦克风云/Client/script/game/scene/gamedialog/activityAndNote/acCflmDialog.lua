--2018春节充值活动春福临门
--author: Liang Qi
acCflmDialog=commonDialog:new()

function acCflmDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.acVo=acCflmVoApi:getAcVo()
	nc.tab1=nil
	nc.layerTab1=nil
	nc.tab2=nil
	nc.layerTab2=nil
	nc.lastTickIndex=0
	return nc
end

function acCflmDialog:resetTab()
	spriteController:addPlist("public/acCflmImage.plist")
	spriteController:addTexture("public/acCflmImage.png")
	spriteController:addPlist("public/acZnqd2017.plist")
	spriteController:addTexture("public/acZnqd2017.png")
	spriteController:addPlist("public/acChunjiepansheng.plist")
	spriteController:addTexture("public/acChunjiepansheng.png")
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addPlist("public/acDouble11_NewImage.plist")
	spriteController:addTexture("public/acDouble11_NewImage.png")
	spriteController:addPlist("public/redFlicker.plist")
	spriteController:addTexture("public/redFlicker.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
	spriteController:addTexture("public/activePicUseInNewGuid.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end 
		index=index+1
	end
	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 155)
	self.bgLayer:addChild(topBorder,1)
end

function acCflmDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			self:doUserHandler()            
		else
			v:setEnabled(true)
		end
	end
	self:getDataByType(idx)
end

function acCflmDialog:getDataByType(idx)
	if(idx==nil)then
		idx=0
	end
	if(idx==1)then
		if(self.tab2==nil)then
			self.tab2=acCflmDialogTabInvest:new()
			self.layerTab2=self.tab2:init(self.acVo,self.layerNum)
			self.bgLayer:addChild(self.layerTab2,1)
		end
		self.layerTab1:setVisible(false)
		self.layerTab1:setPositionX(999333)
		self.layerTab2:setVisible(true)
		self.layerTab2:setPositionX(0)
	else
		if(self.tab1==nil)then
			self.tab1=acCflmDialogTabRecharge:new()
			self.layerTab1=self.tab1:init(self.acVo,self.layerNum)
			self.bgLayer:addChild(self.layerTab1,1)
		end
		self.layerTab1:setVisible(true)
		self.layerTab1:setPositionX(0)
		if(self.layerTab2)then
			self.layerTab2:setVisible(false)
			self.layerTab2:setPositionX(999333)
		end
	end
end

function acCflmDialog:tick()
	if(self.tab1 and self.tab1.tick)then
		self.tab1:tick()
	end
	if(self.tab2 and self.tab2.tick)then
		self.tab2:tick()
	end
	if(self.lastTickIndex==nil or self.lastTickIndex%5==0)then
		local tab1Flag,tab2Flag=false,false
		local curDay=acCflmVoApi:getCurrentDay()
		local totalRechargeDay=(acCflmVoApi:getActiveEndTs() - G_getWeeTs(self.acVo.st))/86400 
		totalRechargeDay=math.min(curDay,totalRechargeDay)
		for i=1,totalRechargeDay do
			if(acCflmVoApi:checkCanRechargeRewardByDay(i))then
				tab1Flag=true
				break
			end
		end
		if(acCflmVoApi:checkCanRechargeFinalReward())then
			tab1Flag=true
		end
		for i=1,acCflmVoApi:getCfg().prolongTime + 1 do
			if(acCflmVoApi:checkInvestStatusByDay(i)==1)then
				tab2Flag=true
			end
		end	
		self:setIconTipVisibleByIdx(tab1Flag,1)
		self:setIconTipVisibleByIdx(tab2Flag,2)
	end
	if(self.lastTickIndex==nil)then
		self.lastTickIndex=1
	else
		self.lastTickIndex=self.lastTickIndex + 1
	end
	local vo=acCflmVoApi:getAcVo()
	if(vo==nil or (vo.et and activityVoApi:isStart(vo)==false))then
		self:close()
	end
end

function acCflmDialog:dispose()
	if(self.tab1 and self.tab1.dispose)then
		self.tab1:dispose()
	end
	if(self.tab2 and self.tab2.dispose)then
		self.tab2:dispose()
	end
	self.lastTickIndex=0
	self.acVo=nil
	self.curPage=1
	self.tab1=nil
	self.layerTab1=nil
	self.tab2=nil
	self.layerTab2=nil
	spriteController:removePlist("public/acCflmImage.plist")
	spriteController:removeTexture("public/acCflmImage.png")
	spriteController:removePlist("public/acZnqd2017.plist")
	spriteController:removeTexture("public/acZnqd2017.png")
	spriteController:removePlist("public/acChunjiepansheng.plist")
	spriteController:removeTexture("public/acChunjiepansheng.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removePlist("public/acDouble11_NewImage.plist")
	spriteController:removeTexture("public/acDouble11_NewImage.png")
	spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
	spriteController:removePlist("public/redFlicker.plist")
	spriteController:removeTexture("public/redFlicker.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end