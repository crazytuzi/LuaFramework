-- @Author: xurui
-- @Date:   2017-04-07 09:47:29
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-30 20:27:45
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparStrength = class("QUIWidgetHeroSparStrength", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroSparMaxLevel = import("...widgets.spar.QUIWidgetHeroSparMaxLevel")

function QUIWidgetHeroSparStrength:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Stengthen_a.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClickItem1", callback = handler(self, self._onTriggerClickItem1)},
		{ccbCallbackName = "onTriggerClickItem2", callback = handler(self, self._onTriggerClickItem2)},
		{ccbCallbackName = "onTriggerClickItem3", callback = handler(self, self._onTriggerClickItem3)},
		{ccbCallbackName = "onTriggerClickItem4", callback = handler(self, self._onTriggerClickItem4)},
		{ccbCallbackName = "onTriggerClickBreakthough", callback = handler(self, self._onTriggerClickBreakthough)},
		{ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
		{ccbCallbackName = "onTriggerOne", callback = handler(self, self._onTriggerOne)},
		{ccbCallbackName = "onTriggerFive", callback = handler(self, self._onTriggerFive)},
	}
	QUIWidgetHeroSparStrength.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.isMax = false

	self._isEating = false
	self._eatNum = 0
	self._eatItem = {}
	self._expItems = {}
	self._isUp = true
	self._isUpGrade = false
	self._isMaster = false
	self._attributeInfo = {}
	self._changeLevel = 0
	self._masterType = "jingshiqianghua_master_"
	
	self:resetAll()
end

function QUIWidgetHeroSparStrength:onEnter()
    self._heroProxy = cc.EventProxy.new(remote.herosUtil)
    self._heroProxy:addEventListener(remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP, handler(self, self.upGrade))

    if not self._expBarScheduler then
		self._expBarScheduler = scheduler.scheduleGlobal(function()
				if self and self._ccbOwner and self._ccbOwner.exp_bar then
					self:_setExpBarScaleX(self._ccbOwner.exp_bar:getScaleX())
				end
			end, 0)
	end
end

function QUIWidgetHeroSparStrength:onExit()
    if self._numEffect ~= nil then
    	self._numEffect:disappear()
    	self._numEffect = nil
    end
    if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	if self._textUpdate ~= nil then 
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end

	if self._expBarScheduler then
		scheduler.unscheduleGlobal(self._expBarScheduler)
		self._expBarScheduler = nil
	end
	self._heroProxy:removeAllEventListeners()
	self:upGrade()
end

function QUIWidgetHeroSparStrength:resetAll()
	self._ccbOwner.tf_item_name:setString("")
	self._ccbOwner.old_level:setString("")
	self._ccbOwner.node_max:setVisible(false)
	self._ccbOwner.btn_one:setVisible(true)
	self._ccbOwner.btn_five:setVisible(true)
	self._ccbOwner.exp_bar:setScaleX(0)
end

function QUIWidgetHeroSparStrength:setInfo(actorId, sparId, index)
	if self.actorId ~= actorId or self.sparId ~= sparId then
		self._oldLevel = nil
		self._scrolling = false
		self._changeLevel = 0
		self._attributeInfo = {}
	end

	self.actorId = actorId
	self.sparId = sparId
	self._index = index

	local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
	self._sparMasterLevel = heroUIModel:getMasterLevelByType(self._masterType)
	self._ccbOwner.master_level:setString(self._sparMasterLevel or 0)

	self.sparInfo = heroUIModel:getSparInfoByPos(self._index).info
	self.itemId = self.sparInfo.itemId
	if self._oldLevel == nil then
		self._oldLevel = self.sparInfo.level
	end

	self._ccbOwner.node_root:setVisible(true)
	local maxLevel = QStaticDatabase:sharedDatabase():getConfiguration().EQUIPMENT_MAX_LEVEL.value
	if maxLevel <= self.sparInfo.level then --已经强化到顶级了
		self._ccbOwner.node_root:setVisible(false)
		if self._maxWidget == nil then
			self._maxWidget = QUIWidgetHeroSparMaxLevel.new()
			self:getView():addChild(self._maxWidget)
			self._maxWidget:setPosition(187, 40)
		end
		self._maxWidget:setInfo(self.actorId, self.sparId, self._index, "strength")
		return
	end
	if self._maxWidget ~= nil then
		self._maxWidget:removeFromParent()
		self._maxWidget = nil
	end

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
	if self._itemBox == nil then
		self._itemBox = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.equ_node:addChild(self._itemBox)
	end
	self._itemBox:setSparInfo(itemConfig, 19, 1.0)

	self.maxStrengthenLevel = math.min(remote.user.level*2, itemConfig.enhance_max or 0)

	self:setExpItems()
	if self._scrolling == false then
		self._scrolling = true
		self:setExpBar()
	end

	if self.sparInfo ~= nil then
		self:setTitleInfo()

		if self.sparInfo.level >= self.maxStrengthenLevel or self.isMax then
			self._ccbOwner.node_max:setVisible(true)
			self._ccbOwner.strengthen_btn:setVisible(false)
			self._ccbOwner.tf_max_level_content:setString("外附魂骨等级达到上限，")
			self._ccbOwner.node_max:setPositionX(-90)
		else
			self._ccbOwner.node_max:setVisible(false)
			self._ccbOwner.strengthen_btn:setVisible(true)
		end
	end
end

--设置不变的信息
function QUIWidgetHeroSparStrength:setTitleInfo()
	self._ccbOwner.old_level:setString(self.sparInfo.level.."/"..self.maxStrengthenLevel)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
	self._ccbOwner.tf_item_name:setString(itemConfig.name)

	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]] or COLORS.j
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)

	self._ccbOwner.tf_break_num:setString("")

	self._ccbOwner.old_prop_title:setString((self.sparInfo.level or 1).."级属性")
	self._ccbOwner.new_prop_title:setString(((self.sparInfo.level or 1) + 1).."级属性")

	local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, self.sparInfo.level)
	local equConfig = QStaticDatabase:sharedDatabase():getEnhanceDataByEquLevel(itemConfig.enhance_data, self.sparInfo.level + 1)
	assert(equConfig ~= nil ,"enhance_data config can't find level :"..self.sparInfo.level)
	self._propIndex = 1

	self:setTFValue("生    命：", math.floor(oldConfig.hp_value or 0), math.floor(equConfig.hp_value or 0))
	self:setTFValue("攻    击：", math.floor(oldConfig.attack_value or 0), math.floor(equConfig.attack_value or 0))
	self:setTFValue("命    中：", math.floor(oldConfig.hit_rating or 0), math.floor(equConfig.hit_rating or 0))
	self:setTFValue("闪    避：", math.floor(oldConfig.dodge_rating or 0), math.floor(equConfig.dodge_rating or 0))
	self:setTFValue("暴    击：", math.floor(oldConfig.critical_rating or 0), math.floor(equConfig.critical_rating or 0))
	self:setTFValue("格    挡：", math.floor(oldConfig.block_rating or 0), math.floor(equConfig.block_rating or 0))
	self:setTFValue("急    速：", math.floor(oldConfig.haste_rating or 0), math.floor(equConfig.haste_rating or 0))
	self:setTFValue("物理防御：", math.floor(oldConfig.armor_physical or 0), math.floor(equConfig.armor_physical or 0))
	self:setTFValue("法术防御：", math.floor(oldConfig.armor_magic or 0), math.floor(equConfig.armor_magic or 0))
	self:setTFValue("生命百分比：", oldConfig.hp_percent or 0, equConfig.hp_percent or 0)
	self:setTFValue("攻击百分比：", oldConfig.attack_percent or 0, equConfig.attack_percent or 0)


	self._ccbOwner.node_jewery_old_prop:setVisible(false)
	self._ccbOwner.node_jewery_new_prop:setVisible(false)
	self._ccbOwner.node_spar_old_prop:setVisible(true)
	self._ccbOwner.node_spar_new_prop:setVisible(true)
end

function QUIWidgetHeroSparStrength:setExpItems()
	self._ids = {10000007, 10000008, 10000009}

	for i = 1, 3, 1 do
		if self._expItems[i] == nil then
			self._expItems[i] = QUIWidgetItemsBox.new()
			self._ccbOwner["item_"..i]:addChild(self._expItems[i])
			self._ccbOwner["item_"..i]:setScale(1.3)
		end
		local count = remote.items:getItemsNumByID(self._ids[i]) or 0
		self._expItems[i]:setGoodsInfo(self._ids[i], ITEM_TYPE.ITEM, count)

		if count > 0 then
			self._ccbOwner["item_layer_"..i]:setVisible(false)
			self._ccbOwner["item_layer_"..i]:setScale(1.3)
		else
			self._ccbOwner["item_layer_"..i]:setVisible(true)
			self._ccbOwner["item_layer_"..i]:setScale(1.3)
		end
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._ids[i])
		if itemConfig ~= nil then
			local exp = string.split(itemConfig.exp_num, "^")
			if tonumber(exp[2]) ~= nil then
				self._ccbOwner["tf_addExp_"..i]:setString("经验＋"..exp[2])
			end
		end


		self._ccbOwner["node_item"..i]:setPositionY(-84)
	end
end

function QUIWidgetHeroSparStrength:setExpBar(addLevel)
	local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
	self.sparInfo = heroUIModel:getSparInfoByPos(self._index).info
	local expInfo = QStaticDatabase:sharedDatabase():getJewelryStrengthenInfoByLevel(self.sparInfo.level + 1)
	if expInfo == nil then 
		self._ccbOwner.exp:setString("")
		self._ccbOwner.exp_bar:setScaleX(0)
		self.isMax = true
		return 
	end
	self.isMax = false

	self._currentExp = self.sparInfo.exp 

	local sparType = "jewelry_exp1"
	if self._index == 2 then
		sparType = "jewelry_exp2"
	end
	
	self._ccbOwner.exp:setString(self._currentExp.."/"..expInfo[sparType] )
	local scaleX = ( self._currentExp/(expInfo[sparType]) ) > 1  and 1 or self._currentExp/(expInfo[sparType])
	local time = 0.1
	if addLevel ~= nil then
		local array = CCArray:create()
		if addLevel > 0 then
			array:addObject(CCScaleTo:create(time, 1, 1))
			array:addObject(CCCallFunc:create(function()
					self._ccbOwner.exp_bar:setScaleX(0)
				end))
		end
		array:addObject(CCScaleTo:create(time, scaleX, 1))

		self._ccbOwner.exp_bar:runAction(CCSequence:create(array))
	else
		self:_setExpBarScaleX(scaleX)
	end
end

function QUIWidgetHeroSparStrength:_setExpBarScaleX( scaleX )
    self._ccbOwner.exp_bar:setScaleX(scaleX)
end

function QUIWidgetHeroSparStrength:setTFValue(name, oldValue, newValue)
	if self._propIndex > 2 then return end
	if oldValue ~= nil then
		if type(oldValue) == "number" or oldValue > 0 then
			if newValue ~= 0 then
				self._ccbOwner["tf_spar_old_name"..self._propIndex]:setString(name)
				self._ccbOwner["tf_spar_new_name"..self._propIndex]:setString(name)
				local value1 = oldValue
				local value2 = oldValue + newValue
				if oldValue ~= 0 and oldValue < 1 and newValue < 1 then
					value1 = (oldValue * 100).."%"
					value2 = ((oldValue + newValue) * 100).."%"
				end
				self._ccbOwner["tf_spar_old_prop"..self._propIndex]:setString("+"..value1)
				self._oldValue = value1
				self._ccbOwner["tf_spar_new_prop"..self._propIndex]:setString("+"..value2)
				self._propIndex = self._propIndex + 1
			end
		end
	end
end

function QUIWidgetHeroSparStrength:strengthenSucceed(changeLevel, masterUpGrade)
	if self._oldLevel == self.sparInfo.level then 
		return 
	end
	if self._effectShow ~= nil then
		self._effectShow:removeFromParent()
		self._effectShow = nil
	end

	self._effectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.equ_node:addChild(self._effectShow)
	self._effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi")
	app.sound:playSound("equipment_enhance")

	self._changeLevel = self._changeLevel + changeLevel

    self:showUpdateEffect(masterUpGrade)
end

function QUIWidgetHeroSparStrength:showUpdateEffect(masterUpGrade)
	if self._oldLevel < self.sparInfo.level then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.itemId)
		local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, self._oldLevel)
		local newConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, self.sparInfo.level)
		self._oldLevel = self.sparInfo.level

        self.attributeNum = 1
		self:_setAttributeInfo("生    命：", oldConfig.hp_value, newConfig.hp_value)
		self:_setAttributeInfo("攻    击：", oldConfig.attack_value, newConfig.attack_value)
		self:_setAttributeInfo("命    中：", oldConfig.hit_rating, newConfig.hit_rating)
		self:_setAttributeInfo("闪    避：", oldConfig.dodge_rating, newConfig.dodge_rating)
		self:_setAttributeInfo("暴    击：", oldConfig.critical_rating, newConfig.critical_rating)
		self:_setAttributeInfo("格    挡：", oldConfig.block_rating, newConfig.block_rating)
		self:_setAttributeInfo("攻    速：", oldConfig.haste_rating, newConfig.haste_rating)
		self:_setAttributeInfo("物理防御：", oldConfig.armor_physical, newConfig.armor_physical)
		self:_setAttributeInfo("法术防御：", oldConfig.armor_magic, newConfig.armor_magic)
		self:_setAttributeInfo("生命百分比：", string.format("%0.3f",(oldConfig.hp_percent or 0) * 100), string.format("%0.3f",(newConfig.hp_percent or 0) * 100))
		self:_setAttributeInfo("攻击百分比：", string.format("%0.3f",(oldConfig.attack_percent or 0) * 100), string.format("%0.3f",(newConfig.attack_percent or 0) * 100))
	end
	if masterUpGrade ~= nil then
		app.master:createMasterLayer()
		self:_showSucceedEffect(masterUpGrade)
	end
end

function QUIWidgetHeroSparStrength:_setAttributeInfo(str, oldValue, newValue)
	local value = tonumber(string.format("%0.3f",(newValue or 0) - (oldValue or 0)))
	if self.attributeNum <= 2 and value ~= 0 then
		if self._attributeInfo[self.attributeNum] == nil then
			self._attributeInfo[self.attributeNum] = {}
			self._attributeInfo[self.attributeNum].value = value
			self._attributeInfo[self.attributeNum].name = str
		else
			self._attributeInfo[self.attributeNum].value = self._attributeInfo[self.attributeNum].value + value
		end
        self.attributeNum = self.attributeNum + 1
	end
end

function QUIWidgetHeroSparStrength:_showSucceedEffect(masterUpGrade)
	if self._strengthenEffectShow ~= nil then
		self._strengthenEffectShow:disappear()
		self._strengthenEffectShow = nil
	end

	local ccbFile = "ccb/effects/StrenghtSccess.ccbi"
	self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_animation:addChild(self._strengthenEffectShow)
	self._strengthenEffectShow:setPosition(ccp(0, 100))
	self._strengthenEffectShow:playAnimation(ccbFile, function()
			self._strengthenEffectShow._ccbOwner.title_enchant:setVisible(false)
			self._strengthenEffectShow._ccbOwner.title_skill:setVisible(false)
			self._strengthenEffectShow._ccbOwner.title_strengthen:setString("等级  ＋"..self._changeLevel)
			if self._attributeInfo ~= nil then
				for i = 1, 2 do
					if self._attributeInfo[i] ~= nil then
						local value = self._attributeInfo[i].value
						if value < 1 then
							value = value.."%"
						end
						self._strengthenEffectShow._ccbOwner["tf_name"..i]:setString(self._attributeInfo[i].name .. "  ＋" .. value)
					else
						self._strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
					end
				end
			end

			self._changeLevel = 0
			self._attributeInfo = {}
		end, function()
			if masterUpGrade then
				app.master:upGradeMaster(masterUpGrade, self._masterType, self.actorId)
				app.master:cleanMasterLayer()
			end
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end)
end

function QUIWidgetHeroSparStrength:setEquipmentPos(equipmentPos)
	self._equipmentPos = equipmentPos
end

function QUIWidgetHeroSparStrength:getClassName()
	return "QUIWidgetHeroSparStrength"
end

--计算升级需要的经验道具
function QUIWidgetHeroSparStrength:countNextLevelNeedExp(level)
	-- local needExp = 0
	local addLevel = 0
	local eatItem = {}
	local eatExp = 0
	local _exp = self._currentExp
	if self.sparInfo.level + level > self.maxStrengthenLevel then
		level = self.maxStrengthenLevel - self.sparInfo.level
	end


	local sparType = "jewelry_exp1"
	if self._index == 2 then
		sparType = "jewelry_exp2"
	end
	if level > 0 then
		for i=1,level do
			local expInfo = QStaticDatabase:sharedDatabase():getJewelryStrengthenInfoByLevel(self.sparInfo.level + i)
			if expInfo ~= nil then
				local isEnough = false
				for _,itemId in ipairs(self._ids) do
					eatItem[itemId] = eatItem[itemId] or 0
					local config = QStaticDatabase:sharedDatabase():getItemByID(itemId)
					local itemNum = remote.items:getItemsNumByID(itemId)
					itemNum = itemNum - eatItem[itemId]
					local exp = string.split(config.exp_num, "^")
					local enhanceExp = tonumber(exp[2]) or 0
					local eatCount = 0
					if itemNum * enhanceExp + _exp >= expInfo[sparType] then
						eatCount = math.ceil((expInfo[sparType] - _exp)/enhanceExp)
						addLevel = addLevel + 1
						isEnough = true
					else
						eatCount = itemNum
					end
					eatItem[itemId] = eatItem[itemId] + eatCount
					_exp = _exp + eatCount * enhanceExp
					eatExp = eatExp + eatCount * enhanceExp
					if isEnough == true then 
						break
					end
				end
				if isEnough == false then
					break
				else
					_exp = _exp - expInfo[sparType]
				end
			end
		end
	end
	return eatItem,addLevel,eatExp
end

function QUIWidgetHeroSparStrength:quickUpGrade(items, addLevel, eatExp)
	self._oldLevel = self.sparInfo.level
	self._oldMasterLevel = self._sparMasterLevel
	self._isUp = false

	self._eatItem = {}

	local isSucc, addLevel = remote.herosUtil:heroSparEatExp(eatExp, self.actorId, self._index)
	if isSucc and addLevel > 0 then
		self:showUpGradeEffect()
	end

	for itemId,count in pairs(items) do
		if count > 0 then
			table.insert(self._eatItem, {type = itemId, count = count})
		end
	end

	self:_showEatNum(eatExp)
	self:setExpBar(addLevel or 0)
	self:showUpGradeEffect()
	self:upGrade()
end

function QUIWidgetHeroSparStrength:_onTriggerClickItem1(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(1)
	else
		self:_onUpHandler(1)
	end
end

function QUIWidgetHeroSparStrength:_onTriggerClickItem2(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(2)
	else
		self:_onUpHandler(2)
	end
end

function QUIWidgetHeroSparStrength:_onTriggerClickItem3(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(3)
	else
		self:_onUpHandler(3)
	end
end

function QUIWidgetHeroSparStrength:_onTriggerClickItem4(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(4)
	else
		self:_onUpHandler(4)
	end
end

function QUIWidgetHeroSparStrength:_onTriggerClickBreakthough()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = {isQuickWay = true}})
end

function QUIWidgetHeroSparStrength:_onTriggerMaster()
	-- self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.CLICK_STRENGTEN_MASTER, masterType = self._masterType})
end

--升一级
function QUIWidgetHeroSparStrength:_onTriggerOne(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_one) == false then return end
	local items, addLevel, eatExp = self:countNextLevelNeedExp(1)
	if addLevel > 0 then
		self:quickUpGrade(items, addLevel, eatExp)
	else
		self._itemId = self._ids[#self._ids]
		app.tip:floatTip("您的资源不足以升级")
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
	end
end

--升五级
function QUIWidgetHeroSparStrength:_onTriggerFive(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_five) == false then return end
	local items,addLevel,eatExp = self:countNextLevelNeedExp(5)
	if addLevel > 0 then
		self:quickUpGrade(items,addLevel,eatExp)
	else
		self._itemId = self._ids[#self._ids]
		app.tip:floatTip("您的资源不足以升级")
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
	end
end

function QUIWidgetHeroSparStrength:_onDownHandler(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._oldLevel = self.sparInfo.level
	self._oldMasterLevel = self._sparMasterLevel
	self._itemIndex = index
	self._itemId = self._ids[index]
	self._isUp = false
	self._addNum = 1

	self._delayTime = 0.2
	-- 延时一秒 如果一秒内未up或者移动则连续吃经验
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItemsForEach), self._delayTime)
end

function QUIWidgetHeroSparStrength:_onUpHandler(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._isEating == false then
		self:_eatExpItem()
	else
		self._isEating = false
	end
	self._scrolling = false
	self._isUp = true
	self:upGrade()
end

function QUIWidgetHeroSparStrength:_eatExpItemsForEach()
	scheduler.unscheduleGlobal(self._timeHandler)
	self._timeHandler = nil
	self._isEating = true
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
end

function QUIWidgetHeroSparStrength:_eatExpItem()
	if self._isUp then
		if self._timeHandler ~= nil then
			scheduler.unscheduleGlobal(self._timeHandler)
			self._timeHandler = nil
		end
		return 
	end
	local itemNum = remote.items:getItemsNumByID(self._itemId) or 0
	if itemNum > 0 then
		if itemNum < self._addNum then
			self._addNum = itemNum or 0
		end
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
		local exps = string.split(itemConfig.exp_num, "^")
		local exp = tonumber(exps[2]) or 0
		exp = exp * self._addNum
		local isSucc, addLevel = remote.herosUtil:heroSparEatExp(exp, self.actorId, self._index)
		if isSucc and addLevel > 0 then
			self:showUpGradeEffect()
		end
		self:addEatNum()
		self:_showEatNum(exp)
		self:setExpItems()
		self:_showEffect(exp)
		self:setExpBar(addLevel or 0)
		if self._isEating == true then
			if self.sparInfo.level < self.maxStrengthenLevel then
				self._delayTime = self._delayTime - 0.02
				self._delayTime = self._delayTime > 0.05 and self._delayTime or 0.05
				self._addNum = self._addNum + 2 
				self._addNum = self._addNum >= 10 and 10 or self._addNum
				self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
			else
				self:_onUpHandler()
			end
		end
	else
		self:upGrade()
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
	end
end

function QUIWidgetHeroSparStrength:addEatNum()
	if remote.items:removeItemsByID(self._itemId, self._addNum, false) == false then
		return
	end
	self._eatNum = self._eatNum + self._addNum
	for _, value in pairs(self._eatItem) do
		if value.type == self._itemId then
			value.count = value.count + self._addNum
			return
		end
	end
	self._eatItem[#self._eatItem + 1] = {type = self._itemId, count = self._addNum}

	local haveExpItems = false
	for i = 1, #self._ids, 1 do
		if remote.items:getItemsNumByID(self._ids[i]) > 0 then
			haveExpItems = true
		end
	end
	if haveExpItems == false then
		self:dispatchEvent({name = QUIWidgetHeroSparStrength.NO_EXP_ITEM})
	end
end


function QUIWidgetHeroSparStrength:_showEatNum(exp)
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_exp:addChild(self._numEffect)
	end
	self._numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
				ccbOwner.content:setString(" ＋"..exp)
            end)
end

function QUIWidgetHeroSparStrength:_showEffect()
	local effectFun1 = function ()
		local actionHandler = nil
		local item = QUIWidgetItemsBox.new()
		item:setGoodsInfo(self._itemId, "item", 0)
		self._ccbOwner["item_"..self._itemIndex]:addChild(item)

		local position1 = self._ccbOwner.node_exp:convertToWorldSpaceAR(ccp(0, 0))
		local position2 = self._ccbOwner["item_"..self._itemIndex]:convertToWorldSpaceAR(ccp(0, 0))

		local targetPosition = ccp(position1.x - position2.x , position1.y - position2.y + 80)

		local moveTo = CCMoveTo:create(0.1, targetPosition)
		local scale = CCScaleTo:create(0.1, 0)
		local func = CCCallFunc:create(function()
				item:removeFromParent()
				item = nil
				actionHandler = nil
			end)
		local array1 = CCArray:create()
		array1:addObject(moveTo)
		array1:addObject(scale)
		local ccspawn = CCSpawn:create(array1)

		local array2 = CCArray:create()
		array2:addObject(ccspawn)
		array2:addObject(func)
		local ccsequence = CCSequence:create(array2)
		actionHandler = item:runAction(ccsequence)
	end
	local effectFun2 = function ()
    	local effect = QUIWidgetAnimationPlayer.new()
    	self._ccbOwner["item_"..self._itemIndex]:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
                effect:disappear()
                effect = nil
            end)
	end
	effectFun1()
	scheduler.performWithDelayGlobal(effectFun2, 0.1)
end

function QUIWidgetHeroSparStrength:upGrade()
	if next(self._eatItem) and self._isUpGrade == false then
		self._isUpGrade = true

		local count = 0
		for i = 1, #self._eatItem, 1 do
			count = count + self._eatItem[i].count
		end
		remote.spar:requestSparEnhance(self.sparId, self._eatItem, function(data)
				self._eatNum = 0
				self._eatItem = {}
				self._isUp = true
				self._isUpGrade = false

				if self._changeLevel > 0 then
					self:_showSucceedEffect()
				end
			end, function (data)end)
	end
end

function QUIWidgetHeroSparStrength:showUpGradeEffect()
	if self.class ~= nil then
		local heroUIModel = remote.herosUtil:getUIHeroByID(self.actorId)
		self._sparMasterLevel = heroUIModel:getMasterLevelByType(self._masterType)
		local masterUpGrade = self._sparMasterLevel > self._oldMasterLevel and self._sparMasterLevel or nil

		if masterUpGrade then
			if self._timeHandler ~= nil then
				scheduler.unscheduleGlobal(self._timeHandler)
				self._timeHandler = nil
			end
			self._isUp = true
			self._isUpGrade = false
			self._isMaster = true
			self._oldMasterLevel = self._sparMasterLevel
		end
		local changeLevel = self.sparInfo.level - self._oldLevel or 0
		self:strengthenSucceed(changeLevel, masterUpGrade)
	end
end

return QUIWidgetHeroSparStrength