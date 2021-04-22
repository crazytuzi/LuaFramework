-- @Author: xurui
-- @Date:   2016-12-29 18:10:28
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-27 16:29:11
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaritimeProtectClient = class("QUIWidgetMaritimeProtectClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetMaritimeProtectClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetMaritimeProtectClient:ctor(options)
	local ccbFile = "ccb/Widget_Haishang_baohu.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIWidgetMaritimeProtectClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMaritimeProtectClient:onEnter()
end

function QUIWidgetMaritimeProtectClient:onExit()
end

function QUIWidgetMaritimeProtectClient:setInfo(param)
	self._info = param.info or {}

	local num, word = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_battle_force:setString(num..(word or ""))
	self._ccbOwner.tf_level:setString("LV."..(self._info.level or "").." "..self._info.name or "")
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_vip:setString("VIP "..(self._info.vip or ""))

	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new()
		self._ccbOwner.node_head:addChild(self._avatar)
		self._avatar:setScale(0.9)
	end
	self._avatar:setInfo(self._info.avatar or 0)
	self._avatar:setSilvesArenaPeak(self._info.championCount)

	if param.selectState ~= nil then
		self:setSelectState(param.selectState)
	end
end

function QUIWidgetMaritimeProtectClient:setSelectState(state)
	self._selectState = state
	self._ccbOwner.btn_select:setHighlighted(state)
end

function QUIWidgetMaritimeProtectClient:getClientInfo()
	return self._info
end

function QUIWidgetMaritimeProtectClient:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetMaritimeProtectClient:_onTriggerSelect()
	if self._selectState then
		return 
	end
	self:dispatchEvent({name = QUIWidgetMaritimeProtectClient.EVENT_CLICK, info = self._info})
end


return QUIWidgetMaritimeProtectClient