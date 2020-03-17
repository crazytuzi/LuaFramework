--[[
挖宝
lizhuangzhuang
2015年8月1日22:38:32
]]

_G.QuestWaBaoVO = setmetatable( {}, {__index = QuestVO} )

function QuestWaBaoVO:GetType()
	return QuestConsts.Type_WaBao;
end

--任务目标类型
function QuestWaBaoVO:GetGoalType()
	return QuestConsts.GoalType_WaBao;
end

function QuestWaBaoVO:GetShowRewards()
	local wabaoid = 0;
	if self.state == QuestConsts.State_CanAccept then
		local level = MainPlayerModel.humanDetailInfo.eaLevel;
		wabaoid = 4*10000 + level;
	else
		wabaoid = WaBaoModel:GetWaBoaInfo().wabaoid;
	end
	local cfg = t_wabaolevel[wabaoid];
	if not cfg then return {}; end
	return RewardManager:Parse(enAttrType.eaExp..","..cfg.rewardExp,cfg.reward);
end

--未接取时显示最高的,接取后显示当前的
function QuestWaBaoVO:GetRewardUIData()
	local rewardList = self:GetShowRewards()
	return table.concat( rewardList, "*" )
end

function QuestWaBaoVO:GetId()
	return self.id;
end

function QuestWaBaoVO:ParseFlag( flag)
end

function QuestWaBaoVO:GetState()
	return self.state;
end

function QuestWaBaoVO:Accept()
	local func = FuncManager:GetFunc(FuncConsts.WaBao);
	if func then
		func:OnQuestClick();
	end
end

-- factory method 建立任务目标
function QuestWaBaoVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_WaBao ]
	return class and class:new( self )
end

function QuestWaBaoVO:GetTitleLabel()
	local txtTitle = StrConfig["quest911"] -- 中间的空格是留给任务图标的
	local lastNum = WaBaoModel:GetWabaoNum();
	local txtState = string.format(StrConfig["quest912"],lastNum);
	return string.format( "%s%s", txtTitle, txtState )
end

function QuestWaBaoVO:GetContentLabel(fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE; end
	if self.state == QuestConsts.State_CanAccept then
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest905"] );
	else
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest910"] );
	end
end

-- 独有节点数组(在内容节点之上)
function QuestWaBaoVO:CreateUpperNodes()
	-- 挖宝 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end

function QuestWaBaoVO:GetPlayRefresh()
	return false;
end