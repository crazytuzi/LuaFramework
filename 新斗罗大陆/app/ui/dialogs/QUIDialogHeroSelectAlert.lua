--
-- zxs
-- 选择英雄时提示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSelectAlert = class("QUIDialogHeroSelectAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")

function QUIDialogHeroSelectAlert:ctor(options) 
 	local ccbFile = "ccb/Dialog_Hero_Select_Alert.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogHeroSelectAlert._onTriggerClose)},
	    {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIDialogHeroSelectAlert._onTriggerSelect)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogHeroSelectAlert._onTriggerConfirm)},
	}
	QUIDialogHeroSelectAlert.super.ctor(self, ccbFile, callBacks, options)
	options.btnDesc = options.btnDesc or {}

	self.isAnimation = options.isAnimation == nil and true or false
	self._isSelect = false

	local title = options.title or "提 示"
	self._ccbOwner.frame_tf_title:setString(title)

	local content = options.content or options.desc or ""
	if options.colorful then
		self._ccbOwner.tf_desc:setString("")
		local richText = QRichText.new(content, 400, {autoCenter = true, stringType = 1})
		richText:setAnchorPoint(ccp(0.5,0.5))
		self._ccbOwner.node_desc:addChild(richText)
	else
		self._ccbOwner.tf_desc:setString(content)
	end

	self:updateSelect()
end

function QUIDialogHeroSelectAlert:updateSelect()	
	self._ccbOwner.sp_select:setVisible(self._isSelect)
	self._ccbOwner.sp_no_select:setVisible(not self._isSelect)
end

function QUIDialogHeroSelectAlert:_onTriggerClose()
	self._type = ALERT_TYPE.COLSE
	self:close()
end

function QUIDialogHeroSelectAlert:_onTriggerSelect()
	self._isSelect = not self._isSelect
	self:updateSelect()
end

function QUIDialogHeroSelectAlert:_onTriggerConfirm(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	self._type = ALERT_TYPE.CONFIRM
	self:close()
end

function QUIDialogHeroSelectAlert:_backClickHandler()
	self._type = ALERT_TYPE.COLSE
	self:close()
end

function QUIDialogHeroSelectAlert:close()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:playEffectOut()
end

function QUIDialogHeroSelectAlert:viewAnimationOutHandler()
	local options = self:getOptions()
	local callback = options.callback
	self:popSelf()

	if callback ~= nil then
		callback(self._type, self._isSelect)
	end
end

return QUIDialogHeroSelectAlert