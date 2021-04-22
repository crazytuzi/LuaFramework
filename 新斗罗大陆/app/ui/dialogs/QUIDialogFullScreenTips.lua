--
-- Author: Qinsiyang
-- Date: 2020-01-10 
-- 
local QUIDialog = import(".QUIDialog")
local QUIDialogFullScreenTips = class("QUIDialogFullScreenTips", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")



function QUIDialogFullScreenTips:ctor(options)
	local ccbFile = "ccb/Dialog_FullScreenTips.ccbi";

	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogFullScreenTips._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFullScreenTips._onTriggerClose)},
	}
	QUIDialogFullScreenTips.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
    if options then
    	self._callback = options.callback
    end
	if self._ccbOwner.node_welcome then
		self._avatar = QSkeletonActor:create("jm_xiaowu")
    	self._avatar:playAnimation("animation", true)
    	self._avatar:setScale(0.6)
		self._ccbOwner.node_welcome:addChild(self._avatar)
	end

    local recordManager = app:getUserOperateRecord()
	recordManager:setRecordByType(recordManager.RECORD_TYPES.FULL_SCENE_TIPS, 1)
end

function QUIDialogFullScreenTips:viewDidAppear()
	QUIDialogFullScreenTips.super.viewDidAppear(self)
end 

function QUIDialogFullScreenTips:viewWillDisappear()
	QUIDialogFullScreenTips.super.viewWillDisappear(self)
end 

function QUIDialogFullScreenTips:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_confirm")
	self:popSelf()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMyInformation",
		options = {avatar = remote.user.avatar, nickName = remote.user.nickname, exp = remote.user.exp, level = remote.user.level,
			expToNextLevel = db:getExperienceByTeamLevel(remote.user.level),
			heroMaxLevel = db:getTeamConfigByTeamLevel(remote.user.level).hero_limit,
			tab= "TAB_SYSTEM_SET"}})

end 

function QUIDialogFullScreenTips:_backClickHandler()
	-- For Arena, no outbound click triggers dialog disappear
	if not self._arena then
    	self:_onTriggerClose()
    end
end

function QUIDialogFullScreenTips:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
		app.sound:playSound("common_cancel")
	end
	self:playEffectOut()
end

function QUIDialogFullScreenTips:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogFullScreenTips:viewAnimationOutHandler()
	local callback = self._callback
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogFullScreenTips
