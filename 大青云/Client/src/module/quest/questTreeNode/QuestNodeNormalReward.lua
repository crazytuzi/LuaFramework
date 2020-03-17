--[[
主界面任务追踪树节点：任务一般奖励(对应任务表经验、金钱、灵力奖励)
2015年5月19日11:22:19
haohu
]]

_G.QuestNodeNormalReward = QuestNode:new( QuestNodeConst.Node_NormalReward )

-- content = questVO

function QuestNodeNormalReward:OnCreate()
	self:AddSubNode( QuestNodeEmpty:new() ) --有图标,占2格,所以加一个空节点
end

-- 获取任务类型
function QuestNodeNormalReward:GetQuestType()
	local quest = self:GetContent()
	return quest:GetType()
end

function QuestNodeNormalReward:GetRewardUIData()
	local quest = self:GetContent()
	return quest:GetRewardUIData()
end

function QuestNodeNormalReward:GetIsDisabled()
	return true
end

function QuestNodeNormalReward:OnRewardRollOver(e)
	RewardManager:OnRewardItemOver(e)
end

function QuestNodeNormalReward:OnRewardRollOut(e)
	RewardManager:OnRewardItemOut(e)
end
