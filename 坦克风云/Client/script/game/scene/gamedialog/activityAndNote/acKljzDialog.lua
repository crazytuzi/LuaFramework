acKljzDialog=commonDialog:new()

function acKljzDialog:new(layerNum)
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

function acKljzDialog:resetTab()

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

	-- self.panelLineBg:setVisible(false)
	-- local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	-- topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	-- topBorder:setAnchorPoint(ccp(0,1))
	-- topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	-- self.bgLayer:addChild(topBorder)

	self:tabClick(0)
end

function acKljzDialog:initTableView()
	-- local hd= LuaEventHandler:createHandler(function(...) do return end end)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(10,10),nil)
end

function acKljzDialog:tabClick(idx)
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

function acKljzDialog:switchTab(type)
	if type==nil then
		type=1
	end
	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acKljzTabOne:new(self)
	   		else
	   			tab=acKljzTabTwo:new(self)
	   		end
		   	self["tab"..type]=tab
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
				print("is visible false???????")
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
					if self["tab"..i].clayer then
						self["tab"..i].clayer:setTouchEnabled(false)
					end
				end
			end
		end
	end 
	showTab( )
end

function acKljzDialog:refresh( tab )

end
function acKljzDialog:doUserHandler()

end

function acKljzDialog:tick()
	local vo=acKljzVoApi:getAcVo()
	if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            acKljzVoApi:setModulTb()
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
	end
end

function acKljzDialog:dispose()
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

end
