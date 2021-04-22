--
-- Author: xurui
-- Date: 2016-06-21 17:10:28
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerRewardRulesReward2 = class("QUIWidgetGloryTowerRewardRulesReward2", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetGloryTowerRewardRulesReward2:ctor(options)
    local ccbFile = "ccb/Widget_GloryTower_explain5.ccbi"
    local callBacks = {}
    QUIWidgetGloryTowerRewardRulesReward2.super.ctor(self, ccbFile, callBacks, options)

end
function QUIWidgetGloryTowerRewardRulesReward2:setInfo( info )
  -- body
    self._ccbOwner.gradeExplainStr:setString(info.explain or "")

    if not self._rewardItems then
        self._rewardItems = {}
        for i = 1, 4, 1 do
            self._rewardItems[i] = QUIWidgetItemsBox.new()
            self._ccbOwner["item"..i]:addChild(self._rewardItems[i])
            self._rewardItems[i]:setVisible(false)
        end
    end

    local rewardInfo = info.rewardInfo
    for i = 1,4,1 do
        if rewardInfo["num_"..i] then
            if rewardInfo["id_"..i] then
                self._rewardItems[i]:setGoodsInfo(rewardInfo["id_"..i],ITEM_TYPE.ITEM, 0)
            else
                self._rewardItems[i]:setGoodsInfo(rewardInfo["id_"..i],rewardInfo["type_"..i], 0)
            end
            self._ccbOwner["reward_nums"..i]:setString("x"..rewardInfo["num_"..i])
            self._rewardItems[i]:setBoxScale(0.3)
            self._rewardItems[i]:setVisible(true)
            self._ccbOwner["reward_nums"..i]:setVisible(true)
            self._ccbOwner["reward_nums"..i]:setScale(0.8)
        else
            self._ccbOwner["reward_nums"..i]:setVisible(false)
            self._rewardItems[i]:setVisible(false)
        end
    end
end

function QUIWidgetGloryTowerRewardRulesReward2:getContentSize(  )
  -- body
    return self._ccbOwner.nodeSize:getContentSize()

end

return QUIWidgetGloryTowerRewardRulesReward2