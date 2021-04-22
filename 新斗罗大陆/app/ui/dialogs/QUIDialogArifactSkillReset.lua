local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArifactSkillReset = class("QUIDialogArifactSkillReset", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogArifactSkillReset:ctor(options)
	local ccbFile = "ccb/Dialog_artifact_chongzhi.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", 				callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerMonthCard",			callback = handler(self, self._onTriggerMonthCard)},
	}
	QUIDialogArifactSkillReset.super.ctor(self,ccbFile,callBacks,options)
	-- self._actorId = options.actorId
	self._title = options.title or ""
	self._contentStr = options.contentStr or ""
	self._costToken = options.costToken or 0
	self._callback = options.callback
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString(self._title)

	-- self._resetToken = db:getConfiguration().RESETTING_RECYCLE.value or 0

	self._isReset = false
	self._haveMonthCard = remote.activity:checkMonthCardActive(2)

	q.setButtonEnableShadow(self._ccbOwner.btn_month_card)

	self:initUIData()

end

function QUIDialogArifactSkillReset:viewWillDisappear()
    QUIDialogArifactSkillReset.super.viewWillDisappear(self)
end

function QUIDialogArifactSkillReset:initUIData( )

	self._ccbOwner.tf_token:setString(self._costToken)
	self._ccbOwner.tf_content:setVisible(false)
	self._ccbOwner.node_content:removeAllChildren()
	local richText = QRichText.new(self._contentStr, 340, {autoCenter = true, stringType = 1, defaultSize = 22})
	richText:setAnchorPoint(ccp(0.5,1))
	self._ccbOwner.node_content:addChild(richText)

	self._ccbOwner.node_month_card:setVisible(self._haveMonthCard)
end

function QUIDialogArifactSkillReset:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogArifactSkillReset:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogArifactSkillReset:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end
	app.sound:playSound("common_cancel")
	self._isReset = true
	self:playEffectOut()
end

function QUIDialogArifactSkillReset:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIDialogArifactSkillReset:viewAnimationOutHandler()
	local callback = self._callback
	local isReset = self._isReset
	self:popSelf()
	if callback ~= nil then
		callback(isReset)
	end
end

return QUIDialogArifactSkillReset