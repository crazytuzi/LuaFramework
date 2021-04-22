local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEnchantInfo = class("QUIDialogEnchantInfo", QUIDialog)
local QScrollContain = import("..QScrollContain")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetEnchantInfo = import("..widgets.QUIWidgetEnchantInfo")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogEnchantInfo:ctor(options)
    local ccbFile = "ccb/Dialog_fumostar.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogEnchantInfo._onTriggerClose)}
    }
    QUIDialogEnchantInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    self._contain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})

	self._actorId = options.actorId
	self._itemId = options.itemId
	self._level = options.level

	self._ccbOwner.frame_tf_title:setString("觉醒效果")

    self:initPage()
end

function QUIDialogEnchantInfo:viewDidAppear()
	QUIDialogEnchantInfo.super.viewDidAppear(self)
end

function QUIDialogEnchantInfo:viewWillDisappear()
	QUIDialogEnchantInfo.super.viewWillDisappear(self)
	if self._contain ~= nil then
		self._contain:disappear()
		self._contain = nil
	end
end

function QUIDialogEnchantInfo:initPage()
	local enchants = QStaticDatabase:sharedDatabase():getEnchants(self._itemId, self._actorId)
	local height = 0
	for index,config in ipairs(enchants) do
		local widget = QUIWidgetEnchantInfo.new()
		widget:setInfo(config,self._level,index)
		widget:setPositionY(-height)
		height = widget:getContentSize().height + height
		self._contain:addChild(widget)
	end
	local size = self._contain:getContentSize()
	size.height = height
	self._contain:setContentSize(size.width, size.height)
end

function QUIDialogEnchantInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogEnchantInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogEnchantInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogEnchantInfo