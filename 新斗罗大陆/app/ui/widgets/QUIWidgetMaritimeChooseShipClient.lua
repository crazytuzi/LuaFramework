-- @Author: xurui
-- @Date:   2016-12-27 15:33:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-12 18:18:36
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaritimeChooseShipClient = class("QUIWidgetMaritimeChooseShipClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetShipBox = import("..widgets.QUIWidgetShipBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetMaritimeChooseShipClient:ctor(options)
	local ccbFile = "ccb/Widget_haishang_ship.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetMaritimeChooseShipClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._baseValue = configuration["maritime_base_value"].value

   	self._ccbOwner.sp_static_gray:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_static_gray:setColor(ccc3(0, 0, 0))
    self._ccbOwner.sp_static_gray:setOpacity(0.5 * 255)	
end

function QUIWidgetMaritimeChooseShipClient:onEnter()
end

function QUIWidgetMaritimeChooseShipClient:onExit()
	if self._refreshEffect ~= nil then
		self._refreshEffect:stopAnimation()
		self._refreshEffect = nil
	end
end

function QUIWidgetMaritimeChooseShipClient:getInfo()
	return self._info
end

function QUIWidgetMaritimeChooseShipClient:setInfo(param)
    self._info = param or {}

	self._shipId = param.shipId
	self._isMy = param.isMy


	if self._shipBox == nil then
		self._shipBox = QUIWidgetShipBox.new({isBig = true})
		self._ccbOwner.node_ship:addChild(self._shipBox)
	end
	self._shipBox:setShipInfo({shipId = self._shipId, isMy = self._isMy}, i, false)
	self:setSelectState()

	local ships = remote.maritime:getMaritimeShipInfoByShipId(self._shipId)
	self._ccbOwner.tf_use_time:setString("耗时："..(ships.ship_transportation_time or 0).."分钟")
	self._ccbOwner.tf_ship_name:setString(ships.ship_name or "")
	local color = ships.ship_colour or 2

	self._ccbOwner.tf_ship_name:enableOutline(true)
	local fontColor = EQUIPMENT_COLOR[color]
	self._ccbOwner.tf_ship_name:setColor(fontColor)
	self._ccbOwner.tf_ship_name = setShadowByFontColor(self._ccbOwner.tf_ship_name, fontColor)


	self._shipAwards = remote.maritime:getMaritimeShipAwardsInfoByShipId(self._shipId, remote.user.level)	
	for i = 1, 1 do
		self._ccbOwner["node_icon_"..i]:removeAllChildren()
		if self._shipAwards["type_"..i] and self._shipAwards["type_"..i] == "item" then
			local items = QStaticDatabase:sharedDatabase():getItemByID(self._shipAwards["id_"..i])
			if items.icon_1 ~= nil then
				local sprite = CCSprite:create(items.icon_1)
				sprite:setScale(0.6)
				self._ccbOwner["node_icon_"..i]:addChild(sprite)
			end
			local num = self._shipAwards["num_"..i] or 0
			self._ccbOwner["tf_value_"..i]:setString(num)
		end
	end
end

function QUIWidgetMaritimeChooseShipClient:setSelectState()
	if self._isMy then
		self._ccbOwner.tf_use_time:setColor(COLORS.j)
		self._ccbOwner.sp_static_gray:setVisible(false)
	else
		self._ccbOwner.tf_use_time:setColor(COLORS.f)
		self._ccbOwner.sp_static_gray:setVisible(true)
	end
end

function QUIWidgetMaritimeChooseShipClient:setRefreshEffect(shipId)
	if self._refreshEffect ~= nil then
		self._refreshEffect:stopAnimation()
		self._refreshEffect = nil
	end

	-- local scale = {0.8, 0.8, 0.9, 1, 1}

	self._refreshEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:addChild(self._refreshEffect)
	-- self._ccbOwner.node_effect:setScale(scale[shipId])
	self._refreshEffect:playAnimation("ccb/effects/haishang_shuaxin1.ccbi", function()end, function()
			self._refreshEffect = nil
		end)
end

function QUIWidgetMaritimeChooseShipClient:_clickShip(event)
	if event.name == QUIWidgetShipBox.EVENT_CLICK then
		self._shipBox:setSelectState()
	end
end

function QUIWidgetMaritimeChooseShipClient:_onTriggerClick()
	if self._shipAwards == nil then
		self._shipAwards = remote.maritime:getMaritimeShipAwardsInfoByShipId(self._shipId, remote.user.level)
	end

	if self._shipAwards["type_1"] and self._shipAwards["type_1"] == "item" then
		local items = QStaticDatabase:sharedDatabase():getItemByID(self._shipAwards["id_1"])
		app.tip:itemTip(items.name, items.id)
	end
end

function QUIWidgetMaritimeChooseShipClient:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetMaritimeChooseShipClient