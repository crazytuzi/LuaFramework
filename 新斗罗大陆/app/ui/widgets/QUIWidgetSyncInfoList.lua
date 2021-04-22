
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSyncInfoList = class("QUIWidgetSyncInfoList", QUIWidget)

QUIWidgetSyncInfoList.EVENT_CLICK_SELECT = "EVENT_CLICK_SELECT"

function QUIWidgetSyncInfoList:ctor(options)
	local ccbFile = "ccb/Widget_SyncInfoListCell.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSyncInfoList.super.ctor(self, ccbFile, callBacks, options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSyncInfoList:setInfo(info,index)
	self._info = info or {}
 	self._index = index
	self._ccbOwner.tf_title1:setString(info.name or "")
end

function QUIWidgetSyncInfoList:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	-- size.height = size.height + 5
	return size
end

return QUIWidgetSyncInfoList