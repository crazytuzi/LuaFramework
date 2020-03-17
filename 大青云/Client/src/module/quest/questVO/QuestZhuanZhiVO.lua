--[[
转职任务
2016年6月28日16:11:08
chenyujia
]]

_G.QuestZhuanZhiVO = setmetatable( {}, {__index = QuestVO} );

--任务类型
function QuestZhuanZhiVO:GetType()
	return QuestConsts.Type_ZhuanZhi
end

--获取任务配表
function QuestZhuanZhiVO:GetCfg()
	local cfg = t_transferquest[self.id]
	if not cfg then
		Debug('error:cannot find ZhuanZhi quest in table.id:'..self.id);
		return;
	end
	return cfg;
end

-- 交任务
function QuestZhuanZhiVO:Submit()
	ZhuanZhiModel:AskGetReward(self.id)
end

-- factory method 建立任务目标
function QuestZhuanZhiVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_ZhuanZhi ]
	return class and class:new( self )
end

--获取快捷任务任务标题文本
function QuestZhuanZhiVO:GetTitleLabel()
	local cfg = self:GetCfg();
	local titleFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>"; -- 中间的空格是留给任务图标的
	return string.format( titleFormat, cfg.name or "name字段待配" )
end

function QuestZhuanZhiVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", sizeStr, str );
end

function QuestZhuanZhiVO:ShowTips()
	local questId   = self:GetId()
	local questCfg  = self:GetCfg()
	local rewardList = ZhuanZhiModel:GetShowTaskReward()
	if not rewardList then return; end
	UIQuestTips:Show(questCfg.name, rewardList);
end

-- -- 对应经验真气金钱
-- function QuestZhuanZhiVO:GetNormalRewardLabel()
-- 	local cfg = self:GetCfg()
-- 	local rewardTable = {}
-- 	local exp = cfg.exp or 0
-- 	if exp > 0 then
-- 		table.push( rewardTable, string.format( StrConfig['quest501'], exp ) )
-- 	end
-- 	return string.format( StrConfig['quest601'], table.concat( rewardTable, ' ' ) )
-- end

-- -- 对应otherReward字段
-- function QuestZhuanZhiVO:GetOtherRewardLabel()
-- 	local cfg = self:GetCfg()
-- 	local rewardStr  = cfg.reward
-- 	if rewardStr == '' then return '' end
-- 	local rewardList = RewardManager:ParseToVO( rewardStr )
-- 	local rewardDesTable = {}
-- 	for i, vo in pairs(rewardList) do
-- 		local itemId = vo.id
-- 		local itemName = ''
-- 		local itemNum = vo.count
-- 		local itemCfg = t_item[itemId] or t_equip[itemId]
-- 		if itemCfg then
-- 			itemName = itemCfg.name
-- 		end
-- 		table.push( rewardDesTable, string.format( "%s:<font color='#42db62'>%s</font>", itemName, itemNum ) );
-- 	end
-- 	return string.format( StrConfig['quest601'], table.concat( rewardDesTable, ' ' ) );
-- end

-- 独有节点数组(在内容节点之上)
function QuestZhuanZhiVO:CreateUpperNodes()
	-- 等级任务显示奖励节点
	local nodes = {}
	-- local cfg = self:GetCfg()
	-- if cfg.exp > 0 then
	-- 	local node1 = QuestNodeNormalReward:new()
	-- 	node1:SetContent( self )
	-- 	table.push( nodes, node1 )
	-- end
	-- if cfg.reward ~= '' then
	-- 	local node2 = QuestNodeOtherReward:new()
	-- 	node2:SetContent( self )
	-- 	table.push( nodes, node2 )
	-- end
	return nodes
end
function QuestZhuanZhiVO:GetPlayRefresh()
	return false;
end