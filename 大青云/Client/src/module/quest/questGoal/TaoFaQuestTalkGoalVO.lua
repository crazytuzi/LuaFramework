--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/7
    Time: 11:53
   ]]

_G.TaoFaQuestTalkGoalVO = setmetatable({},{__index=QuestGoalVO});


function TaoFaQuestTalkGoalVO:GetType()
	return QuestConsts.GoalType_TaoFaQuestTalk;
end


function TaoFaQuestTalkGoalVO:CreateGoalParam()
	return nil;
end

function TaoFaQuestTalkGoalVO:CreateGuideParam()
	return nil;
end

function TaoFaQuestTalkGoalVO:GetLabelContent()
	local questVO = self.questVO
	if not questVO then return end
	local npcCFG = t_npc[questVO:GetCurrNPC()];
	local npcName = npcCFG and npcCFG.name or "";
	return string.format(questVO:GetCfg().finishLink, questVO:ParseQuestLink(npcName));
end

function TaoFaQuestTalkGoalVO:GetTreeDataCount()
	return ""
end

function TaoFaQuestTalkGoalVO:DoGoal()
	local questVO = self.questVO;
	if not questVO then return end
	questVO:DoRunToNpc();
end

-- 是否可传送
function TaoFaQuestTalkGoalVO:CanTeleport()
	local questVO = self.questVO;
	if not questVO then return end
	return questVO:CanTeleport();
end

function TaoFaQuestTalkGoalVO:GetPos()
	local questVO = self.questVO;
	if not questVO then return end
	return questVO:GetNPCPos();
end