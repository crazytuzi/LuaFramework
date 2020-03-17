--[[
卓越引导
lizhuangzhuang
2015年8月2日15:47:19
]]

_G.QuestSuperVO = setmetatable( {}, {__index = QuestVO} )

function QuestSuperVO:GetType()
	return QuestConsts.Type_Super;
end

--任务目标类型
function QuestSuperVO:GetGoalType()
	return QuestConsts.GoalType_Super;
end

function QuestSuperVO:GetRewardUIData()
	local id = ZhuoyueGuideModel:GetId();
	local cfg = t_zhuoyueguide[id];
	if not cfg then return {}; end
	local rewardList = RewardManager:Parse(cfg.reward);
	return table.concat( rewardList, "*" )
end

function QuestSuperVO:GetId()
	return self.id;
end

function QuestSuperVO:ParseFlag(flag)

end

function QuestSuperVO:GetState()
	return self.state;
end

function QuestSuperVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_Super ]
	return class and class:new( self )
end

function QuestSuperVO:GetTitleLabel()
	local txtTitle = StrConfig["quest909"] -- 中间的空格是留给任务图标的
	return txtTitle;
end

function QuestSuperVO:GetContentLabel(fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE; end
	if ZhuoyueGuideModel:GetState() == 0 then
		local id = ZhuoyueGuideModel:GetId();
		local cfg = t_zhuoyueguide[id];
		if not cfg then return ""; end
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, cfg.link );
	else
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest907"] );
	end
end

-- 独有节点数组(在内容节点之上)
function QuestSuperVO:CreateUpperNodes()
	-- 卓越引导 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end

function QuestSuperVO:GetPlayRefresh()
	return false;
end

function QuestSuperVO:GetPlayRewardEffect()
	if ZhuoyueGuideModel:GetState() == 1 then
		return true;
	end
	return false;
end