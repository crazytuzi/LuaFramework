-- @Author: xurui
-- @Date:   2019-11-21 17:10:24
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-10 19:33:32
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogJewelryEvolutionOneClick = class("QUIDialogJewelryEvolutionOneClick", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")

local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogJewelryEvolutionOneClick:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogJewelryEvolutionOneClick.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._jewelryBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._ccbOwner.tf_tips:setAnchorPoint(ccp(0.5, 1))
	self._ccbOwner.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY() + 10)

    if options then
    	self._callBack = options.callBack
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._parentOptions = options.parentOptions
    end

	self._ccbOwner.frame_tf_title:setString("饰品突破")
	self._ccbOwner.tf_select:setString("突破到顶")
	self._oneClickKey = "evolution"
	self.maxStrengthenLevel = remote.user.level
	self._isStrengthenMax = app:getUserOperateRecord():getJewelryOneClickStrengthen(self._oneClickKey) or false
	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)

	for i = 1, 2 do
		self._jewelryBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:addChild(self._jewelryBox[i])
		self._jewelryBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end
	self._jewelryBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
	self._jewelryBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)
end

function QUIDialogJewelryEvolutionOneClick:viewDidAppear()
	QUIDialogJewelryEvolutionOneClick.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:initInfo()
end

function QUIDialogJewelryEvolutionOneClick:countNeedExpItem(startLevel, maxLevel, selectBreakLevel, jewelryConfig, itemList)
	local cannotType = 0

	local isEnough = true
	local breakLevel = 0
	for i = startLevel + 1, maxLevel do
		local config = jewelryConfig[i]
		if q.isEmpty(config) == false and i <= selectBreakLevel then
			-- 不能突破的原因
			local itemCount1 = remote.items:getItemsNumByID(config.component_id_1)
			local itemCount2 = remote.items:getItemsNumByID(config.component_id_2)
			local itemConfig = db:getItemByID(config.item_id)
			if itemConfig and itemConfig.level and itemConfig.level > self._heroInfo.level then
				self._itemNewConfig = config 
				cannotType = 4
				isEnough = false
			end

			if isEnough then
				if (itemList["money"] or 0) + config.price <= remote.user.money then
					if itemList["money"] then
						itemList["money"] = itemList["money"] + config.price
					else
						itemList["money"] = config.price
					end
				else
					cannotType = 1
					isEnough = false
				end
			end

			if isEnough then
				if config.component_id_1 then
					local itemInfo = itemList[config.component_id_1] or {count = 0, id = config.component_id_1}
					if itemInfo.count + config.component_num_1 <= itemCount1 then
						itemInfo.count = itemInfo.count + config.component_num_1
					else
						itemInfo.isNoEnough = true
						cannotType = 2
						isEnough = false
					end
					itemList[config.component_id_1] = itemInfo
				end
			end

			if isEnough then
				if config.component_id_2 then
					local itemInfo = itemList[config.component_id_2] or {count = 0, id = config.component_id_2}
					if itemInfo.count + config.component_num_2 <= itemCount2 then
						itemInfo.count = itemInfo.count + config.component_num_2
					else
						itemInfo.isNoEnough = true
						cannotType = 3
						isEnough = false
					end
					itemList[config.component_id_2] = itemInfo
				end
			end

			if isEnough == false then
				break
			end
			breakLevel = i
		end
	end

	return isEnough, cannotType, breakLevel
end

function QUIDialogJewelryEvolutionOneClick:checkNeedMoney()
	local allNeedMoney = 0
	local allItemCount1 = 0
	local allItemCount2 = 0
	self._itemNewConfig = {}

	local maxBreakLevel = #self._jewelryEvolutionConfig
	local masterInfo, nextMasterInfo = db:getStrengthenMasterByMasterLevel(self._masterType, self._masterLevel, 1)
	local selectBreakLevel = nextMasterInfo.condition or 1
	if self._isStrengthenMax then
		selectBreakLevel = maxBreakLevel
	end

	-- 突破等级map
	self._jewelryConfigMap = {}
	for i = 1, 2 do
		local index = self._jewelryBox[i]:getType()
		local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(index)

		self._jewelryConfigMap[i] = {}
		for _, config in pairs(self._jewelryEvolutionConfig) do
			local itemId = config["jewelry"..i]
			local jewelryConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(itemId)
			if jewelryConfig ~= nil then
				self._jewelryConfigMap[i][config.breakthrough_level] = jewelryConfig
			end
		end
	end

	self._canBeStrEngth = 0  -- 0,可以强化;1,戒指强化道具不足;2,项链强化道具不足;
	self._cannotType = 0
	self._itemList = {}
	local canBreakLevel = 0
	for i = 1, 2 do
		if self._jewelryBox[i] then
			local index = self._jewelryBox[i]:getType()
			local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(index)
			if jewelryInfo.info then
				self._itemList[i] = {}
				local canBeStrEngth, cannotType, breakLevel = self:countNeedExpItem(jewelryInfo.breakLevel, maxBreakLevel, selectBreakLevel, self._jewelryConfigMap[i], self._itemList[i])
				self._cannotType = cannotType
				if breakLevel < canBreakLevel or canBreakLevel == 0 then
					canBreakLevel = breakLevel
				end
				if canBeStrEngth == false and breakLevel == 0 then
					self._canBeStrEngth = i
					break
				end
			end
		end
	end

	self._ccbOwner.confirmText:setString("确 定")
	if (self._canBeStrEngth == 0 and (q.isEmpty(self._itemList[1]) == false or q.isEmpty(self._itemList[2]) == false)) or canBreakLevel > 0 then
		local num, unit = q.convertLargerNumber((self._itemList[1]["money"] or 0) + (self._itemList[2]["money"] or 0))
		local str = "消耗"..num..unit.."金魂币，"
		for i = 1, #self._itemList do
			for key, value in pairs(self._itemList[i]) do
				if key ~= "money" then
					local items = db:getItemByID(value.id)
					str = str..(value.count..items.name).."，"
				end
			end
		end
    	local level, color = remote.herosUtil:getBreakThrough(canBreakLevel)
    	local colorFont = q.convertColorToWord(color)
    	if level > 0 then
    		colorFont = colorFont.."+"..level
    	end
		self._ccbOwner.tf_tips:setString(str.."将饰品突破至"..colorFont.."效果")
		self._ccbOwner.confirmText:setString("突 破")
		self._canBreak = true
	elseif self._cannotType == 1 then
		self._ccbOwner.tf_tips:setString("饰品突破所需金魂币不足，快去获取更多金魂币吧")
		self._needType = "money"
	elseif self._cannotType == 2 then
		local tip = "饰品突破所需戒指突破石不足，快去获取吧"
		if self._canBeStrEngth == 2 then
			tip = "饰品突破所需项链突破石不足，快去获取吧"
		end
		self._ccbOwner.tf_tips:setString(tip)
		local configs = self._jewelryConfigMap[self._canBeStrEngth]
		local itemList = self._itemList[self._canBeStrEngth]
		local itemId = nil
		for key, value in pairs(itemList) do
			if key ~= "money" and value.isNoEnough then
				itemId = value.id
				break
			end
		end
		self._needType = itemId
	elseif self._cannotType == 3 then
		local itemList = self._itemList[self._canBeStrEngth]
		local itemId = nil
		for key, value in pairs(itemList) do
			if key ~= "money" and value.isNoEnough then
				itemId = value.id
				break
			end
		end
		local itemConfig = db:getItemByID(itemId) or {}
		local tip = "饰品突破所需%s不足，快去获取吧"
		if self._canBeStrEngth == 2 then
			tip = "饰品突破所需%s不足，快去获取吧"
		end
		self._ccbOwner.tf_tips:setString(string.format(tip, (itemConfig.name or "")))
		self._needType = itemId
	elseif self._cannotType == 4 then
		local tip = "饰品突破所需魂师等级不足，快去升级吧"
		if self._canBeStrEngth == 2 then
			tip = "饰品突破所需魂师等级不足，快去升级吧"
		end
		self._ccbOwner.tf_tips:setString(tip)
	else
		self._ccbOwner.tf_tips:setString("已经突破到顶级")
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:disableOutline()
	end

	if canBreakLevel == 0 then
		canBreakLevel = nextMasterInfo.condition or 1
	end
	return canBreakLevel
end

function QUIDialogJewelryEvolutionOneClick:setButtonEnabled(state)
	if state == false then
		makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:disableOutline()
		self._ccbOwner.bt_confirm:setEnabled(false)
	elseif state then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:enableOutline()
		self._ccbOwner.bt_confirm:setEnabled(true)
	end

end

function QUIDialogJewelryEvolutionOneClick:initInfo( )
    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
    self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    self._characterInfo = db:getCharacterByID(self._actorId)

    self._jewelryEvolutionConfig = QStaticDatabase:sharedDatabase():getBreakthroughByTalent(self._characterInfo.talent)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
	self.maxStrengthenLevel = #self._jewelryEvolutionConfig
	self.maxMasterLevel = 1

	self.oneTimeStrengthenLevel = self:checkNeedMoney()

	local masterInfo = db:getMasterByMasterLevel(self._masterType, self.maxMasterLevel)
	while masterInfo ~= nil do
		if masterInfo.condition <= self.oneTimeStrengthenLevel then
			self.maxMasterLevel = self.maxMasterLevel + 1
			masterInfo = db:getMasterByMasterLevel(self._masterType, self.maxMasterLevel)
		else
			break
		end
	end
	self.maxMasterLevel = self.maxMasterLevel - 1
	if self._isStrengthenMax then
		self.offersetLevel = self.maxMasterLevel - self._masterLevel
	else
		self.offersetLevel = 1
	end
	if self.offersetLevel == 0 then
		self.offersetLevel = 1
	end

	self._currMasterInfo, self._nextMasterInfo, self._isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(self._masterType, self._masterLevel, self.offersetLevel)


	self:setBoxInfos()
	self:setPropInfo()
end


function QUIDialogJewelryEvolutionOneClick:setBoxInfos()
	for i = 1, 2 do
		self._jewelryBox[i]:setPositionY(-50)
		local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(self._jewelryBox[i]:getType())
		if jewelryInfo.info ~= nil then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(jewelryInfo.info.itemId)
			local canStrengthen = false 
			if jewelryInfo.breakLevel < self.oneTimeStrengthenLevel and jewelryInfo.breakLevel < self.maxStrengthenLevel then
				canStrengthen = true
			end

			self._jewelryBox[i]:setItemInfo(itemInfo, jewelryInfo, self._nextMasterInfo, self._masterType, canStrengthen)
		else
			self._jewelryBox[i]:showEmpty(self._nextMasterInfo)
		end
	end
end

function QUIDialogJewelryEvolutionOneClick:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)

end 

function QUIDialogJewelryEvolutionOneClick:viewWillDisappear()
  	QUIDialogJewelryEvolutionOneClick.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogJewelryEvolutionOneClick:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setSparOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogJewelryEvolutionOneClick:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if self._canBeStrEngth ~= 0 then 
		if self._cannotType == 4 then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.HERO_LEVEL)
		elseif self._needType == "money" then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		else
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._needType)
		end
		return
	end

	local inserProp = function(prop, propKey, value)
		if propKey == nil or value == nil then return end

		if prop[propKey] then
			prop[propKey] = prop[propKey] + value
		else
			prop[propKey] = value
		end
	end

	local jewelryPos = {}
	local oldEquipmentProp = {}
	local oldAllLevel = 0
	for i = 1, 2 do
		local index = self._jewelryBox[i]:getType()
		local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(index)
		if jewelryInfo.breakLevel < self.oneTimeStrengthenLevel then
			table.insert(jewelryPos, index)
			oldAllLevel = oldAllLevel + jewelryInfo.breakLevel

			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(jewelryInfo.info.itemId)
			inserProp(oldEquipmentProp, "hp_value", itemConfig.hp_value)
			inserProp(oldEquipmentProp, "attack_value", itemConfig.attack_value)
			inserProp(oldEquipmentProp, "hp_percent", itemConfig.hp_percent)
			inserProp(oldEquipmentProp, "attack_percent", itemConfig.attack_percent)
		end
	end
	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)
	local untilLevel = self.offersetLevel + self._masterLevel

	app:getClient():jewelryEvolutionOneClickRequest(self._actorId, self.oneTimeStrengthenLevel, function(data)
		if self.class ~= nil then
			local critNum = data.enhanceEquipmentCritCount --暴击

			local newLevel = 0
			local newEquipmentProp = {}
			for key, v in pairs(jewelryPos)  do
				local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(v)
				local equipLevel = 0
				if jewelryInfo then
					equipLevel = jewelryInfo.breakLevel or 0
				end
				newLevel = newLevel + equipLevel
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(jewelryInfo.info.itemId)
				inserProp(newEquipmentProp, "hp_value", itemConfig.hp_value)
				inserProp(newEquipmentProp, "attack_value", itemConfig.attack_value)
				inserProp(newEquipmentProp, "hp_percent", itemConfig.hp_percent)
				inserProp(newEquipmentProp, "attack_percent", itemConfig.attack_percent)
			end

			local attributeInfo = {}
			local index = 1
			if (newEquipmentProp.hp_value or 0) - (oldEquipmentProp.hp_value or 0) > 0 then
				attributeInfo[index] = {name = "生   命", value = (newEquipmentProp.hp_value or 0) - (oldEquipmentProp.hp_value or 0)}
				index = index + 1
			end
			if (newEquipmentProp.attack_value or 0) - (oldEquipmentProp.attack_value or 0) > 0 then
				attributeInfo[index] = {name = "攻   击",value = (newEquipmentProp.attack_value or 0) - (oldEquipmentProp.attack_value or 0 )}
				index = index + 1
			end
			if (newEquipmentProp.hp_percent or 0) - (oldEquipmentProp.hp_percent or 0) > 0 then
				attributeInfo[index] = {name = "生命百分比", value = string.format("%0.1f%%", ((newEquipmentProp.hp_percent or 0) - (oldEquipmentProp.hp_percent or 0))*100)}
				index = index + 1
			end
			if (newEquipmentProp.attack_percent or 0) - (oldEquipmentProp.attack_percent or 0) > 0 then
				attributeInfo[index] = {name = "攻击百分比", value = string.format("%0.1f%%", ((newEquipmentProp.attack_percent or 0) - (oldEquipmentProp.attack_percent or 0))*100)}
				index = index + 1
			end	

			local nowMasterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
			printInfo("~~~~~~ self._masterLevel == %s ~~~~~~~", self._masterLevel)
			printInfo("~~~~~~ nowMasterLevel == %s ~~~~~~~", nowMasterLevel)
			local masterUpGrade = nowMasterLevel > self._masterLevel and nowMasterLevel or self._masterLevel 
			local upLevel = masterUpGrade - self._masterLevel
			printInfo("~~~~~~ upLevel == %s ~~~~~~~", upLevel)
			local showData = {critNum = 0, changeLevel = newLevel - oldAllLevel, masterUpGrade = masterUpGrade, upLevel = upLevel, masterType = self._masterType,attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			remote.user:addPropNumForKey("todayAdvancedBreakthroughCount")
			self:showStrengThenEffect()

			self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE})
		end
	end, function()
		self:setButtonEnabled(true)
	end)
end

function QUIDialogJewelryEvolutionOneClick:showStrengThenEffect()
	for i = 1, 2 do
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijianqianghua_1", "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)
		fcaAnimation:setScale(1/0.78)
		fcaAnimation:setPositionY(-43)
		self._ccbOwner["box_node"..i]:addChild(fcaAnimation)
	end
end

function QUIDialogJewelryEvolutionOneClick:strengthenSucceedEffect(data)
	self._ccbOwner.strenAnimationNode:removeAllChildren()
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 100))
	strengthenEffectShow:playAnimation("ccb/effects/BaojiOneTime.ccbi", function(ccbOwner)
		ccbOwner.level:setVisible(false)
		ccbOwner.node_critcrit:setVisible(false)
		ccbOwner.tf_name:setString("连续突破"..(data.changeLevel).."次")
		if data.attributeInfo then
			for i = 1, 4 do
				if data.attributeInfo[i] then
					local value = data.attributeInfo[i].value
					self._strengthValue = value
					strengthenEffectShow._ccbOwner["tf_name"..i]:setString(data.attributeInfo[i].name .. "＋" .. value)
				else
					strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
				end
			end
		end
	end, function()
		if strengthenEffectShow ~= nil then
			strengthenEffectShow:disappear()
			strengthenEffectShow = nil
			self:setButtonEnabled(true)
			self:initInfo()
		end
	end)

	if data.upLevel > 0 then
		app.master:createMasterLayer()
		self._strengthenScheduler = scheduler.performWithDelayGlobal(function()
				if data.masterUpGrade then
					app.master:upGradeMaster(data.masterUpGrade, data.masterType, self._actorId, nil, data.upLevel)
					app.master:cleanMasterLayer()
				end
			end, 1.3)
	end
end

function QUIDialogJewelryEvolutionOneClick:_eventClickBox(event)

	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local initTab = "TAB_STRONG"
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = event.itemId, heros = self._parentOptions.heros, pos = event.euqipPos, parentOptions = self._parentOptions,
         initTab = initTab, isQuickWay = self._isQuickWay}})
end

function QUIDialogJewelryEvolutionOneClick:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogJewelryEvolutionOneClick:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogJewelryEvolutionOneClick:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogJewelryEvolutionOneClick
