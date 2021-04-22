local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerRewardRulesHead = class("QUIWidgetGloryTowerRewardRulesHead", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")


function QUIWidgetGloryTowerRewardRulesHead:ctor(options)
  local ccbFile = "ccb/Widget_GloryTower_explain1.ccbi"
  local callBacks = {}
  QUIWidgetGloryTowerRewardRulesHead.super.ctor(self, ccbFile, callBacks, options)

end
function QUIWidgetGloryTowerRewardRulesHead:setInfo( info )
  -- body
    local rewardInfo = info.rewardInfo
    self._ccbOwner.topGradeName:setString(info.gradeName or "")

    if rewardInfo then
        if not self._rewardItems then
            self._rewardItems = {}
            for i = 1, 5, 1 do
                self._rewardItems[i] = QUIWidgetItemsBox.new()
                self._ccbOwner["item"..i]:addChild(self._rewardItems[i])
                self._rewardItems[i]:setVisible(false)
            end
        end
        self._ccbOwner.rewardParent:setVisible(true)
        self._ccbOwner.canNotGetReward:setVisible(false)
        for i = 1,5,1 do
            if rewardInfo["num_"..i] then
                if rewardInfo["id_"..i] then
                    self._rewardItems[i]:setGoodsInfo(rewardInfo["id_"..i],ITEM_TYPE.ITEM, 0)
                else
                    self._rewardItems[i]:setGoodsInfo(rewardInfo["id_"..i],rewardInfo["type_"..i], 0)
                end
                self._ccbOwner["reward_nums"..i]:setString("x"..rewardInfo["num_"..i])
                self._rewardItems[i]:setBoxScale(0.35)
                self._rewardItems[i]:setVisible(true)
                self._ccbOwner["reward_nums"..i]:setVisible(true)
            else
                self._ccbOwner["reward_nums"..i]:setVisible(false)
                self._rewardItems[i]:setVisible(false)
            end
        end
    else
        self._ccbOwner.rewardParent:setVisible(false)
        self._ccbOwner.canNotGetReward:setVisible(true)
        
    end

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

function QUIWidgetGloryTowerRewardRulesHead:getContentSize(  )
  -- body
    return self._ccbOwner.nodeSize:getContentSize()

end

return QUIWidgetGloryTowerRewardRulesHead