--[[
打怪副本任务目标
lizhuangzhuang
2015年5月7日11:29:01
]]

_G.FuBenQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function FuBenQuestGoalVO:GetType()
	return QuestConsts.GoalType_FuBen;
end

function FuBenQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function FuBenQuestGoalVO:CreateGoalParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	local goals = GetPoundTable(cfg.questGoals);
	local goal = goals[1];
	if #goals>1 then
		goal = goals[MainPlayerModel.humanDetailInfo.eaProf];
	end
	return split( goal, "," )
end

function FuBenQuestGoalVO:CreateGuideParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	local guides = GetPoundTable(cfg.guideParam);
	local guide = guides[1];
	if #guides>1 then
		guide = guides[MainPlayerModel.humanDetailInfo.eaProf];
	end
	return split( guide, "," );
end

function FuBenQuestGoalVO:GetLabelContent()
	if not self.goalParam[1] then return""; end
	local monsterCfg = t_monster[toint(self.goalParam[1])];
	if not monsterCfg then return ""; end
	local monsterName = "<u><font color='"..self.linkColor.."'>"..monsterCfg.name.."</font></u>";
	local questCfg = self.questVO:GetCfg();
	return string.format(questCfg.unFinishLink,monsterName);
end

function FuBenQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

function FuBenQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = toint( guideParam );
	return QuestUtil:GetQuestPos(posId);
end