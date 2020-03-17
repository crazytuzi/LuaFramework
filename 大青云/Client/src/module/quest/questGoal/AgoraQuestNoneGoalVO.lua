--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/9/5
    Time: 20:43
   ]]

_G.AgoraQuestNoneGoalVO = setmetatable({},{__index=QuestGoalVO});

function AgoraQuestNoneGoalVO:GetType()
	return QuestConsts.GoalType_AgoraNone;
end

function AgoraQuestNoneGoalVO:CreateGoalParam()
	return nil;
end

function AgoraQuestNoneGoalVO:CreateGuideParam()
	return nil;
end

function AgoraQuestNoneGoalVO:GetLabelContent()
	local questVO = self.questVO
	if not questVO then return end
	return string.format(StrConfig["agoraQuest001"], QuestColor.COLOR_GREEN, QuestColor.CONTENT_FONTSIZE, StrConfig["agoraQuest002"]);
end

function AgoraQuestNoneGoalVO:DoGoal()
	FuncManager:OpenFunc(FuncConsts.Agora, true);
end