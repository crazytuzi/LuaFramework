--[[
任务树节点工具
2015年5月11日20:08:31
haohu
]]

_G.QuestNodeUtil = {}

local tmpUID = 0;
function QuestNodeUtil:GetUID()
	tmpUID = tmpUID + 1;
	return tmpUID;
end

function QuestNodeUtil:GenerateQuestTree()
	local root = self.questRootNode
	if not root then
		self.questRootNode = QuestNodeRoot:new()
		root = self.questRootNode
	end
	root:Dispose();
	local questList = QuestModel:GetSortedQuests()
	for _, quest in ipairs(questList) do
		local node = quest:CreateTreeNode();
		if node then root:AddSubNode( node ) end
	end
	--[[
	-- 策划修改为日环任务全部完成了就不显示在任务栏了 yanghongbin/jianghaoran   2016-7-20
	if QuestModel:GetDQState() == QuestConsts.QuestDailyStateFinish then
		local dqNode = self:GetDQFinishNode()
		root:AddSubNode( dqNode )
	end
	]]
	if RandomQuestModel:IsTodayFinish() then
		local rqNode = self:GetRQFinishNode()
		root:AddSubNode( rqNode )
	end
	if WaBaoModel:GetTodayFinish2() then
		local wabaoNode = self:GetWaBaoFinishNode();
		root:AddSubNode( wabaoNode);
	end
	--[[
	--策划修改为屠魔任务全部完成了就不显示在任务栏了 yanghongbin/jianghaoran   2016-7-20
	if FengYaoModel:GetTodayFinish() then
		local fengyaoNode = self:GetFengYaoFinishNode();
		root:AddSubNode( fengyaoNode);
	end
	]]
	return root:GetTreeData();
end

function QuestNodeUtil:GenerateLvQuestTree()
	local root = self.lvQuestRootNode
	if not root then
		self.lvQuestRootNode = QuestNodeRoot:new()
		root = self.lvQuestRootNode
	end
	root:Dispose();
	local list = QuestModel:GetLevelQuests()
	for _, quest in ipairs(list) do
		local node = quest:CreateTreeNode();
		if node then root:AddSubNode( node ) end
	end
	return root:GetTreeData();
end

-- 日环任务今日已完成节点
function QuestNodeUtil:GetDQFinishNode()
	local node = QuestNodeTitle:new()
	local quest = QuestForShowVO:new( QuestConsts.Type_Day, StrConfig['quest17'] )
	node:SetContent(quest)
	return node
end

-- 奇遇任务今日已完成节点
function QuestNodeUtil:GetRQFinishNode()
	local node = QuestNodeTitle:new()
	local quest = QuestForShowVO:new( QuestConsts.Type_Random, StrConfig['quest18'] )
	node:SetContent(quest)
	return node
end

--挖宝任务今日已完成节点
function QuestNodeUtil:GetWaBaoFinishNode()
	local node = QuestNodeTitle:new()
	local quest = QuestForShowVO:new( QuestConsts.Type_WaBao, StrConfig['quest19'] )
	node:SetContent(quest)
	return node
end

--悬赏任务今日已完成节点
function QuestNodeUtil:GetFengYaoFinishNode()
	local node = QuestNodeTitle:new()
	local quest = QuestForShowVO:new( QuestConsts.Type_FengYao, StrConfig['quest20'] )
	node:SetContent(quest)
	return node
end

function QuestNodeUtil:FindNode( uid )
	return self.questRootNode:FindNode( uid );
end

function QuestNodeUtil:FindLvNode( uid )
	return self.lvQuestRootNode:FindNode( uid );
end

function QuestNodeUtil:FindNodeByType( nodeType )
	return self.questRootNode:FindNodeByType( nodeType )
end

function QuestNodeUtil:FindContentNodeByQuestType( questType )
	return self.questRootNode:FindContentNodeByQuestType( questType )
end

--找到指定uid node在list中的索引
function QuestNodeUtil:FindNodeIndex(uid)
	local findFunc;
	findFunc = function(node,nodeIndex)
		if node.subNodes then
			for _, subNode in pairs(node.subNodes) do
				if subNode:ToString() == uid then
					return true,nodeIndex;
				else
					nodeIndex = nodeIndex + 1;
					if subNode.subNodes then
						local find,subNodeIndex = findFunc(subNode,nodeIndex);
						if find then
							return true,subNodeIndex;
						else
							nodeIndex = subNodeIndex;
						end
					end
				end
			end
		end
		return false,nodeIndex;
	end
	local find,index = findFunc(self.questRootNode,0);
	if find then return index; end
	return -1;
end



-- handeler需要实现HandleNodeEvent、HandleRedraw接口
function QuestNodeUtil:RegisterQuestTreeList( list, handeler )
	list.itemClick            = function(e) handeler:HandleNodeEvent( e, "OnClick" ); end
	list.itemRollOver         = function(e) handeler:HandleNodeEvent( e, "OnRollOver" ); end
	list.itemRollOut          = function(e) handeler:HandleNodeEvent( e, "OnRollOut" ); end

	list.itemTeleportClick    = function(e) handeler:HandleNodeEvent( e, "OnTeleportClick" ); end
	list.itemTeleportRollOver = function(e) handeler:HandleNodeEvent( e, "OnTeleportRollOver" ); end
	list.itemTeleportRollOut  = function(e) handeler:HandleNodeEvent( e, "OnTeleportRollOut" ); end
	list.itemAddStarClick     = function(e) handeler:HandleNodeEvent( e, "OnAddStarClick" ); end
	list.itemAddStarRollOver  = function(e) handeler:HandleNodeEvent( e, "OnAddStarRollOver" ); end
	list.itemAddStarRollOut   = function(e) handeler:HandleNodeEvent( e, "OnAddStarRollOut" ); end
	list.itemRewardRollOver   = function(e) handeler:HandleNodeEvent( e, "OnRewardRollOver" ); end
	list.itemRewardRollOut    = function(e) handeler:HandleNodeEvent( e, "OnRewardRollOut" ); end
	list.redraw               = function(e) handeler:HandleRedraw( e ); end
end