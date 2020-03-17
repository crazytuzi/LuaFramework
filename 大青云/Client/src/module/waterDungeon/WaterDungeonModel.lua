--[[
流水副本 model
2015年6月24日12:21:10
haohu
]]

_G.WaterDungeonModel = Module:new()

----------------------------- 流水副本基本信息 ------------------------

WaterDungeonModel.bestWave    = 0 -- 我的最佳波数
WaterDungeonModel.bestExp     = 0 -- 我的最高经验
WaterDungeonModel.bestMonster = 0 -- 我的最多杀怪
WaterDungeonModel.timeUsed    = 0 -- 已用次数
WaterDungeonModel.leftTime    = 0 -- CD剩余时间
WaterDungeonModel.totalKillMonster = 0 --累计杀死怪物数量
WaterDungeonModel.bufferTime = 0 --buffer增加的时间
function WaterDungeonModel:GetBestWave()
	return self.bestWave
end

function WaterDungeonModel:SetBestWave( wave )
	if self.bestWave ~= wave then
		self.bestWave = wave
		self:sendNotification( NotifyConsts.WaterDungeonBestWave )
	end
end

function WaterDungeonModel:GetBestExp()
	return self.bestExp
end

function WaterDungeonModel:SetBestExp( exp )
	if self.bestExp ~= exp then
		self.bestExp = exp
		self:sendNotification( NotifyConsts.WaterDungeonBestExp )
	end
end

function WaterDungeonModel:GetBestMonster()
	return self.bestMonster
end

function WaterDungeonModel:SetBestMonster( monster )
	if self.bestMonster ~= monster then
		self.bestMonster = monster
		self:sendNotification( NotifyConsts.WaterDungeonBestMonster )
	end
end

-- 剩余次数(包括免费次数和付费次数)
-- date:2016/9/28 16:53:52
function WaterDungeonModel:GetTimeAvailable()
	-- 可以使用的总次数(包括免费次数和付费次数)
	local totalTimes = WaterDungeonConsts:GetPayTime() + WaterDungeonConsts:GetDailyFreeTime()
	return math.max( totalTimes - self.timeUsed, 0 )
end

-- 剩余次数(包括免费次数和付费次数)(新)
function WaterDungeonModel:GetTimeAvailableNew()
	-- 可以使用的总次数(包括免费次数和付费次数)
	local totalTimes = WaterDungeonConsts:GetDailyAllTime()
	return math.max( totalTimes - self.timeUsed, 0 )
end

-- 流水副本免费进入次数
function WaterDungeonModel:GetDayFreeTime()
	local freeTimes = WaterDungeonConsts:GetDailyFreeTime() or 0
	local times = freeTimes - self.timeUsed > 0 and freeTimes - self.timeUsed or 0
	return times
end

-- 流水副本付费次数
function WaterDungeonModel:GetDayPayTime()
	local payTimes = WaterDungeonConsts:GetPayTime()                --付费次数
	local dayFreeTimes = WaterDungeonConsts:GetDailyFreeTime() or 1  --免费进入次数
	local dayilyUseTimes =  WaterDungeonModel:GetTimeUsed() or 0    --每日已经使用次数
	if dayilyUseTimes >= dayFreeTimes then
		return math.max( payTimes +dayFreeTimes - self.timeUsed, 0 )
	else
		return math.max( payTimes, 0 )
	end
end

-- 流水副本付费次数(新)
function WaterDungeonModel:GetDayPayTimeNew()
	local totalTimes = WaterDungeonConsts:GetDailyAllTime()            --总进入次数
	local dayFreeTimes = WaterDungeonConsts:GetDailyFreeTime() or 1    --免费进入次数
	local dayilyUseTimes =  WaterDungeonModel:GetTimeUsed() or 0       --每日已经使用次数
	if dayilyUseTimes >= dayFreeTimes then
		return math.max( totalTimes - self.timeUsed, 0 )
	else
		return math.max( totalTimes - dayFreeTimes, 0 )
	end
end

function WaterDungeonModel:GetTimePayAvailable()
	local payTime = WaterDungeonConsts:GetPayTime()   --每日付费次数
	local freeTime = WaterDungeonConsts.timePerDay    --每日免费进入次数
	if self.timeUsed >= WaterDungeonConsts.timePerDay then
		return payTime - ( self.timeUsed - freeTime )
	end
	return payTime
end

-- 经验副本进入消耗的道具的条件是否满足
function WaterDungeonModel:GetPick( )
	local itemId, itemNum = WaterDungeonConsts:GetEnterItem()
	local costItemEnough = BagModel:GetItemNumInBag( itemId ) >= itemNum or false
	return costItemEnough
end

-- 经验副本进入消耗的VIP的类型是否满足
function WaterDungeonModel:CheckVip( )
	local vipType = VipController:IsDiamondVip()             --vip类型是钻石vip
	if vipType then
		return true
	end
	return false
end

function WaterDungeonModel:GetTimeUsed()
	return self.timeUsed
end

function WaterDungeonModel:SetTimeUsed( timeUsed )
	if self.timeUsed ~= timeUsed then
		self.timeUsed = timeUsed
		self:sendNotification( NotifyConsts.WaterDungeonTimeUsed )
	end
	if FuncManager:GetFuncIsOpen(FuncConsts.experDungeon) then
		self:UpdateToQuest();
	end
end


function WaterDungeonModel:SetLeftTime( leftTime )
	if self.leftTime ~= leftTime then
		self.leftTime = leftTime;
	end
end

-- CD剩余时间
function WaterDungeonModel:GetLeftTime( )
	return self.leftTime >= 0 and self.leftTime or 0 ;
end

function WaterDungeonModel:UpdateToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_EXP_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local timeAvailable = WaterDungeonModel:GetDayFreeTime()
	if QuestModel:GetQuest(questId) then
		--次数不够不显示 yanghongbin/jianghaoran 2-16-8-22
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

WaterDungeonModel.lossExp = 0;		--可领取的损失经验
function WaterDungeonModel:SetLossExp(moreExp)
	if not moreExp then return end
	self.lossExp = moreExp;
	self:sendNotification( NotifyConsts.WaterDungeonLossExp )
end

function WaterDungeonModel:GetLossExp()
	return self.lossExp;
end

----------------------------- 流水副本排行榜信息 ------------------------

WaterDungeonModel.rankList = {}

function WaterDungeonModel:GetRankList()
	return self.rankList
end

-- list { rank = { roleId, name, icon, wave } }
function WaterDungeonModel:SetRankList(list)
	self.rankList = list
	self:sendNotification( NotifyConsts.WaterDungeonRank )
end

----------------------------- 流水副本进度信息 ------------------------

WaterDungeonModel.currentWave        = 1 -- 当前第几波
WaterDungeonModel.currentWaveMonster = 0 -- 当前波杀怪数
WaterDungeonModel.totalExp           = 0 -- 累积获得经验

function WaterDungeonModel:GetCurrentWave()
	return self.currentWave
end

function WaterDungeonModel:SetCurrentWave(wave)
	if self.currentWave ~= wave then
		self.currentWave = wave
		self:sendNotification( NotifyConsts.WaterDungeonWave )
	end
end

function WaterDungeonModel:GetCurrentWaveMonster()
	return self.currentWaveMonster
end

function WaterDungeonModel:SetCurrentWaveMonster(numMonster)
	if self.currentWaveMonster ~= numMonster then
		self.currentWaveMonster = numMonster
		self:sendNotification( NotifyConsts.WaterDungeonWaveMonster )
	end
end

function WaterDungeonModel:SetTotalMonster(numMonster)
	if self.totalKillMonster ~= numMonster then
		self.totalKillMonster = numMonster;
		self:sendNotification( NotifyConsts.WaterDungeonTotalMonster )
	end
end

function WaterDungeonModel:GetTotalMonster()
	-- local waveMonster = WaterDungeonConsts:GetWaveMonsterNum()
	-- local historyMonster = (self.currentWave - 1) * waveMonster
	-- return historyMonster + self.currentWaveMonster
	return self.totalKillMonster
end

function WaterDungeonModel:GetExp()
	return self.totalExp
end

function WaterDungeonModel:SetExp(exp)
	if self.totalExp ~= exp then
		self.totalExp = exp
		self:sendNotification( NotifyConsts.WaterDungeonExp )
	end
end

function WaterDungeonModel:SetAddBufferTime(time)
	self.bufferTime = time;
	self:sendNotification( NotifyConsts.WaterDungeonBufferTime)
end

function WaterDungeonModel:GetBufferTime()
	return self.bufferTime
end

-- 清除进度
function WaterDungeonModel:ClearProgress()
	self.currentWave        = 1 -- 当前第几波
	self.currentWaveMonster = 0 -- 当前波杀怪数
	self.totalExp           = 0 -- 累积获得经验
	self.totalKillMonster   = 0 -- 累计杀死怪物数量
end

--------------------------------------------------------------------------------