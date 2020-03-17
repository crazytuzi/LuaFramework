--[[
经验副本
]]

_G.QuestGodDynastyVO = setmetatable({}, { __index = QuestVO })

function QuestGodDynastyVO:GetType()
	return QuestConsts.Type_GodDynasty;
end

function QuestGodDynastyVO:GetGoalType()
	return 0;
end

function QuestGodDynastyVO:GetId()
	return self.id;
end

function QuestGodDynastyVO:GetState()
	return self.state;
end

function QuestGodDynastyVO:CreateQuestGoal()
	return nil;
end

function QuestGodDynastyVO:GetTitleLabel()
	local canIn = DungeonUtils:CheckGodDynastyDungen();
	local leftTimes = ""
	if canIn then
		leftTimes = string.format(StrConfig["quest931"], timeAvailable);
	end
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest932"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestGodDynastyVO:GetPlayRefresh()
	return false;
end

function QuestGodDynastyVO:GetPlayRewardEffect()
	return false;
end

function QuestGodDynastyVO:HasContent()
	return false;
end

function QuestGodDynastyVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.zhuxianDungeon);
end