acTitaniumOfharvestDialog=commonDialog:new()

function acTitaniumOfharvestDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    self.isStop=false
    self.isToday=true
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar2.plist")
    return nc
end

function acTitaniumOfharvestDialog:resetTab()
	acTitaniumOfharvestVoApi:setEnterGameFlag(G_isToday(playerVoApi:getLogindate()))
	local num = SizeOfTable(self.allTabs)
	local index=0
	if num==2 then
		for k,v in pairs(self.allTabs) do
			local  tabBtnItem=v

			if index==0 then
				tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
				self:addTipSp(0,tabBtnItem)
			elseif index==1 then
				tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
				self:addTipSp(1,tabBtnItem)
			end

			if index==self.selectedTabIndex then
				tabBtnItem:setEnabled(false)
			end
			index=index+1
		end
	else
		for k,v in pairs(self.allTabs) do
			local  tabBtnItem=v
			if index==0 then
				tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
				self:addTipSp(0,tabBtnItem)
			elseif index==1 then
				tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
				self:addTipSp(1,tabBtnItem)
			elseif index==2 then
				tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			end
			if index==self.selectedTabIndex then
				tabBtnItem:setEnabled(false)
			end
			index=index+1
		end
	end 
    self.selectedTabIndex = 0
end

function acTitaniumOfharvestDialog:addTipSp(idx,parent)
	local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
	tipSp:setAnchorPoint(CCPointMake(1,1))
	tipSp:setPosition(ccp(parent:getContentSize().width,parent:getContentSize().height))
	parent:addChild(tipSp)
	if idx==0 then
		self.tipSp1 = tipSp
		if acTitaniumOfharvestVoApi:getChongzhiReward()<=0 then
			self.tipSp1:setVisible(false)
		end
	end
	if idx==1 then
		self.tipSp2 = tipSp
		local missionFlag = acTitaniumOfharvestVoApi:getMissionFlag()
		local count = 0
		for k,v in pairs(missionFlag) do
			if v==1 then
				count=count+1
			end
		end
		if count<=0 then
			self.tipSp2:setVisible(false)
		end
	end

end

function acTitaniumOfharvestDialog:initTableView() 
    self:tabClick(0,false)
end

function acTitaniumOfharvestDialog:tabClick(idx,isEffect)
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
            self.acTab1=acTitaniumOfharvestTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
            self:refresh(2)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==1)then
        if(self.acTab2==nil)then 
			self.acTab2=acTitaniumOfharvestTab2:new()
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
         if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==2)then
        if(self.acTab3==nil)then 
			self.acTab3=acTitaniumOfharvestTab3:new()
			self.layerTab3=self.acTab3:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab3)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then            
			self.layerTab3:setPosition(ccp(0,0))
			self.layerTab3:setVisible(true)
        end
    end
end

function acTitaniumOfharvestDialog:tick()
	if acTitaniumOfharvestVoApi:acIsActive()==false then
		self:close()
	end

	if self.tipSp1 then
		if acTitaniumOfharvestVoApi:getChongzhiReward()<=0 then
			self.tipSp1:setVisible(false)
		else
			self.tipSp1:setVisible(true)
		end
	end

	if self.tipSp2 then
		local missionFlag = acTitaniumOfharvestVoApi:getMissionFlag()
		local count = 0
		for k,v in pairs(missionFlag) do
			if v==1 then
				count=count+1
			end
		end
		if count<=0 then
			self.tipSp2:setVisible(false)
		else
			self.tipSp2:setVisible(true)
		end
	end
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then
		self.acTab1:tick()		
	end

	if self and self.bgLayer and self.acTab2 and self.layerTab2 then
		self.acTab2:tick()		
	end

	if self and self.bgLayer and self.acTab3 and self.layerTab3 then
		self.acTab3:tick()		
	end
end
function acTitaniumOfharvestDialog:refresh( tab )
 
end
function acTitaniumOfharvestDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    if self.layerTab3 then
        self.acTab3:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    self.isStop=nil
    self.isToday=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("serverWar/serverWar2.plist")
end