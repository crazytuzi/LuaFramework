--[[
等级任务
2015年5月14日20:38:55
haohu
]]

_G.QuestLevelVO = setmetatable( {}, {__index = QuestVO} );

-- 奖励
function QuestLevelVO:GetRewards()
	local cfg = self:GetCfg();
	if not cfg then return end
	local rewareExp    = cfg.expReward -- int
	local rewareMoney  = cfg.moneyReward -- int
	local rewareZhenqi = cfg.zhenqiReward -- int
	local otherReward  = cfg.otherReward -- string:ID,count#ID,count
	local yuanbao	   = cfg.yuanbao_binding
	return rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao;
end

-- 以*分割
--[[
--策划说不显示等级任务的奖励图标了 yanghongbin/yaochunlong  2016-8-2
function QuestLevelVO:GetRewardUIData()
	local rewareExp, rewareMoney, rewareZhenqi, otherReward = self:GetRewards()
	local rewardList = QuestUtil:GetLevelRewardList(rewareExp, rewareMoney, rewareZhenqi, otherReward);
	return table.concat( rewardList, "*" )
end
]]

--获取任务配表
function QuestLevelVO:GetCfg()
	local cfg = t_questlevel[self.id]
	if not cfg then
		Debug('error:cannot find level quest in table.id:'..self.id);
		return nil;
	end
	return cfg;
end

function QuestLevelVO:GetLvQuestReward()
	local cfg = self:GetCfg();
	return QuestConsts:GetLvQuestRewardIconURL(cfg), QuestConsts:GetLvQuestRewardNumStr(cfg);
end

function QuestLevelVO:ShowTips()
	local cfg = self:GetCfg();
	if not cfg then return end
	local rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao = self:GetRewards()
	local rewardList = QuestUtil:GetLevelRewardList(rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao);
	UIQuestTips:Show(cfg.name, rewardList);
end

-- 交任务
function QuestLevelVO:Submit()
	local cfg = self:GetCfg();
	if not cfg then return end
	local rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao = self:GetRewards()
	local rewardList = QuestUtil:GetLevelRewardList(rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao);
	self:SendSubmit();
	local isGold = false;
	if yuanbao <= 0 then
		isGold = true;
	end
	MainQuestLvFinishedRewardView:Open(self:GetId(), cfg.unFinishLink, rewardList, isGold);
end

-- 发送交任务
function QuestLevelVO:SendSubmit()
	QuestController:FinishQuest( self.id )
end

--获取任务当前的NPC ID
function QuestLevelVO:GetCurrNPC()
	return nil
end

--获取任务接取点
function QuestLevelVO:GetAcceptPoint()
	return nil
end

--获取任务完成点
function QuestLevelVO:GetFinishPoint()
	return nil
end

--任务类型
function QuestLevelVO:GetType()
	return QuestConsts.Type_Level
end

--获取快捷任务任务标题文本
function QuestLevelVO:GetTitleLabel()
	local cfg = self:GetCfg();
	local titleFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>"; -- 中间的空格是留给任务图标的
	local stateFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='%s'>%s</font>"
	local txtTitle = string.format( titleFormat, cfg.name )
	local state = self:GetState();
	local labelStateColor = QuestConsts:GetStateLabelColor(state);
	local labelState = QuestConsts:GetStateLabel(state);
	--目标任务名称后面不显示该任务的完成状态。 yanghongbin/jianghaoran 2016-8-22
	--local txtState = string.format( stateFormat, labelStateColor, labelState );
	--return string.format( "%s%s", txtTitle, txtState );
	return string.format( "%s", txtTitle);
end

function QuestLevelVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", sizeStr, str );
end

-- 对应经验真气金钱
function QuestLevelVO:GetNormalRewardLabel()
	local cfg = self:GetCfg()
	local rewardTable = {}
	local exp    = cfg.expReward or 0
	if exp > 0 then
		table.push( rewardTable, string.format( StrConfig['quest501'], exp ) )
	end
	local money  = cfg.moneyReward or 0
	if money > 0 then
		table.push( rewardTable, string.format( StrConfig['quest502'], money ) )
	end
	local zhenqi = cfg.zhenqiReward or 0
	if zhenqi > 0 then
		table.push( rewardTable, string.format( StrConfig['quest503'], zhenqi ) )
	end
	return string.format( StrConfig['quest601'], table.concat( rewardTable, ' ' ) )
end

-- 对应otherReward字段
function QuestLevelVO:GetOtherRewardLabel()
	local cfg = self:GetCfg()
	local rewardStr  = cfg.otherReward
	if rewardStr == '' then return '' end
	local rewardList = RewardManager:ParseToVO( rewardStr )
	local rewardDesTable = {}
	for i, vo in pairs(rewardList) do
		local itemId = vo.id
		local itemName = ''
		local itemNum = vo.count
		local itemCfg = t_item[itemId] or t_equip[itemId]
		if itemCfg then
			itemName = itemCfg.name
		end
		table.push( rewardDesTable, string.format( "%s:<font color='"..QuestColor.COLOR_GREEN.."'>%s</font>", itemName, itemNum ) );
	end
	return string.format( StrConfig['quest601'], table.concat( rewardDesTable, ' ' ) )
end

-- 独有节点数组(在内容节点之上)
function QuestLevelVO:CreateUpperNodes()
	-- 等级任务显示奖励节点
	local nodes = {}
	--[[
	--策划说不显示等级任务的奖励图标了 yanghongbin/yaochunlong  2016-8-2
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	]]
	local cfg = self:GetCfg()
	if cfg.otherReward ~= '' then
		local node2 = QuestNodeOtherReward:new()
		node2:SetContent( self )
		table.push( nodes, node2 )
	end
	return nodes
end
function QuestLevelVO:GetPlayRefresh()
	return false;
end
function QuestLevelVO:GetPlayRewardEffect()
	local state = self:GetState()
	return state == QuestConsts.State_CanFinish
end
