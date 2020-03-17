--[[
奇遇任务对话类任务目标
2015年7月31日10:20:11
haohu
]]
--------------------------------------------------------------

_G.RandomTalkGoalVO = setmetatable( {}, { __index = QuestGoalVO } )

function RandomTalkGoalVO:GetType()
	return QuestConsts.GoalType_RandomTalk
end

function RandomTalkGoalVO:CreateGoalParam()
	return {}
end

function RandomTalkGoalVO:CreateGuideParam()
	return {}
end

-- 是否可传送
function RandomTalkGoalVO:CanTeleport()
	return true
end