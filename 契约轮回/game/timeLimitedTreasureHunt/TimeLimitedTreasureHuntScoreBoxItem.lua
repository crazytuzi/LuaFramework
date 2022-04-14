--限时寻宝奖励积分宝箱Item
TimeLimitedTreasureHuntScoreBoxItem = TimeLimitedTreasureHuntScoreBoxItem or class("TimeLimitedTreasureHuntScoreBoxItem",TimeLimitedRushScoreBoxItem)

function TimeLimitedTreasureHuntScoreBoxItem:ctor(parent_node)
    self.abName = "TimeLimitedTreasureHunt"
    self.assetName = "TimeLimitedTreasureHuntScoreBoxItem"
    self.layer = "UI"
end

function TimeLimitedTreasureHuntScoreBoxItem:dctor()

end

function TimeLimitedTreasureHuntScoreBoxItem:InitUI(  )
    self.img_score_box = GetImage(self.img_score_box)
    self.txt_score = GetText(self.txt_score)

    SetVisible(self.preview_parent,false)
    SetVisible(self.received,false)
end

