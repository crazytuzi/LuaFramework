local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerRewardRulesReward = class("QUIWidgetGloryTowerRewardRulesReward", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetGloryTowerRewardRulesReward:ctor(options)
    local ccbFile = "ccb/Widget_GloryTower_explain2.ccbi"
    local callBacks = {}
    QUIWidgetGloryTowerRewardRulesReward.super.ctor(self, ccbFile, callBacks, options)

end
function QUIWidgetGloryTowerRewardRulesReward:setInfo( info )
  -- body
    self._ccbOwner.gradeExplainStr:setString(info.gradeName..":"..info.explain)
    
    self._ccbOwner.upIcon:setVisible(false)
    self._ccbOwner.downIcon:setVisible(false)
    if info.crownIcon then
        if info.crownIcon.upIcon then
            self._ccbOwner.upIcon:setVisible(true)
            self._ccbOwner.upIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(info.crownIcon.upIcon))
        end
        if info.crownIcon.downIcon then
            self._ccbOwner.downIcon:setVisible(true)
            self._ccbOwner.downIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(info.crownIcon.downIcon))
        end
    end
end

function QUIWidgetGloryTowerRewardRulesReward:getContentSize(  )
  -- body
    return self._ccbOwner.nodeSize:getContentSize()

end

return QUIWidgetGloryTowerRewardRulesReward