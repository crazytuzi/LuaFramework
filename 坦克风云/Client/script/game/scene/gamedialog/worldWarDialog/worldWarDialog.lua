require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogTab1"
require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogTab2"
require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialogTab3"
worldWarDialog=commonDialog:new()

function worldWarDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWar.plist")
	return nc
end

function worldWarDialog:resetTab()
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

function worldWarDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)

    if idx==1 then
        local canClick=true
        local setFleetStatus=worldWarVoApi:getSetFleetStatus()
        if setFleetStatus==1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_cannot_set_fleet1"),30)
            canClick=false
        elseif setFleetStatus==5 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_cannot_set_fleet5"),30)
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
	self:getDataByType(idx+1)

	if idx==2 then
		worldWarVoApi:setShopHasOpen()
		self:setIconTipVisibleByIdx(false,3)
	end
end

function worldWarDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			local function getWarInfoHandler()
				self.tab1=worldWarDialogTab1:new()
				self.layerTab1=self.tab1:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab1)
				if(self.selectedTabIndex==0)then
					self:switchTab(1)
				end
			end
			worldWarVoApi:getWarInfo(getWarInfoHandler)
		else
			self:switchTab(1)
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			local function callback2()
				self.tab2=worldWarDialogTab2:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			end
			local bType=worldWarVoApi:getSignStatus()
			if bType~=nil then
				worldWarVoApi:getScheduleInfo(bType,callback2)
			else
				callback2()
			end
		else
			self:switchTab(2)
		end
	elseif(type==3)then
		if(self.tab3==nil)then
			-- local function getWarInfoHandler()
			-- 	local function callback3()
					self.tab3=worldWarDialogTab3:new()
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

function worldWarDialog:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,3 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)

				-- 如果不是舰队设置的页签，则troopsLayer的触摸关闭
				local troopsLayerCanTouch = false
				if i==2 then
					troopsLayerCanTouch = true
				end
				if G_editLayer~=nil then
					for k,v in pairs(G_editLayer) do
						if k==13 or k==14 or k==15 then
							if v.clayer then
								-- 打开的时候，只打开当前显示的子页签
								if troopsLayerCanTouch==true then
									--print("selectedTabIndex",self["tab"..i].selectedTabIndex)
									if self["tab"..i] and self["tab"..i].curTab==(k-11) then
										v.clayer:setTouchEnabled(troopsLayerCanTouch)
									end
								else
									v.clayer:setTouchEnabled(troopsLayerCanTouch)
								end
							end
						end
					end
				end
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
end

function worldWarDialog:tick()
	local warStatus=worldWarVoApi:checkStatus()
	if(self.warStatus and self.warStatus>0 and warStatus==0)then
		self:close()
		do return end
	end
	self.warStatus=warStatus
	for i=1,3 do
		if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
			self["tab"..i]:tick()
		end
	end

	if self.selectedTabIndex~=2 then
		local initFlag=worldWarVoApi:getInitFlag()
		if initFlag and initFlag==1 then
			local shopHasOpen=worldWarVoApi:getShopHasOpen()
			if shopHasOpen==false then
				self:setIconTipVisibleByIdx(true,3)
			else
				self:setIconTipVisibleByIdx(false,3)
			end
		end
	end
end

function worldWarDialog:dispose()
	-- 清理所有的troopsLayer
	G_editLayer = {}
	
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