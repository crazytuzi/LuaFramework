--[[
经验副本
]]

_G.QuestSGZCVO = setmetatable({}, { __index = QuestVO })

function QuestSGZCVO:GetType()
	return QuestConsts.Type_SGZC;
end

function QuestSGZCVO:GetGoalType()
	return 0;
end

function QuestSGZCVO:GetId()
	return self.id;
end

function QuestSGZCVO:GetState()
	return self.state;
end

function QuestSGZCVO:CreateQuestGoal()
	return nil;
end

function QuestSGZCVO:GetTitleLabel()
	local timeAvailable = DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_SGZC)
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest934"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestSGZCVO:GetPlayRefresh()
	return false;
end

function QuestSGZCVO:GetPlayRewardEffect()
	return false;
end

function QuestSGZCVO:HasContent()
	return false;
end

function QuestSGZCVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.singleDungeon, false, DungeonConsts.SingleDungeon_SGZC);
end