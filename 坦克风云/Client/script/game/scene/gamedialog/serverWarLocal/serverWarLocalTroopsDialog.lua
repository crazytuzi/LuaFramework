require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsSubTab11"
require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsSubTab21"
serverWarLocalTroopsDialog=commonDialog:new()

function serverWarLocalTroopsDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tab1=nil
	self.tab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.closeBtnPos=nil
	return nc
end

function serverWarLocalTroopsDialog:resetTab()
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
	-- 清除临时选择的军徽
	if base.emblemSwitch==1 then
		emblemVoApi:setTmpEquip(nil)
	end
	-- 清除临时选择的飞机
	if base.plane==1 then
		planeVoApi:setTmpEquip(nil)
	end

	-- local function eventListener(event,data)
 --        self:dealEvent(event,data)
 --    end
 --    self.eventListener=eventListener
 --    eventDispatcher:addEventListener("localWar.battle",eventListener)
end


-- function serverWarLocalTroopsDialog:dealEvent(event,data)
--     if(data.type=="over")then
-- 		self:close()
-- 	end
-- end

function serverWarLocalTroopsDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	local function realSwitchSubTab()
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
	-- print("self.selectedTabIndex",self.selectedTabIndex,idx,self.tab2)
	if idx==0 and self.tab2 then
		if self.tab2.isChangeFleet then
			local setFleetStatus=serverWarLocalVoApi:getSetFleetStatus()
			local isChangeFleet,costTanks=self.tab2:isChangeFleet()
			-- print("setFleetStatus",setFleetStatus)
			-- print("isChangeFleet",isChangeFleet)
			if setFleetStatus==0 and isChangeFleet==true then
				local function onConfirm()
	                local function saveBack()
	                    realSwitchSubTab()
	                end
	                self.tab2:saveHandler(saveBack)
	            end
	            local function onCancle()
	            	self.tab2:refresh()
	                realSwitchSubTab()
	            end
	            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_set_changed_fleet"),nil,self.layerNum+1,nil,nil,onCancle)
	        else
	            realSwitchSubTab()
			end
		else
			realSwitchSubTab()
		end
	else
		realSwitchSubTab()
	end
end

function serverWarLocalTroopsDialog:getDataByType(type)
	if(type==nil)then
		type=1
	end
	if(type==1)then
		if(self.tab1==nil)then
			-- local function getCurTroopsInfoCallback()
			-- 	local function getTankInfoHandler()
					self.tab1=serverWarLocalTroopsSubTab11:new()
					self.layerTab1=self.tab1:init(self.layerNum,self)
					self.bgLayer:addChild(self.layerTab1)
					if(self.selectedTabIndex==0)then
						self:switchTab(1)
					end
			-- 	end
			-- 	serverWarLocalVoApi:getTankInfo(getTankInfoHandler)
			-- end
			-- serverWarLocalVoApi:getCurTroopsInfo(getCurTroopsInfoCallback)
		else
			self:switchTab(1)
			self.tab1:refresh()
		end
	elseif(type==2)then
		if(self.tab2==nil)then
			-- local function callback2()
				self.tab2=serverWarLocalTroopsSubTab21:new()
				self.layerTab2=self.tab2:init(self.layerNum,self)
				self.bgLayer:addChild(self.layerTab2)
				if(self.selectedTabIndex==1)then
					self:switchTab(2)
				end
			-- end
			-- serverWarLocalVoApi:getTankInfo(callback2)
		else
			self:switchTab(2)
			self.tab2:refresh()
		end
	end
end

function serverWarLocalTroopsDialog:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,2 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
			end
			if self and self.closeBtn then
		        if type==1 then
		        	if self.closeBtnPos then
			        	self.closeBtn:setPosition(self.closeBtnPos)
			        end
		        else
		        	if self.closeBtnPos==nil then
			        	local posX,posY=self.closeBtn:getPosition()
			        	self.closeBtnPos=ccp(posX,posY)
			        end
			        self.closeBtn:setPosition(ccp(10000,0))
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

function serverWarLocalTroopsDialog:tick()
	if self then
		for i=1,2 do
			if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
				self["tab"..i]:tick()
			end
		end
	end
end

function serverWarLocalTroopsDialog:dispose()
	for i=1,2 do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.closeBtnPos=nil
	-- eventDispatcher:removeEventListener("localWar.battle",self.eventListener)
end