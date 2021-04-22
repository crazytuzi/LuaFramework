-- @Author: xurui
-- @Date:   2017-04-05 18:21:20
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-10-10 11:19:43
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparBackPackInfoClient = class("QUIWidgetSparBackPackInfoClient", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetSparBackPackInfoClientSuitClient = import(".QUIWidgetSparBackPackInfoClientSuitClient")

function QUIWidgetSparBackPackInfoClient:ctor(options)
	local ccbFile = "ccb/Widget_spar_packsack_client.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetSparBackPackInfoClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._posY = self._ccbOwner.node_client:getPositionY()

	self._suitClient = {}
end

function QUIWidgetSparBackPackInfoClient:onEnter()
end

function QUIWidgetSparBackPackInfoClient:onExit()
end

function QUIWidgetSparBackPackInfoClient:setDetailInfo(props, suit)
	self._height = 120
	for i = 1, 8 do
		self._ccbOwner["tf_value"..i]:setVisible(props[i] ~= nil)
		self._ccbOwner["tf_name"..i]:setVisible(props[i] ~= nil)
		if props[i] ~= nil then
			self._ccbOwner["tf_value"..i]:setString(" +"..props[i].value)
			self._ccbOwner["tf_name"..i]:setString(props[i].name.."：")
		end
	end

	local visibleNum = #props / 2
	self._ccbOwner.node_client:setPositionY(self._posY + (4 - visibleNum) * 20 )

	local height = 0
	for i = 1, #suit do
		if self._suitClient[i] == nil then
			self._suitClient[i] = QUIWidgetSparBackPackInfoClientSuitClient.new()
			self._ccbOwner.node_client:addChild(self._suitClient[i])
		end
		self._suitClient[i]:setSuitInfo(suit[i])
		local contentSize = self._suitClient[i]:getContentSize()
		self._suitClient[i]:setPositionY(-height)
		height = height + contentSize.height
	end
	self._height = self._height + height
end

function QUIWidgetSparBackPackInfoClient:getSuitClient()
	return self._suitClient or {}
end

function QUIWidgetSparBackPackInfoClient:getContentSize()
	return CCSize(400, self._height)
end


return QUIWidgetSparBackPackInfoClient