--[[	
	文件名称：QUIDialogGloryEntranceTips.lua
	创建时间：2016-08-23 10:43:08
	作者：nieming
	描述：QUIDialogGloryEntranceTips
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogGloryEntranceTips = class("QUIDialogGloryEntranceTips", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

--初始化
function QUIDialogGloryEntranceTips:ctor(options)
	if not options then
		options = {}
	end
	self._time = options.time or 0
	local ccbFile
	if options.state == 1 then
		ccbFile = "Dialog_GloryArena_tips1.ccbi"
	else
		ccbFile = "Dialog_GloryArena_tips2.ccbi"
	end
	local callBacks = {
	}
	QUIDialogGloryEntranceTips.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._ccbOwner.time:setString(q.timeToDayHourMinute(self._time))
end

function QUIDialogGloryEntranceTips:updateTime( ... )
	-- body
	if self._time > 0 then
		self._time = self._time -1;
	end
	self._ccbOwner.time:setString(q.timeToDayHourMinute(self._time))
end

--describe：关闭对话框
function QUIDialogGloryEntranceTips:close( )
	self:playEffectOut()
end



function QUIDialogGloryEntranceTips:viewDidAppear()
	QUIDialogGloryEntranceTips.super.viewDidAppear(self)
	--代码
	self._timeUpdateScheduler = scheduler.scheduleGlobal(handler(self, self.updateTime),1)

end

function QUIDialogGloryEntranceTips:viewWillDisappear()
	QUIDialogGloryEntranceTips.super.viewWillDisappear(self)
	--代码
	if self._timeUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeUpdateScheduler)
	end
end

function QUIDialogGloryEntranceTips:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
--function QUIDialogGloryEntranceTips:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogGloryEntranceTips:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogGloryEntranceTips
