--月度签到
acMonthlySignDialog=commonDialog:new()
function acMonthlySignDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.freeTab = nil
	nc.freeLayer = nil
	nc.payTab = nil
	nc.payLayer = nil
	return nc
end

function acMonthlySignDialog:resetTab()
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
	self:tabClick(0)
end

--点击tab页签 idx:索引
function acMonthlySignDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end	
	if idx==1 then
		if self.freeLayer ~= nil then
			self.freeLayer:setVisible(false)
			self.freeLayer:setPosition(ccp(999333,0))
		end
		if self.payLayer==nil then
			self.payTab=acMonthlySignDialogTabPay:new()
			self.payLayer=self.payTab:init(self.layerNum)
			self.bgLayer:addChild(self.payLayer,1)
		else
			self.payLayer:setVisible(true)
		end
		self.payLayer:setPosition(ccp(0,0))
	elseif idx==0 then			
		if self.payLayer~=nil then
			self.payLayer:setVisible(false)
			self.payLayer:setPosition(ccp(999333,0))
		end		
		if self.freeLayer==nil then
			self.freeTab=acMonthlySignDialogTabFree:new()
			self.freeLayer=self.freeTab:init(self.layerNum)
			self.bgLayer:addChild(self.freeLayer,1)
		else
			self.freeLayer:setVisible(true)
		end
		self.freeLayer:setPosition(ccp(0,0))
	end
end

function acMonthlySignDialog:update()
	local acVo = acMonthlySignVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self and self.close then
				self:close()
			end
		elseif self and self.bgLayer  then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
			if self.payTab and self.payTab.update then
				self.payTab:update()
			end
			if self.freeTab and self.freeTab.update then
				self.freeTab:update()
			end
		end
		acMonthlySignVoApi:afterUpdate()
	end 
end

function acMonthlySignDialog:dispose()
	if self.payTab~=nil then
		self.payTab:dispose()
	end
	if self.freeTab~=nil then
		self.freeTab:dispose()
	end
	self.payTab = nil
	self.payLayer = nil
	self.freeTab = nil
	self.freeLayer = nil
end