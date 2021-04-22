-- @Author: xurui
-- @Date:   2017-04-10 17:09:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 11:35:14
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparMaxLevel = class("QUIWidgetHeroSparMaxLevel", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")

function QUIWidgetHeroSparMaxLevel:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_tupo1_full.ccbi"
	local callBacks = {}
	QUIWidgetHeroSparMaxLevel.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetHeroSparMaxLevel:resetAll()
	self._ccbOwner.equ_node:removeAllChildren()
	self._qualityWidget = nil
	for i = 1, 4 do
		self._ccbOwner["tf_name"..i]:setVisible(false)
		self._ccbOwner["tf_value"..i]:setVisible(false)
	end
end

function QUIWidgetHeroSparMaxLevel:setInfo(actorId, sparId, index, selectTab)
	self:resetAll()

	self._actorId = actorId
	self._sparId = sparId
	self._index = index
	
	local heroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	local sparInfo = heroModle:getSparInfoByPos(self._index).info or {}
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.itemId)

	local propInfo = {}
	if selectTab == "grade" then
		propInfo = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(sparInfo.itemId, sparInfo.grade)	
		self:setMaxSpByIcon( QSpriteFrameByPath(QResPath("up_grade_max")) )
	else
		propInfo = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, sparInfo.level)
		local frame = QSpriteFrameByPath(QResPath("up_grade_max"))
		if frame then
			self:setMaxSpByPlist(frame)
		end
	end

	self._ccbOwner.tf_item_name:setString(itemConfig.name)
	
	local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)

	local index = 1
	index = self:setTFValue("生    命:", math.floor(propInfo.hp_value or 0), index)
	index = self:setTFValue("攻    击:", math.floor(propInfo.attack_value or 0), index)
	index = self:setTFValue("命    中:", math.floor(propInfo.hit_rating or 0), index)
	index = self:setTFValue("闪    避:", math.floor(propInfo.dodge_rating or 0), index)
	index = self:setTFValue("暴    击:", math.floor(propInfo.critical_rating or 0), index)
	index = self:setTFValue("格    挡:", math.floor(propInfo.block_rating or 0), index)
	index = self:setTFValue("急    速:", math.floor(propInfo.haste_rating or 0), index)
	index = self:setTFValue("物理防御:", math.floor(propInfo.armor_physical or 0), index)
	index = self:setTFValue("法术防御:", math.floor(propInfo.armor_magic or 0), index)
	index = self:setTFValue("生命增加:", (propInfo.hp_percent or 0), index, true)
	index = self:setTFValue("攻击增加:", (propInfo.attack_percent or 0), index, true)
	index = self:setTFValue("物防增加:", (propInfo.armor_physical_percent or 0), index, true)
	index = self:setTFValue("法防增加:", (propInfo.armor_magic_percent or 0), index, true)

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.equ_node:addChild(itemAvatar)
	itemAvatar:setSparInfo(itemConfig, 19, nil)
	if selectTab == "grade" then
		itemAvatar:setStar(sparInfo.grade)
	end
end		

--设置图片
function QUIWidgetHeroSparMaxLevel:setMaxSpByPlist(frame)
	self._ccbOwner.sp_max:setDisplayFrame(frame)
end

--设置图片
function QUIWidgetHeroSparMaxLevel:setMaxSpByIcon(frame)
	if frame == nil then return end
	self._ccbOwner.sp_max:setDisplayFrame(frame)
end

function QUIWidgetHeroSparMaxLevel:setTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_name"..index] ~= nil then
		self._ccbOwner["tf_name"..index]:setString(title)
		self._ccbOwner["tf_name"..index]:setVisible(true)
		self._ccbOwner["tf_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_value"..index]:setString(value)
		end
	end
	return index+1
end

return QUIWidgetHeroSparMaxLevel