require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogTab1"
require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogTab2"
require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialogTab3"
alienTechDialog=commonDialog:new()

function alienTechDialog:new(flag)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	self.selectSubTab3=1
	-- 跳转第三个签得标志
	self.flag=flag
	return nc
end

function alienTechDialog:resetTab()
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

	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	local tabBtnItem = self.allTabs[1]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCMenuItemImage")
    local tabBtn=tolua.cast(temTabBtnItem:getParent(),"CCMenu")
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)

	alienTechVoApi:updateSavedTank()
end

function alienTechDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==0) then
        	self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-260))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,260))
        	self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,40))
        elseif (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-180))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,180))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,40))
        elseif (self.selectedTabIndex==2) then
        	if self.selectSubTab3==1 or self.selectSubTab3==4 then
	            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
	            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,210))
	            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,50))
        	elseif self.selectSubTab3==2 or self.selectSubTab3==3 then
        		self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-260))
	            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,260))
	            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,150))
        	end
        end

        self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bottomforbidSp:setTouchPriority(-(self.layerNum-1)*20-4)

    end
end

function alienTechDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	-- if idx==1 then
	-- 	local setFleetStatus=serverWarTeamVoApi:getSetFleetStatus()
	-- 	if setFleetStatus==0 or setFleetStatus==6 then
	-- 	else
	-- 		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_cannot_set_fleet"..setFleetStatus),30)

	-- 		for k,v in pairs(self.allTabs) do
	-- 			if self.oldSelectedTabIndex==v:getTag() then
	-- 				v:setEnabled(false)
	-- 			else
	-- 				v:setEnabled(true)
	-- 			end
	-- 		end
	-- 		self.selectedTabIndex=self.oldSelectedTabIndex
	--         self:tabClickColor(self.selectedTabIndex)
	-- 		do return end
	-- 	end
	-- end

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

end

function alienTechDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			local function callback11()
				self.tab1=alienTechDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				
				if self.flag then
					self:tabClick(2)
				else
					if(self.selectedTabIndex==0)then
						self:switchTab(1)
					end
				end
			end
			alienTechVoApi:getTechData(callback11)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function callback2()
				self.tab2=alienTechDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end
			alienTechVoApi:getTechData(callback2)
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			-- local function getWarInfoHandler()
			-- 	local function callback3()
					self.tab3=alienTechDialogTab3:new(self.flag)
					self.layerTab3=self.tab3:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab3)
					if(self.selectedTabIndex==2)then
						self:switchTab(3)
					end
			-- 	end
			-- 	serverWarTeamVoApi:getShopAndBetInfo(callback3)
			-- end
			-- serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(3)
		end
	end
end

function alienTechDialog:switchTab(type)
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

function alienTechDialog:tick()
	for i=1,3 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end
end

function alienTechDialog:doUserHandler()
	local acceptList=alienTechVoApi:acceptAllUidTb()
	local acount=SizeOfTable(acceptList)
	local sendList=alienTechVoApi:sendAllUidTb()
	local scount=SizeOfTable(sendList)
	local count=acount+scount
	if count>0 then
		self:setTipsVisibleByIdx(true,3,count)
	else
		self:setTipsVisibleByIdx(false,3)
	end
end

function alienTechDialog:dispose()
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
	self.selectSubTab3=1
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
end