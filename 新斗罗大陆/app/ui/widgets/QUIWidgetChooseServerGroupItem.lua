--
-- Author: nieming
-- Date: 2014-05-08 16:07:32
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChooseServerGroupItem = class("QUIWidgetChooseServerGroupItem", QUIWidget)

QUIWidgetChooseServerGroupItem.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetChooseServerGroupItem:ctor(options)
	local ccbFile = "ccb/Widget_ChooseServer_GroupItem.ccbi"
	-- local callBacks = {
 --        {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIWidgetChooseServerGroupItem._onTriggerChoose)},	
	-- }
	QUIWidgetChooseServerGroupItem.super.ctor(self,ccbFile,nil,options)
	-- cc.GameObject.extend(self)
    -- self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetChooseServerGroupItem:setInfo(groupItemInfo)
	if not groupItemInfo or type(groupItemInfo) ~= "table" then
		return
	end
	self._groupInfo = groupItemInfo
	if groupItemInfo.name then
		self._ccbOwner.btnLable:setString(groupItemInfo.name)
	end
	-- self:setSelected(false)
end

function QUIWidgetChooseServerGroupItem:getContentSize(  )
	
	return self._ccbOwner.btnGroupItem:getContentSize()
end

function QUIWidgetChooseServerGroupItem:setSelected( trueOrFalse )
	self._ccbOwner.btnGroupItem:setEnabled(trueOrFalse)
	if trueOrFalse then
		self._ccbOwner.btnLable:setColor(ccc3(255,216,173))

	else
		-- self._ccbOwner.btnLable:setColor(ccc3(91,46,2))
		self._ccbOwner.btnLable:setColor(ccc3(168,26,20))
	end

end


-- function QUIWidgetChooseServerGroupItem:onCleanup()
-- 	-- print("QUIWidgetChooseServerGroupItem  clean ---------------1")
-- 	self:removeAllEventListeners()
-- end

-- function QUIWidgetChooseServerGroupItem:_onTriggerChoose(event)
-- 	print("------------QUIWidgetChooseServerGroupItem ------------")
-- 	self:dispatchEvent({name = QUIWidgetChooseServerGroupItem.EVENT_CLICK, groupInfo = self._groupInfo})
-- end

return QUIWidgetChooseServerGroupItem