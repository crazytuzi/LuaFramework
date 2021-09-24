require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarInforTab1"
require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarInforTab2"
require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarInforTab3"
dimensionalWarInforDialog=commonDialog:new()

function dimensionalWarInforDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	return nc
end

function dimensionalWarInforDialog:resetTab()
	local index=0
	local tabHeight=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		elseif index==2 then
			tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
		end
		-- if index==0 then
		-- 	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		-- elseif index==1 then
		-- 	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		-- end
		if index==self.selectedTabIndex then
	     	tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

	-- self:tabClick(0)
end

function dimensionalWarInforDialog:initTableView()
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-360),nil)
    -- self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,35))
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setMaxDisToBottomOrTop(80)
end

function dimensionalWarInforDialog:tabClick(idx,isEffect)
	if isEffect==false then
	else
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
	self:getDataByType(idx+1)
end

function dimensionalWarInforDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		local function applyDataCallback(isInit)
			if isInit==true then
				dimensionalWarVoApi:setInitSelfRank(true)
			end
			if(self.tab1==nil)then
				self.tab1=dimensionalWarInforTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			else
				self:switchTab(1)
			end
		end
		if dimensionalWarVoApi:getStatus()==20 and dimensionalWarVoApi:getInitSelfRank()==false then
			dimensionalWarVoApi:getApplyData(applyDataCallback)
		else
			applyDataCallback(false)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			-- local function getShopInfoCallback( ... )
			-- 	local function formatPointDetailHandler()
					self.tab2=dimensionalWarInforTab2:new()
					self.layerTab2=self.tab2:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab2)
					if(self.selectedTabIndex==1)then
						self:switchTab(2)
					end
			-- 	end
			-- 	serverWarLocalVoApi:formatPointDetail(formatPointDetailHandler)
			-- end
			-- serverWarLocalVoApi:getShopInfo(getShopInfoCallback)
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			-- local function formatPointDetailHandler()
				self.tab3=dimensionalWarInforTab3:new()
				self.layerTab3=self.tab3:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab3)
				if(self.selectedTabIndex==2)then
					self:switchTab(3)
				end
			-- end
			-- if serverWarLocalVoApi:checkStatus()>10 then
			-- 	serverWarLocalVoApi:setPointDetailFlag(-1)
			-- end
			-- serverWarLocalVoApi:formatPointDetail(formatPointDetailHandler)
		else
			self:switchTab(3)
		end
	end
end

function dimensionalWarInforDialog:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,3 do
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

function dimensionalWarInforDialog:tick()
	for i=1,3 do
		if self and self["tab"..i] and self["tab"..i].tick then
			self["tab"..i]:tick()
		end
	end
end

function dimensionalWarInforDialog:dispose()
	for i=1,3 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
end