
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparAbsorbSuccess = class("QUIDialogSparAbsorbSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSparAbsorbSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SparAbsorbSuccess.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSparAbsorbSuccess.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self.isAnimation = true --是否动画显示
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(false)

    self._isEnd = false
	self.actorId = options.actorId
	self.callback = options.callback
	self.oldSparInfo = options.oldSparInfo
	self.newSparInfo = options.newSparInfo
	self._index = options.index
	
	self._ccbOwner.node_select:setVisible(false)

	self._oldProp = {}
	self._newProp = {}
	self._needPlusProp = false
	app.sound:playSound("task_complete")
end

function QUIDialogSparAbsorbSuccess:viewDidAppear()
	QUIDialogSparAbsorbSuccess.super.viewDidAppear(self)

	self:setSparPropInfo()

	self._animationStage = "1"
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIDialogSparAbsorbSuccess:viewWillDisappear()
	QUIDialogSparAbsorbSuccess.super.viewWillDisappear(self)
end

function QUIDialogSparAbsorbSuccess:viewAnimationEndHandler(name)
	if self._needPlusProp then
		self._animationStage = name
	else
		self._isEnd = true
	end
end


function QUIDialogSparAbsorbSuccess:setSparPropInfo()
	if self._sparOldItem == nil then
		self._sparOldItem = QUIWidgetSparBox.new()
		self._ccbOwner.old_head:addChild(self._sparOldItem)
	end
	self._sparOldItem:setGemstoneInfo(self.oldSparInfo, self._index)
	self._sparOldItem:setName("")
	self._sparOldItem:setStrengthVisible(false)

	if self._sparNewItem == nil then
		self._sparNewItem = QUIWidgetSparBox.new()
		self._ccbOwner.new_head:addChild(self._sparNewItem)
	end
	self._sparNewItem:setGemstoneInfo(self.newSparInfo, self._index)
	self._sparNewItem:setName("")
	self._sparNewItem:setStrengthVisible(false)
	local  itemId = self.oldSparInfo.itemId
	local itemConfig = db:getItemByID(itemId)
	self._ccbOwner.oldName:setString(itemConfig.name or "")
	self._ccbOwner.newName:setString(itemConfig.name or "")

	local absorbLv1 = self.oldSparInfo.inheritLv  or 0
	local absorbLv2 = self.newSparInfo.inheritLv  or 1

	local absorbConfig1 = db:getSparsAbsorbConfigBySparItemIdAndLv(itemId, absorbLv1 )
	local absorbConfig2 = db:getSparsAbsorbConfigBySparItemIdAndLv(itemId, absorbLv2 )
	if absorbConfig1 then
		self._oldProp = remote.spar:setPropInfo(absorbConfig1)
	end

	self._newProp = remote.spar:setPropInfo(absorbConfig2)
	self._needPlusProp = #self._newProp > 4 
	for i = 1, 8 do
		if self._newProp[i] then
			self._ccbOwner["node_title_"..i]:setString(self._newProp[i].name.."：")
			self._ccbOwner["tf_new_value_"..i]:setString(self._newProp[i].value)
			if self._oldProp[i] then
				self._ccbOwner["tf_old_value_"..i]:setString(self._oldProp[i].value)
			else
				self._ccbOwner["tf_old_value_"..i]:setString(0)
			end
		else
			self._ccbOwner["node_prop_"..i]:setVisible(false)
		end
	end
end

function QUIDialogSparAbsorbSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSparAbsorbSuccess:_onTriggerClose()
	print("self._animationStage = "..self._animationStage )
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "2"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			self._animationStage = "2"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "2" then
			self._animationStage = "3"
			self._animationManager:runAnimationsForSequenceNamed("3")	
		else
			self._animationStage = "4"
			self._animationManager:runAnimationsForSequenceNamed("4")
			self._isEnd = true
		end
	end
end

function QUIDialogSparAbsorbSuccess:viewAnimationOutHandler()
	local callback = self.callback
	self:popSelf()
    if callback ~= nil then
    	callback()
    end
end


return QUIDialogSparAbsorbSuccess