--[[
    Created by IntelliJ IDEA.
    组队副本
    User: Hongbin Yang
    Date: 2016/8/23
    Time: 21:40
   ]]


_G.QuestTeamDungeonVO = setmetatable( {}, {__index = QuestVO} )

function QuestTeamDungeonVO:GetType()
	return QuestConsts.Type_Team_Dungeon;
end

--任务目标类型
function QuestTeamDungeonVO:GetGoalType()
	return QuestConsts.GoalType_Team_Dungeon;
end

function QuestTeamDungeonVO:GetRewardUIData()
	local num = QiZhanDungeonModel:GetNextLayerNum();
	local cfg = t_ridereward[num];
	if not cfg then return end
	local rewardList = RewardManager:Parse( cfg.reward );
	return table.concat( rewardList, "*" )
end

function QuestTeamDungeonVO:GetId()
	return self.id;
end

function QuestTeamDungeonVO:ParseFlag(flag)

end

function QuestTeamDungeonVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestTeamDungeonVO:CreateQuestGoal()
--	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_Team_Dungeon ]
--	return class and class:new( self )
	return nil;
end

function QuestTeamDungeonVO:GetTitleLabel()
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); --今日剩余次数
	local leftTimes = string.format(StrConfig["quest912"], enterNum);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest919"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimes;
end

function QuestTeamDungeonVO:GetContentLabel(fontSize)
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
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest921"] );
	-- elseif state == FengYaoConsts.ShowType_Accepted then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest906"] );
	-- elseif state == FengYaoConsts.ShowType_NoAward then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest907"] );
	-- end
	-- return "";
end

-- 独有节点数组(在内容节点之上)
--[[策划要求不再显示3个奖励内容图标了 yanghongbin/jianghaoran   2016-8-23
function QuestTeamDungeonVO:CreateUpperNodes()
	-- 封妖 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end
]]

function QuestTeamDungeonVO:GetPlayRefresh()
	return false;
end

function QuestTeamDungeonVO:GetPlayRewardEffect()
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_NoAward then
	-- return true;
	-- end
	return false;
end

function QuestTeamDungeonVO:ShowTips()
--	local rewardList = split(self:GetRewardUIData(), "*");
--	UIQuestTips:Show(StrConfig["quest919"], rewardList);
end

function QuestTeamDungeonVO:HasContent()
	return false;
end

function QuestTeamDungeonVO:OnTitleClick()
	FuncManager:OpenFunc(FuncConsts.teamDungeon);
end