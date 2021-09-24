require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalInforTab1"
require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalAgainstRankTab3"
require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalInforTab3"
serverWarLocalInforDialog=commonDialog:new()

function serverWarLocalInforDialog:new()
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

function serverWarLocalInforDialog:resetTab()
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

function serverWarLocalInforDialog:tabClick(idx)
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

function serverWarLocalInforDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			-- local function getWarInfoHandler()
				self.tab1=serverWarLocalInforTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			-- end
			-- worldWarVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function callback2()
				self.tab2=serverWarLocalAgainstRankTab3:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end

            local personalListFlag=serverWarLocalVoApi:getPersonalListFlag()
            if (serverWarLocalVoApi:checkStatus()>=20 and serverWarLocalVoApi:checkStatus()<30) and serverWarLocalVoApi:isEndOfoneBattle() and personalListFlag[1]==0 then
                serverWarLocalVoApi:getPersonalList(1,callback2)
            elseif serverWarLocalVoApi:checkStatus()==30 and personalListFlag[2]==0 then
                serverWarLocalVoApi:getPersonalList(1,callback2)
            else
                callback2()
            end
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			self.tab3=serverWarLocalInforTab3:new()
			self.layerTab3=self.tab3:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab3)
			if(self.selectedTabIndex==2)then
				self:switchTab(3)
			end
		else
			self:switchTab(3)
		end
	end
end

function serverWarLocalInforDialog:switchTab(type)
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

function serverWarLocalInforDialog:tick()
	for i=1,3 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end
end

function serverWarLocalInforDialog:dispose()
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