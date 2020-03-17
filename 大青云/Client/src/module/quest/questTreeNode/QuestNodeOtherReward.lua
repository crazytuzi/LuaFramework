--[[
主界面任务追踪树节点：任务其他奖励(对应任务表otherReward, 物品奖励)
2015年5月19日11:22:19
haohu
]]

_G.QuestNodeOtherReward = QuestNode:new( QuestNodeConst.Node_OtherReward )

-- content = questVO

function QuestNodeOtherReward:GetLabel()
	local quest = self:GetContent()
	local label =  quest:GetOtherRewardLabel();
	return string.format( "   %s", label ); -- 内容节点缩进一个字
end

-- 获取任务类型
function QuestNodeOtherReward:GetQuestType()
	local quest = self:GetContent();
	return quest:GetType()
end