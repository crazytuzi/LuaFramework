local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRule = class("QUIDialogRule", QUIDialog)

local QUIWidgetRuleClient = import("..widgets.QUIWidgetRuleClient")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QScrollView = import("...views.QScrollView")

QUIDialogRule.SUNWELL_RULE = "SUNWELL_RULE"
QUIDialogRule.GLORYTOWER_RULE = "GLORYTOWER_RULE"
QUIDialogRule.INVASION_RULE = "INVASION_RULE"

function QUIDialogRule:ctor(options)
	local ccbFile = "ccb/Dialog_SunWell_Rule.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogRule._onTriggerClose)}
	}
	QUIDialogRule.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	if options ~= nil then
		self._ruleType = options.ruleType
	end

	self._height = self._ccbOwner.sheet_layout:getContentSize().height
    self._width = self._ccbOwner.sheet_layout:getContentSize().width

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {sensitiveDistance = 10})
   -- self._scrollView:setGradient(true)
    self._scrollView:setVerticalBounce(true)

    self:initPage()
end

function QUIDialogRule:viewDidAppear()
	QUIDialogRule.super.viewDidAppear(self)
end

function QUIDialogRule:viewWillDisappear()
	QUIDialogRule.super.viewWillDisappear(self)
end

function QUIDialogRule:initPage()
	self._totalHeight = 0
	self._client = QUIWidgetRuleClient.new({ruleType = self._ruleType})
	self._totalHeight = self._client:getContentHeight()
	self._totalWidth= 790      
    self._scrollView:addItemBox(self._client)
    self._scrollView:setRect(0, -self._totalHeight, 0, -self._totalWidth)
end

function QUIDialogRule:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRule:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRule:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogRule
