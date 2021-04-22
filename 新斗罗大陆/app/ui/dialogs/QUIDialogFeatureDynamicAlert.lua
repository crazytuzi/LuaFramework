-- @Author: xurui
-- @Date:   2019-03-06 10:47:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-20 16:53:05
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFeatureDynamicAlert = class("QUIDialogFeatureDynamicAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogFeatureDynamicAlert:ctor(options)
	local ccbFile = "ccb/Dialog_chat_interaction.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
    }
    QUIDialogFeatureDynamicAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    CalculateUIBgSize(self._ccbOwner.ly_bg)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._configIndex = options.configIndex
    	self._params = options.params
    end

    self._isConfirm = false
end

function QUIDialogFeatureDynamicAlert:viewDidAppear()
	QUIDialogFeatureDynamicAlert.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogFeatureDynamicAlert:viewWillDisappear()
  	QUIDialogFeatureDynamicAlert.super.viewWillDisappear(self)
end

function QUIDialogFeatureDynamicAlert:setInfo()
	local config = remote.userDynamic.featureConfig[tonumber(self._configIndex)]

	self._ccbOwner.node_rank:setVisible(config.titleType == 1)
	self._ccbOwner.node_plunder:setVisible(config.titleType == 2)
	self._ccbOwner.node_fightClub:setVisible(config.titleType == 3)
	self._ccbOwner.node_maritime:setVisible(config.titleType == 4)
	self._ccbOwner.node_maritime_project:setVisible(config.titleType == 5)
	self._ccbOwner.node_offer_reward:setVisible(config.titleType == 6)

	local str = ""
	if config.titleType == 1 then
		self._ccbOwner.tf_rank:setString(self._params[1] or "")
		str = string.format(config.content, self._params[2], self._params[3])
	elseif config.titleType == 2 or config.titleType == 4 or config.titleType == 5 then
		str = string.format(config.content, self._params[1], self._params[2])
	elseif config.titleType == 3 then
		self._ccbOwner.tf_win_count:setString((self._params[1] or "").."杯")
		str = string.format(config.content, self._params[2])
	elseif config.titleType == 6 then
		str = string.format(config.content, self._params[1])
	end
	
	if config.titleType == 5 or config.titleType == 6 then
		self._ccbOwner.label_btntext:setString("好 的")
	end

	self._richText = QRichText.new(str, 350, {stringType = 1, autoCenter = false, defaultSize = 24, defaultColor = COLORS.a})
	self._richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_text:addChild(self._richText)
end

function QUIDialogFeatureDynamicAlert:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFeatureDynamicAlert:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFeatureDynamicAlert:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
  	app.sound:playSound("common_small")
	self._isConfirm = true

	self:playEffectOut()
end

function QUIDialogFeatureDynamicAlert:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._isConfirm)
	end
end

return QUIDialogFeatureDynamicAlert
