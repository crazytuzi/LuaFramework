require "luascript/script/game/scene/gamedialog/allianceDialog/allianceShopDialogTabP"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceShopDialogTabA"
allianceShopDialog=commonDialog:new()
function allianceShopDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.shopTab1=nil
	self.layerTab1=nil
	self.shopTab2=nil
	self.layerTab2=nil

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	return nc
end

function allianceShopDialog:resetTab()
	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	self:tabClick(0)
end

function allianceShopDialog:initTableView()
	local myDonateDescLb=GetTTFLabel(getlocal("allianceShop_myDonate"),28)
	myDonateDescLb:setColor(G_ColorGreen)
	myDonateDescLb:setAnchorPoint(ccp(0,0.5))
	myDonateDescLb:setPosition(ccp(30,G_VisibleSizeHeight-180))
	self.bgLayer:addChild(myDonateDescLb)
	self.myDonateLb=GetTTFLabel(allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()),28)
	self.myDonateLb:setAnchorPoint(ccp(0,0.5))
	self.myDonateLb:setPosition(ccp(40+myDonateDescLb:getContentSize().width,G_VisibleSizeHeight-180))
	self.bgLayer:addChild(self.myDonateLb)
end

function allianceShopDialog:tabClick(idx,isEffect)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:resetForbidLayer()
	self:switchTab(idx+1)
end

function allianceShopDialog:switchTab(type)
	if type==nil then
		type=1
	end
	if self["shopTab"..type]==nil then
		local tab
		if(type==1)then
			tab=allianceShopDialogTabP:new()
		elseif(type==2)then
			tab=allianceShopDialogTabA:new()
		end
		self["shopTab"..type]=tab
		self["layerTab"..type]=tab:init(self.layerNum,self)
		self.bgLayer:addChild(self["layerTab"..type])
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

function allianceShopDialog:tick()
	for i=1,2 do
		if(self["shopTab"..i])then
			self["shopTab"..i]:tick()
		end
	end
end

function allianceShopDialog:refresh()
	for i=1,2 do
		if(self["shopTab"..i])then
			self["shopTab"..i].countdown=0
			self["shopTab"..i]:tick()
		end
	end
end

function allianceShopDialog:dispose()
	if(self.shopTab1)then
		self.shopTab1:dispose()
		self.shopTab1=nil
		self.layerTab1=nil
	end
	if(self.shopTab2)then
		self.shopTab2:dispose()
		self.shopTab2=nil
		self.layerTab2=nil
	end
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
	-- if G_isCompressResVersion()==true then
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
	-- else
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
	-- end
	
	self.myDonateLb=nil
	allianceShopVoApi.dialog=nil
end