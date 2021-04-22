-- @Author: xurui
-- @Date:   2016-12-24 12:27:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 15:25:55
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetShipBox = class("QUIWidgetShipBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetShipBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetShipBox:ctor(options)
	local ccbFile = "ccb/effects/haishang_chuan2.ccbi"
	if options and options.isBig then
		ccbFile = "ccb/effects/haishang_chuan.ccbi"
		self._isBigShip = options.isBig
	end
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetShipBox.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._oldShipId = nil
	
	self:resetAll()
end

function QUIWidgetShipBox:resetAll()
	for i = 1, 6 do
		self._ccbOwner["node_ship_"..i]:setVisible(false)
	end
end

function QUIWidgetShipBox:onEnter()
end

function QUIWidgetShipBox:onExit()
end

function QUIWidgetShipBox:setShipInfo(ship, index, isStatic)
	self._shipInfo = ship
	self._index = index

	self:setShipSpriteFrame(self._shipInfo.shipId)

	if ship.isMy ~= nil then
		self:setSelectState(ship.isMy, isStatic)
	end
end

function QUIWidgetShipBox:setShipSpriteFrame(shipId)
	if shipId == nil then return end

	for i = 1, 6 do
		self._ccbOwner["node_ship_"..i]:setVisible(false)
	end
	
	self._ccbOwner["node_ship_"..shipId]:setVisible(true)
	self._ccbOwner["sp_ship_"..shipId]:setVisible(true)

	if self._isBigShip ~= true then
		local startPosY = -math.random(0, 20) - 20
		self._ccbOwner["sp_ship_"..shipId]:setPositionY(startPosY)
		self:setShipEffect(self._ccbOwner["sp_ship_"..shipId], startPosY)

		if self._oldShipId == nil or self._oldShipId ~= shipId then
			self._ccbOwner.node_achieve:retain()
			self._ccbOwner.node_achieve:removeFromParent()
			self._ccbOwner["sp_ship_"..shipId]:addChild(self._ccbOwner.node_achieve)
			self._ccbOwner.node_achieve:release()
			self._ccbOwner.node_achieve:setScale(1.4)
			self._ccbOwner.node_achieve:setPosition(ccp(90, 165))
			self._oldShipId = shipId
		end
	end
end

function QUIWidgetShipBox:setShipEffect(shipNode, startPosY)
	local offsetY = -40-startPosY

	local effectFunc
	effectFunc = function()
		local effectArray = CCArray:create()
		effectArray:addObject(CCMoveBy:create(math.abs(offsetY/20), ccp(0, offsetY)))
		effectArray:addObject(CCMoveBy:create(1, ccp(0, 20)))
		effectArray:addObject(CCCallFunc:create(function()
				if offsetY ~= -20 then
					offsetY = -20
				end
				shipNode:stopAllActions()
				effectFunc()
			end))

		shipNode:runAction(CCSequence:create(effectArray))
	end 
	effectFunc()
end

function QUIWidgetShipBox:getShipInfo()
	return self._shipInfo
end

function QUIWidgetShipBox:setSelectState(state, isStatic)
	if not self._shipInfo.shipId then
		return
	end
	if state == nil then state = false end
	if state then
		q.makeButtonLight(self._ccbOwner["sp_ship_"..self._shipInfo.shipId])
	else
		q.makeButtonNormal(self._ccbOwner["sp_ship_"..self._shipInfo.shipId])
	end

	if self._isBigShip and isStatic then
		self._ccbOwner["node_ship_"..self._shipInfo.shipId]:setVisible(state)
		self._ccbOwner["ndoe_static_ship_"..self._shipInfo.shipId]:setVisible(not state)
	end
end

function QUIWidgetShipBox:setGrayState(state)
	if state == nil then state = false end

	self._ccbOwner.node_achieve:setVisible(state)
	if state then
		self._ccbOwner["sp_ship_"..self._shipInfo.shipId]:setColor(COLORS.f)
	else
		self._ccbOwner["sp_ship_"..self._shipInfo.shipId]:setColor(COLORS.A)
	end
end

function QUIWidgetShipBox:getContentSize()
	return self._ccbOwner.btn_click_ship:getContentSize()
end

function QUIWidgetShipBox:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetShipBox.EVENT_CLICK, shipInfo = self._shipInfo, index = self._index})
end

return QUIWidgetShipBox