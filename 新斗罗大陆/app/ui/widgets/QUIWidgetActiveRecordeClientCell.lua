-- @Author: xurui
-- @Date:   2016-11-10 21:11:06
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-11-11 16:20:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActiveRecordeClientCell = class("QUIWidgetActiveRecordeClientCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")

function QUIWidgetActiveRecordeClientCell:ctor(options)
	local ccbFile = "ccb/Widget_society_choujiangjilu_client.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetActiveRecordeClientCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActiveRecordeClientCell:onEnter()
end

function QUIWidgetActiveRecordeClientCell:onExit()
end

function QUIWidgetActiveRecordeClientCell:setInfo(param)
	self._info = param.log
	local icon = remote.items:getURLForItem(ITEM_TYPE.CONSORTIA_MONEY, "alphaIcon")
	self._ccbOwner.node_tf_recorde:removeAllChildren()
    local node = QRichText.new({
        {oType = "font", content = self._info.nickname or "",size = 22,color = ccc3(255,195,49)},
        {oType = "font", content = "在军团抽奖中，获得",size = 22,color = ccc3(253,226,191)},
        {oType = "img", fileName = icon, scale = 0.6},
        {oType = "font", content = "x "..self._info.drawCount or 0,size = 22,color = ccc3(255,195,49)},
    },700)
    self._ccbOwner.node_tf_recorde:addChild(node)
end

function QUIWidgetActiveRecordeClientCell:getContentSize()
	return self._ccbOwner.background3:getContentSize()
end

return QUIWidgetActiveRecordeClientCell