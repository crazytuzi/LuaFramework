--[[
前往坐标类任务目标
lizhuangzhuang
2014年9月11日16:01:44
]]

_G.GoPosQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function GoPosQuestGoalVO:GetType()
	return QuestConsts.GoalType_GoPos;
end

function GoPosQuestGoalVO:GetTotalCount()
	return 1;
end

function GoPosQuestGoalVO:GetLabelContent()
	if not self.goalParam[1] then return""; end
	local posCfg = t_position[toint(self.goalParam[1])];
	if not posCfg then return ""; end
	local name = "<u><font color='"..self.linkColor.."'>"..posCfg.name.."</font></u>";
	local questCfg = self.questVO:GetCfg();
	return string.format(questCfg.unFinishLink,name);
end

function GoPosQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0));
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPos(point);
end

-- 是否可传送
function GoPosQuestGoalVO:CanTeleport()
	return true
end

function GoPosQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = toint( guideParam );
	return QuestUtil:GetQuestPos(posId);
end