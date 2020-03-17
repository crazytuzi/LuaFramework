--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/7
    Time: 11:53
   ]]

_G.AgoraQuestTalkGoalVO = setmetatable({},{__index=QuestGoalVO});


function AgoraQuestTalkGoalVO:GetType()
	return QuestConsts.GoalType_AgoraQuestTalk;
end


function AgoraQuestTalkGoalVO:CreateGoalParam()
	return nil;
end

function AgoraQuestTalkGoalVO:CreateGuideParam()
	return nil;
end

function AgoraQuestTalkGoalVO:GetLabelContent()
	local questVO = self.questVO
	if not questVO then return end
	local npcCFG = t_npc[questVO:GetCurrNPC()];
	local npcName = npcCFG and npcCFG.name or "";
	return string.format(questVO:GetCfg().finishLink, questVO:ParseQuestLink(npcName));
end

function AgoraQuestTalkGoalVO:GetTreeDataCount()
	return ""
end

function AgoraQuestTalkGoalVO:DoGoal()
	local questVO = self.questVO;
	if not questVO then return end
	questVO:DoRunToNpc();
end

-- 是否可传送
function AgoraQuestTalkGoalVO:CanTeleport()
	local questVO = self.questVO;
	if not questVO then return end
	return questVO:CanTeleport();
end

function AgoraQuestTalkGoalVO:GetPos()
	local questVO = self.questVO;
	if not questVO then return end
	return questVO:GetNPCPos();
end