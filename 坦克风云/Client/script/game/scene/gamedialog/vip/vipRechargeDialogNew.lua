vipRechargeDialogNew=commonDialog:new()

function vipRechargeDialogNew:new()
	require "luascript/script/game/scene/gamedialog/vip/vipRechargeDialogNewTabNormal"
	require "luascript/script/game/scene/gamedialog/vip/vipRechargeDialogNewTabMonthly"
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerTab1=nil
	self.rechargeTab1=nil
	self.layerTab2=nil
	self.rechargeTab2=nil
	return nc
end

function vipRechargeDialogNew:resetTab()
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

function vipRechargeDialogNew:tabClick(idx)
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

function vipRechargeDialogNew:switchTab(type)
	if type==nil then
		type=1
	end
	if self["rechargeTab"..type]==nil then
		local tab
		if(type==1)then
			tab=vipRechargeDialogNewTabNormal:new()
		elseif(type==2)then
			tab=vipRechargeDialogNewTabMonthly:new()
		end
		self["rechargeTab"..type]=tab
		self["layerTab"..type]=tab:init(self.layerNum,self)
		self.bgLayer:addChild(self["layerTab"..type])
	end
	for i=1,2 do
		if(i==type)then
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPositionX(0)
				self["layerTab"..i]:setVisible(true)
			end
		else
			if(self["layerTab"..i]~=nil)then
				self["layerTab"..i]:setPositionX(999333)
				self["layerTab"..i]:setVisible(false)
			end
		end
	end
end

function vipRechargeDialogNew:tick()
	for i=1,2 do
		if(self["rechargeTab"..i] and self["rechargeTab"..i].tick)then
			self["rechargeTab"..i]:tick()
		end
	end
end

function vipRechargeDialogNew:dispose()
	for i=1,2 do
		if(self["rechargeTab"..i] and self["rechargeTab"..i].dispose)then
			self["rechargeTab"..i]:dispose()
		end
		self["rechargeTab"..i]=nil
		self["layerTab"..i]=nil
	end
end
