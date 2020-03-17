--[[
参加活动类任务目标
haohu
2015年5月15日21:11:20
]]

_G.ActivityGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function ActivityGoalVO:GetType()
	return QuestConsts.GoalType_Activity;
end

--活动类型
function ActivityGoalVO:GetActivityType()
	return tonumber(self.goalParam[1]);
end

--任务目标需要完成的总数量
function ActivityGoalVO:GetTotalCount()
	return tonumber( self.goalParam[2] ) or 0;
end

--执行目标指引
function ActivityGoalVO:DoGoal()
	local activityType = self:GetActivityType()
	local funcId = 0
	if activityType == 1 then -- 1为世界boss活动类型,世界boss 主UI与其他活动不一样，所以加这个判断
		funcId = FuncConsts.WorldBoss
	else
		funcId = FuncConsts.Activity
	end
	FuncManager:OpenFunc( funcId )
end