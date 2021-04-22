local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainUnionRank = class("QUIWidgetUnionDragonTrainUnionRank", QUIWidget)
local QUnionAvatar = import("....utils.QUnionAvatar")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")

function QUIWidgetUnionDragonTrainUnionRank:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_paihang3.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonTrainUnionRank.super.ctor(self, ccbFile, callBack, options)

end

function QUIWidgetUnionDragonTrainUnionRank:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetUnionDragonTrainUnionRank:setInfo(data)
	self._ccbOwner.first:setVisible(data.rank == 1)
	self._ccbOwner.second:setVisible(data.rank == 2)
	self._ccbOwner.third:setVisible(data.rank == 3)
	self._ccbOwner.other:setVisible(data.rank > 3)
	self._ccbOwner.other:setString(data.rank)
	self._ccbOwner.tf_level:setString("LV."..data.level)
	self._ccbOwner.tf_name:setString(data.name)
	print("num",data.consortiaScore)
	local num, str = q.convertLargerNumber(math.floor(data.consortiaScore))
	print("num,str",num,str)
	self._ccbOwner.tf_value1:setString(num..(str or ""))
	-- self._ccbOwner.tf_value1:setString(data.consortiaScore)
	self._ccbOwner.tf_env_name:setString(data.gameAreaName or "")
	
	if self._avatar == nil then
		self._avatar = QUnionAvatar.new()
		self._ccbOwner.node_avatar:addChild(self._avatar)
	end
	self._avatar:setInfo(data.icon)
	self._avatar:setConsortiaWarFloor(data.consortiaWarFloor)

	local floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
	floorIcon:setInfo(data.consortiaFloor, "unionDragonWar")
	self._ccbOwner.node_floor:removeAllChildren()
	self._ccbOwner.node_floor:setScale(0.6)
	self._ccbOwner.node_floor:addChild(floorIcon)
end

return QUIWidgetUnionDragonTrainUnionRank