--[[
主界面任务追踪树节点
2015年5月11日15:16:48
haohu
]]

_G.QuestNodeConst = {}

QuestNodeConst.Node_Root         = "Node_Root"; -- 根节点
QuestNodeConst.Node_Group        = "Node_Group"; -- 支线或奇遇任务的大节点
QuestNodeConst.Node_Title        = "Node_Title"; -- 任务标题
QuestNodeConst.Node_Content      = "Node_Content"; -- 任务内容
QuestNodeConst.Node_DQStar       = "Node_DQStar"; -- 日环星级
QuestNodeConst.Node_Des          = "Node_Des"; -- 任务描述
QuestNodeConst.Node_Recommend    = "Node_Recommend"; -- 推荐挂机
QuestNodeConst.Node_NormalReward = "Node_NormalReward"; -- 任务奖励(经验，金钱，灵力)
QuestNodeConst.Node_OtherReward  = "Node_OtherReward"; -- 任务奖励(其他)
QuestNodeConst.Node_Empty        = "Node_Empty"; -- 空节点

------------------------------------------------------------------------------------

_G.QuestNode = {}

QuestNode.type     = nil -- 类型
QuestNode.content  = nil -- 内容
QuestNode.opened   = nil -- 展开
QuestNode.subNodes = nil -- 子节点列表

------------------------------------protected----------------------------

-- 是否有展开按钮
function QuestNode:HasBtn()
	return false
end

-- 是否有传送按钮
function QuestNode:HasTeleportBtn()
	return false
end
-- 获取任务类型的文本如 【主线】   yanghongbin/jianghaoran   2016-7-20
function QuestNode:GetQuestTypeLabel()
	return "";
end

function QuestNode:GetIconURL()
	return ''
end

function QuestNode:HasStar()
	return false
end

function QuestNode:GetStateRefresh()
	return false
end

function QuestNode:GetStar()
	return 0
end

function QuestNode:HasAddStarBtn()
	return false
end

function QuestNode:HasAddStarEffect()
	return false
end

function QuestNode:HasRewardEffect()
	return false
end

-- label
function QuestNode:GetLabel()
	return ""
end

function QuestNode:GetLvQuestReward()
	return "", "";
end

function QuestNode:GetRewardUIData()
	return ""
end

function QuestNode:GetIsDisabled()
	return false
end

function QuestNode:GetTreeDataSubNodes()
	local nodes = {};
	local subNodes = self:GetSubNodes();
	if subNodes then
		for _, subNode in ipairs(subNodes) do
			local subTreeData = subNode:GetTreeData();
			table.push( nodes, subTreeData );
		end
	end
	return nodes;
end



------------------------------------public----------------------------

QuestNode.uid = nil;
function QuestNode:new(nodeType)
	local node = {}
	setmetatable( node, { __index = self } )
	node.type = nodeType or self.type
	if not node.type then
		Error("quest node type missing, string expected, got nil")
		print(debug.traceback())
	end
	node.opened = true
	node.uid = QuestNodeUtil:GetUID();
	node:OnCreate()
	return node
end

function QuestNode:OnCreate()
	-- override
end

function QuestNode:Test()
	if not _G.isDebug then
		return
	end
	print(self:ToString())
	if self.subNodes then
		for _, subNode in pairs(self.subNodes) do
			subNode:Test()
		end
	end
end
----------------------鼠标事件----------------------------

function QuestNode:OnClick()
	Debug(self.nodeType)
end

function QuestNode:OnRollOver()
	-- body
end

function QuestNode:OnRollOut()
	UIQuestTips:Hide()
	UIQuestDayTips:Hide()
	UIRandomQuestTips:Hide()
	TipsManager:Hide()
end

function QuestNode:OnTeleportClick()
	-- body
end

function QuestNode:OnTeleportRollOver()
	-- body
end

function QuestNode:OnTeleportRollOut()
	-- body
end

function QuestNode:OnAddStarClick()
	-- body
end

function QuestNode:OnAddStarRollOver()
	-- body
end

function QuestNode:OnAddStarRollOut()
	-- body
end

function QuestNode:OnRewardRollOver()
	-- body
end

function QuestNode:OnRewardRollOut()
	-- body
end


----------------------鼠标事件end----------------------------

-- 节点类型
function QuestNode:GetType()
	return self.type;
end

-- 获取子节点列表
function QuestNode:GetSubNodes()
	return self.subNodes
end

-- 添加子节点
function QuestNode:AddSubNode(node)
	if not node then return end
	if not self.subNodes then
		self.subNodes = {}
	end
	table.push(self.subNodes, node)
end

-- 获取节点内容 content在不同类型节点中数据结构不同
function QuestNode:GetContent()
	if not self.content then
		Error( string.format( "content missing in quest tree NODE:%s", self:ToString() ) );
	end
	return self.content
end

-- 设置节点内容
function QuestNode:SetContent( content )
	self.content = content;
end

-- 获取任务类型
function QuestNode:GetQuestType()
	return 0
end

-- 节点展开状态
function QuestNode:GetOpened()
	return self.opened
end

-- 设置节点展开状态
function QuestNode:SetOpened(opened)
	self.opened = opened;
end

-- toString
function QuestNode:ToString()
	return string.format( "Quest_%s_%s", self.type, self.uid );
end

-- 生成供 UIData.copyDataToTree 使用的数据
function QuestNode:GetTreeData()
	local node = {}
	node.uid               = self:ToString()
	node.titleTypeLabel    = self:GetQuestTypeLabel()
	node.label             = self:GetLabel()
	node.open              = self:GetOpened()
	node.withIcon          = self:HasBtn()
	node.showTeleport      = self:HasTeleportBtn()
	node.iconUrl           = self:GetIconURL()
	node.showStar          = self:HasStar()
	node.star              = self:GetStar()
	node.showAddStar       = self:HasAddStarBtn()
	node.showAddStarEffect = self:HasAddStarEffect()
	node.showRewardEffect  = self:HasRewardEffect()
	node.stateRefresh      = self:GetStateRefresh()
	node.disabled          = self:GetIsDisabled()
	node.lvQuestRewardIconURL, node.lvQuestRewardStr = self:GetLvQuestReward();
	local nodeStr   = UIData.encode( node )
	local nodes     = self:GetTreeDataSubNodes()
	local rewardStr = self:GetRewardUIData()
	local uidataStr = string.format( "%s*%s", nodeStr, rewardStr )
	return { str = uidataStr, nodes = nodes }
end

-- 根据uid递归寻找节点
function QuestNode:FindNode(uid)
	local node;
	if self:ToString() == uid then
		node = self
	else
		if self.subNodes then
			for _, subNode in pairs(self.subNodes) do
				node = subNode:FindNode( uid )
				if node then break end
			end
		end
	end
	return node
end

-- 根据节点类型递归寻找节点，找到第一个即返回
function QuestNode:FindNodeByType( nodeType )
	local node;
	if self:GetType() == nodeType then
		node = self
	else
		if self.subNodes then
			for _, subNode in pairs(self.subNodes) do
				node = subNode:FindNodeByType( nodeType )
				if node then break end
			end
		end
	end
	return node
end

-- 根据任务类型递归寻找内容节点
function QuestNode:FindContentNodeByQuestType( questType )
	local node;
	-- 是内容节点，且任务类型符合
	if self:GetQuestType() == questType and self:GetType() == QuestNodeConst.Node_Content then
		node = self
	else
		if self.subNodes then
			for _, subNode in pairs(self.subNodes) do
				node = subNode:FindContentNodeByQuestType( questType )
				if node then break end
			end
		end
	end
	return node
end

-- GC
function QuestNode:Dispose()
	self:DisposeContent()
	if self.subNodes then
		for _, subNode in pairs(self.subNodes) do
			subNode:Dispose()
		end
		self.subNodes = nil
	end
end

function QuestNode:DisposeContent()
	self.content = nil;
end