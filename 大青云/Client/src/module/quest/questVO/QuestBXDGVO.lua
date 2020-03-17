--[[
经验副本
]]

_G.QuestBXDGVO = setmetatable({}, { __index = QuestVO })

function QuestBXDGVO:GetType()
	return QuestConsts.Type_BXDG;
end

function QuestBXDGVO:GetGoalType()
	return 0;
end

function QuestBXDGVO:GetId()
	return self.id;
end

function QuestBXDGVO:GetState()
	return self.state;
end

function QuestBXDGVO:CreateQuestGoal()
	return nil;
end

function QuestBXDGVO:GetTitleLabel()
	local timeAvailable = DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_BXDG)
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest933"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestBXDGVO:GetPlayRefresh()
	return false;
end

function QuestBXDGVO:GetPlayRewardEffect()
	return false;
end

function QuestBXDGVO:HasContent()
	return false;
end

function QuestBXDGVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.singleDungeon, false, DungeonConsts.SingleDungeon_BXDG);
end