  --[[
牧野之战
]]

_G.QuestMakionVO = setmetatable( {}, {__index = QuestVO} )

function QuestMakionVO:GetType()
	return QuestConsts.Type_Makion;
end

--任务目标类型
function QuestMakionVO:GetGoalType()
	return nil;
end

function QuestMakionVO:GetRewardUIData()
	local rewardList = nil;
	local rewardLv = math.ceil(MainPlayerModel.humanDetailInfo.eaLevel / 5);
	local liushuirewardCFG = t_liushuifuben[rewardLv];
	if liushuirewardCFG then
		rewardList = RewardManager:Parse(liushuirewardCFG.water_reward);
	end
	if not rewardList then return nil; end
	return table.concat( rewardList, "*" )
end

function QuestMakionVO:GetId()
	return self.id;
end

function QuestMakionVO:ParseFlag(flag)

end

function QuestMakionVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestMakionVO:CreateQuestGoal()
--	local class = QuestVO.GoalClassMap[QuestConsts.GoalType_EXP_Dungeon]
--	return class and class:new( self )
	return nil;
end

function QuestMakionVO:GetTitleLabel()
	local timeAvailable = WaterDungeonModel:GetDayFreeTime()
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest90006"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestMakionVO:GetContentLabel(fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_Awarded then
		-- local istoday, remaintime = FengYaoUtil:GetTimeNextRefresh();
		-- if istoday then
			-- local min = math.ceil(remaintime/60);
			-- local str = string.format(StrConfig["quest903"],min);
			-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, str );
		-- else
			-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest904"] );
		-- end
	-- elseif state == FengYaoConsts.ShowType_NoAccept then
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest90006"] );
	-- elseif state == FengYaoConsts.ShowType_Accepted then
		-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest906"] );
	-- elseif state == FengYaoConsts.ShowType_NoAward then
		-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest907"] );
	-- end
	-- return "";
end

function QuestMakionVO:GetPlayRefresh()
	return false;
end

function QuestMakionVO:GetPlayRewardEffect()
	return false;
end

function QuestMakionVO:ShowTips()
--	local rewardList = split(self:GetRewardUIData(), "*");
--	UIQuestTips:Show(StrConfig["quest90006"], rewardList);
end

function QuestMakionVO:HasContent()
	return false;
end

function QuestMakionVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.experDungeon);
end