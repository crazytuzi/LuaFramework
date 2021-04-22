--	S魂骨突破上限时显示
-- Author: qinsiyang
-- 
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneEvolutionLevelLimit = class("QUIWidgetGemstoneEvolutionLevelLimit", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")
local QNotificationCenter = import("...controllers.QNotificationCenter")


function QUIWidgetGemstoneEvolutionLevelLimit:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_tupo1_tips.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGod", callback = handler(self, self._onTriggerGod)},
		{ccbCallbackName = "onTriggerMix", callback = handler(self, self._onTriggerMix)},
	}
	QUIWidgetGemstoneEvolutionLevelLimit.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetGemstoneEvolutionLevelLimit:resetAll()
	self._ccbOwner.equ_node:removeAllChildren()
	self._qualityWidget = nil
	for i = 1, 4 do
		self._ccbOwner["tf_name"..i]:setVisible(false)
		self._ccbOwner["tf_value"..i]:setVisible(false)
	end

	for i = 1, 2 do
		self._ccbOwner["tf_prop_name_L"..i]:setVisible(false)
		self._ccbOwner["tf_prop_value_L"..i]:setVisible(false)
		self._ccbOwner["tf_prop_name_R"..i]:setVisible(false)
		self._ccbOwner["tf_prop_value_R"..i]:setVisible(false)		
	end

end

function QUIWidgetGemstoneEvolutionLevelLimit:setInfo(actorId, gemstoneSid, gemstonePos)
	self:resetAll()

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)

	self._advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstone.mix_level or 0
	local propInfo = {}

    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local name = self:handleName(itemConfig.name,self._advancedLevel , level,mixLevel)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]

	self._ccbOwner.tf_item_name:setString(name )
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)

	self._ccbOwner.tf_item_name_cur:setString(name )
	self._ccbOwner.tf_item_name_cur:setColor(fontColor)
	self._ccbOwner.tf_item_name_cur = setShadowByFontColor(self._ccbOwner.tf_item_name_cur, fontColor)	

    local level2,color2 = remote.herosUtil:getBreakThrough(gemstone.craftLevel + 1) 
    local name2 = self:handleName(itemConfig.name,self._advancedLevel , level2 , mixLevel)
	local fontColor2 = BREAKTHROUGH_COLOR_LIGHT[color2]

	self._ccbOwner.tf_item_name_next:setString(name2 )
	self._ccbOwner.tf_item_name_next:setColor(fontColor2)
	self._ccbOwner.tf_item_name_next = setShadowByFontColor(self._ccbOwner.tf_item_name_next, fontColor2)

	local breakconfig1 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel)
	local breakconfig2 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel+1)

	local propTFInfo = {}
	table.insert(propTFInfo , {fieldName = "hp_value", name = "生    命:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "attack_value", name = "攻    击:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "hit_rating", name = "命    中:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "dodge_rating", name = "闪    避:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "critical_rating", name = "暴    击:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "block_rating", name = "格    挡:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "haste_rating", name = "急    速:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "armor_physical", name = "物理防御:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "armor_magic", name = "法术防御:", isPercent = false })
	table.insert(propTFInfo , {fieldName = "hp_percent", name = "生命增加:", isPercent = true })
	table.insert(propTFInfo , {fieldName = "attack_percent", name = "攻击增加:", isPercent = true })
	table.insert(propTFInfo , {fieldName = "armor_physical_percent", name = "物防增加:", isPercent = true })
	table.insert(propTFInfo , {fieldName = "armor_magic_percent", name = "法防增加:", isPercent = true })


	self:updateTFPropValue( propTFInfo, breakconfig1 ,"tf_name" ,"tf_value")
	self:updateTFPropValue( propTFInfo, breakconfig1 ,"tf_prop_name_L" ,"tf_prop_value_L")
	self:updateTFPropValue( propTFInfo, breakconfig2 ,"tf_prop_name_R" ,"tf_prop_value_R")


	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.equ_node:addChild(itemAvatar)
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,self._advancedLevel , mixLevel)

end

function QUIWidgetGemstoneEvolutionLevelLimit:handleName(name, advancedLevel,level , mixLevel)
    name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)
    if level > 0 then
    	name = name .. "＋".. level
    end
    return name
end

function QUIWidgetGemstoneEvolutionLevelLimit:updateTFPropValue( propTFInfo, proptable , name_str,value_str)
	local index = 1
	for i,v in ipairs(propTFInfo) do
		local value = proptable[v.fieldName] or 0
		if value > 0  then
			if self._ccbOwner[name_str..index] and  self._ccbOwner[value_str..index] then

				self._ccbOwner[name_str..index]:setString(v.name)
				self._ccbOwner[name_str..index]:setVisible(true)
				self._ccbOwner[value_str..index]:setVisible(true)
				if v.isPercent == true then
					self._ccbOwner[value_str..index]:setString(string.format("%0.1f%%",value*100))
				else
					self._ccbOwner[value_str..index]:setString( math.floor(value or 0))
				end	
				index = index + 1			
			else
				return 
			end
		end
	end
end

function QUIWidgetGemstoneEvolutionLevelLimit:_onTriggerGod(e)
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = "TAB_TOGOD"})
end

function QUIWidgetGemstoneEvolutionLevelLimit:_onTriggerMix(e)
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = remote.gemstone.EVENT_JUMP_MIX})
end

return QUIWidgetGemstoneEvolutionLevelLimit