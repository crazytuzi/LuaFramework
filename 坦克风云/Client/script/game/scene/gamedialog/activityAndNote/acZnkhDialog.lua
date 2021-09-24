acZnkhDialog=commonDialog:new()

function acZnkhDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

    return nc
end

function acZnkhDialog:resetTab()
	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)

	local index=0
	for k,v in pairs(self.allTabs) do
		 local  tabBtnItem=v
		 if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		else
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 end
		 if index==self.selectedTabIndex then
			 tabBtnItem:setEnabled(false)
		 end
		 index=index+1
	end
	self.selectedTabIndex=0
end

function acZnkhDialog:initTableView()
	self:tabClick(0)
end

function acZnkhDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function acZnkhDialog:switchTab(type)
	if type==nil then
		type=1
	end
	if self["tab"..type]==nil then
   		local tab
   		if(type==1)then
   			tab=acZnkhTabOne:new()
   		else
   			tab=acZnkhTabTwo:new()
   		end
	   	self["tab"..type]=tab
	   	-- self["layerTab"..type]=tab:init(self.layerNum, type==2 and self.tab1 or nil)
	   	self["layerTab"..type]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..type])
   	end
	for i=1,2 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
				if self["tab"..i].clayer then
					self["tab"..i].clayer:setTouchEnabled(true)
				end
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
				if self["tab"..i].clayer then
					self["tab"..i].clayer:setTouchEnabled(false)
				end
			end
		end
	end
	if type==2 and self["tab"..type] then
		self["tab"..type]:refreshCurScore()
	end
end

function acZnkhDialog:doUserHandler()

end

function acZnkhDialog:fastTick()
	local vo=acZnkhVoApi:getAcVo()
	if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    else
		if self and self.tab1 and self.tab1.fastTick then
			self.tab1:fastTick()
		end
		if self and self.tab2 and self.tab2.fastTick then
			self.tab2:fastTick()
		end
	end
end

function acZnkhDialog:tick()
	local vo=acZnkhVoApi:getAcVo()
	if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    else
		if self and self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		if self and self.tab2 and self.tab2.tick then
			self.tab2:tick()
		end
		if self then
			for k,v in pairs(self.allTabs) do
				local tipSp = v:getChildByTag(101)
				if tipSp and tolua.cast(tipSp,"CCSprite") then
					tipSp = tolua.cast(tipSp,"CCSprite")
					tipSp:setVisible(false)
					if v:getTag()==0 then
						tipSp:setVisible(acZnkhVoApi:isShowNumRewardRedPoint())
					else
						tipSp:setVisible(acZnkhVoApi:isCanGetRankReward())
					end
				end
			end
		end
	end
end

function acZnkhDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then
		self.tab2:dispose()
	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self=nil
end