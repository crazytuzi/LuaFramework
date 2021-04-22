--
-- Author: lxb
-- Date: 2016-08-05 14:37:12
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneToGodMaxLevel = class("QUIWidgetGemstoneToGodMaxLevel", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")

function QUIWidgetGemstoneToGodMaxLevel:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_togod_full.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSkillInfo1", callback = handler(self, self._onTriggerSkillInfo1)},
		{ccbCallbackName = "onTriggerSkillInfo2", callback = handler(self, self._onTriggerSkillInfo2)},
	}
	QUIWidgetGemstoneToGodMaxLevel.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetGemstoneToGodMaxLevel:resetAll()
	self._ccbOwner.equ_node:removeAllChildren()
	self._qualityWidget = nil
	for i = 1, 2 do
		self._ccbOwner["tf_name"..i]:setVisible(false)
		self._ccbOwner["tf_value"..i]:setVisible(false)
	end
end

function QUIWidgetGemstoneToGodMaxLevel:setInfo(actorId, gemstoneSid, gemstonePos, selectTab)
	self:resetAll()

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = db:getItemByID(gemstone.itemId)
	self._gemstone = gemstone
	local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	if selectTab == "TAB_TOGOD" then --化神等级上限
		QSetDisplayFrameByPath(self._ccbOwner.sp_max, QResPath("up_grade_max"))
	end


    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local name = itemConfig.name
	local mixLevel = gemstone.mix_level or 0
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_item_name:setString(name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
	
	local index = 1
	local advancedInfo = remote.gemstone:getAllAdvancedProp(gemstone.itemId,1,GEMSTONE_MAXADVANCED_LEVEL) or {}
	index = self:setTFValue("生    命:", math.floor(advancedInfo.hp_value or 0), index)
	index = self:setTFValue("攻    击:", math.floor(advancedInfo.attack_value or 0), index)
	index = self:setTFValue("物理防御:", math.floor(advancedInfo.armor_physical or 0), index)
	index = self:setTFValue("法术防御:", math.floor(advancedInfo.armor_magic or 0), index)

	local maxLevel = db:getConfiguration().GEMSTONE_MAX_GODLEVEL.value
	local maxPropInfo = remote.gemstone:getAllAdvancedProp(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL+1,maxLevel) or {}
	index = self:setTFValue("生    命:", math.floor(maxPropInfo.hp_value or 0), index)
	index = self:setTFValue("攻    击:", math.floor(maxPropInfo.attack_value or 0), index)
	index = self:setTFValue("物理防御:", math.floor(maxPropInfo.armor_physical or 0), index)
	index = self:setTFValue("法术防御:", math.floor(maxPropInfo.armor_magic or 0), index)


	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.equ_node:addChild(itemAvatar)
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,advancedLevel ,mixLevel)
	itemAvatar:hideAllColor()
	
	local advancedSkillId, godSkillId = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,advancedLevel)

	if advancedSkillId then
		local skillInfo = db:getSkillByID(advancedSkillId)
		self._ccbOwner.tf_skillname1:setString(skillInfo.name)
	else
		self._ccbOwner.tf_skillname1:setString("无")
	end

	if godSkillId then
		local skillInfo = db:getSkillByID(godSkillId)
		self._ccbOwner.tf_skillname2:setString(skillInfo.name)
	else
		self._ccbOwner.tf_skillname2:setString("无")
	end
end

--设置图片
function QUIWidgetGemstoneToGodMaxLevel:setMaxSpByPlist(plist, name)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist)
	self._ccbOwner.sp_max:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name))
end

function QUIWidgetGemstoneToGodMaxLevel:setTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_name"..index] ~= nil then
		self._ccbOwner["tf_name"..index]:setString(title)
		self._ccbOwner["tf_name"..index]:setVisible(true)
		self._ccbOwner["tf_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_value"..index]:setString("+"..value)
		end
	end
	return index+1
end

function QUIWidgetGemstoneToGodMaxLevel:_onTriggerSkillInfo1(event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_checkAdvanced) == false then return end
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone,gemAdvancedType=remote.gemstone.GEMSTONE_ANDVANCED_STATE}}, {isPopCurrentDialog = false})
end


function QUIWidgetGemstoneToGodMaxLevel:_onTriggerSkillInfo2( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_checkGod) == false then return end
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone,gemAdvancedType=remote.gemstone.GEMSTONE_TOGOD_STATE}}, {isPopCurrentDialog = false})
end

return QUIWidgetGemstoneToGodMaxLevel