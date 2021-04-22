-- Author: qinyuanji
-- This utility class is used to listen to system board message 

local QChatData = import(".QChatData")
local QBulletinData = class("QBulletinData", QChatData)
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSystemNotice = import("...ui.widgets.QUIWidgetSystemNotice")

function QBulletinData:ctor(maxCount)
	QBulletinData.super.ctor(self, "bulletin", maxCount)

  	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetSystemNotice.SHOW_NOTICE_ON_CHAT, self._onBulletinMsgReceived, self)
end

function QBulletinData:_onBulletinMsgReceived(event)
	assert(event.message, "message is nil")

	self:_onMessageReceived(nil, event.from, nil, event.message, q.OSTime(), self:parseMisc({nickName = event.from, type = "admin"}))
end

return QBulletinData