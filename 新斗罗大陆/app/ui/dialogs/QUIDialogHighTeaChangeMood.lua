
local QUIDialog = import(".QUIDialog")
local QUIDialogHighTeaChangeMood = class("QUIDialogHighTeaChangeMood", QUIDialog)

function QUIDialogHighTeaChangeMood:ctor(options)
	local ccbFile = "ccb/Dialog_HighTea_MoodChange.ccbi"
	local callBacks = {
	}
	QUIDialogHighTeaChangeMood.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self._backCallback = options.callback
	local desc = options.word or "宁荣荣的心情发生变化"
	self._exitLock = true

	self._ccbOwner.tf_mood_desc:setString(desc)

	self._schedulerHandler = scheduler.performWithDelayGlobal(function()
		self._exitLock = false
		self:onTriggerBackHandler()
	end, 2)

end

function QUIDialogHighTeaChangeMood:viewDidAppear()
	QUIDialogHighTeaChangeMood.super.viewDidAppear(self)

end

function QUIDialogHighTeaChangeMood:viewWillDisappear()
	QUIDialogHighTeaChangeMood.super.viewWillDisappear(self)
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QUIDialogHighTeaChangeMood:onTriggerBackHandler()
	if self._exitLock then return end

    self:popSelf()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogHighTeaChangeMood