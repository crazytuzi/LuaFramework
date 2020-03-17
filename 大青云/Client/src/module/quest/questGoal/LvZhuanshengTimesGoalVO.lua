--[[
转生次数达到
lizhuangzhuang
2015-10-5 21:28:15
]]

_G.ZhuanshengTimesGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function ZhuanshengTimesGoalVO:GetType()
	return QuestConsts.GoalType_ZhuanshengTimes;
end

function ZhuanshengTimesGoalVO:DoGoal()
	-- ZhuanContoller:ShowOpenView(true);
end