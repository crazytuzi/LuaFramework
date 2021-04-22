local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerRewardRulesSeparator = class("QUIWidgetGloryTowerRewardRulesSeparator", QUIWidget)



function QUIWidgetGloryTowerRewardRulesSeparator:ctor(options)
  local ccbFile = "ccb/Widget_GloryTower_explain3.ccbi"
  local callBacks = {}
  QUIWidgetGloryTowerRewardRulesSeparator.super.ctor(self, ccbFile, callBacks, options)

end
function QUIWidgetGloryTowerRewardRulesSeparator:setInfo( info )
  -- body
    self._ccbOwner.separatorName:setString(info.name)

end

function QUIWidgetGloryTowerRewardRulesSeparator:getContentSize(  )
  -- body
    return self._ccbOwner.nodeSize:getContentSize()

end

return QUIWidgetGloryTowerRewardRulesSeparator