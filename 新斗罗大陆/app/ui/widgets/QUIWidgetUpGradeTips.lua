local QUIWidget = import(".QUIWidget")
local QUIWidgetUpGradeTips = class("QUIWidgetUpGradeTips", QUIWidget)

function QUIWidgetUpGradeTips:ctor(options)
  local ccbFile = "ccb/Widget_HeroUpgarde_tis2.ccbi"
  local callBacks = {}
  QUIWidgetUpGradeTips.super.ctor(self, ccbFile, callBacks, options)
  
--  local bg_delayTime = CCDelayTime:create(time)
--  local bg_fadeOut = CCFadeOut:create(0.3)
--  local bg_fadeAction = CCArray:create()
--  bg_fadeAction:addObject(bg_delayTime)
--  bg_fadeAction:addObject(bg_fadeOut)
--  local bg_ccsequence = CCSequence:create(bg_fadeAction)
  
--  self._ccbOwner.up_grade:runAction(CCFadeOut:create(0.3))
  
end

return QUIWidgetUpGradeTips