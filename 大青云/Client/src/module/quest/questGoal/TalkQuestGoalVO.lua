--[[
对话类任务目标
lizhuangzhuang
2014年9月11日15:16:03
]]

_G.TalkQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function TalkQuestGoalVO:GetType()
	return QuestConsts.GoalType_Talk;
end

-- 是否可传送
function TalkQuestGoalVO:CanTeleport()
	return true
end