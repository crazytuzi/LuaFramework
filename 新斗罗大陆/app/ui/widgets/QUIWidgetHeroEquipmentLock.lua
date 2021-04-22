local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroEquipmentLock = class("QUIWidgetHeroEquipmentLock", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")

function QUIWidgetHeroEquipmentLock:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_lock.ccbi"
	local callBacks = {
		}
	QUIWidgetHeroEquipmentLock.super.ctor(self,ccbFile,callBacks,options)
	self._equipmentBox = QUIWidgetEquipmentSpecialBox.new()
	self._equipmentBox:setIsLock(true)
	self._ccbOwner.node_item:addChild(self._equipmentBox)
end

function QUIWidgetHeroEquipmentLock:resetAll()
	self._ccbOwner.node_item:removeAllChildren()
end

function QUIWidgetHeroEquipmentLock:setInfo(actorId, itemId, pos)
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if pos == EQUIPMENT_TYPE.JEWELRY1 then
		self._ccbOwner.tf_tips2:setString(app.unlock:getConfigByKey("UNLOCK_BADGE").team_level)
		self._equipmentBox:setType(pos)
		return 
	end
	if pos == EQUIPMENT_TYPE.JEWELRY2 then
		self._ccbOwner.tf_tips2:setString(app.unlock:getConfigByKey("UNLOCK_GAD").team_level)
		self._equipmentBox:setType(pos)
		return 
	end
end

return QUIWidgetHeroEquipmentLock