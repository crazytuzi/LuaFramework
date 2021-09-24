require "luascript/script/game/scene/gamedialog/localWar/localWarReportDialogTab1"
require "luascript/script/game/scene/gamedialog/localWar/localWarReportDialogTab2"
localWarReportDialog=commonDialog:new()

function localWarReportDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	return nc
end

function localWarReportDialog:resetTab()
	local index=0
	local tabHeight=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		-- elseif index==2 then
		-- 	tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		end
		if index==self.selectedTabIndex then
	     	tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function localWarReportDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)

	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:getDataByType(idx+1)
end

function localWarReportDialog:getDataByType(type)
	if self and self.bgLayer then
		if(type==nil)then
			type=1
		end
		if(type==1)then
			if(self.tab1==nil)then
				local function getAllianceReportHandler()
					self.tab1=localWarReportDialogTab1:new()
					self.layerTab1=self.tab1:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab1)
					if(self.selectedTabIndex==0)then
						self:switchTab(1)
					end
				end
				localWarVoApi:updateReportList(1,getAllianceReportHandler)
			else
				self:switchTab(1)
			end
		elseif(type==2)then
			if(self.tab2==nil)then
				local function getReportHandler()
					self.tab2=localWarReportDialogTab2:new()
					self.layerTab2=self.tab2:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab2)
					if(self.selectedTabIndex==1)then
						self:switchTab(2)
					end
				end
				localWarVoApi:updateReportList(2,getReportHandler)
				-- local bType=worldWarVoApi:getSignStatus()
				-- if bType~=nil then
				-- 	worldWarVoApi:getScheduleInfo(bType,callback2)
				-- 	localWarVoApi:updateReportList(2,getReportHandler)
				-- else
				-- 	callback2()
				-- end
			else
				self:switchTab(2)
			end
		end
	end
end

function localWarReportDialog:switchTab(type)
	if self and self.bgLayer then
		if type==nil then
			type=1
		end
		for i=1,2 do
			if(i==type)then
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(0,0))
					self["layerTab"..i]:setVisible(true)
				end
			else
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
				end
			end
		end
	end
end

function localWarReportDialog:tick()
	if self and self.bgLayer then
		for i=1,2 do
			if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
				self["tab"..i]:tick()
			end
			if localWarVoApi:getIsNewReport(i)==0 then
				self:setIconTipVisibleByIdx(true,i)
			else
				self:setIconTipVisibleByIdx(false,i)
			end
		end
	end
end

function localWarReportDialog:dispose()
	if self then
		for i=1,2 do
			if (self["tab"..i]~=nil and self["tab"..i].dispose) then
				self["tab"..i]:dispose()
			end
		end
		self.tab1=nil
		self.tab2=nil
		self.layerTab1=nil
		self.layerTab2=nil
	end
end