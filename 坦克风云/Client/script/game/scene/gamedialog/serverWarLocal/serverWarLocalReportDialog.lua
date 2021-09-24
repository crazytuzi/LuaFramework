require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalReportTab1"
require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalReportTab2"
serverWarLocalReportDialog=commonDialog:new()

function serverWarLocalReportDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	spriteController:addPlist("public/serverWarLocal/serverWarLocalCity.plist")
	return nc
end

function serverWarLocalReportDialog:resetTab()
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
	self.panelLineBg:setVisible(false)
	G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-158)
	-- self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	-- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function serverWarLocalReportDialog:tabClick(idx)
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

function serverWarLocalReportDialog:getDataByType(type)
	if self and self.bgLayer then
		if(type==nil)then
			type=1
		end
		if(type==1)then
			if(self.tab1==nil)then
				local function getReportHandler()
					self.tab1=serverWarLocalReportTab1:new()
					self.layerTab1=self.tab1:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab1)
					if(self.selectedTabIndex==0)then
						self:switchTab(1)
					end
				end
				serverWarLocalVoApi:formatReportList(1,getReportHandler)
			else
				self:switchTab(1)
			end
		elseif(type==2)then
			if(self.tab2==nil)then
				local function getAllianceReportHandler()
					self.tab2=serverWarLocalReportTab2:new()
					self.layerTab2=self.tab2:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab2)
					if(self.selectedTabIndex==1)then
						self:switchTab(2)
					end
				end
				serverWarLocalVoApi:formatReportList(2,getAllianceReportHandler)
			else
				self:switchTab(2)
			end
		end
	end
end

function serverWarLocalReportDialog:switchTab(type)
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

function serverWarLocalReportDialog:tick()
	if self and self.bgLayer then
		for i=1,2 do
			if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
				self["tab"..i]:tick()
			end
			if serverWarLocalVoApi:getIsNewReport(i)==0 then
				self:setIconTipVisibleByIdx(true,i)
			else
				self:setIconTipVisibleByIdx(false,i)
			end
		end
	end
end

function serverWarLocalReportDialog:dispose()
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
	spriteController:removePlist("public/serverWarLocal/serverWarLocalCity.plist")
end