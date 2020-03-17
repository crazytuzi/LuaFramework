--[[
	2015年6月18日, PM 09:02:27
	新版极限挑战Model
	wangyanwei
]]

_G.ExtremitChallengeModel = Module:new();

--UI存储数据

ExtremitChallengeModel.myExtremityData = {};
ExtremitChallengeModel.extremityBossRankList = {};
ExtremitChallengeModel.extremityMonsterRankList = {};

function ExtremitChallengeModel:OnInitMyData(bossHarm,bossRank,monsterRank,monsterNum,bossState,monsterState,bossJoinNum,monsterJoinNum)
	self.myExtremityData = {};
	self.myExtremityData.bossHarm = bossHarm;
	self.myExtremityData.bossRank = bossRank;
	self.myExtremityData.monsterRank = monsterRank;
	self.myExtremityData.monsterNum = monsterNum;
	self.myExtremityData.bossState = bossState;
	self.myExtremityData.monsterState = monsterState;
	self.myExtremityData.bossJoinNum = bossJoinNum;
	self.myExtremityData.monsterJoinNum = monsterJoinNum;
end

--BOSS总人数
function ExtremitChallengeModel:GetBossOverNum()
	local maxNum = self.myExtremityData.bossJoinNum or 0;
	local myRankIndex = self.myExtremityData.bossRank or 0;
	if maxNum == 0 or myRankIndex == 0 then
		return nil
	end
	if maxNum == 1 then
		return 100
	end
	local overNum = 100 - toint(myRankIndex / maxNum) * 100;
	if overNum == 0 then return 1 end
	if overNum == 100 then return 99 end
	return overNum
end

--Monster总人数
function ExtremitChallengeModel:GetMonsterOverNum()
	local maxNum = self.myExtremityData.monsterJoinNum or 0;
	local myRankIndex = self.myExtremityData.monsterRank or 0;
	if maxNum == 0 or myRankIndex == 0 then
		return nil
	end
	if maxNum == 1 then
		return 100
	end
	local overNum = 100 - toint(myRankIndex / maxNum) * 100;
	if overNum == 0 then return 1 end
	if overNum == 100 then return 99 end
	return overNum
end

--自己历史最高记录
ExtremitChallengeModel.maxData = {};
function ExtremitChallengeModel:OnSaveMaxNum(bossHarm,monsterNum)
	self.maxData.bossHarm = bossHarm;
	self.maxData.monsterNum = monsterNum;
end

--获取自己的最高记录
function ExtremitChallengeModel:OnGetMySelfMaxData()
	return self.maxData;
end

--领奖成功后改变奖励状态
function ExtremitChallengeModel:OnSetRewardState()
	local data = self.myExtremityData;
	if data == {} then return end
	data.bossState = 1;
	data.monsterState = 1;
end

function ExtremitChallengeModel:OnInitRankData(bossRankList,monsterRankList)
	self.extremityBossRankList = {};
	self.extremityMonsterRankList = {};
	
	--存储BOSS排行榜数据
	for i , v in ipairs(bossRankList) do
		if v.roleId ~= '0_0' then
			local vo = {};
			vo.roleId = v.roleId;
			vo.roleRank = v.roleRank;
			vo.roleName = v.roleName;
			vo.roleHarm = v.roleHarm;
			table.push(self.extremityBossRankList,vo);
		end
	end
	
	--存储小怪排行榜数据
	for i , v in ipairs(monsterRankList) do
		if v.roleId ~= '0_0' then
			local vo = {};
			vo.roleId = v.roleId;
			vo.roleRank = v.roleRank;
			vo.roleName = v.roleName;
			vo.roleNum = v.roleNum;
			table.push(self.extremityMonsterRankList,vo);
		end
	end
end

function ExtremitChallengeModel:GetBossRankData()
	local bossRankData = self.extremityBossRankList;
	self.extremityBossRankList = {};
	return bossRankData;
end

function ExtremitChallengeModel:GetBossMonsterData()
	local monsterRankData = self.extremityMonsterRankList;
	self.extremityMonsterRankList = {};
	return monsterRankData;
end

--//获取领奖状态
function ExtremitChallengeModel:GetBossRewardState()
	return self.myExtremityData.bossState
end

function ExtremitChallengeModel:GetMonsterRewardState()
	return self.myExtremityData.monsterState
end

--进入后定时请求临时排名
function ExtremitChallengeModel:OnSendRankIndex()
	local func = function ()
		if UIExtremitChallengeInfo:IsShow() then
			local state = self:GetExtremityType();
			if state == 0 then
				ExtremitChallengeController:OnSendRankIndex(state,self:OnGetBossHarm())
			else
				ExtremitChallengeController:OnSendRankIndex(state,self:OnGetKillMonsterNum())
			end
		end
	end
	local cfg = t_consts[84];
	self.timeKey = TimerManager:RegisterTimer(func,cfg.val1 * 1000);
	func();
end

--//退出后移除请求排名定时器
function ExtremitChallengeModel:OnCleanTime()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--存储预估排名
ExtremitChallengeModel.rankNum = 0;
function ExtremitChallengeModel:OnSetRankNum(rankNum)
	self.rankNum = rankNum;
end

--储存BOSS伤害
ExtremitChallengeModel.bossHarm = 0;
function ExtremitChallengeModel:OnSetBossHarm(bossHarm)
	self.bossHarm = bossHarm;
end

--储存击杀小怪数量
ExtremitChallengeModel.killMonsterNum = 0;
function ExtremitChallengeModel:OnSetMonsterNum(killMonsterNum)
	self.killMonsterNum = killMonsterNum;
end

function ExtremitChallengeModel:OnGetRankNum()
	return self.rankNum;
end

function ExtremitChallengeModel:OnGetBossHarm()
	return self.bossHarm;
end

function ExtremitChallengeModel:OnGetKillMonsterNum()
	return self.killMonsterNum;
end

--进入成功后储存进入的副本类型
ExtremitChallengeModel.extremityType = 0;
function ExtremitChallengeModel:SetExtremityType(extremityType)
	self.extremityType = extremityType;
end

function ExtremitChallengeModel:GetExtremityType()
	return self.extremityType;
end