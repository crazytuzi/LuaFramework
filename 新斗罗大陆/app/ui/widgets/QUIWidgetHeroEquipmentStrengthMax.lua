local QUIWidgetHeroInfoMax = import("..widgets.QUIWidgetHeroInfoMax")
local QUIWidgetHeroEquipmentStrengthMax = class("QUIWidgetHeroEquipmentStrengthMax", QUIWidgetHeroInfoMax)
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetHeroEquipmentStrengthMax:ctor(options)
	QUIWidgetHeroEquipmentStrengthMax.super.ctor(self, options)
	self._ccbOwner.tf_item_name:setPositionY(self.posY)
end


function QUIWidgetHeroEquipmentStrengthMax:setInfo(actorId, itemId)
	self:resetAll()
	local equipment = remote.herosUtil:getWearByItem(actorId, itemId)

	local enchantLevel = equipment.enchants or 0
	local itemInfo = remote.items:getItemAllPropByitemId(itemId, equipment.level, enchantLevel, actorId)
	itemInfo = remote.items:countEquipmentPropForHeroLevel(itemInfo, remote.herosUtil:getHeroByID(actorId).level)
	self:setProp(itemInfo)
	self:setEquipment(actorId, itemId)

	self:setMaxSpByPlist(nil, QResPath("up_grade_max"))
end

return QUIWidgetHeroEquipmentStrengthMax