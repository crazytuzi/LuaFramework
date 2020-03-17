--[[
送信类任务目标
lizhuangzhuang
2014年9月11日16:00:18
]]

_G.SendMailQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function SendMailQuestGoalVO:GetType()
	return QuestConsts.GoalType_SendMail;
end

function SendMailQuestGoalVO:GetTotalCount()
	return 1;
end