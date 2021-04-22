--
-- Author: xurui
-- Date: 2015-09-09 16:46:10
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStrengthenMax = class("QUIWidgetStrengthenMax", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIViewController = import("..QUIViewController")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")

function QUIWidgetStrengthenMax:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Evolution_full.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)}
	}
	QUIWidgetStrengthenMax.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetStrengthenMax:setHeroInfo(actorId, itemId)
	self.actorId = actorId
	self.itemId = itemId

	self.equipment = remote.herosUtil:getWearByItem(self.actorId, self.itemId)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
	if self._itemBox == nil then
		self._itemBox = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.equ_node:addChild(self._itemBox)
	end
	self._itemBox:setEquipmentInfo(itemConfig, self.actorId)


	local enchantLevel = self.equipment.enchants or 0
	local itemInfo = remote.items:getItemAllPropByitemId(self.itemId, self.equipment.level, enchantLevel, actorId)
	itemInfo = remote.items:countEquipmentPropForHeroLevel(itemInfo, remote.herosUtil:getHeroByID(self.actorId).level)
	self._ccbOwner.tf_item_name:setString(itemConfig.name)
	local fontColor = COLORS.j
	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(self.actorId, self.itemId)
	local level,color = remote.herosUtil:getBreakThrough(breaklevel)
	if color ~= nil then
		fontColor = UNITY_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_item_name:setColor(fontColor)	
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)


	self:setMaxInfo(itemInfo)
	self._ccbOwner.tf_content:setString("强化等级已达到上限")

	self._masterType = "enhance_master_"
	self._ccbOwner.equip_master:setVisible(true)
	self._ccbOwner.jewelry_master:setVisible(false)
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		self._masterType = "jewelry_master_"
		self._ccbOwner.equip_master:setVisible(false)
		self._ccbOwner.jewelry_master:setVisible(true)
	end

	local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
	self._equipMasterLevel = heroUIModel:getMasterLevelByType(self._masterType)
	self._ccbOwner.master_level:setString(self._equipMasterLevel or 0)
end

function QUIWidgetStrengthenMax:setEquipmentPos(equipmentPos)
	self._equipmentPos = equipmentPos
end

function QUIWidgetStrengthenMax:setMaxInfo(itemInfo)
	if itemInfo.hp_value ~= nil and itemInfo.hp_value ~= 0 then
		self._ccbOwner.tf_name1:setString("生    命：")
		self._ccbOwner.tf_value1:setString("+ "..itemInfo.hp_value)
	elseif itemInfo.attack_value ~= nil and itemInfo.attack_value ~= 0 then
		self._ccbOwner.tf_name1:setString("攻    击：")
		self._ccbOwner.tf_value1:setString("+ "..itemInfo.attack_value)
	elseif itemInfo.armor_physical ~= nil and itemInfo.armor_physical ~= 0 then
		self._ccbOwner.tf_name1:setString("物理防御：")
		self._ccbOwner.tf_value1:setString("+ "..itemInfo.armor_physical)
	elseif itemInfo.armor_magic ~= nil and itemInfo.armor_magic ~= 0 then
		self._ccbOwner.tf_name1:setString("法术防御：")
		self._ccbOwner.tf_value1:setString("+ "..itemInfo.armor_magic)
	elseif itemInfo.hp_percent ~= nil and itemInfo.hp_percent ~= 0 then
		self._ccbOwner.tf_name1:setString("生命百分比：")
		self._ccbOwner.tf_value1:setString("+ "..(itemInfo.hp_percent*100).."%")
	elseif itemInfo.attack_percent ~= nil and itemInfo.attack_percent ~= 0 then
		self._ccbOwner.tf_name1:setString("攻击百分比：")
		self._ccbOwner.tf_value1:setString("+ "..(itemInfo.attack_percent*100).."%")
	end
	self._ccbOwner.tf_name2:setVisible(false)
	self._ccbOwner.tf_value2:setVisible(false)
	self._ccbOwner.tf_name3:setVisible(false)
	self._ccbOwner.tf_value3:setVisible(false)
	self._ccbOwner.tf_name4:setVisible(false)
	self._ccbOwner.tf_value4:setVisible(false)
end

function QUIWidgetStrengthenMax:getClassName()
	return "QUIWidgetStrengthenMax"
end

function QUIWidgetStrengthenMax:_effectFinished()
end

function QUIWidgetStrengthenMax:_onTriggerMaster()
	self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.CLICK_STRENGTEN_MASTER, masterType = self._masterType})
end

return QUIWidgetStrengthenMax