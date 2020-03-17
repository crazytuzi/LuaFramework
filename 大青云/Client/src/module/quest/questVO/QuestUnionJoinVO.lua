--[[
加入帮派
]]

_G.QuestUnionJoinVO = setmetatable({}, { __index = QuestVO })

function QuestUnionJoinVO:GetType()
	return QuestConsts.Type_UnionJoin;
end

function QuestUnionJoinVO:GetGoalType()
	return 0;
end

function QuestUnionJoinVO:GetId()
	return self.id;
end

function QuestUnionJoinVO:GetState()
	return self.state;
end

function QuestUnionJoinVO:CreateQuestGoal()
	return nil;
end

function QuestUnionJoinVO:GetTitleLabel()
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest939"]) -- 中间的空格是留给任务图标的
	return txtTitle;
end

function QuestUnionJoinVO:GetPlayRefresh()
	return false;
end

function QuestUnionJoinVO:GetPlayRewardEffect()
	return false;
end

function QuestUnionJoinVO:HasContent()
	return false;
end

function QuestUnionJoinVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.Guild, false);
end