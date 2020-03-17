--[[
杀怪收集类任务目标
lizhuangzhuang
2014年9月11日15:52:58
]]

_G.MonsterCollectQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function MonsterCollectQuestGoalVO:GetType()
	return QuestConsts.GoalType_KillMonsterCollect;
end

function MonsterCollectQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function MonsterCollectQuestGoalVO:GetLabelContent()
	if not self.goalParam[4] then return ""; end
	local itemCfg = t_item[toint(self.goalParam[4])];
	if not itemCfg then return""; end
	local name = "<u><font color='"..self.linkColor.."'>"..itemCfg.name.."</font></u>";
	local questCfg = self.questVO:GetCfg();
	return string.format(questCfg.unFinishLink,name);
end

function MonsterCollectQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x+2,point.y+2,0),completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil);
end

-- 是否可传送
function MonsterCollectQuestGoalVO:CanTeleport()
	return true
end

function MonsterCollectQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = toint( guideParam );
	return QuestUtil:GetQuestPos(posId);
end