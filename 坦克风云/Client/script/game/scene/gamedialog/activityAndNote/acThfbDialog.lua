-- @Author hj
-- @Description 特惠风暴活动总板子
-- @Date 2018-05-16

acThfbDialog=commonDialog:new()

function acThfbDialog:new( ... )
	local nc = {
		layerTab1=nil,
		layerTab2=nil,
		tab1=nil,
		tab2=nil
	}

	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acThfbDialog:resetTab( ... )
	spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
	-- 两个子板
	local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end

function acThfbDialog:tabClick(idx,id)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	if id then
		self:switchTab(idx+1,id)
	else
		self:switchTab(idx+1)
	end
end

function acThfbDialog:switchTab(idx,id)
	if idx==nil then
		idx=1
	end
	if self["tab"..idx]==nil then
   		local tab
   		if (idx==1) then
   			-- 礼包
   			tab=acThfbGiftBagDialog:new(self.layerNum,self)
   		else
   			-- 任务
   			tab=acThfbTaskDialog:new(self.layerNum,self)
   		end
	   	self["tab"..idx]=tab
	   	self["layerTab"..idx]=tab:init()
	   	self.bgLayer:addChild(self["layerTab"..idx],3)
   	end
   	-- 设置位置
	for i=1,2 do
		local pos=ccp(999999,0)
		local visible=false
		if(i==idx)then
			pos=ccp(0,0)
			visible=true
			if id and i==2 and self.tab2 and self.tab2.jumpTask then
				self.tab2:jumpTask(id)
			end
		end
		if(self["layerTab"..i]~=nil)then
			self["layerTab"..i]:setPosition(pos)
			self["layerTab"..i]:setVisible(visible)
		end
	end
end

function acThfbDialog:doUserHandler( ... )

	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end
	
	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,5)

	-- 去渐变线
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
	self:tabClick(0)
end

function acThfbDialog:tick( ... )

	for i=1,2,1 do
		if self["tab"..i] and  self["tab"..i].tick then	
			self["tab"..i]:tick()
		end
	end
	self:refreshRedpoint()
end

function acThfbDialog:fastTick( ... )
	for i=1,2,1 do
		if self["tab"..i] and  self["tab"..i].fastTick then	
			self["tab"..i]:fastTick()
		end
	end
end

function acThfbDialog:refreshRedpoint( ... )

	local num = acThfbVoApi:getTaskDoneNum()
	local tipBg = tolua.cast(self.allTabs[2]:getChildByTag(10),"CCSprite")
	local numLb = tolua.cast(tipBg:getChildByTag(11),"CCLabelTTF")
	if num > 0 then
		tipBg:setVisible(true)
		numLb:setString(num)
		numLb:setPosition(ccp(17,18))
	else
		tipBg:setVisible(false)
   	end

end

function acThfbDialog:dispose( ... )
	spriteController:removeTexture("public/taskYouhua.png")
	spriteController:removePlist("public/taskYouhua.plist")
	-- body
	if self.layerTab1 then
		self.tab1:dispose()
    end
    if self.layerTab2 then
    	self.tab2:dispose()
    end
	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
end