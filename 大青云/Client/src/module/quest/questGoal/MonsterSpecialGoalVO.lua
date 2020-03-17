--[[
特殊杀怪类任务目标
haohu
2015年8月10日20:36:30
]]

_G.MonsterSpecialGoalVO = setmetatable({},{__index=QuestGoalVO});

function MonsterSpecialGoalVO:GetType()
	return QuestConsts.GoalType_SpecialMonster;
end

function MonsterSpecialGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function MonsterSpecialGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg()
	return questCfg.unFinishLink
end

function MonsterSpecialGoalVO:DoGoal()
	local point = self:GetPos()
	if not point then return end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new(point.x, point.y, 0), completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil );
end

-- 是否可传送
function MonsterSpecialGoalVO:CanTeleport()
	return true
end

function MonsterSpecialGoalVO:GetPos()
	local guideParam = self.guideParam[1]
	if not guideParam then return end
	local posId = tonumber( guideParam )
	return QuestUtil:GetQuestPos(posId)
end