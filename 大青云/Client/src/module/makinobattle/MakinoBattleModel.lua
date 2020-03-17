--[[
	时间:   2016年10月20日 16:23:35
	开发者: houxudong
	功能:   牧野之数据
]]

_G.MakinoBattleDungeonModel = Module:new()

MakinoBattleDungeonModel.dungeonData = nil;
MakinoBattleDungeonModel.bestTeamList = nil;   --最强队伍列表
MakinoBattleDungeonModel.rankList = nil;       --排行榜
MakinoBattleDungeonModel.rewardList = nil;     --奖励列表
MakinoBattleDungeonModel.passWave = 0;         --通过波数
MakinoBattleDungeonModel.waveRewardList = nil; --每波奖励
MakinoBattleDungeonModel.totalNpcHp = 0;       --NPC初始血量
MakinoBattleDungeonModel.totalPointSocre = 0;  --当前的积分数

-- 返回牧野副本界面数据
function MakinoBattleDungeonModel:UpDateMakinoBattleDungeonData(dungeonData)
	self.rankList = nil
	self.bestTeamList = nil
	self.rewardList = nil
	local data = {};
	data.enterNum 		= dungeonData.enterNum;			--进入次数
	data.nowBestLayer	= dungeonData.nowBestLayer;		--今日挑战的最好成绩
	data.bestLayer		= dungeonData.bestLayer;		--自己历史最好成绩
	data.bestTeamLayer	= dungeonData.bestTeamLayer;	--全服历史最好成绩
	local bestTeamList	= dungeonData.bestTeamList;		--最强通关队伍列表
	local rankList		= dungeonData.rankList;			--排行榜列表
	local rewardList	= dungeonData.rewardList;		--奖励列表
	
	self.dungeonData = data;
	--排行榜数据
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
	--排行榜数据排序
	if self.rankList then
		table.sort(self.rankList,function(A,B)
			return A.rankIndex < B.rankIndex;
		end)
	end

	--最强队伍
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
	--队伍排序
	if self.bestTeamList then
		table.sort(self.bestTeamList,function (A,B)
			return A.cap < B.cap;
		end)
	end

	-- 通过奖励
	for i,v in ipairs(rewardList) do
		if not self.rewardList then
			self.rewardList = {};
		end
		if v.index ~= '' then
			local vo = {};
			vo.index = v.index;
			vo.state = v.get;
			table.push(self.rewardList,vo);
		end
	end
	-- 奖励排序
	if self.rewardList then
		table.sort( self.rewardList, function ( A,B)
			return A.index < B.index
		end )
	end
end

-- 获取牧野界面数据
function MakinoBattleDungeonModel:GetMakinoDungeonData( )
	return self.dungeonData
end

-- 获取排行榜信息
function MakinoBattleDungeonModel:GetRankListDungeonData( )
	return self.rankList
end

-- 获取最强队伍信息
function MakinoBattleDungeonModel:GetBeastTeamDungeonData( )
	return self.bestTeamList
end

-- 获取奖励信息
function MakinoBattleDungeonModel:GetRewardDungeonData( )
	return self.rewardList
end

-- 改变某个奖励的领取状态
function MakinoBattleDungeonModel:ChangeRewardState( msg )
	local index = msg.index;
	for i,v in ipairs(self.rewardList) do
		if v.index == index then
			v.state = 2   --已领取奖励
		end
	end
end

-- 返回波数和每波奖励信息
function MakinoBattleDungeonModel:BackWaveAndRewardData(msg)
	self.passWave = msg.layer
	if not self.waveRewardList then
		self.waveRewardList = msg.rewardList 
		return;
	end
	if not self.waveRewardList or not msg.rewardList then return; end
	for i,v in ipairs(msg.rewardList) do
		if self.waveRewardList[i] and v.itemId == self.waveRewardList[i].itemId then
			self.waveRewardList[i].itemNum = self.waveRewardList[i].itemNum + v.itemNum
		else
			local vo = {}
			vo.itemId = v.itemId
			vo.itemNum = v.itemNum
			table.push(self.waveRewardList,vo)
		end
	end
end

-- 设置当前的波数
function MakinoBattleDungeonModel:SetCurWave( )
	self.passWave = 0;
end

-- 得到当前的波数
function MakinoBattleDungeonModel:GetCurWave( )
	return self.passWave;
end

-- 得到当前每波的奖励
function MakinoBattleDungeonModel:GetEveryWaveReward( )
	return self.waveRewardList
end

-- 清空累计奖励
function MakinoBattleDungeonModel:ClearEveryWaveReward( )
	self.waveRewardList = {}
end

-- 设置初始的NPC血量信息
function MakinoBattleDungeonModel:SetInitNpcHp(msg)
	self.totalNpcHp = msg.maxHP
end

-- 获取初始的NPC血量信息
function MakinoBattleDungeonModel:GetInintNpcHp( )
	return self.totalNpcHp
end

-- 设置当前的积分
function MakinoBattleDungeonModel:SetCurAllPointScore(msg)
	self.totalPointSocre = msg.score
end

-- 获取当前的积分
function MakinoBattleDungeonModel:GetCurAllPointSocre( )
	return self.totalPointSocre
end

-- 清空当前的积分
function MakinoBattleDungeonModel:ClearCurAllPointScore()
	self.totalPointSocre = 0
end