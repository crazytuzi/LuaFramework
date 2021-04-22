-- @Author: xurui
-- @Date:   2019-12-06 10:41:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 16:31:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountMaterGuideGradeSuccess = class("QUIDialogMountMaterGuideGradeSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountMaterGuideGradeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_master_guide_success.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMountMaterGuideGradeSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    	self._masterConfig = options.masterConfig
    end

	self._isEnd = false

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
end

function QUIDialogMountMaterGuideGradeSuccess:viewDidAppear()
	QUIDialogMountMaterGuideGradeSuccess.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogMountMaterGuideGradeSuccess:viewWillDisappear()
  	QUIDialogMountMaterGuideGradeSuccess.super.viewWillDisappear(self)
end

function QUIDialogMountMaterGuideGradeSuccess:animationEndHandler()
	self._isEnd = true
end

function QUIDialogMountMaterGuideGradeSuccess:setInfo()
	if self._masterConfig then
		local props = QActorProp:getPropUIByConfig(self._masterConfig)
		local nameStr = self._masterConfig.master_name or ""
		local desc = ""
		for i, prop in pairs(props) do
			local value = prop.value
			if prop.isPercent then
				value = (prop.value*100).."%"
			end
			desc = desc .. " ".."全队攻防血" .."+"..value
			break
		end
		self._ccbOwner.tf_prop:setString(desc)

		self._ccbOwner.tf_name:setString(nameStr)
		self._ccbOwner.tf_name1:setString(nameStr)
		self._ccbOwner.tf_name2:setString(nameStr)
	end
end

function QUIDialogMountMaterGuideGradeSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMountMaterGuideGradeSuccess:_onTriggerClose()
	if self._isEnd == false then return end

  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMountMaterGuideGradeSuccess:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMountMaterGuideGradeSuccess
