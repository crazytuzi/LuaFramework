--[[
杀怪类任务目标
lizhuangzhuang
2014年9月11日15:51:13
]]

_G.AgoraMonsterQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function AgoraMonsterQuestGoalVO:GetType()
	return QuestConsts.GoalType_AgoraKillMonster;
end

function AgoraMonsterQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function AgoraMonsterQuestGoalVO:CreateGoalParam()
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
function AgoraMonsterQuestGoalVO:CreateGuideParam()
	return nil;
end
function AgoraMonsterQuestGoalVO:GetLabelContent()
	if not self.goalParam[1] then return""; end
	local monsterCfg = t_monster[toint(self.goalParam[1])];
	if not monsterCfg then return ""; end
	local monsterName = string.format( "<u><font color='%s'>%s</font></u>", self.linkColor, monsterCfg.name );
	local questCfg = self.questVO:GetCfg();
	return string.format( questCfg.finishLink, monsterName);
end

function AgoraMonsterQuestGoalVO:GetNoticeLable()
	return string.format( self.questVO:GetCfg().finishLink, t_monster[toint(self.goalParam[1])].name ) .. string.format("(%s/%s)", self.currCount, self:GetTotalCount())
end

function AgoraMonsterQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x+2,point.y+2,0),completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil);
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPosAttack(point);
end

-- 是否可传送
function AgoraMonsterQuestGoalVO:CanTeleport()
	return true
end

function AgoraMonsterQuestGoalVO:GetPos()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg();
	if not cfg then return; end
	local point = QuestUtil:GetQuestPos(toint(cfg.postion));
	return point;
end