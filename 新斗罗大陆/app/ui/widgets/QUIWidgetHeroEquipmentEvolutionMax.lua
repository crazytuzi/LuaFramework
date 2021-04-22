local QUIWidgetHeroInfoMax = import("..widgets.QUIWidgetHeroInfoMax")
local QUIWidgetHeroEquipmentEvolutionMax = class("QUIWidgetHeroEquipmentEvolutionMax", QUIWidgetHeroInfoMax)
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetHeroEquipmentEvolutionMax:ctor(options)
	QUIWidgetHeroEquipmentEvolutionMax.super.ctor(self, options)
	self._ccbOwner.tf_item_name:setPositionY(self.posY)
end


function QUIWidgetHeroEquipmentEvolutionMax:setInfo(actorId, itemId)
	self:resetAll()
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	self:setProp(itemConfig)
	self:setEquipment(actorId, itemId)
	self:setMaxSpByPlist(nil, QResPath("up_grade_max"))
end

return QUIWidgetHeroEquipmentEvolutionMax