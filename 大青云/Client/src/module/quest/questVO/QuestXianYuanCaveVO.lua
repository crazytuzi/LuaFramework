--[[
经验副本
]]

_G.QuestXianYuanCaveVO = setmetatable({}, { __index = QuestVO })

function QuestXianYuanCaveVO:GetType()
	return QuestConsts.Type_XianYuanCave;
end

function QuestXianYuanCaveVO:GetGoalType()
	return 0;
end

function QuestXianYuanCaveVO:GetId()
	return self.id;
end

function QuestXianYuanCaveVO:GetState()
	return self.state;
end

function QuestXianYuanCaveVO:CreateQuestGoal()
	return nil;
end

function QuestXianYuanCaveVO:GetTitleLabel()
	local leftMin = XianYuanUtil:GetLeftTime();
	local leftTimeStr = string.format(StrConfig['quest929'], leftMin);

	--	local timeAvailable = WaterDungeonModel:GetDayFreeTime()
	--	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest928"]) -- 中间的空格是留给任务图标的
	--	return txtTitle .. leftTimes;
	return txtTitle .. leftTimeStr;
end

function QuestXianYuanCaveVO:GetPlayRefresh()
	return false;
end

function QuestXianYuanCaveVO:GetPlayRewardEffect()
	return false;
end

function QuestXianYuanCaveVO:HasContent()
	return false;
end

function QuestXianYuanCaveVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.DaBaoMiJing);
end