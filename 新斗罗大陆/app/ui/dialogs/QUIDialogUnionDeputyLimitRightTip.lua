-- 
-- zxs
-- 副宗主显示权限提示
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDeputyLimitRightTip = class("QUIDialogUnionDeputyLimitRightTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogUnionDeputyLimitRightTip:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_zhufu.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogUnionDeputyLimitRightTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._callback = options.callback
    self._hasRight = options.hasRight or false
	self:setInfo()
end

function QUIDialogUnionDeputyLimitRightTip:setInfo()
	local str = ""
	if self._hasRight then
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("union_right_show_title")[1])
		str = "魂师大人，当前宗主离线72小时以\n上，副宗主获得了设置群发邮件的\n权力，代替宗主组织宗门的活动~"
	else
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("union_right_show_title")[2])
		str = "魂师大人，当前宗主已经从新上线，\n群发邮件的权限已经回归宗主~"
	end
    self._ccbOwner.tf_text:setString(str)
end

function QUIDialogUnionDeputyLimitRightTip:_onTriggerOK()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDeputyLimitRightTip:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogUnionDeputyLimitRightTip
