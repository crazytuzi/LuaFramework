local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroNormalEquipmentStrengthen = class("QUIWidgetHeroNormalEquipmentStrengthen", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIDialogHeroInformation = import("..dialogs.QUIDialogHeroInformation")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetHeroNormalEquipmentStrengthen.WEAR_STRENGTHEN_SUCCEED = "WEAR_STRENGTHEN_SUCCEED"

function QUIWidgetHeroNormalEquipmentStrengthen:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Stengthen_e.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOneWearMax", callback = handler(self, QUIWidgetHeroNormalEquipmentStrengthen._onTriggerOneWearMax)},
		{ccbCallbackName = "onTriggerStrengthenOne", callback = handler(self, QUIWidgetHeroNormalEquipmentStrengthen._onTriggerStrengthenOne)},
		{ccbCallbackName = "onTriggerClickBreakthough", callback = handler(self, self._onTriggerClickBreakthough)},
		{ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
	}
	QUIWidgetHeroNormalEquipmentStrengthen.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.vipUnlock = nil
	self._animationEnded = true
end

function QUIWidgetHeroNormalEquipmentStrengthen:onEnter()
	-- self._userEventProxy = cc.EventProxy.new(remote.user)
 --    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
end

function QUIWidgetHeroNormalEquipmentStrengthen:onExit()
	if self._effectShow ~= nil then
		self._effectShow:disappear()
		self._effectShow = nil
	end
    if self._timeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._timeHandler)
    	self._timeHandler = nil
    end
    if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
    -- self._userEventProxy:removeAllEventListeners()
end

function QUIWidgetHeroNormalEquipmentStrengthen:resetAll()
	self._ccbOwner.tf_item_name:setString("")
	self._ccbOwner.old_level:setString("")
	self._ccbOwner.tf_money:setString("")
	self._ccbOwner.tf_money_one:setString("")
	self._ccbOwner.node_max:setVisible(false)
end

function QUIWidgetHeroNormalEquipmentStrengthen:setHeroInfo(actorId, itemId)
	if self.actorId ~= actorId or self.itemId ~= itemId then
		self:resetAll()
		self._oldLevel = nil
	end
	self.actorId = actorId
	self.itemId = itemId

	local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
	self._equipMasterLevel = heroUIModel:getMasterLevelByType("enhance_master_")
	self._ccbOwner.master_level:setString(self._equipMasterLevel or 0)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
	
	if self._itemBox == nil then
		self._itemBox = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.equ_node:addChild(self._itemBox)
	end
	self._itemBox:setEquipmentInfo(itemConfig, self.actorId)

	self.maxStrengthenLevel = remote.herosUtil:getEquipmentStrengthenMaxLevel()

	self.equipment = remote.herosUtil:getWearByItem(self.actorId, self.itemId)

	self:setNeedMoney()
	
	if self._oldLevel == nil then
		self._oldLevel = self.equipment.level
	-- else
	-- 	return
	end
	if self.equipment ~= nil then
		self:setStrengthenButtonInfo()
	end
	self:setTitleInfo()
end

function QUIWidgetHeroNormalEquipmentStrengthen:setNeedMoney()
	local strengthenLevel = 5
	self.wearNeedMoney, self.onWearLevel = self:getOneWearNeedMoney(self.itemId, strengthenLevel)
	self.oneWearNeedMoney, self.oneStrengthenLevel= self:getOneWearNeedMoney(self.itemId, 1)
	if self.wearNeedMoney == nil or self.onWearLevel == nil then return end

	local labelLevel = math.abs(self.onWearLevel - self.equipment.level)
	labelLevel = labelLevel > strengthenLevel and strengthenLevel or labelLevel
	self._ccbOwner.strengthen_label:setString("强化"..labelLevel.."次")
	self._ccbOwner.tf_money:setString(self.wearNeedMoney)
	self._ccbOwner.tf_money_one:setString(self.oneWearNeedMoney)

	if self.wearNeedMoney > remote.user.money then
		self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_money:setColor(ccc3(61, 13, 0))
	end
	if self.oneWearNeedMoney > remote.user.money then
		self._ccbOwner.tf_money_one:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_money_one:setColor(ccc3(61, 13, 0))
	end
end

function QUIWidgetHeroNormalEquipmentStrengthen:setStrengthenButtonInfo(level)
	local equipmentLevel = level == nil and self.equipment.level or level
	if equipmentLevel >= self.maxStrengthenLevel then
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.strengthen_btn:setVisible(false)
		self._ccbOwner.strengthen_one_btn:setVisible(false)
	else
		self._ccbOwner.node_max:setVisible(false)
		self._ccbOwner.strengthen_btn:setVisible(true)
		self._ccbOwner.strengthen_one_btn:setVisible(true)
	end
end 

--设置不变的信息
function QUIWidgetHeroNormalEquipmentStrengthen:setTitleInfo()

	self._ccbOwner.old_level:setString(self.equipment.level.."/"..self.maxStrengthenLevel)

	local enchantLevel = self.equipment.enchants or 0
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
	
	self._ccbOwner.tf_item_name:setString(itemConfig.name)
	local fontColor = COLORS.j
	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(self.actorId, self.itemId)
	local level,color = remote.herosUtil:getBreakThrough(breaklevel)
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)

	if level > 0 then
		self._ccbOwner.tf_break_num:setString("＋"..level)
		self._ccbOwner.tf_break_num:setColor(fontColor)
		self._ccbOwner.tf_break_num = setShadowByFontColor(self._ccbOwner.tf_break_num, fontColor)
		self._ccbOwner.tf_break_num:setPositionX(self._ccbOwner.tf_item_name:getPositionX() + self._ccbOwner.tf_item_name:getContentSize().width)
	else
		self._ccbOwner.tf_break_num:setString("")
	end
	self._ccbOwner.old_prop_title:setString((self.equipment.level or 1).."级属性")
	self._ccbOwner.new_prop_title:setString(((self.equipment.level or 1) + 1).."级属性")

	local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, self.equipment.level)
	local equConfig = QStaticDatabase:sharedDatabase():getEnhanceDataByEquLevel(itemConfig.enhance_data, self.equipment.level + 1)
	assert(equConfig ~= nil ,"enhance_data "..itemConfig.enhance_data.." can't find level :"..self.equipment.level.." please @terrry")
	self._index = 1

	self:setTFValue("生    命：", "生命", math.floor(oldConfig.hp_value or 0), math.floor(equConfig.hp_value or 0), "hp_value")
	self:setTFValue("攻    击：", "攻击", math.floor(oldConfig.attack_value or 0), math.floor(equConfig.attack_value or 0), "attack_value")
	self:setTFValue("命    中：", "命中", math.floor(oldConfig.hit_rating or 0), math.floor(equConfig.hit_rating or 0), "hit_rating")
	self:setTFValue("闪    避：", "闪避", math.floor(oldConfig.dodge_rating or 0), math.floor(equConfig.dodge_rating or 0), "dodge_rating")
	self:setTFValue("暴    击：", "暴击", math.floor(oldConfig.critical_rating or 0), math.floor(equConfig.critical_rating or 0), "critical_rating")
	self:setTFValue("格    挡：", "格挡", math.floor(oldConfig.block_rating or 0), math.floor(equConfig.block_rating or 0), "block_rating")
	self:setTFValue("急    速：", "急速", math.floor(oldConfig.haste_rating or 0), math.floor(equConfig.haste_rating or 0), "haste_rating")
	self:setTFValue("物理防御：", "物理防御", math.floor(oldConfig.armor_physical or 0), math.floor(equConfig.armor_physical or 0), "armor_physical")
	self:setTFValue("法术防御：", "法术防御", math.floor(oldConfig.armor_magic or 0), math.floor(equConfig.armor_magic or 0), "armor_magic")
	self:setTFValue("生命增加：", "生命增加", oldConfig.hp_percent or 0, equConfig.hp_percent or 0, "hp_percent")
	self:setTFValue("攻击增加：", "攻击增加", oldConfig.attack_percent or 0, equConfig.attack_percent or 0, "attack_percent")
end

--计算一个装备强化到指定等级需要的钱
function QUIWidgetHeroNormalEquipmentStrengthen:getOneWearNeedMoney(itemId, maxlevel)
	local result = 0
	local equipment = remote.herosUtil:getWearByItem(self.actorId, itemId)
	if equipment == nil then return end
	local level = 0
	for i = equipment.level, (equipment.level + maxlevel - 1), 1 do
		local money = QStaticDatabase:sharedDatabase():getStrengthenInfoByEquLevel(i + 1)
		if money ~= nil and i <= (self.maxStrengthenLevel - 1) then
			result = result + money
			level = i
			if result > remote.user.money then
				if (result - money) == 0 then
					return result, level + 1	
				end
				return result - money, level
			end
		else
			return result, level + 1
		end
	end
	return result, level + 1
end

--计算所有可强化装备强化到最大等级需要的钱
function QUIWidgetHeroNormalEquipmentStrengthen:getAllWearNeedMoney()
	local result = 0
	local heroInfo = remote.herosUtil:getHeroByID(self.actorId)
	local maxLevel = self.maxStrengthenLevel
	local addLevel = 0
	while true do
		local index = 0
		for _, value in pairs(heroInfo["equipments"]) do
			local equipment = remote.herosUtil:getWearByItem(self.actorId, value["itemId"])
			if (equipment.level + addLevel) < maxLevel then
				local money = QStaticDatabase:sharedDatabase():getStrengthenInfoByEquLevel(equipment.level + addLevel + 1)
				if money ~= nil then
					result = result + money
					if result > remote.user.money then
						if (result - money) == 0 then
							return result
						end
						return result - money, addLevel
					end
				end
			else
				index = index + 1
			end
		end
		addLevel = addLevel + 1

		if index == #heroInfo["equipments"] then
			return result, addLevel
		end
	end
end

function QUIWidgetHeroNormalEquipmentStrengthen:setTFValue(name, cname, oldValue, newValue, state)
	if self._index >= 2 then return end
	if oldValue ~= nil then
		if type(oldValue) == "number" or oldValue > 0 then
			if newValue ~= 0 then
				self._cname = cname
				self._ccbOwner["name1"]:setString(name)
				self._ccbOwner["name2"]:setString(name)
				local value1 = oldValue
				local value2 = oldValue + newValue
				if oldValue ~= 0 and oldValue < 1 and newValue < 1 then
					value1 = (oldValue * 100).."%"
					value2 = ((oldValue + newValue) * 100).."%"
				end
				self._ccbOwner["old_prop"]:setString(" +"..value1)
				self._ccbOwner["new_prop"]:setString(" +"..value2)
				self._oldPropValue = value1
				self._oldValue = value1
				self._propState = state 
				self._index = self._index + 1
			end
		end
	end
end

--获取当前魂师可以强化的装备ID
function QUIWidgetHeroNormalEquipmentStrengthen:getCanStrengthenEquipment()
	local heroInfo = remote.herosUtil:getHeroByID(self.actorId)
	local maxLevel = self.maxStrengthenLevel
	local itemIds = {}
	for _, value in pairs(heroInfo["equipments"]) do
		local equipment = remote.herosUtil:getWearByItem(self.actorId, value["itemId"])
		if equipment.level < maxLevel then
			table.insert(itemIds, value["itemId"])
		end
	end
	return itemIds
end

------------------------------event------------------------

function QUIWidgetHeroNormalEquipmentStrengthen:onEvent(event)
	if event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self:setNeedMoney()
	end
end

function QUIWidgetHeroNormalEquipmentStrengthen:strengthenSucceed(state, itemIds, changeLevel, critNum, masterUpGrade)
	if self._effectShow ~= nil then
		self._effectShow:removeFromParent()
		self._effectShow = nil
	end
	self._effectShow = QUIWidgetAnimationPlayer.new()
	
	self._ccbOwner.equ_node:addChild(self._effectShow)
	self._effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi")
	app.sound:playSound("equipment_enhance")

	self._totalLevel = {}
	self._critNum = critNum or 0
	self._changeLevel = changeLevel or 0
	local allLevel = critNum == nil and self._changeLevel or (self._changeLevel + self._critNum)

	for i = 1, allLevel, 1 do
		self._totalLevel[i] = 1
	end

	self:_showEffect(allLevel, self._totalLevel[index], itemId, masterUpGrade)

end

function QUIWidgetHeroNormalEquipmentStrengthen:_showEffect(changeLevel, critNum, itemId, masterUpGrade)
	self._attributeInfo = {}
	local value = 0
	self._attributeInfo = {{name = self._propState, value =  value}}
	self._attributeInfo[1].name = self._cname or ""

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)

	for i = 1, changeLevel, 1 do
		local equConfig1 = QStaticDatabase:sharedDatabase():getEnhanceDataByEquLevel(itemConfig.enhance_data, self._oldLevel+i)
		if equConfig1 then
			self._attributeInfo[1].value =  self._attributeInfo[1].value + (equConfig1[self._propState] or 0)
		end
	end
	self._oldLevel = self._oldLevel + changeLevel

	self:setLabelScale(self._ccbOwner.old_level, 1.2)
	self:setLabelScale(self._ccbOwner.old_prop, 1.2)
	self:setLabelScale(self._ccbOwner.new_prop, 1.2)

	self:setStrengthenButtonInfo(self._oldLevel)
	self:canStrengthen(masterUpGrade)
end

function QUIWidgetHeroNormalEquipmentStrengthen:setLabelScale(node, scale)
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(0.1, 1.2))
	ccArray:addObject(CCScaleTo:create(0.1, 1))
	node:runAction(CCSequence:create(ccArray))
end 

function QUIWidgetHeroNormalEquipmentStrengthen:_effectFinished()
	self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE})
	self._animationEnded = true
	self:setButtonEnabled(true)
end

function QUIWidgetHeroNormalEquipmentStrengthen:refreshProperty()
end

function QUIWidgetHeroNormalEquipmentStrengthen:canStrengthen(masterUpGrade)
	-- self:_effectFinished()
	self:dispatchEvent({name = QUIWidgetHeroNormalEquipmentStrengthen.WEAR_STRENGTHEN_SUCCEED, state = "0", itemIds = {self.itemId}, 
					critNum = self._critNum, changeLevel = self._changeLevel, attributeInfo = self._attributeInfo, masterUpGrade = masterUpGrade, masterType = "enhance_master_"})
end

function QUIWidgetHeroNormalEquipmentStrengthen:setEquipmentPos(equipmentPos)
	self._equipmentPos = equipmentPos
end

function QUIWidgetHeroNormalEquipmentStrengthen:getClassName()
	return "QUIWidgetHeroNormalEquipmentStrengthen"
end

function QUIWidgetHeroNormalEquipmentStrengthen:_onTriggerStrengthenMaster()
	local function getPosByHeroID(heroes, heroId)
		local pos = 1
		for i, actorId in ipairs(heroes) do
			if actorId == heroId then
				pos = i
				break
			end
		end

		return pos
	end

	local pos = getPosByHeroID(remote.herosUtil:getHaveHero(), self.actorId)
	app:getNavigationManager():pushViewController(app.mainUILayer, 
		{uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
			options = {hero = remote.herosUtil:getHaveHero(), pos = pos, detailType = QUIDialogHeroInformation.HERO_STRENGTHEN_MASTER,
				strengthenMaster = app.master.STRENGTHEN_MASTER}}
	)
end

function QUIWidgetHeroNormalEquipmentStrengthen:_onTriggerStrengthenOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.stengthen_equ_one) == false then return end
	if self._animationEnded == false then return end

	if self.oneWearNeedMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end
	local oldMasterLevel = self._equipMasterLevel
	self._animationEnded = false
	local itemIds = {self.itemId}
	app:getClient():heroEquipmentStrengthenRequest(self.actorId, itemIds, self.oneStrengthenLevel, false ,function(data)
		if self.class ~= nil then
			self:setButtonEnabled(false)
			local critNum = data.enhanceEquipmentCritCount
			
			local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
			self._equipMasterLevel = heroUIModel:getMasterLevelByType("enhance_master_")
			local masterUpGrade = self._equipMasterLevel > oldMasterLevel and self._equipMasterLevel or nil

			self:strengthenSucceed("0", itemIds, 1, critNum, masterUpGrade)
		end
		remote.user:addPropNumForKey("todayEquipEnhanceCount", 1)
	end, function()
		self._animationEnded = true
	end)
end

function QUIWidgetHeroNormalEquipmentStrengthen:_onTriggerOneWearMax(event)
	if q.buttonEventShadow(event, self._ccbOwner.stengthen_equ) == false then return end
	if self._animationEnded == false then return end

	if self.wearNeedMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end
	local changeLevel = math.abs(self.equipment.level - self.onWearLevel)
	local oldLevel = self.equipment.level
	local oldMasterLevel = self._equipMasterLevel
	-- self:setMaster()
	local itemIds = {self.itemId}
	self._animationEnded = false
	app:getClient():heroEquipmentStrengthenRequest(self.actorId, itemIds, self.onWearLevel,false, function(data)
		if self.class ~= nil then
			self:setButtonEnabled(false)
			local critNum = data.enhanceEquipmentCritCount or 0
			local equipment = remote.herosUtil:getWearByItem(self.actorId, self.itemId)
			changeLevel = equipment.level - oldLevel - critNum

			local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
			self._equipMasterLevel = heroUIModel:getMasterLevelByType("enhance_master_")
			local masterUpGrade = self._equipMasterLevel > oldMasterLevel and self._equipMasterLevel or nil

			self:strengthenSucceed("0", itemIds, changeLevel, critNum, masterUpGrade)
		end
		remote.user:addPropNumForKey("todayEquipEnhanceCount", changeLevel)
	end, function()
		self._animationEnded = true
	end)
end

function QUIWidgetHeroNormalEquipmentStrengthen:setButtonEnabled(state)
	if state == false then
		makeNodeFromNormalToGray(self._ccbOwner.button_stengthen_one)
		makeNodeFromNormalToGray(self._ccbOwner.button_stengthen)
		self._ccbOwner.strengthen_label_one:disableOutline() 
		self._ccbOwner.strengthen_label:disableOutline() 

		self._ccbOwner.stengthen_equ_one:setEnabled(false)
		self._ccbOwner.stengthen_equ:setEnabled(false)
		self._ccbOwner.stengthen_equ_one:setHighlighted(false)
		self._ccbOwner.stengthen_equ:setHighlighted(false)
	elseif state then
		makeNodeFromGrayToNormal(self._ccbOwner.button_stengthen)
		makeNodeFromGrayToNormal(self._ccbOwner.button_stengthen_one)
		self._ccbOwner.strengthen_label_one:enableOutline() 
		self._ccbOwner.strengthen_label:enableOutline() 

		
		self._ccbOwner.stengthen_equ_one:setEnabled(true)
		self._ccbOwner.stengthen_equ:setEnabled(true)
		self._ccbOwner.stengthen_equ_one:setHighlighted(false)
		self._ccbOwner.stengthen_equ:setHighlighted(false)
	end

end

function QUIWidgetHeroNormalEquipmentStrengthen:_onTriggerClickBreakthough()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetHeroNormalEquipmentStrengthen:_onTriggerMaster()
	self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.CLICK_STRENGTEN_MASTER, masterType = "enhance_master_"})
end

function QUIWidgetHeroNormalEquipmentStrengthen:_checkStrengthenMaster()
	if app.master:checkStrengthenMaster(self.actorId) then
		app.tip:refreshTip()
		app.tip:masterTip(app.master.STRENGTHEN_MASTER, self.actorId)
	end
end

function QUIWidgetHeroNormalEquipmentStrengthen:setMaster()
	--保存强化大师等级
	app.master:setStrengthenMaster(self.actorId)
end

return QUIWidgetHeroNormalEquipmentStrengthen
