  --[[
经验副本
]]

_G.QuestExpDungeonVO = setmetatable( {}, {__index = QuestVO} )

function QuestExpDungeonVO:GetType()
	return QuestConsts.Type_EXP_Dungeon;
end

--任务目标类型
function QuestExpDungeonVO:GetGoalType()
	return QuestConsts.GoalType_EXP_Dungeon;
end

function QuestExpDungeonVO:GetRewardUIData()
	local rewardList = nil;
	local rewardLv = math.ceil(MainPlayerModel.humanDetailInfo.eaLevel / 5);
	local liushuirewardCFG = t_liushuifuben[rewardLv];
	if liushuirewardCFG then
		rewardList = RewardManager:Parse(liushuirewardCFG.water_reward);
	end
	if not rewardList then return nil; end
	return table.concat( rewardList, "*" )
end

function QuestExpDungeonVO:GetId()
	return self.id;
end

function QuestExpDungeonVO:ParseFlag(flag)

end

function QuestExpDungeonVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestExpDungeonVO:CreateQuestGoal()
--	local class = QuestVO.GoalClassMap[QuestConsts.GoalType_EXP_Dungeon]
--	return class and class:new( self )
	return nil;
end

function QuestExpDungeonVO:GetTitleLabel()
	local timeAvailable = WaterDungeonModel:GetDayFreeTime()
	local leftTimes = string.format(StrConfig["quest912"], timeAvailable);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest90006"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestExpDungeonVO:GetContentLabel(fontSize)
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

function QuestExpDungeonVO:GetPlayRefresh()
	return false;
end

function QuestExpDungeonVO:GetPlayRewardEffect()
	return false;
end

function QuestExpDungeonVO:ShowTips()
--	local rewardList = split(self:GetRewardUIData(), "*");
--	UIQuestTips:Show(StrConfig["quest90006"], rewardList);
end

function QuestExpDungeonVO:HasContent()
	return false;
end

function QuestExpDungeonVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.experDungeon);
end