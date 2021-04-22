


local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSyncFormation = class("QUIWidgetSyncFormation", QUIWidget)

QUIWidgetSyncFormation.EVENT_CLICK_SELECT = "EVENT_CLICK_SELECT"

function QUIWidgetSyncFormation:ctor(options)
	local ccbFile = "ccb/Widget_SyncFormation.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSyncFormation.super.ctor(self, ccbFile, callBacks, options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end


function QUIWidgetSyncFormation:onEnter()
end

function QUIWidgetSyncFormation:onExit()
end

function QUIWidgetSyncFormation:setInfo(info,index)
	self._info = info or {}
 	self._index = index
	self._ccbOwner.tf_name:setString(info.name or "")
	self._ccbOwner.tf_name:setFontSize(self._info.fontSize)

	--set icon
	if info.icon then
		if self._icon == nil then
			self._icon = CCSprite:create()
			self._icon:setScale(0.86)
			self._ccbOwner.node_icon:addChild(self._icon)
		end
		QSetDisplayFrameByPath(self._icon, info.icon)
	end
	if info.isSelect then
		self._ccbOwner.sp_select:setVisible(true)
	else
		self._ccbOwner.sp_select:setVisible(false)
	end

end

function QUIWidgetSyncFormation:resetMainNodePosition()
	self._ccbOwner.node_main:setPosition(ccp(0, 0))

end

function QUIWidgetSyncFormation:setSelectNodeVisible(visible)
	self._ccbOwner.node_select:setVisible(visible)
end

function QUIWidgetSyncFormation:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSyncFormation.EVENT_CLICK_SELECT, index = self._index})
end

function QUIWidgetSyncFormation:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	-- size.height = size.height + 5
	return size
end

return QUIWidgetSyncFormation