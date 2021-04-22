--
-- Author: wkwang
-- Date: 2015-03-04 17:08:35
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroEquipmentEvolution = class("QUIWidgetHeroEquipmentEvolution", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetItemDropInfoCell = import("..widgets.QUIWidgetItemDropInfoCell")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QUIDialogAlertBreak = import("..dialogs.QUIDialogAlertBreak")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

QUIWidgetHeroEquipmentEvolution.EVENT_EVOLUTION_SUCC =  "EVENT_EVOLUTION_SUCC"
QUIWidgetHeroEquipmentEvolution.EVENT_EVOLUTION_SELELCT =  "EVENT_EVOLUTION_SELELCT"

function QUIWidgetHeroEquipmentEvolution:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_Evolution_a.ccbi"
	local callBacks = {
	{ccbCallbackName = "onTriggerEvolution", callback = handler(self, QUIWidgetHeroEquipmentEvolution._onTriggerEvolution)},
	{ccbCallbackName = "onTriggerClickLevel", callback = handler(self, QUIWidgetHeroEquipmentEvolution._onTriggerClickLevel)},
	{ccbCallbackName = "onTiggerClickStrength", callback = handler(self, QUIWidgetHeroEquipmentEvolution._onTiggerClickStrength)},
	}
	QUIWidgetHeroEquipmentEvolution.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.materials = {}

    -- if app.unlock:getUnlockEnhance() == false then
    	self._ccbOwner.tf_old_name2:setVisible(false)
    	self._ccbOwner.tf_old_value2:setVisible(false)
    	self._ccbOwner.tf_new_name2:setVisible(false)
    	self._ccbOwner.tf_new_value2:setVisible(false)
    -- end

    self._canEvolution = true
end

function QUIWidgetHeroEquipmentEvolution:onEnter()
	QUIWidgetHeroEquipmentEvolution.super.onEnter(self)
	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	-- self._userEventProxy = cc.EventProxy.new(remote.user)
 --    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CLOSE_EQUIPMENT_COMPOSE_DIALOG, self._onComposeDialogCloseHandler, self)

    self._canEvolution = true
end

function QUIWidgetHeroEquipmentEvolution:onExit()
	QUIWidgetHeroEquipmentEvolution.super.onExit(self)
	if self._composeDialog ~= nil then
		self._composeDialog:removeAllEventListeners()
		self._composeDialog = nil
	end
	if self.materials ~= nil and #self.materials > 0 then
		for _,item in ipairs(self.materials) do
			item:removeAllEventListeners()
			item:removeFromParent()
		end
		self.materials = {}
	end
	self._itemsProxy:removeAllEventListeners()
    -- self._userEventProxy:removeAllEventListeners()
    if self._canEvolutionScheduler then
    	scheduler.unscheduleGlobal(self._canEvolutionScheduler)
    	self._canEvolutionScheduler = nil
    end

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CLOSE_EQUIPMENT_COMPOSE_DIALOG, self._onComposeDialogCloseHandler, self)
    self._canEvolution = true
end

function QUIWidgetHeroEquipmentEvolution:resetAll()
	if self.materials ~= nil and #self.materials > 0 then
		for _,item in ipairs(self.materials) do
			item:removeAllEventListeners()
			item:removeFromParent()
		end
		self.materials = {}
	end
	self._needMoney = 0
	self._isMaterilEnough = true
	self._ccbOwner.node_old_icon:removeAllChildren()
	self._ccbOwner.node_new_icon:removeAllChildren()

	local index = 1
	while true do
		if self._ccbOwner["tf_old_name"..index] ~= nil and self._ccbOwner["tf_new_name"..index] ~= nil then
			self._ccbOwner["tf_old_name"..index]:setString("")
			self._ccbOwner["tf_old_value"..index]:setString("")
			self._ccbOwner["tf_new_name"..index]:setString("")
			self._ccbOwner["tf_new_value"..index]:setString("")
		else
			break
		end
		index = index + 1
	end
end

function QUIWidgetHeroEquipmentEvolution:setInfo(actorId, itemId, pos)
	self:resetAll()
	self._actorId = actorId
	self._itemOldId = itemId
	self._equipmentPos = pos
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._itemOldConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemOldId)
	self._equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(self._equipmentPos)
	self._evolutionLevel = self._equipmentInfo.breakLevel
	local nextBreakInfo = self._equipmentInfo.nextBreakInfo
	if nextBreakInfo == nil then
		--突破到顶级了 todo
		self._ccbOwner.tf_break_tips:setVisible(true)
		self._ccbOwner.node_composite:setVisible(false)
	else
		self._ccbOwner.node_composite:setVisible(true)
		self._ccbOwner.tf_break_tips:setVisible(false)
		self._itemNewId = nextBreakInfo[self._equipmentPos]
	    local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(self._actorId, self._itemOldId)
	    local level,color = remote.herosUtil:getBreakThrough(breaklevel) 
	    local name = self._itemOldConfig.name or " "
	    if level > 0 then 
	    	name = name .. "＋".. level
	    end
		self._ccbOwner.tf_old_name:setString(name)
		local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		self._ccbOwner.tf_old_name:setColor(fontColor)
		self._ccbOwner.tf_old_name = setShadowByFontColor(self._ccbOwner.tf_old_name, fontColor)

		local index = 1
		index = self:setOldTFValue("生    命:", math.floor(self._itemOldConfig.hp_value or 0), index)
		index = self:setOldTFValue("攻    击:", math.floor(self._itemOldConfig.attack_value or 0), index)
		index = self:setOldTFValue("命    中:", math.floor(self._itemOldConfig.hit_rating or 0), index)
		index = self:setOldTFValue("闪    避:", math.floor(self._itemOldConfig.dodge_rating or 0), index)
		index = self:setOldTFValue("暴    击:", math.floor(self._itemOldConfig.critical_rating or 0), index)
		index = self:setOldTFValue("格    挡:", math.floor(self._itemOldConfig.block_rating or 0), index)
		index = self:setOldTFValue("急    速:", math.floor(self._itemOldConfig.haste_rating or 0), index)
		index = self:setOldTFValue("物理防御:", math.floor(self._itemOldConfig.armor_physical or 0), index)
		index = self:setOldTFValue("法术防御:", math.floor(self._itemOldConfig.armor_magic or 0), index)
		index = self:setOldTFValue("生命增加:", (self._itemOldConfig.hp_percent or 0), index, true)
		index = self:setOldTFValue("攻击增加:", (self._itemOldConfig.attack_percent or 0), index, true)
		-- self._ccbOwner.tf_old_value2:setString(self._itemOldConfig.enhance_max or "")
		local itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_old_icon:addChild(itemAvatar)
		itemAvatar:setEquipmentInfo(self._itemOldConfig, self._actorId)

		self._itemNewConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemNewId)
		local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._itemNewId)
		self._isShowHeroLevel = self._itemNewConfig.level > 1
		self._strengthLevel = itemCraftConfig.strengthen_levels or 0
		self._ccbOwner.node_hero_level:setVisible(self._isShowHeroLevel)
		self._ccbOwner.node_hero_strength:setVisible(self._strengthLevel > 0)

		self._ccbOwner.hero_icon_level:setString("LV"..self._itemNewConfig.level)
		self._ccbOwner.equip_icon_level:setString("LV"..self._strengthLevel)
		self._ccbOwner.tf_level:setString("魂师"..self._itemNewConfig.level.."级")
		self._ccbOwner.strength_level:setString("强化"..self._strengthLevel.."级")
		local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
		if self._itemNewConfig.level > heroInfo.level then
			self._ccbOwner.tf_level:setColor(COLORS.m)
		else
			self._ccbOwner.tf_level:setColor(COLORS.k)
		end
		if self._strengthLevel > self._equipmentInfo.info.level then
			self._ccbOwner.strength_level:setColor(COLORS.m)
		else
			self._ccbOwner.strength_level:setColor(COLORS.k)
		end

	    local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(self._actorId, self._itemNewId)
	    local level,color = remote.herosUtil:getBreakThrough(breaklevel) 
	    local name = self._itemNewConfig.name or " "
	    if level > 0 then
	    	name = name .. "＋".. level
	    end
		self._ccbOwner.tf_new_name:setString(name)
		local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		self._ccbOwner.tf_new_name:setColor(fontColor)
		self._ccbOwner.tf_new_name = setShadowByFontColor(self._ccbOwner.tf_new_name, fontColor)

		local index = 1
		index = self:setNewTFValue("生    命:", math.floor(self._itemNewConfig.hp_value or 0), index)
		index = self:setNewTFValue("攻    击:", math.floor(self._itemNewConfig.attack_value or 0), index)
		index = self:setNewTFValue("命    中:", math.floor(self._itemNewConfig.hit_rating or 0), index)
		index = self:setNewTFValue("闪    避:", math.floor(self._itemNewConfig.dodge_rating or 0), index)
		index = self:setNewTFValue("暴    击:", math.floor(self._itemNewConfig.critical_rating or 0), index)
		index = self:setNewTFValue("格    挡:", math.floor(self._itemNewConfig.block_rating or 0), index)
		index = self:setNewTFValue("急    速:", math.floor(self._itemNewConfig.haste_rating or 0), index)
		index = self:setNewTFValue("物理防御:", math.floor(self._itemNewConfig.armor_physical or 0), index)
		index = self:setNewTFValue("法术防御:", math.floor(self._itemNewConfig.armor_magic or 0), index)
		index = self:setNewTFValue("生命增加:", (self._itemNewConfig.hp_percent or 0), index, true)
		index = self:setNewTFValue("攻击增加:", (self._itemNewConfig.attack_percent or 0), index, true)
		-- self._ccbOwner.tf_new_value2:setString(self._itemNewConfig.enhance_max or "")
		local itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_new_icon:addChild(itemAvatar)
		itemAvatar:setEquipmentInfo(self._itemNewConfig, self._actorId)
		self:showComposite()
	end
end

function QUIWidgetHeroEquipmentEvolution:setOldTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_old_name"..index] ~= nil then
		self._ccbOwner["tf_old_name"..index]:setString(title)
		self._ccbOwner["tf_old_name"..index]:setVisible(true)
		self._ccbOwner["tf_old_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_old_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_old_value"..index]:setString(value)
		end
	end
	return index+1
end

function QUIWidgetHeroEquipmentEvolution:setNewTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_new_name"..index] ~= nil then
		self._ccbOwner["tf_new_name"..index]:setString(title)
		self._ccbOwner["tf_new_name"..index]:setVisible(true)
		self._ccbOwner["tf_new_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_new_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_new_value"..index]:setString(value)
		end
	end
	return index+1
end

--show composite node
function QUIWidgetHeroEquipmentEvolution:showComposite()
	if self.materials ~= nil and #self.materials > 0 then
		for _,item in ipairs(self.materials) do
			item:removeAllEventListeners()
			item:removeFromParent()
		end
		self.materials = {}
	end

	self:setNeedMoney()

	local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._itemNewId)
	if itemCraftConfig == nil then return end
	local items = {}
	if itemCraftConfig.money_type ~= nil then
		table.insert(items, {type = remote.items:getItemType(itemCraftConfig.money_type), count = itemCraftConfig.money_num})
	end
	local index = 1
	while true do
		local itemId = itemCraftConfig["component_id_"..index]
		local itemCount = itemCraftConfig["component_num_"..index]
		if itemId == nil then
			break
		end
		table.insert(items, {id = itemId, type = ITEM_TYPE.ITEM, count = itemCount})
		index = index + 1
	end
	for i=1,4 do
		self._ccbOwner["status"..i]:setVisible(false)
	end
	local itemCount = 1
	local totalCount = #items

	if self._strengthLevel > 0 then
		totalCount = totalCount + 1
	end

	if self._isShowHeroLevel == true then
		totalCount = totalCount + 1
		if self._ccbOwner["status"..totalCount.."_item"..itemCount] ~= nil then
			self._ccbOwner.node_hero_level:retain()
			self._ccbOwner.node_hero_level:removeFromParent()
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:setVisible(true)
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:addChild(self._ccbOwner.node_hero_level)
			self._ccbOwner.node_hero_level:setPosition(0,0)
			self._ccbOwner.node_hero_level:release()
		end
		itemCount = itemCount + 1
	end

	if self._strengthLevel > 0 then
		if self._ccbOwner["status"..totalCount.."_item"..itemCount] ~= nil then
			self._ccbOwner.node_hero_strength:retain()
			self._ccbOwner.node_hero_strength:removeFromParent()
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:setVisible(true)
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:addChild(self._ccbOwner.node_hero_strength)
			self._ccbOwner.node_hero_strength:setPosition(0,0)
			self._ccbOwner.node_hero_strength:release()
		end
		itemCount = itemCount + 1
	end

	if self._ccbOwner["status"..totalCount] then
		self._ccbOwner["status"..totalCount]:setVisible(true)
	end
	local itemBox
	for index,item in pairs(items) do
		if self._ccbOwner["status"..totalCount.."_item"..itemCount] ~= nil then
			itemBox = QUIWidgetHeroEquipmentEvolutionItem.new()
			itemBox:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._itemClickHandler))
			itemBox:setInfo(item.id, item.count, item.type)
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:setVisible(true)
			self._ccbOwner["status"..totalCount.."_item"..itemCount]:addChild(itemBox)
			table.insert(self.materials, itemBox)
			if self._isMaterilEnough == true then
				self._isMaterilEnough = itemBox:isEnough()
			end
		end
		itemCount = itemCount + 1
	end
end

function QUIWidgetHeroEquipmentEvolution:setNeedMoney()
	local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._itemNewId)
	if itemCraftConfig == nil then return end
	self._needMoney = itemCraftConfig.price or 0
	self._ccbOwner.tf_money:setString(self._needMoney)
	if self._needMoney > remote.user.money then
		self._ccbOwner.tf_money:setColor(COLORS.m)
	else
		self._ccbOwner.tf_money:setColor(COLORS.k)
	end
end

function QUIWidgetHeroEquipmentEvolution:onEvent(event)
	if event.name == remote.items.EVENT_ITEMS_UPDATE then
		self:showComposite()
	elseif event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self:setNeedMoney()
	end
end

function QUIWidgetHeroEquipmentEvolution:_itemClickHandler(event)
	app.sound:playSound("common_item")

	if event.itemType ~= ITEM_TYPE.ITEM then
		local dropType = nil
		if event.itemType == ITEM_TYPE.THUNDER_MONEY then
			dropType = ITEM_TYPE.THUNDER_MONEY
		elseif event.itemType == ITEM_TYPE.ARENA_MONEY then
			dropType = ITEM_TYPE.ARENA_MONEY
		end
		if dropType ~= nil then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, dropType)
    	end
		return
	end 

	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 then
		-- print("[Kumo] QUIWidgetHeroEquipmentEvolution (1)")
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemID, event.needNum)
	elseif self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		-- print("[Kumo] QUIWidgetHeroEquipmentEvolution (2)")
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemID, event.needNum)
	else
		-- print("[Kumo] QUIWidgetHeroEquipmentEvolution (3)")
		-- QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemID, event.needNum)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
    		options = {id = event.itemID, count = event.needNum}}, {isPopCurrentDialog = false})
	end
end

function QUIWidgetHeroEquipmentEvolution:_onComposeDialogCloseHandler(event)
	-- if self._composeDialog ~= nil then
	-- 	self._composeDialog:removeAllEventListeners()
	-- 	self._composeDialog = nil
	-- end
	if event.isCompose == true then
		local selectBox = nil
		for _,box in ipairs(self.materials) do
			if box:getItemId() == event.itemId then
				selectBox = box
			end
		end
		if selectBox ~= nil then
			self._composeAnimation = QUIWidgetAnimationPlayer.new()
			local p = selectBox:convertToWorldSpaceAR(ccp(0,0))
			p = self:convertToNodeSpaceAR(p)
			self._composeAnimation:setPosition(p.x, p.y)
			self:addChild(self._composeAnimation)
			self._composeAnimation:playAnimation("ccb/effects/EquipmentUpgarde.ccbi", nil, function ()
				self._composeAnimation = nil
			end)
            local arr = CCArray:create()
            arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
            arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
            arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
            arr:addObject(CCScaleTo:create(0.1,1,1))
            selectBox:runAction(CCSequence:create(arr))
		end
	end
end

function QUIWidgetHeroEquipmentEvolution:_onTriggerEvolution(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_break) == false then return end
	if self._canEvolution == false then 
		app.tip:floatTip("正在突破中～")
		return 
	end

	if self._needMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end

	if self._isMaterilEnough == false then
		local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._itemNewId)
		local money_type = itemCraftConfig.money_type
		local money_num = itemCraftConfig.money_num
		money_type = remote.items:getItemType(money_type)
		if money_type~=nil and (remote.user[money_type] or 0) < money_num then
			local moneyInfo = remote.items:getWalletByType(money_type)
			local dropType = ITEM_TYPE.THUNDER_MONEY
			if moneyInfo.name == "arenaMoney" then
				dropType = ITEM_TYPE.ARENA_MONEY
			end
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, dropType)
			-- app.tip:floatTip(moneyInfo.nativeName.."不足!")
			return
		end
		local index = 1
		while itemCraftConfig ~= nil and itemCraftConfig["component_id_"..index] ~= nil do
			local itemId = itemCraftConfig["component_id_"..index]
			local needNum = itemCraftConfig["component_num_"..index]
			local haveNum = remote.items:getItemsNumByID(itemId)
			if needNum > haveNum then
				break
			end
			index = index + 1
		end
		if itemCraftConfig ~= nil and itemCraftConfig["component_id_"..index] ~= nil  then
			if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 then
				QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, itemCraftConfig["component_id_"..index], itemCraftConfig["component_num_"..index])
			elseif self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
				QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, itemCraftConfig["component_id_"..index], itemCraftConfig["component_num_"..index])
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
					options = {id = itemCraftConfig["component_id_"..index], count = itemCraftConfig["component_num_"..index]}}, {isPopCurrentDialog = false})
			end
		end
		return
	end

	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
		local nextItemId = self._equipmentInfo.nextBreakInfo[self._equipmentInfo.pos]
		local nextItemConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(nextItemId)
		if heroInfo.breakthrough < (nextItemConfig.hero_break or 0) then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAlertBreak", 
				options = { typeName = QUIDialogAlertBreak.TYPE_ITEM, itemId = nextItemId, actorId = self._actorId}}, {isPopCurrentDialog = false})
			return 
		end
	end
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if self._itemNewConfig.level > heroInfo.level then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.HERO_LEVEL)
		return  
	end

	if self._strengthLevel > self._equipmentInfo.info.level then
		app.tip:floatTip("魂师大人，您的装备强化等级不足，请先去强化装备！")
		return
	end

	local masterType = "shipingtupo_master_"
	local oldUIModel = clone(remote.herosUtil:getUIHeroByID(self._actorId))
	local oldMasterLevel = oldUIModel:getMasterLevelByType(masterType)
	self._canEvolution = false
	app:getClient():heroEquipmentCraftRequest(self._actorId, self._itemNewId, function ()
		if self._ccbView then
			local masterUpGrade = nil
			local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	 		if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
				remote.user:addPropNumForKey("todayAdvancedBreakthroughCount")

				local newMasterLevel = newUIModel:getMasterLevelByType(masterType)
				masterUpGrade = newMasterLevel > oldMasterLevel and newMasterLevel or nil
	 		else
				remote.user:addPropNumForKey("todayEquipBreakthroughCount")
			end
			self:dispatchEvent({name = QUIWidgetHeroEquipmentEvolution.EVENT_EVOLUTION_SUCC})

			local successTip = app.master.JEWELRY_BREAK_TIP
			if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
				successTip = app.master.EQUIPMENT_BREAK_TIP
			end
			if app.master:getMasterShowState(successTip) then
		    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEquipmentBreakthroughSuccess", 
		        	options = {oldUIModel = oldUIModel, newUIModel = newUIModel, pos = self._equipmentPos, masterUpGrade = masterUpGrade, masterType = masterType, 
		        	successTip = successTip}}, {isPopCurrentDialog = false})
		    else
				local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
				if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
					dialog:_refreshBatlleForce( true )
				end
				if masterUpGrade ~= nil then
					app.master:upGradeMaster(masterUpGrade, masterType, self._actorId)
				end
		    end
		end
	end)

	self._canEvolutionScheduler = scheduler.performWithDelayGlobal(function()
			self._canEvolution = true
		end, 1)
end

function QUIWidgetHeroEquipmentEvolution:_breakSucc(oldUIModel, newUIModel, masterUpGrade, masterType)
	local oldEquipmentInfo = oldUIModel:getEquipmentInfoByPos(self._equipmentPos)
	local newEquipmentInfo = newUIModel:getEquipmentInfoByPos(self._equipmentPos)
	local oldItemConfig = QStaticDatabase:sharedDatabase():getItemByID(oldEquipmentInfo.info.itemId)
	local newItemConfig = QStaticDatabase:sharedDatabase():getItemByID(newEquipmentInfo.info.itemId)
	local prop = {}
	for _, v in ipairs(QActorProp._uiFields) do
		if oldItemConfig[v.fieldName] and newItemConfig[v.fieldName] then
			local value = newItemConfig[v.fieldName] - oldItemConfig[v.fieldName]
			if value > 0 then
				table.insert(prop, {name = v.name, value = value})
			end
		end
	end
	local ccbFile = "ccb/effects/Baoji.ccbi"
	local effectAni = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:addChild(effectAni)
	effectAni:setPosition(ccp(100, 0))
	effectAni:playAnimation(ccbFile, function()
			effectAni._ccbOwner.sp_baoji:setVisible(false)
			effectAni._ccbOwner.sp_tupo:setVisible(true)
			effectAni._ccbOwner.node_1:setVisible(true)
			effectAni._ccbOwner.node_2:setVisible(false)
			effectAni._ccbOwner.node_3:setVisible(false)
			effectAni._ccbOwner["tf_name1"]:setString("成功突破到："..(newItemConfig.name or ""))
			for i = 1, #prop do
				local value = prop[i].value
				if value < 1 then
					value = (value*100).."%"
				end
				effectAni._ccbOwner["node_"..(i+1)]:setVisible(true)
				effectAni._ccbOwner["tf_name"..(i+1)]:setString(prop[i].name .. "  ＋" .. value)
			end
		end, function ()
			local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
			if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
				dialog:_refreshBatlleForce( true )
			end
			if masterUpGrade ~= nil then
				app.tip:refreshTip()
				app.tip:masterTip(masterType, masterUpGrade)
			end
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_EQUIPMENT_BREAKTHROUGH})
		end)	
end

function QUIWidgetHeroEquipmentEvolution:_onTriggerClickLevel()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if self._itemNewConfig.level > heroInfo.level then
		app.tip:floatTip("魂师等级不足，请先将魂师升级到"..self._itemNewConfig.level.."级后再进行突破吧")
	else
		app.tip:floatTip("装备突破所需的魂师等级已经达到可以突破了")
	end
end

function QUIWidgetHeroEquipmentEvolution:_onTiggerClickStrength()
	if self._strengthLevel > self._equipmentInfo.info.level then
		app.tip:floatTip("装备强化等级不足，请先将装备强化到"..self._strengthLevel.."级后再进行突破吧")
	else
		app.tip:floatTip("装备突破所需的强化等级已经达到可以突破了")
	end
end

return QUIWidgetHeroEquipmentEvolution