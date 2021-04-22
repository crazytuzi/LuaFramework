--
-- Author: xurui
-- Date: 2015-10-28 19:53:19
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMasterCell = class("QUIWidgetMasterCell", QUIWidget)

local QUIHeroModel = import("...models.QUIHeroModel")

QUIWidgetMasterCell.EVENT_CLICK_BOX = "EVENT_CLICK_BOX"

function QUIWidgetMasterCell:ctor(options)
	local ccbFile = "ccb/widget_Equipmaster3.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
	}
	QUIWidgetMasterCell.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.name:setString("")
	self._ccbOwner.level:setString("")
	self._ccbOwner.level_bar:setScaleX(0)

    self._ccbOwner.sp_gray:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_gray:setColor(ccc3(0, 0, 0))
    self._ccbOwner.sp_gray:setOpacity(0.3 * 255)

end

function QUIWidgetMasterCell:onExit()
	QUIWidgetMasterCell.super.onExit(self)
	self:removeAllEventListeners()
end

function QUIWidgetMasterCell:setItemInfo(itemInfo, equipmentInfo, nextMasterInfo, masterType, canStrengthen)
	self._itemInfo = itemInfo
	self._equipmentInfo = equipmentInfo
	self._nextMasterInfo = nextMasterInfo

	if itemInfo ~= nil then
		self._ccbOwner.name:setString(self._itemInfo.name)
		local icon = CCSprite:create()
		icon:setTexture(CCTextureCache:sharedTextureCache():addImage(self._itemInfo.icon_1))
		if masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			icon:setScale(0.7)
		end
		self._ccbOwner.icon_node:addChild(icon)
	end
	if canStrengthen then
		self._ccbOwner.sp_canStrengh:setVisible(true)
	else
		self._ccbOwner.sp_canStrengh:setVisible(false)
	end

	if self._nextMasterInfo ~= nil and next(self._nextMasterInfo) then
		local nowLevel = (self._equipmentInfo and self._equipmentInfo.info) and (self._equipmentInfo.info.level or 0) or 0
		if masterType == QUIHeroModel.EQUIPMENT_ENCHANT_MASTER or  masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
			nowLevel = self._equipmentInfo.info.enchants or 0
		elseif masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
			nowLevel = self._equipmentInfo.breakLevel or 0
		elseif masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
			nowLevel = self._equipmentInfo.info.craftLevel or 0
		elseif masterType == QUIHeroModel.GEMSTONE_MASTER then
			nowLevel = self._equipmentInfo.info.level or 0
		elseif masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			nowLevel = self._equipmentInfo.level or 0
		end

		local level = nowLevel.."/"..self._nextMasterInfo.condition
		self._ccbOwner.level:setString(level)

		local scaleX = tonumber(nowLevel)/tonumber(self._nextMasterInfo.condition)
		scaleX = scaleX > 1 and 1 or scaleX
		self._ccbOwner.level_bar:setScaleX(scaleX)
	end
end 

function QUIWidgetMasterCell:setForceIcon(state)
	self._ccbOwner.force_icon:setVisible(state or false)
end

function QUIWidgetMasterCell:setForceInfo(newForce, maxForce)
	self._ccbOwner.level:setString(newForce.."/"..maxForce)
	local scaleX = newForce/maxForce
	scaleX = scaleX > 1 and 1 or scaleX
	self._ccbOwner.level_bar:setScaleX(scaleX)
	self._ccbOwner.name:setString("培养战力")
end

function QUIWidgetMasterCell:showEmpty(nextMasterInfo, masterType)
	self._ccbOwner.name:setString("未装备")
	self._ccbOwner.name:setColor(UNITY_COLOR.red)
	self._ccbOwner.node_lock:setVisible(true)
	self._ccbOwner.sp_gray:setVisible(true)
	
	local level = "0/"..nextMasterInfo.condition
	self._ccbOwner.level:setString(level)
	if masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER then
		self._ccbOwner.sp_gemstone_bg:setVisible(false)
		self._ccbOwner.sp_spar_bg:setVisible(true)
		self._ccbOwner.sp_magicHerb_bg:setVisible(false)
	elseif masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
		self._ccbOwner.sp_gemstone_bg:setVisible(false)
		self._ccbOwner.sp_spar_bg:setVisible(false)
		self._ccbOwner.sp_magicHerb_bg:setVisible(true)
	else
		self._ccbOwner.sp_gemstone_bg:setVisible(true)
		self._ccbOwner.sp_spar_bg:setVisible(false)
		self._ccbOwner.sp_magicHerb_bg:setVisible(false)
	end 
end

function QUIWidgetMasterCell:setType(equipName)
	self._equipName = equipName
end

function QUIWidgetMasterCell:getType()
	return self._equipName
end

function QUIWidgetMasterCell:_onTriggerClick()
	local itemId = nil
	if self._itemInfo ~= nil then
		itemId = self._itemInfo.id or nil
	end
	self:dispatchEvent({name = QUIWidgetMasterCell.EVENT_CLICK_BOX, euqipPos = self._equipName, itemId = itemId})
end

return QUIWidgetMasterCell