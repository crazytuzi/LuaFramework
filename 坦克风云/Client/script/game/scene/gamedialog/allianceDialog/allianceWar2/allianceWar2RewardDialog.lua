allianceWar2RewardDialog=commonDialog:new()

function allianceWar2RewardDialog:new(cityData,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cityData=cityData
	self.type=type
	return nc
end

function allianceWar2RewardDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end


function allianceWar2RewardDialog:doUserHandler()
	local acTab1=allianceWar2DetailTab1:new(self.type,self.cityData)
	local layerTab1=acTab1:init(self.layerNum,65)
	self.bgLayer:addChild(layerTab1)
end