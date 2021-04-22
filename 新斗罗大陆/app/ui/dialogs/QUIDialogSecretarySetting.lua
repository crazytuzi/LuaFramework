--
-- zxs
-- 小秘书单个设置
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSecretarySetting = class("QUIDialogSecretarySetting", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 

function QUIDialogSecretarySetting:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_setting.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
	}
	QUIDialogSecretarySetting.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self._ccbOwner.frame_tf_title:setString("设 置")

	self._setId = options.setId
	self:initScrollView()
	self:initSettingLayer()
	self:initSettingTips()
end

function QUIDialogSecretarySetting:initScrollView()
	self._sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._sheetSize, {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
end

function QUIDialogSecretarySetting:initSettingLayer()
	local dataProxy = remote.secretary:getSecretaryDataProxyById(self._setId)
	local widgets, totalHeight = dataProxy:getSettingWidgets()
	if totalHeight == nil then totalHeight = 0 end
	
	for _, widget in ipairs(widgets) do
		self._scrollView:addItemBox(widget)
	end
	self._scrollView:setRect(0, -totalHeight, 0, self._sheetSize.width)
end

function QUIDialogSecretarySetting:initSettingTips()
	local dataProxy = remote.secretary:getSecretaryDataProxyById(self._setId)
	local isTips, tips = dataProxy:getSettingTips()
	self._ccbOwner.tf_tips:setVisible(isTips)
	self._ccbOwner.tf_tips:setString(tips)
end

function QUIDialogSecretarySetting:_onTriggerOk()
    app.sound:playSound("common_switch")

	local dataProxy = remote.secretary:getSecretaryDataProxyById(self._setId)
	dataProxy:saveSecretarySetting()

	app.tip:floatTip("设置已保存~")
    self:playEffectOut()
end

function QUIDialogSecretarySetting:_onTriggerCancel()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

function QUIDialogSecretarySetting:_onTriggerClose()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

return QUIDialogSecretarySetting