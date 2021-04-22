local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRuleClient = class("QUIWidgetRuleClient", QUIWidget)

local QUIDialogRule = import("..dialogs.QUIDialogRule")

function QUIWidgetRuleClient:ctor(options)
    local ccbFile = "ccb/Widget_SunWell_Rule.ccbi"
    if options ~= nil then
  		self._ruleType = options.ruleType
  	end

	if self._ruleType == QUIDialogRule.GLORYTOWER_RULE then
		ccbFile = "ccb/Widget_GloryTower_rule.ccbi"
	elseif self._ruleType == QUIDialogRule.INVASION_RULE then
		ccbFile = "ccb/Widget_Panjun_rule.ccbi"
	end
  	local callBack = {}
  	QUIWidgetRuleClient.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetRuleClient:getContentHeight()
	if self._ruleType == QUIDialogRule.GLORYTOWER_RULE then
		return 350
	elseif self._ruleType == QUIDialogRule.SUNWELL_RULE then
		return 360
	elseif self._ruleType == QUIDialogRule.INVASION_RULE then
		return 460
	end
end

return QUIWidgetRuleClient