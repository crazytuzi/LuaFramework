--
-- Author: qinyuanji
-- Date: 2015-03-5 17:08:35
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEquipmentCompose = class("QUIWidgetEquipmentCompose", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QQuickWay = import("...utils.QQuickWay")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIWidgetEquipmentCompose.NEW_EQUIPMENT_SELECTED = "NEW_EQUIPMENT_SELECTED"
QUIWidgetEquipmentCompose.EQUIPMENT_COMPOSED = "EQUIPMENT_COMPOSED"
QUIWidgetEquipmentCompose.EQUIPMENT_START_COMPOSED = "EQUIPMENT_START_COMPOSED"
QUIWidgetEquipmentCompose.EQUIPMENT_END_COMPOSED = "EQUIPMENT_END_COMPOSED"

function QUIWidgetEquipmentCompose:ctor(options)
	local ccbFile = "ccb/Widget_HeroEquipment_compose.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerCompose", callback = handler(self, QUIWidgetEquipmentCompose._onTriggerCompose)},
		}
	QUIWidgetEquipmentCompose.super.ctor(self,ccbFile,callBacks,options)

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    assert(options.id, "Invalid equipment id")
    self:setInfo(options.id)
    self._isCompose = false
end

function QUIWidgetEquipmentCompose:onEnter()
	QUIWidgetEquipmentCompose.super.onEnter(self)
end

function QUIWidgetEquipmentCompose:onExit()
	QUIWidgetEquipmentCompose.super.onExit(self)

	self:removeAllEventListeners()

	if self._scheduler then scheduler.unscheduleGlobal(self._scheduler) end
end

function QUIWidgetEquipmentCompose:setPrice(price)
	self._ccbOwner.tf_money:setString(price)
	if price >= 100000 then
		local tmp = math.log10(price/100000) + 1
		self._ccbOwner.tf_money:setScale(5/(5 + tmp))
	end

	if price > remote.user.money then
		self._ccbOwner.tf_money:setColor(COLORS.m)
	else
		self._ccbOwner.tf_money:setColor(COLORS.k)
	end
end

function QUIWidgetEquipmentCompose:setInfo(equipmentId)
    local item = QUIWidgetItemsBox.new()
    item:setGoodsInfo(equipmentId, ITEM_TYPE.ITEM, 0)
    item:setScale(0.8)
    self._ccbOwner.source:addChild(item)

    local materials = {}
	local item_craft = QStaticDatabase:sharedDatabase():getItemCraftByItemId(equipmentId)
	self:setPrice(item_craft.price)
	if item_craft["component_id_3"] then
		self._ccbOwner.branch1:setVisible(false)
		self._ccbOwner.branch2:setVisible(false)
		self._ccbOwner.branch3:setVisible(true)
		for i = 1, 3 do 
			if item_craft["component_id_"..i] then
				local material = QUIWidgetHeroEquipmentEvolutionItem.new()
				-- material:setBgDark(true)
				material:setInfo(item_craft["component_id_"..i],item_craft["component_num_"..i])
				material:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._subEquipmentSelected))
				self._ccbOwner["item3_"..i]:removeAllChildren()
    			self._ccbOwner["item3_"..i]:setScale(0.8)
				self._ccbOwner["item3_"..i]:addChild(material)

				local pos = material:convertToWorldSpaceAR(ccp(0,0))
				table.insert(materials, {id = item_craft["component_id_"..i], pos = pos})
			end
		end
	elseif item_craft["component_id_2"] then
		self._ccbOwner.branch1:setVisible(false)
		self._ccbOwner.branch2:setVisible(true)
		self._ccbOwner.branch3:setVisible(false)
		for i = 1, 2 do 
			if item_craft["component_id_"..i] then
				local material = QUIWidgetHeroEquipmentEvolutionItem.new()
				-- material:setBgDark(true)
				material:setInfo(item_craft["component_id_"..i],item_craft["component_num_"..i])
				material:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._subEquipmentSelected))
				self._ccbOwner["item2_"..i]:removeAllChildren()
				self._ccbOwner["item2_"..i]:addChild(material)
    			self._ccbOwner["item2_"..i]:setScale(0.8)

				local pos = material:convertToWorldSpaceAR(ccp(0,0))
				table.insert(materials, {id = item_craft["component_id_"..i], pos = pos})
			end
		end
	else
		self._ccbOwner.branch1:setVisible(true)
		self._ccbOwner.branch2:setVisible(false)
		self._ccbOwner.branch3:setVisible(false)
		for i = 1, 1 do 
			if item_craft["component_id_"..i] then
				local material = QUIWidgetHeroEquipmentEvolutionItem.new()
				-- material:setBgDark(true)
				material:setInfo(item_craft["component_id_"..i],item_craft["component_num_"..i])
				material:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._subEquipmentSelected))
				self._ccbOwner["item1_"..i]:removeAllChildren()
				self._ccbOwner["item1_"..i]:addChild(material)
    			self._ccbOwner["item1_"..i]:setScale(0.8)

				local pos = material:convertToWorldSpaceAR(ccp(0,0))
				table.insert(materials, {id = item_craft["component_id_"..i], pos = pos})
			end
		end
	end

	self._onTriggerComposeImple = function()
		if self._isCompose == true then return end
		for i = 1, 3 do 
			if item_craft["component_id_" .. i] then
				if item_craft["component_num_"..i] > remote.items:getItemsNumByID(item_craft["component_id_"..i]) then
					-- QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, item_craft["component_id_"..i], item_craft["component_num_"..i], nil, nil, "道具合成数量不足，请查看获取途径~")
					-- app.tip:floatTip("合成材料不足")
					self:dispatchEvent({name = QUIWidgetEquipmentCompose.NEW_EQUIPMENT_SELECTED, id = item_craft["component_id_"..i], count = item_craft["component_num_"..i]})
					return
				end
			end
		end

		if item_craft.price > remote.user.money then
			-- app.tip:floatTip("合成费用不足")
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return
		end
		self._isCompose = true 
		self:dispatchEvent({name = QUIWidgetEquipmentCompose.EQUIPMENT_START_COMPOSED})

		local callback = function ()
			if self.class then
				self:_playComposeAnimation(materials, self._ccbOwner.source, function ( ... )
					self:setInfo(equipmentId)
					self:dispatchEvent({name = QUIWidgetEquipmentCompose.EQUIPMENT_COMPOSED, id = equipmentId})
				end, function (...)
					self:dispatchEvent({name = QUIWidgetEquipmentCompose.EQUIPMENT_END_COMPOSED})
				end)
			end
		end

		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(equipmentId)
		if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE then
			remote.gemstone:gemstoneComposeRequest(equipmentId, callback)
		else
			app:getClient():itemCraftRequest(equipmentId, callback)
		end
	end
end

function QUIWidgetEquipmentCompose:getIsCompose()
	return self._isCompose == true
end

function QUIWidgetEquipmentCompose:_playComposeAnimation(materials, target, endCallback)
	local targetP = ccp(target:getPositionX(), target:getPositionY())
	for k, v in ipairs(materials) do
		local material = QUIWidgetHeroEquipmentEvolutionItem.new()
		material:setInfo(v.id)
		material:setPosition(v.pos)
		self:getView():addChild(material)

		local arr = CCArray:create()
	    arr:addObject(CCMoveTo:create(0.2, targetP))
	    arr:addObject(CCCallFunc:create(function()
	            material:removeFromParentAndCleanup(true)
	        end))
	    local seq = CCSequence:create(arr)
	    material:runAction(seq)
	end

	self._scheduler = scheduler.performWithDelayGlobal(function ( ... )
	    local effect = QUIWidgetAnimationPlayer.new()
	    target:addChild(effect)
	    effect:playAnimation("effects/UseItem3.ccbi", nil, function()
				endCallback()	            
	        end)
	end, 0.18)
end

function QUIWidgetEquipmentCompose:_subEquipmentSelected(event)
	self:dispatchEvent({name = QUIWidgetEquipmentCompose.NEW_EQUIPMENT_SELECTED, id = event.itemID, count = event.needNum})
end

function QUIWidgetEquipmentCompose:_onTriggerCompose(event)
	if q.buttonEventShadow(event, self._ccbOwner.compose_btn) == false then return end

	app.sound:playSound("common_confirm")
	self:_onTriggerComposeImple()
end

return QUIWidgetEquipmentCompose