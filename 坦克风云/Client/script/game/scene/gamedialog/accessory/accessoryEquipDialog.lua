--配件强化改造精炼科技的面板
accessoryEquipDialog=commonDialog:new()

function accessoryEquipDialog:new(tankID,partID,defaultTab)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tankID=tankID
	nc.partID=partID
	if(defaultTab)then
		nc.selectedTabIndex=defaultTab - 1
	end
	nc.layerTab1=nil
	nc.layerTab2=nil
	nc.layerTab3=nil
	nc.layerTab4=nil
	nc.accessoryEquipTab1=nil
	nc.accessoryEquipTab2=nil
	nc.accessoryEquipTab3=nil
	nc.accessoryEquipTab4=nil
	return nc
end

function accessoryEquipDialog:resetTab()
	local index=0
	local count=#self.allTabs
	local posX=(G_VisibleSizeWidth - count*self.allTabs[1]:getContentSize().width)/2
	if(count==4)then
		posX=20
	end
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		tabBtnItem:setAnchorPoint(ccp(0,0))
		tabBtnItem:setPosition(posX,G_VisibleSizeHeight - 156)
		local scaleX=1
		if(count==4)then
			tabBtnItem:setScaleY(1.5)
			scaleX=(G_VisibleSizeWidth - 40)/4/tabBtnItem:getContentSize().width
			tabBtnItem:setScaleX(scaleX)
			local lb=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
			lb:setScaleX(1/scaleX)
			lb:setScaleY(1/1.5)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
		posX=posX + tabBtnItem:getContentSize().width*scaleX
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self:tabClick(self.selectedTabIndex)
	self:tabClickColor(self.selectedTabIndex)
end

function accessoryEquipDialog:resetForbidLayer()
   self.bottomforbidSp:setContentSize(self.bgLayer:getContentSize())
end

function accessoryEquipDialog:tabClick(idx)
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

function accessoryEquipDialog:switchTab(type)
	if type==nil then
		type=self.selectedTabIndex + 1
	end
	if self["accessoryEquipTab"..type]==nil then
		local tab
		if(type==1)then
			tab=accessoryEquipDialogTabUpgrade:new(self.tankID,self.partID)
		elseif(type==2)then
			tab=accessoryEquipDialogTabSmelt:new(self.tankID,self.partID)
		elseif(type==3)then
			tab=accessoryEquipDialogTabPurify:new(self.tankID,self.partID)
		else
			tab=accessoryEquipDialogTabTech:new(self.tankID,self.partID)
		end
		self["accessoryEquipTab"..type]=tab
		self["layerTab"..type]=tab:init(self.layerNum)
		self.bgLayer:addChild(self["layerTab"..type])
	end
	for i=1,4 do
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

function accessoryEquipDialog:tick()
	for i=1,4 do
		if(self["accessoryEquipTab"..i] and self["accessoryEquipTab"..i].tick)then
			self["accessoryEquipTab"..i]:tick()
		end
	end
end

function accessoryEquipDialog:dispose()
	for i=1,4 do
		if(self["accessoryEquipTab"..i] and self["accessoryEquipTab"..i].dispose)then
			self["accessoryEquipTab"..i]:dispose()
		end
		self["accessoryEquipTab"..i]=nil
		self["layerTab"..i]=nil
	end
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/hero/heroequip/equipBigBg.jpg")
	eventDispatcher:dispatchEvent("accessory.dialog.closeEquip")
end
