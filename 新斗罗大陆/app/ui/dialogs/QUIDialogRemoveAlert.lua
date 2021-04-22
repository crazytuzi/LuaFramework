local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRemoveAlert = class("QUIDialogRemoveAlert", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogRemoveAlert:ctor(options)
	local ccbFile = "ccb/Dialog_Remove_Alert.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", 				callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerMonthCard",			callback = handler(self, self._onTriggerMonthCard)},
	}
	QUIDialogRemoveAlert.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	q.setButtonEnableShadow(self._ccbOwner.btn_month_card)

	self._title = options.title or ""
	self._contentStr = options.contentStr or ""
	self._costToken = options.costToken
	self._callback = options.callback

	self._ccbOwner.frame_tf_title:setString(self._title)

	if self._costToken then
		self._ccbOwner.node_price:setVisible(true)
		local haveMonthCard = remote.activity:checkMonthCardActive(2)
		self._ccbOwner.node_month_card:setVisible(haveMonthCard)
	else
		self._ccbOwner.node_price:setVisible(false)
		self._ccbOwner.node_month_card:setVisible(false)
	end

	self._isRemove = false

	self:initUIData()
end

function QUIDialogRemoveAlert:viewWillDisappear()
    QUIDialogRemoveAlert.super.viewWillDisappear(self)
end

function QUIDialogRemoveAlert:initUIData()
	if self._costToken then
		self._ccbOwner.tf_token:setString(self._costToken)
	end

	self._ccbOwner.tf_content:setVisible(false)
	self._ccbOwner.node_content:removeAllChildren()
	local richText = QRichText.new(self._contentStr, 340, {autoCenter = true, stringType = 1, defaultSize = 22})
	richText:setAnchorPoint(ccp(0.5,1))
	self._ccbOwner.node_content:addChild(richText)
end

function QUIDialogRemoveAlert:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRemoveAlert:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogRemoveAlert:_onTriggerOK(event)
	app.sound:playSound("common_cancel")
	self._isRemove = true
	self:playEffectOut()
end

function QUIDialogRemoveAlert:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIDialogRemoveAlert:viewAnimationOutHandler()
	local callback = self._callback
	local isRemove = self._isRemove
	self:popSelf()
	if callback ~= nil then
		callback(isRemove)
	end
end

return QUIDialogRemoveAlert