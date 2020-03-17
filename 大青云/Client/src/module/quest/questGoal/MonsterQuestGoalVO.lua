--[[
杀怪类任务目标
lizhuangzhuang
2014年9月11日15:51:13
]]

_G.MonsterQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function MonsterQuestGoalVO:GetType()
	return QuestConsts.GoalType_KillMonster;
end

function MonsterQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function MonsterQuestGoalVO:CreateGoalParam()
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

function MonsterQuestGoalVO:CreateGuideParam()
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

function MonsterQuestGoalVO:GetLabelContent()
	if not self.goalParam[1] then return""; end
	local monsterCfg = t_monster[toint(self.goalParam[1])];
	if not monsterCfg then return ""; end
	local monsterName = string.format( "<u><font color='%s'>%s</font></u>", self.linkColor, monsterCfg.name );
	local questCfg = self.questVO:GetCfg();
	return string.format( questCfg.unFinishLink, monsterName );
end

function MonsterQuestGoalVO:GetNoticeLable()
	return string.format( self.questVO:GetCfg().unFinishLink, t_monster[toint(self.goalParam[1])].name) .. string.format("(%s/%s)", self.currCount, self:GetTotalCount())
end

function MonsterQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	self.monsterPos = nil;
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x+2,point.y+2,0),completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil);
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPosAttack(point);
end

-- 是否可传送
function MonsterQuestGoalVO:CanTeleport()
	return true
end
MonsterQuestGoalVO.monsterPos = nil;
function MonsterQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = tonumber( guideParam );
	if not self.monsterPos then
		self.monsterPos = QuestUtil:GetQuestPos(posId)
	end
	return self.monsterPos;
end