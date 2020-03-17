--[[
经验副本
]]

_G.QuestBabelVO = setmetatable({}, { __index = QuestVO })

function QuestBabelVO:GetType()
	return QuestConsts.Type_Babel;
end

function QuestBabelVO:GetGoalType()
	return 0;
end

function QuestBabelVO:GetId()
	return self.id;
end

function QuestBabelVO:GetState()
	return self.state;
end

function QuestBabelVO:CreateQuestGoal()
	return nil;
end

function QuestBabelVO:GetTitleLabel()
	local timeAvailable = BabelModel:GetTotalTimesAvailable()
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest930"]) -- 中间的空格是留给任务图标的
	local canAttack = StrConfig["quest935"];
	return txtTitle .. canAttack;
end

function QuestBabelVO:GetPlayRefresh()
	return false;
end

function QuestBabelVO:GetPlayRewardEffect()
	return false;
end

function QuestBabelVO:HasContent()
	return false;
end

function QuestBabelVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.Babel);
end