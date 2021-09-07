-- region *.lua
-- Date jia 2017-4-25
-- endregion 套娃 model
DollsRandomModel = DollsRandomModel or BaseClass()

function DollsRandomModel:__init()
    self.curRewardLevel = 1
    self.curRewardShowLevel = 1  --显示奖励的等级
    self.rewardsList = {}
    self.lastRewardList = {}
end

function DollsRandomModel:__delete()
    self:CloseRewardPanel()
    self:CloseWindow()
end

function DollsRandomModel:OpenRewardPanel(openData)
    if self.rewarPanel == nil then
        local parent = CampaignManager.Instance.model.secondaryWin
        self.rewarPanel = DollsRandomRewardPanel.New(parent)
	end
	self.rewarPanel:Show(openData)
end

function DollsRandomModel:CloseRewardPanel()
    if self.rewarPanel ~= nil then
        self.rewarPanel:DeleteMe()
        self.rewarPanel = nil
    end
end

function DollsRandomModel:ResetRewardList()
    if self.rewardsList ~= nil then
        table.sort(self.rewardsList, function(a,b) return a.times < b.times end)
    end
end
