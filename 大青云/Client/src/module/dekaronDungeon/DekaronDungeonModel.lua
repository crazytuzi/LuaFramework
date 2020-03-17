--[[
	2016年1月8日12:01:41
	wangyanwei
	挑战副本model
]]

_G.DekaronDungeonModel = Module:new()

DekaronDungeonModel.dungeonData = nil;
DekaronDungeonModel.bestTeamList = nil;
DekaronDungeonModel.rankList = nil;
function DekaronDungeonModel:DekaronDungeonUpDate(dungeonData)
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
end

--获取副本信息
function DekaronDungeonModel:GetDekaronDungeonData()
	return self.dungeonData;
end

--获取排行榜信息
function DekaronDungeonModel:GetDekaronDungeonRankData()
	return self.rankList;
end

--获取最强队伍信息
function DekaronDungeonModel:GetDekaronDungeonBestTeamData()
	return self.bestTeamList;
end

--//击杀怪物列表
DekaronDungeonModel.killList = nil;
function DekaronDungeonModel:SetDungeonLayerMonster(killList)
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

function DekaronDungeonModel:GetDungeonKillMonsterList()
	return self.killList;
end

--自己队伍中队员准备状态
DekaronDungeonModel.teamStateList = nil;
function DekaronDungeonModel:SetDungeonTeamState(guid,state)
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

function DekaronDungeonModel:RemoveTeamState(guid)
	
end

function DekaronDungeonModel:ClearTeamDate()
	self.teamStateList = nil;
end