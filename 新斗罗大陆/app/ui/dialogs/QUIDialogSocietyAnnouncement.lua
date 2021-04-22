--[[	
	文件名称：QUIDialogSocietyAnnouncement.lua
	创建时间：2016-04-28 14:32:34
	作者：nieming
	描述：QUIDialogSocietyAnnouncement
]]

local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyAnnouncement = class("QUIDialogSocietyAnnouncement", QUIDialogBaseUnion)


local QUIWidgetSocietyAnnouncement = import("..widgets.QUIWidgetSocietyAnnouncement")
local QUIWidgetSocietyXuanyan = import("..widgets.QUIWidgetSocietyXuanyan")

QUIDialogSocietyAnnouncement.AnnouncementTab = "AnnouncementTab"
QUIDialogSocietyAnnouncement.NotifyTab = "NotifyTab"

function QUIDialogSocietyAnnouncement:ctor(options)
	local ccbFile = "Dialog_society_announcement.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAnnouncement", callback = handler(self, QUIDialogSocietyAnnouncement._onTriggerAnnouncement)},
		{ccbCallbackName = "onTriggerNotify", callback = handler(self, QUIDialogSocietyAnnouncement._onTriggerNotify)},
	}
	QUIDialogSocietyAnnouncement.super.ctor(self,ccbFile,callBacks,options)
	
	self._ccbOwner.frame_tf_title:setString("公告牌")
end

function QUIDialogSocietyAnnouncement:_init( options )
	self._curSelected = QUIDialogSocietyAnnouncement.AnnouncementTab;

	remote.union:unionNotifyBoardRequest(self:safeHandler(function (data)
       	self._data = data.consortiaBillboardList
		self:setInfo()
    end))
	

end

function QUIDialogSocietyAnnouncement:setInfo(  )
	if not self._data then
		return
	end

	if self._curSelected == QUIDialogSocietyAnnouncement.AnnouncementTab then
		if not self._announcementWidget then
			self._announcementWidget = QUIWidgetSocietyAnnouncement.new();
			self._ccbOwner.widgetClient:addChild(self._announcementWidget)
			self._announcementWidget:setInfo(self._data.mainMessage, self._data.consortiaBillboard)
		end
		self._announcementWidget:setVisible(true)
		if self._notifyWidget then
			self._notifyWidget:setVisible(false)
		end

		self._ccbOwner.btn_announcement:setEnabled(false)
		self._ccbOwner.btn_notify:setEnabled(true)
	else
		if not self._notifyWidget then
			self._notifyWidget =  QUIWidgetSocietyXuanyan.new();
			self._ccbOwner.widgetClient:addChild(self._notifyWidget)
			self._notifyWidget:setInfo(self._data.notice)
		end
		self._notifyWidget:setVisible(true)
		if self._announcementWidget then
			self._announcementWidget:setVisible(false)
		end
		
		self._ccbOwner.btn_announcement:setEnabled(true)
		self._ccbOwner.btn_notify:setEnabled(false)
	end
end

function QUIDialogSocietyAnnouncement:_onTriggerAnnouncement(e)
    app.sound:playSound("common_switch")
	self._curSelected = QUIDialogSocietyAnnouncement.AnnouncementTab
	self:setInfo()
end

function QUIDialogSocietyAnnouncement:_onTriggerNotify(e)
    app.sound:playSound("common_switch")
	self._curSelected = QUIDialogSocietyAnnouncement.NotifyTab
	self:setInfo()
end

function QUIDialogSocietyAnnouncement:viewDidAppear()
	QUIDialogSocietyAnnouncement.super.viewDidAppear(self)
end

function QUIDialogSocietyAnnouncement:viewWillDisappear()
	QUIDialogSocietyAnnouncement.super.viewWillDisappear(self)
end

return QUIDialogSocietyAnnouncement
