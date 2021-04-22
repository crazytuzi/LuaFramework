--
-- Author: Your Name
-- Date: 2014-06-05 15:22:02
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroEquipment = class("QUIWidgetHeroEquipment",QUIWidget)

local QRemote = import("...models.QRemote")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentBox = import(".QUIWidgetEquipmentBox")
local QUIHeroModel = import("...models.QUIHeroModel")

function QUIWidgetHeroEquipment:ctor(options)
	QUIWidgetHeroEquipment.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._equipBoxs = {}
	self._isAllWear = false
	if options then
		self._isDisplay = options.isDisplay
	end
end


function QUIWidgetHeroEquipment:onEnter()
    -- self._remoteProxy = cc.EventProxy.new(remote)
    -- self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self._onEvent))
end

function QUIWidgetHeroEquipment:onExit()
	self:removeBoxEvent()
 --    self._remoteProxy:removeAllEventListeners()
end

--设置UI
function QUIWidgetHeroEquipment:setUI(equipBoxs)
	self:removeBoxEvent()
	self._equipBoxs = equipBoxs
	self:addBoxEvent()
end

--设置魂师
function QUIWidgetHeroEquipment:setHero(actorId)
	self._actorId = actorId
	self:refreshBox()
end

--刷新装备显示
function QUIWidgetHeroEquipment:refreshBox()
	self:_removeAll()
	self._hero = remote.herosUtil:getHeroByID(self._actorId)
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	for _,box in pairs(self._equipBoxs) do 
		local equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(box:getType())
		box:resetAll()
		if equipmentInfo ~= nil then
			local itemId = equipmentInfo.info.itemId
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
			box:setEquipmentInfo(itemInfo, self._actorId)
			--设置装备的突破等级
			if box.setEvolution ~= nil then
				box:setEvolution(equipmentInfo.breakLevel)
			end

			if not self._isDisplay then
				if equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_NONE then

				elseif equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_BREAK then
					if box.showCanEvolution ~= nil then
						local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(equipmentInfo.nextBreakInfo[box:getType()])
						local targetItem = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.nextBreakInfo[equipmentInfo.pos])
						local b = (self._hero.level>= (targetItem.level or 0))
						if itemCraftConfig.price <= remote.user.money then
							box:showCanEvolution(b)
						end
					end
				elseif equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_CHALLENGE then
					box:showCanChallenge(true)
				elseif equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_DROP then
					box:showCanDrop(true)
				elseif equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_COMPOSE then

				end
			end

			-- 检查装备是否可以觉醒
			if not self._isDisplay and app.unlock:getUnlockEnchant() and remote.herosUtil:checkEquipmentEnchantById(self._actorId, itemId) then
				box:showCanEnchant(true)
			else
				box:showCanEnchant(false)
			end

			local equipment = remote.herosUtil:getWearByItem(self._actorId, itemId) -- suspect of refresh overhead

			if box.showEnchantIcon ~= nil then
				box:showEnchantIcon(true, equipment.enchants or 0, 0.7)
			end
			
			box:setIsLock(false)
			
			if self._isDisplay then
				box:showStrengthenLevelIcon(true, equipmentInfo.info.level or 1)
			else
				local showStrengthenLevel = false
				if box:getType() == EQUIPMENT_TYPE.JEWELRY1 or box:getType() == EQUIPMENT_TYPE.JEWELRY2 then
					showStrengthenLevel = app.unlock:getUnlockEnhanceAdvanced()
				else
					showStrengthenLevel = app.unlock:getUnlockEnhance()
				end
				if showStrengthenLevel then
					box:showStrengthenLevelIcon(true, equipmentInfo.info.level)
				end
			end
		else
			--未解锁
			box:setIsLock(true)
			box:showCanStrengthen(false)
		end
	end
end

function QUIWidgetHeroEquipment:addBoxEvent()
	for _,box in pairs(self._equipBoxs) do 
		if box.addEventListener then
			box:addEventListener(QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK, handler(self, self._onEvent))
		end
	end
end

function QUIWidgetHeroEquipment:removeBoxEvent()
	if self._equipBoxs then
		for _,box in pairs(self._equipBoxs) do 
			if box.removeAllEventListeners then
				box:removeAllEventListeners()
			end
		end
	end
end

function QUIWidgetHeroEquipment:_onEvent(event)
	if event.name == QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK then
		self:dispatchEvent(event)

	elseif event.name == QRemote.HERO_UPDATE_EVENT then
		if self._actorId ~= nil then
			self:setHero(self._actorId)
		end
	end
end

function QUIWidgetHeroEquipment:_removeAll()
	if self._equipBoxs == nil then return end
	for _,box in pairs(self._equipBoxs) do 
		box:resetAll()
	end
end

function QUIWidgetHeroEquipment:showGreenState()
	if self._equipBoxs == nil then return end
	for _,box in pairs(self._equipBoxs) do 
		box:showState(true)
	end
end

return QUIWidgetHeroEquipment