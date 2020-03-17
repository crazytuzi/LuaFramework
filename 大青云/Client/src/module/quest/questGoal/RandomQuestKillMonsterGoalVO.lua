--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/9/3
    Time: 14:29
   ]]
_G.RandomQuestKillMonsterGoalVO = setmetatable({},{__index=QuestGoalVO});

function RandomQuestKillMonsterGoalVO:GetType()
	return QuestConsts.GoalType_RandomKillMonster;
end

function RandomQuestKillMonsterGoalVO:CreateGoalParam()
	return nil;
end

function RandomQuestKillMonsterGoalVO:CreateGuideParam()
	return nil;
end

function RandomQuestKillMonsterGoalVO:GetTotalCount()
	local questVO = self.questVO
	if not questVO then return end
	return questVO:GetMonsterCount();
end

function RandomQuestKillMonsterGoalVO:GetLabelContent()
	local questVO = self.questVO
	if not questVO then return end
	if not questVO:GetMonsterID() then return; end
	local monsterName = t_monster[questVO:GetMonsterID()].name;

	return StrConfig["randomQuest201"] .. string.format(StrConfig["randomQuest202"], QuestColor.COLOR_GREEN, QuestColor.CONTENT_FONTSIZE, monsterName);
end

function RandomQuestKillMonsterGoalVO:GetNoticeLable()
	return StrConfig['quest1003'] .. t_monster[self.questVO:GetMonsterID()].name .. string.format("(%s/%s)", self.currCount, self:GetTotalCount())
end

function RandomQuestKillMonsterGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x+2,point.y+2,0),completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil);
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPosAttack(point);
end

-- 是否可传送
function RandomQuestKillMonsterGoalVO:CanTeleport()
	return true
end

function RandomQuestKillMonsterGoalVO:GetPos()
	local questVO = self.questVO
	if not questVO then return end
	if not questVO:GetMonsterPos() then return; end
	return QuestUtil:GetQuestPos(questVO:GetMonsterPos());
end