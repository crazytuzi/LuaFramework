require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogTab1"
require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogTab2"
require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogTab3"
serverWarPersonalDialog=commonDialog:new()

function serverWarPersonalDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	self.isShowTip=false
	return nc
end

function serverWarPersonalDialog:resetTab()
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
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	-- 清除临时选择的军徽
	if base.emblemSwitch==1 then
		emblemVoApi:setTmpEquip(nil)
	end
	-- 清除临时选择的飞机
	if base.plane==1 then
		planeVoApi:setTmpEquip(nil)
	end
end

function serverWarPersonalDialog:tabClick(idx)
	-- local status=serverWarPersonalVoApi:checkStatus()
	-- if status>=20 then
	-- 	local function getScheduleInfoCallback()
	-- 		self:realTabClick(idx)
	-- 	end
	-- 	serverWarPersonalVoApi:getScheduleInfo(getScheduleInfoCallback)
	-- else
		self:realTabClick(idx)
	-- end
end
function serverWarPersonalDialog:realTabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	if idx==1 then
		local canClick=true
		local setFleetStatus=serverWarPersonalVoApi:getSetFleetStatus()
		if setFleetStatus==1 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_cannot_set_fleet1"),30)
			canClick=false
		elseif setFleetStatus==5 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_cannot_set_fleet5"),30)
			canClick=false
		end
		if canClick==true then
		else
			for k,v in pairs(self.allTabs) do
				if self.oldSelectedTabIndex==v:getTag() then
					v:setEnabled(false)
				else
					v:setEnabled(true)
				end
			end
			self.selectedTabIndex=self.oldSelectedTabIndex
	        self:tabClickColor(self.selectedTabIndex)
			do return end
		end
	end

	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:resetForbidLayer()
	self:getDataByType(idx+1)

	if idx==2 then
		serverWarPersonalVoApi:setShopHasOpen()
		self:setIconTipVisibleByIdx(false,3)
	end
end

function serverWarPersonalDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			local function callback1()
				self.tab1=serverWarPersonalDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
				local function setIsShowTip()
					self.isShowTip=true
				end
				serverWarPersonalVoApi:getTroopsInfo(setIsShowTip)
			end
			serverWarPersonalVoApi:getWarInfo(callback1)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function callback2()
				self.tab2=serverWarPersonalDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end
			serverWarPersonalVoApi:getTroopsInfo(callback2)
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			local function callback3()
				self.tab3=serverWarPersonalDialogTab3:new()
				self.layerTab3=self.tab3:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab3)
				if(self.selectedTabIndex==2)then
					self:switchTab(3)
				end
			end
			serverWarPersonalVoApi:getShopInfo(callback3)
		else
			self:switchTab(3)
		end
	end
end

function serverWarPersonalDialog:switchTab(type)
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
	if self and self.tab2 and self.tab2.setEnabledTouch then
		if type==2 then
			self.tab2:setEnabledTouch(true)
		else
			self.tab2:setEnabledTouch(false)
		end
	end
end

function serverWarPersonalDialog:tick()
	for i=1,3 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end

	local isAllSet=serverWarPersonalVoApi:getIsAllSetFleet()
	if self.isShowTip==true and isAllSet==false then
		self:setIconTipVisibleByIdx(true,2)
	else
		self:setIconTipVisibleByIdx(false,2)
	end

	if self.selectedTabIndex~=2 then
		local shopHasOpen=serverWarPersonalVoApi:getShopHasOpen()
		if shopHasOpen==false then
			self:setIconTipVisibleByIdx(true,3)
		else
			self:setIconTipVisibleByIdx(false,3)
		end
	end
end

function serverWarPersonalDialog:dispose()
	for i=1,3 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end