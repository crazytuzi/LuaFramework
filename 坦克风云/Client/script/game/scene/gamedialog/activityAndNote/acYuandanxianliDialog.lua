acYuandanxianliDialog = commonDialog:new()

function acYuandanxianliDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.tabLayer1=nil
	self.tabLayer2=nil
	self.tabLayer3=nil

	return nc
end

function acYuandanxianliDialog:resetTab( )
	local index = 0

	for k,v in pairs(self.allTabs) do
		local tabBtnItem = v

		if index == 0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index ==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index == 2 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width*2,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index == self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	self.selectedTabIndex=0
end

function acYuandanxianliDialog:initTableView( )
	local function callback( )
		
	end
	local hd = LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

	--向后端申请数据

	self:tabClick(0,false)
end

function acYuandanxianliDialog:tabClick( idx )
	if newGuidMgr:isNewGuiding() then
		do
			return
		end
	end
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end

	if idx==2 then
		if self.tabLayer3 ==nil then
			self.tab3 =acYuandanxianliDialogTab3:new()
			self.tabLayer3 =self.tab3:init(self.layerNum)
			self.bgLayer:addChild(self.tabLayer3)
		else
			self.tabLayer3:setVisibable(true)
		end

		if self.tabLayer2 then
			self.tabLayer2:removeFromParentAndCleanup(true)
			self.tabLayer2=nil
		end
		if self.tabLayer1 then
			self.tabLayer1:removeFromParentAndCleanup(true)
			self.tabLayer1=nil
		end
	elseif idx==1 then
		if self.tabLayer2 ==nil then 
			self.tab2 =acYuandanxianliDialogTab2:new()
			self.tabLayer2 =self.tab2:init(self.layerNum)
			self.bgLayer:addChild(self.tabLayer2)
		else
			self.tabLayer2:setVisible(true)
		end

		if self.tabLayer3 then
			self.tabLayer3:removeFromParentAndCleanup(true)
			self.tabLayer3=nil
		end
		if self.tabLayer1 then
			self.tabLayer1:removeFromParentAndCleanup(true)
			self.tabLayer1=nil
		end
	elseif idx==0 then
		if self.tabLayer1 ==nil then
			self.tab1 =acYuandanxianliDialogTab1:new()
			self.tabLayer1 =self.tab1:init(self.layerNum)
			self.bgLayer:addChild(self.tabLayer1)
		else
			self.tabLayer1:setVisible(true)
		end

		if self.tabLayer3 then
			self.tabLayer3:removeFromParentAndCleanup(true)
			self.tabLayer3=nil
		end
		if self.tabLayer2 then
			self.tabLayer2:removeFromParentAndCleanup(true)
			self.tabLayer2=nil
		end
	end
end

function acYuandanxianliDialog:tick( )
	if self.tabLayer3 ~=nil then
		self.tab3:tick()
	end
	if self.tabLayer2 ~=nil then
		self.tab2:tick()
	end
	if self.tabLayer1 ~=nil then
		self.tab1:tick()
	end
end
function acYuandanxianliDialog:fastTick( )
	if self.tabLayer1 ~=nil then
		self.tab1:fastTick()
	end
	-- if self.tabLayer2 ~=nil then
	-- 	self.tab2:fastTick()
	-- end
	-- if self.tabLayer3 ~=nil then
	-- 	self.tab3:fastTick()
	-- end
end
function acYuandanxianliDialog:update(  )
	local acVo = acYuandanxianliVoApi:getAcVo()
	if acVo ~=nil then
		if activityVoApi:isStart(acVo) ==false then --活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
			end
		end
	end
end
function acYuandanxianliDialog:dispose( )
	if self.tabLayer3 ~=nil then
		self.tab3:dispose()
	end
	if self.tabLayer2 ~=nil then
		self.tab2:dispose()
	end
	if self.tabLayer1 ~=nil then
		self.tab1:dispose()
	end
	self.tabLayer1=nil
	self.tabLayer2=nil
	self.tabLayer3=nil
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self=nil

end