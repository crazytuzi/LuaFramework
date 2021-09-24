--2017四周年周年庆典活动
--author: Liang Qi
acAnniversaryFourDialog=commonDialog:new()

function acAnniversaryFourDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.acVo=acAnniversaryFourVoApi:getAcVo()
	nc.curPage=1
	nc.tab1=nil
	nc.layerTab1=nil
	nc.tab2=nil
	nc.layerTab2=nil
	nc.lastTickIndex=0
	return nc
end

function acAnniversaryFourDialog:resetTab()
	spriteController:addPlist("public/acZnqd2017.plist")
	spriteController:addTexture("public/acZnqd2017.png")
	spriteController:addPlist("public/acAnniversary.plist")
	spriteController:addTexture("public/acAnniversary.png")
	spriteController:addPlist("public/newDisplayImage.plist")
	spriteController:addTexture("public/newDisplayImage.png")
	spriteController:addPlist("public/activePicUseInNewGuid.plist")
	spriteController:addTexture("public/activePicUseInNewGuid.png")
	spriteController:addPlist("public/acOpenyearImage.plist")
	spriteController:addTexture("public/acOpenyearImage.png")
	spriteController:addPlist("public/acthreeyear_images.plist")
	spriteController:addTexture("public/acthreeyear_images.png")
	spriteController:addPlist("public/yellowFlicker.plist")
	spriteController:addTexture("public/yellowFlicker.png")
	spriteController:addPlist("public/blueFilcker.plist")
	spriteController:addTexture("public/blueFilcker.png")
	spriteController:addPlist("public/greenFlicker.plist")
	spriteController:addTexture("public/greenFlicker.png")
	spriteController:addPlist("public/purpleFlicker.plist")
	spriteController:addTexture("public/purpleFlicker.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
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

function acAnniversaryFourDialog:tabClick(idx)
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

function acAnniversaryFourDialog:getDataByType(idx)
	if(idx==nil)then
		idx=0
	end
	if(idx==1)then
		if(self.tab2==nil)then
			self.tab2=acAnniversaryFourTabRecharge:new()
			self.layerTab2=self.tab2:init(self.acVo,self.layerNum)
			self.bgLayer:addChild(self.layerTab2,1)
		end
		self.layerTab1:setVisible(false)
		self.layerTab1:setPositionX(999333)
		self.layerTab2:setVisible(true)
		self.layerTab2:setPositionX(0)
	else
		if(self.tab1==nil)then
			self.tab1=acAnniversaryFourTabWelfare:new()
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

function acAnniversaryFourDialog:tick()
	if(self.tab1 and self.tab1.tick)then
		self.tab1:tick()
	end
	if(self.tab2 and self.tab2.tick)then
		self.tab2:tick()
	end
	if(self.lastTickIndex==nil or self.lastTickIndex%5==0)then
		local tab1Flag,tab2Flag=false,false
		local allExperience=acAnniversaryFourVoApi:getAllExperience()
		for k,v in pairs(allExperience) do
			if(acAnniversaryFourVoApi:checkCanGetExperienceReward(v)==true)then
				tab1Flag=true
				break			
			end
		end
		local allAchievements=acAnniversaryFourVoApi:getAllAchievements()
		for k,v in pairs(allAchievements) do
			if(acAnniversaryFourVoApi:checkCanGetAchievementReward(v)==1)then
				tab1Flag=true				
				break
			end
		end
		self:setIconTipVisibleByIdx(tab1Flag,1)
		local allRecharge=acAnniversaryFourVoApi:getRechargeCfg()
		for k,v in pairs(allRecharge) do
			if(acAnniversaryFourVoApi:checkCanGetRechargeReward(k)==1)then
				tab2Flag=true
			end
		end
		self:setIconTipVisibleByIdx(tab2Flag,2)
	end
	if(self.lastTickIndex==nil)then
		self.lastTickIndex=1
	else
		self.lastTickIndex=self.lastTickIndex + 1
	end
	local vo=acAnniversaryFourVoApi:getAcVo()
	if(vo==nil or (vo.et and activityVoApi:isStart(vo)==false))then
		self:close()
	end
end

function acAnniversaryFourDialog:dispose()
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
	spriteController:removePlist("public/acZnqd2017.plist")
	spriteController:removeTexture("public/acZnqd2017.png")
	spriteController:removePlist("public/acAnniversary.plist")
	spriteController:removeTexture("public/acAnniversary.png")
	spriteController:removePlist("public/newDisplayImage.plist")
	spriteController:removeTexture("public/newDisplayImage.png")
	spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
	spriteController:removePlist("public/acOpenyearImage.plist")
	spriteController:removeTexture("public/acOpenyearImage.png")
	spriteController:removePlist("public/acthreeyear_images.plist")
	spriteController:removeTexture("public/acthreeyear_images.png")
	spriteController:removePlist("public/yellowFlicker.plist")
	spriteController:removeTexture("public/yellowFlicker.png")
	spriteController:removePlist("public/blueFilcker.plist")
	spriteController:removeTexture("public/blueFilcker.png")
	spriteController:removePlist("public/greenFlicker.plist")
	spriteController:removeTexture("public/greenFlicker.png")
	spriteController:removePlist("public/purpleFlicker.plist")
	spriteController:removeTexture("public/purpleFlicker.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end