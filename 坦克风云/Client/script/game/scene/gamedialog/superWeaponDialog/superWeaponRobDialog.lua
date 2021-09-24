require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponRobDialogTab1"
require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponRobDialogTab2"
superWeaponRobDialog=commonDialog:new()

function superWeaponRobDialog:new(defaultTab,defaultWeaponID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.tab1=nil
	nc.tab2=nil
	nc.layerTab1=nil
	nc.layerTab2=nil
	nc.defaultTab=defaultTab
	nc.defaultWeaponID=defaultWeaponID
	return nc
end

function superWeaponRobDialog:resetTab()
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
	if(self.defaultTab)then
		self:tabClick(self.defaultTab - 1)
	end
end

function superWeaponRobDialog:tabClick(idx)
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

function superWeaponRobDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			-- local function getWarInfoHandler()
				self.tab1=superWeaponRobDialogTab1:new(self.defaultWeaponID)
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
			-- local function callback2()
				self.tab2=superWeaponRobDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			-- end
			-- localWarVoApi:getOffice(callback2)
		else
			self:switchTab(2)
		end
	-- elseif(type==3)then
	-- 	if(self.tab3==nil)then
	-- 		-- local function getWarInfoHandler()
	-- 		-- 	local function callback3()
	-- 				self.tab3=superWeaponRobDialogTab3:new()
	-- 				self.layerTab3=self.tab3:init(self.layerNum,self)
	-- 				self.bgLayer:addChild(self.layerTab3)
	-- 				if(self.selectedTabIndex==2)then
	-- 					self:switchTab(3)
	-- 				end
	-- 		-- 	end
	-- 		-- 	serverWarTeamVoApi:getShopAndBetInfo(callback3)
	-- 		-- end
	-- 		-- serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
	-- 	else
	-- 		self:switchTab(3)
	-- 	end
	end
end

function superWeaponRobDialog:switchTab(type)
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

function superWeaponRobDialog:tick()
	-- local warStatus=worldWarVoApi:checkStatus()
	-- if(self.warStatus and self.warStatus>0 and warStatus==0)then
	-- 	self:close()
	-- 	do return end
	-- end
	-- self.warStatus=warStatus
	for i=1,2 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end

	-- if self.selectedTabIndex~=2 then
	-- 	local initFlag=worldWarVoApi:getInitFlag()
	-- 	if initFlag and initFlag==1 then
	-- 		local shopHasOpen=worldWarVoApi:getShopHasOpen()
	-- 		if shopHasOpen==false then
	-- 			self:setIconTipVisibleByIdx(true,3)
	-- 		else
	-- 			self:setIconTipVisibleByIdx(false,3)
	-- 		end
	-- 	end
	-- end
end

function superWeaponRobDialog:dispose()
	for i=1,2 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
	-- self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	-- self.layerTab3=nil
end