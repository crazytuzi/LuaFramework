--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/9/5
    Time: 20:43
   ]]

_G.RandomQuestNoneGoalVO = setmetatable({},{__index=QuestGoalVO});

function RandomQuestNoneGoalVO:GetType()
	return QuestConsts.GoalType_RandomNone;
end

function RandomQuestNoneGoalVO:CreateGoalParam()
	return nil;
end

function RandomQuestNoneGoalVO:CreateGuideParam()
	return nil;
end

function RandomQuestNoneGoalVO:GetLabelContent()
	local questVO = self.questVO
	if not questVO then return end
	return string.format(StrConfig["randomQuest202"], QuestColor.COLOR_GREEN, QuestColor.CONTENT_FONTSIZE, StrConfig["randomQuest203"]);
end

function RandomQuestNoneGoalVO:DoGoal()
	FuncManager:OpenFunc(FuncConsts.QuestRandom, true);
end