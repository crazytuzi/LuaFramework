--[[
	2015年11月13日23:56:40
	wangyanwei
	骑战副本
]]

_G.QiZhanDungeonModel = Module:new()

QiZhanDungeonModel.dungeonData = nil;
QiZhanDungeonModel.bestTeamList = nil;
QiZhanDungeonModel.rankList = nil;
QiZhanDungeonModel.rewardList = nil;  --累计奖励
function QiZhanDungeonModel:QiZhanDungeonUpDate(dungeonData)
	self.rankList = nil
	self.bestTeamList = nil
	local data = {};
	data.enterNum 		= dungeonData.enterNum;			--进入进入次数
	data.nowBestLayer	= dungeonData.nowBestLayer;		--今日挑战的最好成绩
	data.bestLayer		= dungeonData.bestLayer;		--自己历史最好成绩
	data.bestTeamLayer	= dungeonData.bestTeamLayer;	--全服历史最好成绩
	local bestTeamList	= dungeonData.bestTeamList;		--最强通关队伍列表
	local rankList		= dungeonData.rankList;			--排行榜列表
	
	self.dungeonData = data;
	
	--//排行榜数据
	for i , rankVO in ipairs(rankList) do
		if not self.rankList then
			self.rankList = {};
		end
		if rankVO.name ~= '' then
			local vo = {};
			vo.name 		= rankVO.name;			--人物名称
			vo.layer 		= rankVO.layer;			--通关层数
			vo.rankIndex	= rankVO.rankIndex;		--排行名次
			
			table.push(self.rankList,vo);
		end
	end
	--//排行榜数据排序
	if self.rankList then
		table.sort(self.rankList,function(A,B)
			return A.rankIndex < B.rankIndex;
		end)
	end
	
	--//最强队伍
	for i , bestTeamVO in ipairs(bestTeamList) do
		if not self.bestTeamList then
			self.bestTeamList = {};
		end
		if bestTeamVO.name ~= '' then
			local vo = {};
			vo.name = bestTeamVO.name;				--人物名称
			vo.cap 	= bestTeamVO.cap ;			--是否队长  0是队长
			
			table.push(self.bestTeamList,vo);
		end
	end
	--//队伍排序
	if self.bestTeamList then
		table.sort(self.bestTeamList,function (A,B)
			return A.cap < B.cap;
		end)
	end

	if FuncManager:GetFuncIsOpen(FuncConsts.teamDungeon) then
		self:UpdateToQuest();
	end
end

-- 累计奖励
function QiZhanDungeonModel:QiZhanDungeonUpDateReward( list )
	self.rewardList = {}
	for k,v in pairs(list) do
		local vo = {}
		vo.id  = v.itemId
		vo.num = v.itemNum
		table.push(self.rewardList,vo)
	end
end

function QiZhanDungeonModel:UpdateToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Team_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); --今日剩余次数
	if QuestModel:GetQuest(questId) then
		--次数不够不显示 yanghongbin/jianghaoran 2-16-8-22
		if enterNum <= 0 then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if enterNum <= 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function QiZhanDungeonModel:GetNextLayerNum()
	local num = 0;
	local dungeonData = QiZhanDungeonModel:GetQiZhanDungeonData();
	local bestLayer = dungeonData.bestLayer;
	num = bestLayer + 1;
	if bestLayer == QiZhanDungeonUtil:GetListCount() then  --最高层数
		num = bestLayer;
	end
	return num;
end

--获取副本信息
function QiZhanDungeonModel:GetQiZhanDungeonData()
	return self.dungeonData;
end

--获取排行榜信息
function QiZhanDungeonModel:GetQiZhanDungeonRankData()
	return self.rankList;
end

--获取最强队伍信息
function QiZhanDungeonModel:GetQiZhanDungeonBestTeamData()
	return self.bestTeamList;
end

--获取累计奖励信息
function QiZhanDungeonModel:GetQiZhanDungeonRewardListData()
	return self.rewardList;
end

--//击杀怪物列表
QiZhanDungeonModel.killList = nil;
function QiZhanDungeonModel:SetDungeonLayerMonster(killList)
	self.killList = {};						--//清空
	
	local list = {};
	for i , killVO in pairs(killList) do			--相同怪物ID合并
		if not list[killVO.monsterId] then
			list[killVO.monsterId] = {};
			list[killVO.monsterId].id = killVO.monsterId;
			list[killVO.monsterId].num = killVO.monsterNum;
		else
			list[killVO.monsterId].num = list[killVO.monsterId].num + killVO.monsterNum;
		end
	end
	
	self.killList = list;
end

function QiZhanDungeonModel:GetDungeonKillMonsterList()
	return self.killList;
end

--自己队伍中队员准备状态
QiZhanDungeonModel.teamStateList = nil;
function QiZhanDungeonModel:SetDungeonTeamState(guid,state)
	if not self.teamStateList then
		self.teamStateList = {};
	end
	
	local player = TeamModel:GetMemberById(guid);
	if not player then
		print('team not player------------',guid)
		print('team not player------------',guid)
		trace(TeamModel:GetMemberList())
		print('team not player------------',guid)
		print('team not player------------',guid)
	end
	
	
	if not self.teamStateList[guid] then
		self.teamStateList[guid] = {};
	end
	self.teamStateList[guid].guid = guid;
	self.teamStateList[guid].state = state;
end

function QiZhanDungeonModel:RemoveTeamState(guid)
	
end

function QiZhanDungeonModel:ClearTeamDate()
	self.teamStateList = nil;
end