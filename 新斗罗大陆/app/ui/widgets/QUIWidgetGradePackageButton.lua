-- @Author: liaoxianbo
-- @Date:   2019-07-08 11:44:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-02 17:36:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGradePackageButton = class("QUIWidgetGradePackageButton", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetGradePackageButton:ctor(options)
	local ccbFile = "ccb/WIdget_activity_gradepackage_button.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGradePackageButton.super.ctor(self, ccbFile, callBacks, options)
  
	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetGradePackageButton:refreshInfo()
	self:setInfo(self._info)
end

function QUIWidgetGradePackageButton:setInfo(info)
	self._info = info

	local titleStr = self._info.title or ""
	local title = CCString:create(titleStr)

	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateDisabled)
	self._ccbOwner.btn_click:setLabelAnchorPoint(ccp(0.55, 0.3))

	if self._info.unlockTime then
		local endTime = remote.gradePackage:getGradePackageUntilTime()
		local untilTime = self._info.unlockTime + HOUR*endTime*1000 - q.serverTime() * 1000
		self._ccbOwner.tf_time:setString("("..q.timeToHourMinuteSecondMs(untilTime)..")")
		self:updateUnlockTime()
	else
		self._ccbOwner.tf_time:setString(self._info.btnLimtLevel.."级解锁")
	end

	self._ccbOwner.sp_tips:setVisible(remote.gradePackage:checkGradePakgeBtnRedTips(self._info.btnLimtLevel))
end

function QUIWidgetGradePackageButton:updateUnlockTime( )
	self:_updateTime()
	if self._schedulerBtnUnLockTime then
		scheduler.unscheduleGlobal(self._schedulerBtnUnLockTime)
		self._schedulerBtnUnLockTime = nil
	end
	self._schedulerBtnUnLockTime = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIWidgetGradePackageButton:_updateTime()
	if self._info.unlockTime == nil then 
		if self._schedulerBtnUnLockTime then
			scheduler.unscheduleGlobal(self._schedulerBtnUnLockTime)
			self._schedulerBtnUnLockTime = nil
		end		
		return 
	end
	local isOvertime, timeStr, color = remote.gradePackage:updateTime(self._info.unlockTime)
	if not isOvertime then
		self._ccbOwner.tf_time:setString(timeStr)
		-- self._ccbOwner.tf_time:setColor(color)
	else
		self._ccbOwner.tf_time:setString("00:00:00")
		if self._schedulerBtnUnLockTime then
			scheduler.unscheduleGlobal(self._schedulerBtnUnLockTime)
			self._schedulerBtnUnLockTime = nil
		end
	end
end

function QUIWidgetGradePackageButton:getInfo()
	return self._info
end

function QUIWidgetGradePackageButton:setSelect(b)
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
	if b then
		self._ccbOwner.tf_time:setColor(ccc3(121, 36, 16))
	else
		self._ccbOwner.tf_time:setColor(ccc3(204, 135, 109))
	end
end

function QUIWidgetGradePackageButton:onEnter()
end

function QUIWidgetGradePackageButton:onExit()
	if self._schedulerBtnUnLockTime then
		scheduler.unscheduleGlobal(self._schedulerBtnUnLockTime)
		self._schedulerBtnUnLockTime = nil
	end
end

function QUIWidgetGradePackageButton:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetGradePackageButton
