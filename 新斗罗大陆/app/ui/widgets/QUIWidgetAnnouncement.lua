-- 
-- zxs 
-- 公告
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAnnouncement = class("QUIWidgetAnnouncement", QUIWidget)

QUIWidgetAnnouncement.TITLE_BUTTON_CLICK = "TITLE_BUTTON_CLICK"

function QUIWidgetAnnouncement:ctor(options)
	local ccbFile = "ccb/Widget_Announcement.ccbi"
	local callbacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetAnnouncement._onTriggerClick)},
    }
	QUIWidgetAnnouncement.super.ctor(self, ccbFile, callbacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetAnnouncement:setInfo(info)
	self._ccbOwner.tf_name:setString(info.title or "")
	self._ccbOwner.tf_name1:setString(info.title or "")

	local titleType = tonumber(info.type or 0)
	self._ccbOwner.sp_normal:setVisible(titleType == 1)
	self._ccbOwner.sp_special:setVisible(titleType == 2)
	self._idIndex = info.id

	self:setSelect(info.isSelect or false)	
end

function QUIWidgetAnnouncement:setSelect(isSelect)
	self._isSelect = isSelect
	self._ccbOwner.sp_button:setEnabled(not isSelect)
	self._ccbOwner.sp_button:setHighlighted(isSelect)

	if isSelect then
		self._ccbOwner.tf_name:setColor(COLORS.S)
	else
		self._ccbOwner.tf_name:setColor(COLORS.T)
	end
end

function QUIWidgetAnnouncement:getContentSize()
	local size = self._ccbOwner.sp_button:getContentSize()
	return size
end

function QUIWidgetAnnouncement:_onTriggerClick()
    self:dispatchEvent({name = QUIWidgetAnnouncement.TITLE_BUTTON_CLICK, idIndex = self._idIndex})
end

return QUIWidgetAnnouncement