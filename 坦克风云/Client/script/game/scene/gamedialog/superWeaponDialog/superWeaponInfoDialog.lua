--超级武器进阶装配和仓库的面板
superWeaponInfoDialog=commonDialog:new()
function superWeaponInfoDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.layerTab1=nil
	nc.layerTab2=nil
	nc.layerTab3=nil

	nc.tab1=nil
	nc.tab2=nil
	nc.tab3=nil

	require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponInfoDialogTabUpgrade"
	require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponInfoDialogTabEquip"
	require "luascript/script/game/scene/gamedialog/superWeaponDialog/superWeaponInfoDialogTabList"
	return nc
end

function superWeaponInfoDialog:resetTab()
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
			tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			self.equipTip = CCSprite:createWithSpriteFrameName("IconTip.png")
			self.equipTip:setPosition(ccp(tabBtnItem:getContentSize().width-10,tabBtnItem:getContentSize().height-10))
			self.equipTip:setVisible(false)
			tabBtnItem:addChild(self.equipTip)
			self:checkNotice()
		elseif index==2 then
			tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	local function onDataChange(event,data)
		self:checkNotice()
	end
	self.eventListener=onDataChange
	eventDispatcher:addEventListener("superweapon.data.info",onDataChange)
	self:switchTab(1)
end

function superWeaponInfoDialog:tabClick(idx)
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function superWeaponInfoDialog:switchTab(type)
	if type==nil then
		type=1
	end
	for i=1,3 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(0,0))
				self["layerTab"..i]:setVisible(true)
			else
				if(i==1)then
					self.tab1=superWeaponInfoDialogTabUpgrade:new()
				elseif(i==2)then
					self.tab2=superWeaponInfoDialogTabEquip:new()
				else
					self.tab3=superWeaponInfoDialogTabList:new()
				end
				self["layerTab"..i]=self["tab"..i]:init(self.layerNum,self)
				self.bgLayer:addChild(self["layerTab"..i],5)
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPosition(ccp(999333,0))
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
end

function superWeaponInfoDialog:checkNotice()
	if(self.equipTip)then
		local equipNum=0
		for k,v in pairs(superWeaponVoApi:getEquipList()) do
			if(v and v~=0 and v~="0")then
				equipNum=equipNum + 1
			end
		end
		if(equipNum<6 and SizeOfTable(superWeaponVoApi:getWeaponList())>equipNum)then
			self.equipTip:setVisible(true)
		else
			self.equipTip:setVisible(false)
		end
	end
end

function superWeaponInfoDialog:dispose()
	for i=1,3 do
		if(self["tab"..i] and self["tab"..i].dispose)then
			self["tab"..i]:dispose()
		end
	end
	eventDispatcher:removeEventListener("superweapon.data.info",self.eventListener)
end
