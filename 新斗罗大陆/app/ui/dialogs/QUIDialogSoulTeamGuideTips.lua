-- @Author: liaoxianbo
-- @Date:   2020-03-01 19:38:09
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-09 21:46:09
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTeamGuideTips = class("QUIDialogSoulTeamGuideTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogSoulTeamGuideTips:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_TeamGuide.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerCheck", callback = handler(self, self._onTriggerCheck)},
    }
    QUIDialogSoulTeamGuideTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	q.setButtonEnableShadow(self._ccbOwner.btn_help)

    if options then
    	self._callBack = options.callBack
    	self._soulTeamNum = options.soulTeamNum
    end
    self._ccbOwner.frame_tf_title:setString("魂灵开坑")
    self._ccbOwner.tf_title_1:setString(self._soulTeamNum.."小队扩展魂灵位") 
    local str = string.format("效果：开启后可在所有%d小队玩法的阵容中上阵第二只魂灵",self._soulTeamNum)
    self._ccbOwner.tf_desc:setString(str)   
end

function QUIDialogSoulTeamGuideTips:viewDidAppear()
	QUIDialogSoulTeamGuideTips.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogSoulTeamGuideTips:viewWillDisappear()
  	QUIDialogSoulTeamGuideTips.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulTeamGuideTips:_onTriggerCheck( )
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOccultGuide"})
end

function QUIDialogSoulTeamGuideTips:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulTeamGuideTips:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulTeamGuideTips:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulTeamGuideTips
