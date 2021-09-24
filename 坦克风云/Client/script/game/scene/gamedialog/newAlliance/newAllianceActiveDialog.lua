-- @Author hj
-- @Date 2018-11-14
-- @Description 军团活跃

newAllianceActiveDialog = commonDialog:new()

function newAllianceActiveDialog:new( ... )
	-- body
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

function newAllianceActiveDialog:resetTab( ... )

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

function newAllianceActiveDialog:tabClick(idx,id)
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

function newAllianceActiveDialog:switchTab(idx,id)
	if idx==nil then
		idx=1
	end
	if self["tab"..idx]==nil then
   		local tab
   		if (idx==1) then
   			-- 礼包
   			tab=newAllianceActiveInfoDialog:new(self.layerNum)
   		else
   			-- 任务
   			tab=newAllianceActiveWelfareDialog:new(self.layerNum)
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

function newAllianceActiveDialog:doUserHandler( ... )

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

	spriteController:addPlist("public/nbSkill2.plist")
	spriteController:addTexture("public/nbSkill2.png")

end

function newAllianceActiveDialog:tick( ... )

	for i=1,2,1 do
		if self["tab"..i] and  self["tab"..i].tick then	
			self["tab"..i]:tick()
		end
	end
end

function newAllianceActiveDialog:fastTick( ... )
	for i=1,2,1 do
		if self["tab"..i] and  self["tab"..i].fastTick then	
			self["tab"..i]:fastTick()
		end
	end
end

function newAllianceActiveDialog:dispose( ... )

	spriteController:removePlist("public/nbSkill2.plist")
	spriteController:removeTexture("public/nbSkill2.png")

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