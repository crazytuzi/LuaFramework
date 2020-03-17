--[[
    Created by IntelliJ IDEA.
    竞技场
    User: Hongbin Yang
    Date: 2016/12/5
    Time: 16:40
   ]]


_G.QuestArenaVO = setmetatable({}, { __index = QuestVO })

function QuestArenaVO:GetType()
	return QuestConsts.Type_Arena;
end

function QuestArenaVO:GetGoalType()
	return 0;
end

function QuestArenaVO:GetId()
	return self.id;
end

function QuestArenaVO:GetState()
	return self.state;
end

function QuestArenaVO:CreateQuestGoal()
	return nil;
end

function QuestArenaVO:GetTitleLabel()
	local timeAvailable = ArenaModel:GetLeftTimes();
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest942"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestArenaVO:GetPlayRefresh()
	return false;
end

function QuestArenaVO:GetPlayRewardEffect()
	return false;
end

function QuestArenaVO:HasContent()
	return false;
end

function QuestArenaVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.Arena, false);
end