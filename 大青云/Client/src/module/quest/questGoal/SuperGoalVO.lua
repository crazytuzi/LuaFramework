--[[
任务目标:卓越
lizhuangzhuang
2015年8月2日15:56:51
]]

_G.SuperGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function SuperGoalVO:GetType()
	return QuestConsts.GoalType_Super;
end

function SuperGoalVO:CreateGoalParam()
	return nil;
end

function SuperGoalVO:CreateGuideParam()
	return nil;
end

function SuperGoalVO:DoGoal()
	if ZhuoyueGuideModel:GetState() == 1 then
		ZhuoyueGuideController:GetReward();
	else
		UIZhuoyueGuide:Show();
	end
	ZhuoyueGuideController:CloseGuide();
end
