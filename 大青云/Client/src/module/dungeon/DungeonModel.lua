--[[
副本 model
郝户
2014年11月17日21:31:53
]]

_G.DungeonModel = Module:new();

DungeonModel.isInDungeon = false
DungeonModel.currentDungeonId = nil;
DungeonModel.currentStep = -1
DungeonModel.currentMonsterId = 0
DungeonModel.vipEnterNum = 0
----------------------------------------------------------------------------------------------------
-- 副本组列表
DungeonModel.dungeonGroupList = {};   -- 用来存储单人副本同一组的副本数据

DungeonModel.currentKillNum = 0

-- filter : cfg.show_type, 根据显示类型进行筛选
function DungeonModel:GetDungeonGroupList(filter)
	if not filter then
		return self.dungeonGroupList
	end
	local list = {}
	local playerLv = MainPlayerModel.humanDetailInfo.eaLevel
	for group, dungeonGroup in pairs(self.dungeonGroupList) do
		local cfgInfo  = dungeonGroup:GetGroupCfg()
		if dungeonGroup:GetShowType() == filter then
			list[group] = dungeonGroup
		end
	end
	return list
end

function DungeonModel:SetVipEnterNum(num )
	if self.vipEnterNum ~= num then
		self.vipEnterNum = num
	end
end

function DungeonModel:GetVipEnterNum( )
	return DungeonConsts:GetDiamondVipEnterConst() - self.vipEnterNum or 0
end

function DungeonModel:ResetKillNum(targetStr)
	self.currentKillNum = 0
	self.currentMonsterId = 0
	if not targetStr or targetStr == "" then return end
	local targetList = split(targetStr, ",")
	if targetList and #targetList > 0 then
		self.currentMonsterId = toint(targetList[1])
	end
end

function DungeonModel:SetKillNum(value)
	local charId = value.deadid
	local monster = MonsterController:GetMonster(charId)
	if not monster then
		Debug("monster dead: ", charId)
		return
	end
	
	if monster.monsterId == self.currentMonsterId then
		self.currentKillNum = self.currentKillNum + 1
		UIDungeonStory:UpdateKillNum()
	end
end

-- 副本难度
function DungeonModel:GetDungeonDifficulty()
	if self.currentDungeonId then
		return self.currentDungeonId % 100;
	end

	-- local cfg = t_dungeons[self.currentDungeonId]
	-- if cfg then
	-- 	return cfg.difficulty
	-- end

	return nil
end

--初始化单人副本item
function DungeonModel:Init()
	local index = 0;
	for id, cfg in pairs(t_dungeons) do
		local group = cfg.group;
		index = index +1;
		local playerLv = MainPlayerModel.humanDetailInfo.eaLevel
		if not self:GetDungeonGroup( group ) then
			local dungeonGroup = DungeonGroup:new()
			dungeonGroup:SetGroup( group )
			self:SetDungeonGroup( dungeonGroup );

			local cfgInfo  = dungeonGroup:GetGroupCfg()
			-- WriteLog(LogType.Normal,true,'-------------cfgInfo.min_level',cfgInfo.min_level)

		end

		--[[
		local minLevel = toint(cfg.min_level);
		local maxLevel = toint(cfg.max_level);

		if playerLv >= minLevel and playerLv <= maxLevel then
			break;
		else
			return;
		end
		--]]
	end
end

-- 服务端通知: 更新副本组列表(同一地图不同难度为一组)
function DungeonModel:UpdateDungeonGroupList(dungeonGroupList,vipTimes)
	for _, vo in pairs(dungeonGroupList) do
		local dungeonGroup = self:GetDungeonGroup( vo.group )  --副本组
		if not dungeonGroup then return; end                   --change:hoxudong date:2016/5/20
		dungeonGroup:SetUsedTimes( vo.usedTimes )              --已用次数
		dungeonGroup:SetUsedPayTimes( vo.usedPayTimes )        --已用付费次数
		dungeonGroup:SetCurrentDiff( vo.curDiff )
		for diff, diffInfo in pairs(vo.difficultyList) do
			dungeonGroup:SetMyTimeOfDifficulty( diff, diffInfo.time )
		end
		self:sendNotification( NotifyConsts.DungeonGroupChange );
	end
	self:SetVipEnterNum(vipTimes)	
	-- print("黄金vip进入次数",vipTimes)
	self:UpdateToQuest_BXDG()
	self:UpdateToQuest_SGZC()
end

function DungeonModel:GetDungeonGroup( group )
	return self.dungeonGroupList[group];
end

function DungeonModel:SetDungeonGroup(  dungeonGroup )
	local group = dungeonGroup:GetGroup()

	self.dungeonGroupList[group] = dungeonGroup;

	-- local cfgInfo  = dungeonGroup:GetGroupCfg()
	-- WriteLog(LogType.Normal,true,'-------------cfgInfo.min_level哈哈哈',cfgInfo.min_level)
end

function DungeonModel:IsDungeonDialog()
	if not self.isInDungeon then return false end
	local stepVO = t_dunstep[self.currentStep]
	
	if stepVO then 
		if stepVO.type == 3 then return true end 
	end
	
	return false
end

function DungeonModel:GetDungeonStep()
	if not self.isInDungeon then return -1 end
	
	return self.currentStep
end

function DungeonModel:IsInDungeon()
	return self.isInDungeon;
end

--------------------------------------------------------------------------------------------------------

-- 副本排行榜
DungeonModel.dungeonRankInfo = {};

function DungeonModel:SetRank(id, rankList, championIcon)
	local rankInfo = {};
	rankInfo.rankList = rankList
	rankInfo.championIcon = championIcon;
	self.dungeonRankInfo[id] = rankInfo;
	self:sendNotification( NotifyConsts.DungeonRank, id );
end

function DungeonModel:GetRank(id)
	return self.dungeonRankInfo[id];
end

function DungeonModel:GetRankVO(id, rank)
	local rankInfo = self.dungeonRankInfo[id];
	local rankList = rankInfo and rankInfo.rankList;
	return rankList and rankList[rank];
end

-------------------------------------------old-------------------------------------------------------------

-- -- 副本排行榜
-- DungeonModel.dungeonRankInfo = {};

-- function DungeonModel:SetRank(group, rankList, championIcon)
-- 	local groupRankInfo = {};
-- 	groupRankInfo.rankList = rankList
-- 	groupRankInfo.championIcon = championIcon;
-- 	self.dungeonRankInfo[group] = groupRankInfo;
-- 	self:sendNotification( NotifyConsts.DungeonRank, group );
-- end

-- function DungeonModel:GetRank(group)
-- 	return self.dungeonRankInfo[group];
-- end

-- function DungeonModel:GetRankVO(group, rank)
-- 	local groupRankInfo = self.dungeonRankInfo[group];
-- 	local rankList = groupRankInfo and groupRankInfo.rankList;
-- 	return rankList and rankList[rank];
-- end

-----------------------------------------------------------------
--跨服副本
-----------------------------------------------------------------
DungeonModel.interDungeonList = {}
function DungeonModel:InitInterDungeon()
	for id, cfg in pairs(t_worlddungeons) do
		if not self:GetInterDungeon( id ) then
			local dungeonVO = InterDungeonVO:new()
			dungeonVO:SetId( id )
			self:SetInterDungeon( dungeonVO );
		end
	end
end

function DungeonModel:SetInterDungeon(  dungeonVO )
	local dungeonId = dungeonVO:GetId()
	self.interDungeonList[dungeonId] = dungeonVO;
end

function DungeonModel:GetInterDungeon( dungeonId )
	return self.interDungeonList[dungeonId];
end


function DungeonModel:UpdateInterDungeonList(interDungeonList)
	for _, vo in pairs(interDungeonList) do
		local dungeonGroup = self:GetInterDungeon( vo.Id )
		dungeonGroup:SetUsedTimes( vo.usedTimes )
		dungeonGroup:SetUsedPayTimes( vo.usedPayTimes )
	end
	-- self:sendNotification( NotifyConsts.DungeonGroupChange );
end

function DungeonModel:UpdateToQuest_BXDG()
	if not FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon) then return; end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_BXDG, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;

	local timeAvailable = DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_BXDG)
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

function DungeonModel:UpdateToQuest_SGZC()
	if not FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon) then return; end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_SGZC, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;

	local timeAvailable = DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_SGZC)
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

-- 单人副本进入消耗的VIP的类型是否满足(黄金vip)
function DungeonModel:CheckVip( )
	local vipType = VipController:IsGoldVip()             --是否是黄金vip
	if vipType then
		return true
	end
	return false
end