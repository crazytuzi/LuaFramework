--[[
    Created by IntelliJ IDEA.
    组队经验副本
    User: Hongbin Yang
    Date: 2016/8/23
    Time: 21:40
   ]]


_G.QuestTeamExpDungeonVO = setmetatable( {}, {__index = QuestVO} )

function QuestTeamExpDungeonVO:GetType()
	return QuestConsts.Type_Team_EXP_Dungeon;
end

--任务目标类型
function QuestTeamExpDungeonVO:GetGoalType()
	return QuestConsts.GoalType_Team_Exp_Dungeon;
end

function QuestTeamExpDungeonVO:GetRewardUIData()
	local num = QiZhanDungeonModel:GetNextLayerNum();
	local cfg = t_ridereward[num];
	if not cfg then return end
	local rewardList = RewardManager:Parse( cfg.reward );
	return table.concat( rewardList, "*" )
end

function QuestTeamExpDungeonVO:GetId()
	return self.id;
end

function QuestTeamExpDungeonVO:ParseFlag(flag)

end

function QuestTeamExpDungeonVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestTeamExpDungeonVO:CreateQuestGoal()
--	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_Team_Exp_Dungeon ]
--	return class and class:new( self )
	return nil;
end

function QuestTeamExpDungeonVO:GetTitleLabel()
	local enterNum = TimeDungeonModel:GetEnterNum(); --今日剩余次数
	local leftTimes = string.format(StrConfig["quest912"], enterNum);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest920"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestTeamExpDungeonVO:GetContentLabel(fontSize)
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
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest922"] );
	-- elseif state == FengYaoConsts.ShowType_Accepted then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest906"] );
	-- elseif state == FengYaoConsts.ShowType_NoAward then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest907"] );
	-- end
	-- return "";
end

function QuestTeamExpDungeonVO:GetPlayRefresh()
	return false;
end

function QuestTeamExpDungeonVO:GetPlayRewardEffect()
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_NoAward then
	-- return true;
	-- end
	return false;
end
--[[
--没给如何显示
function QuestTeamExpDungeonVO:ShowTips()
	local questId   = self:GetId()
	local questCfg  = self:GetCfg()
	local rewardList = split(self:GetRewardUIData(), "*");
	UIQuestTips:Show(StrConfig["quest920"], rewardList);
end
]]
function QuestTeamExpDungeonVO:HasContent()
	return false;
end

function QuestTeamExpDungeonVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.teamExper);
end