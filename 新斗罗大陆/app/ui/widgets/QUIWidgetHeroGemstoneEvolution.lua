local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneEvolution = class("QUIWidgetHeroGemstoneEvolution", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGemstoneEvolutionMaxLevel = import("..widgets.QUIWidgetGemstoneEvolutionMaxLevel")
local QUIWidgetGemstoneEvolutionLevelLimit = import("..widgets.QUIWidgetGemstoneEvolutionLevelLimit")
local QUIHeroModel = import("...models.QUIHeroModel")

function QUIWidgetHeroGemstoneEvolution:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_tupo1.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerEvolution", callback = handler(self, self._onTriggerEvolution)},
		}
	QUIWidgetHeroGemstoneEvolution.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.materials = {}
end

function QUIWidgetHeroGemstoneEvolution:onExit()
	QUIWidgetHeroGemstoneEvolution.super.onExit(self)
	if self._dialog ~= nil then
		self._dialog:removeAllEventListeners()
		self._dialog = nil
	end
end



function QUIWidgetHeroGemstoneEvolution:setInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
	
	local breakconfig1 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel)
	local breakconfig2 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(gemstone.itemId, gemstone.craftLevel+1)



	if q.isEmpty(breakconfig2) then --已经突破到顶级了
		self._ccbOwner.node_composite:setVisible(false)
		self._ccbOwner.tf_break_tips:setVisible(false)
		if self._maxWidget == nil then
			self._maxWidget = QUIWidgetGemstoneEvolutionMaxLevel.new()
			self:getView():addChild(self._maxWidget)
		end
		self._maxWidget:setInfo(actorId, gemstoneSid, gemstonePos, "TAB_EVOLUTION")
		if self._limitWidget ~= nil then
			self._limitWidget:removeFromParent()
			self._limitWidget = nil
		end		
		return
	end


	local mixlevel = gemstone.mix_level or 0
	if gemstone.godLevel < GEMSTONE_MAXADVANCED_LEVEL and mixlevel <= 0  and gemstone.craftLevel >= S_GEMSTONE_MAXEVOLUTION_LEVEL then

		self._ccbOwner.node_composite:setVisible(false)
		self._ccbOwner.tf_break_tips:setVisible(false)
		if self._limitWidget == nil then
			self._limitWidget = QUIWidgetGemstoneEvolutionLevelLimit.new()
			self._limitWidget:setPositionX(-146)
			self:getView():addChild(self._limitWidget)
		end
		self._limitWidget:setInfo(actorId, gemstoneSid, gemstonePos)
		if self._maxWidget ~= nil then
			self._maxWidget:removeFromParent()
			self._maxWidget = nil
		end

		return
	end

	if self._maxWidget ~= nil then
		self._maxWidget:removeFromParent()
		self._maxWidget = nil
	end

	if self._limitWidget ~= nil then
		self._limitWidget:removeFromParent()
		self._limitWidget = nil
	end

	self._ccbOwner.node_composite:setVisible(true)



	self._ccbOwner.node_composite:setVisible(true)
	self._ccbOwner.tf_break_tips:setVisible(false)
	self._needMoney = breakconfig2.price or 0
	self._ccbOwner.tf_money:setString(self._needMoney)
	if self._needMoney > remote.user.money then
		self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_money:setColor(COLORS.k)
	end
	local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	--设置老属性
    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local name = itemConfig.name
	local mixLevel = gemstone.mix_level or 0
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_old_name:setString(name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_old_name:setColor(fontColor)
	self._ccbOwner.tf_old_name = setShadowByFontColor(self._ccbOwner.tf_old_name, fontColor)

	local index = 1
	index = self:setOldTFValue("生    命:", math.floor(breakconfig1.hp_value or 0), index)
	index = self:setOldTFValue("攻    击:", math.floor(breakconfig1.attack_value or 0), index)
	index = self:setOldTFValue("命    中:", math.floor(breakconfig1.hit_rating or 0), index)
	index = self:setOldTFValue("闪    避:", math.floor(breakconfig1.dodge_rating or 0), index)
	index = self:setOldTFValue("暴    击:", math.floor(breakconfig1.critical_rating or 0), index)
	index = self:setOldTFValue("格    挡:", math.floor(breakconfig1.block_rating or 0), index)
	index = self:setOldTFValue("急    速:", math.floor(breakconfig1.haste_rating or 0), index)
	index = self:setOldTFValue("物理防御:", math.floor(breakconfig1.armor_physical or 0), index)
	index = self:setOldTFValue("法术防御:", math.floor(breakconfig1.armor_magic or 0), index)
	index = self:setOldTFValue("生命增加:", (breakconfig1.hp_percent or 0), index, true)
	index = self:setOldTFValue("攻击增加:", (breakconfig1.attack_percent or 0), index, true)
	index = self:setOldTFValue("物防增加:", (breakconfig1.armor_physical_percent or 0), index, true)
	index = self:setOldTFValue("法防增加:", (breakconfig1.armor_magic_percent or 0), index, true)

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_old_icon:addChild(itemAvatar)
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,advancedLevel, gemstone.mix_level)

	--设置新属性
    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel+1) 
    name = itemConfig.name
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_new_name:setString(name)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_new_name:setColor(fontColor)
	self._ccbOwner.tf_new_name = setShadowByFontColor(self._ccbOwner.tf_new_name, fontColor)
	
	local index = 1
	index = self:setNewTFValue("生    命:", math.floor(breakconfig2.hp_value or 0), index)
	index = self:setNewTFValue("攻    击:", math.floor(breakconfig2.attack_value or 0), index)
	index = self:setNewTFValue("命    中:", math.floor(breakconfig2.hit_rating or 0), index)
	index = self:setNewTFValue("闪    避:", math.floor(breakconfig2.dodge_rating or 0), index)
	index = self:setNewTFValue("暴    击:", math.floor(breakconfig2.critical_rating or 0), index)
	index = self:setNewTFValue("格    挡:", math.floor(breakconfig2.block_rating or 0), index)
	index = self:setNewTFValue("急    速:", math.floor(breakconfig2.haste_rating or 0), index)
	index = self:setNewTFValue("物理防御:", math.floor(breakconfig2.armor_physical or 0), index)
	index = self:setNewTFValue("法术防御:", math.floor(breakconfig2.armor_magic or 0), index)
	index = self:setNewTFValue("生命增加:", (breakconfig2.hp_percent or 0), index, true)
	index = self:setNewTFValue("攻击增加:", (breakconfig2.attack_percent or 0), index, true)
	index = self:setNewTFValue("物防增加:", (breakconfig2.armor_physical_percent or 0), index, true)
	index = self:setNewTFValue("法防增加:", (breakconfig2.armor_magic_percent or 0), index, true)

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_new_icon:addChild(itemAvatar)
	itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel+1,1.0,advancedLevel, gemstone.mix_level)

	--突破所需材料
	local items = {}
	if breakconfig2.money_type ~= nil then
		table.insert(items, {type = remote.items:getItemType(breakconfig2.money_type), count = breakconfig2.money_num})
	end
	local index = 1
	while true do
		local itemId = breakconfig2["component_id_"..index]
		local itemCount = breakconfig2["component_num_"..index]
		if itemId == nil then
			break
		end
		table.insert(items, {id = itemId, type = ITEM_TYPE.ITEM, count = itemCount})
		index = index + 1
	end
	local posX = -(#items - 1) * 153/2
	local itemBox = nil
	self._needMateril = nil
	for index,item in ipairs(items) do
		itemBox = QUIWidgetHeroEquipmentEvolutionItem.new()
		itemBox:setPositionX(posX)
		itemBox:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._itemClickHandler))
		itemBox:setInfo(item.id, item.count, item.type)
		self._ccbOwner.node_item:setVisible(true)
		self._ccbOwner.node_item:addChild(itemBox)
		table.insert(self.materials, itemBox)
		posX = posX + 153
		if self._isMaterilEnough == true then
			self._isMaterilEnough = itemBox:isEnough()
			if self._isMaterilEnough == false then
				self._needMateril = item
			end
		end
	end
end

function QUIWidgetHeroGemstoneEvolution:setOldTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_old_name"..index] ~= nil then
		self._ccbOwner["tf_old_name"..index]:setString(title)
		self._ccbOwner["tf_old_name"..index]:setVisible(true)
		self._ccbOwner["tf_old_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_old_value"..index]:setString("+"..string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_old_value"..index]:setString("+"..value)
		end
	end
	return index+1
end

function QUIWidgetHeroGemstoneEvolution:setNewTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_new_name"..index] ~= nil then
		self._ccbOwner["tf_new_name"..index]:setString(title)
		self._ccbOwner["tf_new_name"..index]:setVisible(true)
		self._ccbOwner["tf_new_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_new_value"..index]:setString("+"..string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_new_value"..index]:setString("+"..value)
		end
	end
	return index+1
end

function QUIWidgetHeroGemstoneEvolution:resetAll()
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

function QUIWidgetHeroGemstoneEvolution:quickWayHandler(id, itemType, count)
	if itemType ~= ITEM_TYPE.ITEM then
		local dropType = nil
		if itemType == ITEM_TYPE.THUNDER_MONEY then
			dropType = ITEM_TYPE.THUNDER_MONEY
		elseif itemType == ITEM_TYPE.ARENA_MONEY then
			dropType = ITEM_TYPE.ARENA_MONEY
		end
		if dropType ~= nil then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, dropType)
    	end
		return
	end 

	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, id, count)
	elseif self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, id, count)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
    		options = {id = id, count = count}}, {isPopCurrentDialog = false})
	end
end

function QUIWidgetHeroGemstoneEvolution:_onTriggerEvolution(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_break) == false then return end
	if self._needMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end

	if self._isMaterilEnough == false then
		self:quickWayHandler(self._needMateril.id, self._needMateril.type, self._needMateril.count)
		return 
	end

	local oldUIModel = clone(remote.herosUtil:getUIHeroByID(self._actorId))
	remote.gemstone:gemstoneCraftRequest(self._gemstoneSid, function ()
		if not self._actorId then
			return
		end
		
		local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
		local successTip = app.master.GEMSTONE_BREAK_TIP
		if app.master:getMasterShowState(successTip) then
    		self._dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBreakthroughSuccess", 
        	options = {oldUIModel = oldUIModel, newUIModel = newUIModel, pos = self._gemstonePos, successTip = successTip}}, {isPopCurrentDialog = false})
        	if self._dialog then
    			self._dialog:addEventListener(self._dialog.EVENT_CLOSE, function (e)
	    			self._dialog:removeAllEventListeners()
	    			self._dialog = nil

					local oldBreakMaster = oldUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
					local newBreakMaster = newUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
					if newBreakMaster > oldBreakMaster then
						app.master:upGradeGemstoneMaster(oldBreakMaster, newBreakMaster, QUIHeroModel.GEMSTONE_BREAK_MASTER, self._actorId)
					end
	    		end)
	    	end
	    else
	    	local oldBreakMaster = oldUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
			local newBreakMaster = newUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
			if newBreakMaster > oldBreakMaster then
				app.master:upGradeGemstoneMaster(oldBreakMaster, newBreakMaster, QUIHeroModel.GEMSTONE_BREAK_MASTER, self._actorId)
			end	
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	    end

	end)
end

function QUIWidgetHeroGemstoneEvolution:_itemClickHandler(event)
	app.sound:playSound("common_item")
	self:quickWayHandler(event.itemID, event.itemType, event.needNum)
end

return QUIWidgetHeroGemstoneEvolution