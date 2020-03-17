--[[
主宰之路层数达到
lizhuangzhuang
2015-10-5 21:22:04
]]

_G.DominateRoadFloorGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DominateRoadFloorGoalVO:GetType()
	return QuestConsts.GoalType_DominateRoadFloor;
end

--设置进度
function DominateRoadFloorGoalVO:SetCurrCount(count)
	self.currCount = count % 10000;
end

--任务目标需要完成的总数量
function DominateRoadFloorGoalVO:GetTotalCount()
	local roadId = tonumber( self.goalParam[1] ) or 0
	return roadId % 10000
end

function DominateRoadFloorGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.DominateRoute )
end