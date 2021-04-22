--
-- Author: xurui
-- Date: 2016-08-05 14:37:12
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneEvolutionMaxLevel = class("QUIWidgetGemstoneEvolutionMaxLevel", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")

function QUIWidgetGemstoneEvolutionMaxLevel:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_tupo1_full.ccbi"
	local callBacks = {}
	QUIWidgetGemstoneEvolutionMaxLevel.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetGemstoneEvolutionMaxLevel:resetAll()
	self._ccbOwner.equ_node:removeAllChildren()
	self._qualityWidget = nil
	for i = 1, 4 do
		self._ccbOwner["tf_name"..i]:setVisible(false)
		self._ccbOwner["tf_value"..i]:setVisible(false)
	end
end

function QUIWidgetGemstoneEvolutionMaxLevel:setInfo(actorId, gemstoneSid, gemstonePos, selectTab)
	self:resetAll()

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
	local mixLevel = gemstone.mix_level or 0

	self._advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local propInfo = {}
	if selectTab == "TAB_EVOLUTION" then
		propInfo = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel)
		QSetDisplayFrameByPath(self._ccbOwner.sp_max, QResPath("up_grade_max"))
	elseif selectTab == "TAB_TOGOD" then --化神等级上限
		local maxLevel = db:getConfiguration().GEMSTONE_MAX_GODLEVEL.value
		propInfo = remote.gemstone:getAllAdvancedProp(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL+1,maxLevel)
		QSetDisplayFrameByPath(self._ccbOwner.sp_max, QResPath("up_grade_max"))
	else
		propInfo = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, gemstone.level)
		QSetDisplayFrameByPath(self._ccbOwner.sp_max, QResPath("up_grade_max"))
	end

    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local name = itemConfig.name
    name = remote.gemstone:getGemstoneNameByData(name,self._advancedLevel,mixLevel)
    
    
    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_item_name:setString(name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
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
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,self._advancedLevel,mixLevel)

	-- if self._qualityWidget == nil then
	-- 	self._qualityWidget = QUIWidgetQualitySmall.new()
	-- 	self._qualityWidget:setScale(0.8)
	-- 	self._qualityWidget:setPosition(ccp(-50,28))
	-- 	self._ccbOwner.equ_node:addChild(self._qualityWidget)
	-- end
	-- self._qualityWidget:setQuality(remote.gemstone:getSABC(itemConfig.gemstone_quality).lower)
end

--设置图片
function QUIWidgetGemstoneEvolutionMaxLevel:setMaxSpByPlist(plist, name)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist)
	self._ccbOwner.sp_max:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name))
end

function QUIWidgetGemstoneEvolutionMaxLevel:setTFValue(title, value, index, isPercent)
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

return QUIWidgetGemstoneEvolutionMaxLevel