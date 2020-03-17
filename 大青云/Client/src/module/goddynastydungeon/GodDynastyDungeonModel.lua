--[[
	2016年10月14日, PM 18:31:52
	houxudong
]]
_G.GodDynastyDungeonModel = Module:new();

--打开UI所需要的数据
GodDynastyDungeonModel.godDynastyData = {};
GodDynastyDungeonModel.rewardAllList ={}    --所有的奖励堆集

function GodDynastyDungeonModel:UpDataGodDynastyInfo(obj)
	self.godDynastyData = {};
	for i , v in pairs(obj) do
		self.godDynastyData[i] = v;
	end
	self:UpdateToQuest();
	self:sendNotification(NotifyConsts.GodDynastyUpData);
end

--返回诛仙阵排行榜的数据
GodDynastyDungeonModel.rankListInfo = {};
function GodDynastyDungeonModel:BackRankData(list)
	self.rankListInfo = {};
	for i , v in ipairs(list) do
		self.rankListInfo[i] = v;
	end
	self:sendNotification(NotifyConsts.GodDynastyRankUpdate)
end

--得到我历史通过最高成数
function GodDynastyDungeonModel:GetMyHistoryMaxLayer()
	return self.godDynastyData.maxLayer or 0;
end

-- 得到我今日最高可挑战层数
function GodDynastyDungeonModel:GetMyDayChangeMaxLayer()
	return self.godDynastyData.nowLayer or 0;
end

--我进入了第几层
GodDynastyDungeonModel.nowLayer = 0;
--是否已经过关 0未过 1过关
GodDynastyDungeonModel.layerState = 0;
-- 层数list
GodDynastyDungeonModel.layerList = {}
--通过返回结果
function GodDynastyDungeonModel:OnBackLayer(msg)
	self.nowLayer = msg.layer;
	table.insert(self.layerList,self.nowLayer)
	if msg.state == 0 then
		self.layerState = 0;
	else
		self.layerState = 1;
	end
	UIGodDynastyDungeon:Hide();
	UIDungeonMain:Hide()
	UIGodDynastyDungeonResultView:Hide();
	UIGodDynastyInfo:Show();
end

-- 获取刚进入时的副本层数
function GodDynastyDungeonModel:GetEnterLayerNum( )
	if #GodDynastyDungeonModel.layerList then
		table.sort( GodDynastyDungeonModel.layerList, function ( A,B)
			return A < B
		end )
		return GodDynastyDungeonModel.layerList[1] and GodDynastyDungeonModel.layerList[1]
	end
	return 1
end

--本次通关结果
function GodDynastyDungeonModel:OnBackLayerResultInfo(obj)
	if obj.state == 0 then
		UIGodDynastyDungeonResultView:OnOpen(0);
		return ;
	elseif obj.state == 1 then 
		UIGodDynastyDungeonResultView:OnOpen(1,obj.rewardList);
	elseif obj.state == 2 then
		UIGodDynastyDungeonResultView:OnOpen(2);
	end
end

-- 副本里面所有的奖励堆集
function GodDynastyDungeonModel:GetAllRewardInDungeon( )
	local cfg = t_zhuxianzhen[self.nowLayer];
	if not cfg then return nil; end
	-- test code
	-- cfg.reward = "152000001,5#151200001,5#151200001,5#10,5"
	local rewardList = split(cfg.reward,'#')
	for i,v in ipairs(rewardList) do
		local vo = split(rewardList[i],',')
		local voo = {}
		voo.id = toint(vo[1])
		voo.num = toint(vo[2])
		table.push(self.rewardAllList,voo)
	end
	if #self.rewardAllList == #rewardList then
		for i=1,#self.rewardAllList do
			self.rewardAllList[i].num = 0
		end
	end
	return self.rewardAllList
end

--退出诛仙阵
function GodDynastyDungeonModel:OnOutGodDynastyBack(msg)
	if msg.state == 0 then
		return;
	end
	if UIGodDynastyDungeonResultView:IsShow() then
		UIGodDynastyDungeonResultView:Hide();
	end
	UIGodDynastyInfo:Hide();
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	GodDynastyDungeonController:OnEnterGame();
	if UITimeTopSec:IsShow() then
		UITimeTopSec:Hide();
	end
	self.layerList = {}
	self.rewardAllList = {}
end

function GodDynastyDungeonModel:UpdateToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_GodDynasty, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;

	local timeAvailable = DungeonUtils:CheckGodDynastyDungen();
	if QuestModel:GetQuest(questId) then
		if not timeAvailable then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if not timeAvailable then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end