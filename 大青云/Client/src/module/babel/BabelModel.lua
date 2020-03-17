--[[
	2015年1月23日, PM 02:57:59
	wangyawnei
]]
_G.BabelModel = Module:new();

--打开UI所需要的数据
BabelModel.babelData = {};
function BabelModel:UpDataBabelInfo(obj)
	self.babelData = {};
	for i , v in pairs(obj) do
		self.babelData[i] = v;
	end
	self:UpdateToQuest()
	self:sendNotification(NotifyConsts.BabelUpData);
end

--返回排行榜的数据
BabelModel.rankListInfo = {};
function BabelModel:BackRankData(list)
	self.rankListInfo = {};
	for i , v in ipairs(list) do
		self.rankListInfo[i] = v;
	end
	-- UIBabel:ShowChild('babelRank');   --打开子界面排行榜
	self:sendNotification(NotifyConsts.BabelRankUpdate)
end

--得到我当前层
function BabelModel:GetNowLayer()
	return self.babelData.layer or 0;
end

--当前挑战的最高层
function BabelModel:GetTallestLayer()
	return self.babelData.maxLayer or 0;
end

--我进入了第几层
BabelModel.nowLayer = 0;
--是否已经过关 0未过 1过关
BabelModel.layerState = 0;
function BabelModel:OnBackLayer(msg)
	self.nowLayer = msg.layer;
	if msg.state == 0 then
		self.layerState = 0;
	else
		self.layerState = 1;
	end
	if UIBabel:IsShow() then
		UIBabel:Hide();
	end
	if UIDungeonMain:IsShow() then
		UIDungeonMain:Hide();
	end
	if UIBabelMainView:IsShow() then
		UIBabelMainView:Hide();
	end
	if UIBabelResult:IsShow() then
		UIBabelResult:Hide();
	end
	if UIBabelLayerInfo:IsShow() then
		self:sendNotification(NotifyConsts.BabelInfoPanelOpen);  -- 播放剧情
		return;
	end
	UIBabelLayerInfo:Show();
end

--本次通关结果
function BabelModel:OnBackLayerResultInfo(obj)
	if obj.state == 0 then
		UIBabelResult:OnOpen(0);
		return ;
	elseif obj.state == 1 then 
		UIBabelResult:OnOpen(1,obj.rewardList);
	elseif obj.state == 2 then
		UIBabelResult:OnOpen(2);
	end
end

--退出通天塔
function BabelModel:OnOutBabelBack(msg)
	if msg.state == 0 then
		return
	end
	if UIBabelResult:IsShow() then
		UIBabelResult:Hide();
	end
	UIBabelLayerInfo:Hide();
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	BabelController:OnEnterGame();
	UITimeTopSec:Hide();
end

--剧情播放完毕
function BabelModel:OnEndStoryHandler()
	self:sendNotification(NotifyConsts.BabelStory);
end

-- 规则:
-- 1.判断当前可以打的层数可以获得的装备
-- 2.改装备品质大于玩家身上同部位装备品质
-- 3.如果玩家身上同部位没有装备，直接返回true
function BabelModel:CheckGetEquipsOverSelfEquipsQuality()
	if not self.babelData then return false; end
	local curLayer = self.babelData.layer or 0
	local maxlayer = self:GetTallestLayer()
	if not curLayer then return false end
	local cfg = t_doupocangqiong[curLayer];
	if not cfg then return false end
	local firstList = cfg.firstReward;        --首通奖励
	if not firstList then return false end
	local firstListReward = split(firstList,'#')
	local isfirst = curLayer > maxlayer       --是否首次
	if isfirst then
		local isHaveEquip = false;
		local rewardEquipList = {};           --所有的奖励装备
		for i,v in ipairs(firstListReward) do
			if t_equip[toint(split(v,',')[1])] then
				isHaveEquip = true;
				local vo = {};
				vo.id = toint(split(v,',')[1])
				table.push(rewardEquipList,vo)
			else
				isHaveEquip = false;
			end
		end
		if #rewardEquipList == 0 then return false end
		return self:CompareEquip(rewardEquipList)
	else
		local sweepReward = cfg.reward;       --扫荡奖励
		if not sweepReward then return false end
		local sweepRewardList = split(sweepReward,'#')
		local isHaveEquip = false;
		local equipList = {};                 --所有的奖励装备
		for i,v in pairs(sweepRewardList) do
			if t_equip[toint(split(v,',')[1])] then
				isHaveEquip = true;
				local vo = {};
				vo.id = toint(split(v,',')[1])
				table.push(equipList,vo)
			else
				isHaveEquip = false;
			end
		end
		if #equipList == 0 then return false; end
		return self:CompareEquip(equipList)
	end
end

function BabelModel:CompareEquip(rewardEquipList)
	-- 和全身装备进行比较
	local result = false;
	local hasPos = false;
	for k, v in pairs(rewardEquipList) do
		local rewardCFG = t_equip[v.id];
		if rewardCFG then
			local rewardPos = rewardCFG.pos;
			local rewardQuality = rewardCFG.quality;
			local bag = BagModel:GetBag(BagConsts.BagType_Role);
			for i = 0, 10 do
				local equip = bag:GetItemByPos(i)
				if equip then
					local equipCFG = t_equip[equip:GetTid()]
					if equipCFG then
						local equipPos = equipCFG.pos;
						local equipQuality = equipCFG.quality;
						if rewardPos == equipPos then
							if equipQuality < rewardQuality then
								result = true;
								return true;
							end
							hasPos = true;
						end
					end
				end
			end
			if not hasPos then
				result = true;
			end
		end
	end
	return result;
end

function BabelModel:GetTotalTimes()
	local total = 20
	if t_consts[48] then
		total = toint(t_consts[48].val3);
	end
	return total
end

function BabelModel:GetTotalTimesAvailable()
	local babelData = BabelModel.babelData;
	return babelData.daikyNum or 0;
end

function BabelModel:UpdateToQuest()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Babel) then return; end

	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Babel, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;

	local timeAvailable = self:GetTotalTimesAvailable();
	if QuestModel:GetQuest(questId) then
		if timeAvailable <= 0 then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if timeAvailable <= 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end