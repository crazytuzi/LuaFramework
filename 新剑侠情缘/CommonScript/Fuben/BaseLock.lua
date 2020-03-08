-------------------------------------------------------------------
--File		: baselock.lua
--Author	: zhengyuhua
--Date		: 2008-5-13 10:24
--Describe	: 基础锁逻辑脚本
-------------------------------------------------------------------
Fuben.Lock = Fuben.Lock or {};
Fuben.Lock.tbBaseLock = {}
local tbBaseLock = Fuben.Lock.tbBaseLock;

-- 前序锁类型
tbBaseLock.SERIES_LOCK		= 1;	-- 串锁
tbBaseLock.PARALLEL_LOCK	= 2; 	-- 并锁

function tbBaseLock:InitLock(nTime, nMultiNum)
	self.tbNextLock = {};
	self.tbSerPreLock = {};	-- 串式前序锁
	self.tbParPreLock = {}; -- 并式前序锁
	self.nPreLockNum = 0;
	if not self.nLockId then
		self.nLockId = 0;
	end
	self.nStartState = 0;
	self.nLockState = 0;
	self.nTimerId = 0;
	self.nTime = nTime;
	self.nClose = 0;
	self.nMultiNum = nMultiNum;
end


-----
-- 串式前序锁 所有前序锁解开才可解开
-- 并式前序锁 任何一前序锁解开则这一并式前序锁算解开
-- 例如:
-- tbLock:AddPreLock(tbLock1, tbLock2, {tbLock3, tbLock4}, tbLock5, {tbLock6, tbLock7})
-- 其中{tbLock3, tbLock4}, {tbLock6, tbLock7} 属于两个串序锁，也就是{tbLock3, tbLock4} 中tbLock3,tbLock4只要有1个解开，
--串序锁就算解开。
-- 所以要使tbLock开始，必须都解开前序锁 tbLock1, tbLock2, tbLock3(或tbLock4), tbLock5, tbLock6(或tbLock7)
function tbBaseLock:AddPreLock(...)
	local arg = {...}
	for i, tbPreLock in pairs(arg) do
		if type(tbPreLock) == "table" and tbPreLock.tbNextLock then
			self.tbSerPreLock[tbPreLock.nLockId] = 1;
			table.insert(tbPreLock.tbNextLock, {nType = self.SERIES_LOCK, tbLock = self});	-- 串式前序锁
			self.nPreLockNum = self.nPreLockNum + 1;
		elseif type(tbPreLock) == "table" then
			local nParLockId = #self.tbParPreLock;
			local bIsAvail = 0;
			for j, tbSubLock in pairs(tbPreLock) do
				if tbSubLock.tbNextLock then
					bIsAvail = 1;
					if not self.tbParPreLock[nParLockId] then
						self.tbParPreLock[nParLockId] = {};
					end
					self.tbParPreLock[nParLockId][tbSubLock.nLockId] = 1;
					table.insert(tbSubLock.tbNextLock, {nType = self.PARALLEL_LOCK, tbLock = self, nIndex = nParLockId});	-- 并式前序锁
				end

			end
			if bIsAvail == 1 then
				self.nPreLockNum = self.nPreLockNum + 1;
			end
		end
	end
end

function tbBaseLock:UnLockPreLock(nType, nLockId, nIndex)	-- nIndex 只对并式锁有效,即nType == self.PARALLEL_LOCK
	if self.nStartState == 1 then	-- 锁内逻辑已经开始
		return 0;
	end
	if nType == self.SERIES_LOCK then
		if self.tbSerPreLock[nLockId] then
			self.tbSerPreLock[nLockId]= nil;
			self.nPreLockNum = self.nPreLockNum - 1;
		end
	elseif nType == self.PARALLEL_LOCK then
		if self.tbParPreLock[nIndex] then
			if self.tbParPreLock[nIndex][nLockId] then
				self.tbParPreLock[nIndex] = nil;
				self.nPreLockNum = self.nPreLockNum - 1;
			end
		end
	end
	if self.nPreLockNum <= 0 then
		self:StartLock();
		return 1;
	end
end

function tbBaseLock:StartLock()
	if self.nStartState == 1 or self.nClose == 1 then
		return 0;
	end
	self.nStartState = 1;
	if self.nTime > 0 then
		self.nTimerId = Timer:Register(self.nTime, self.TimeOut, self);
	end
	self:OnStartLock();
	if self.nMultiNum <= 0 and self.nTime == 0 then
		self:UnLock();
	end
end

function tbBaseLock:UnLock()
	if self.nLockState == 1 or self.nClose == 1 then
		return 0;
	end
	self.nLockState = 1;
	self:OnUnLock();
	if self.nClose == 1 then
		return 0;
	end
	for i, tbLock in pairs(self.tbNextLock) do
		tbLock.tbLock:UnLockPreLock(tbLock.nType, self.nLockId, tbLock.nIndex);
	end
	self:Close();
end

-- 开始锁内逻辑(可重载)
function tbBaseLock:OnStartLock()
end

-- 本锁被解开后的回调 (可重载)
function tbBaseLock:OnUnLock()
end

function tbBaseLock:UnLockMulti()
	self.nMultiNum = self.nMultiNum - 1
	if self.nMultiNum <= 0 and self.nLockState == 0 and self.nStartState == 1 then
		self:UnLock();
	end
end

function tbBaseLock:TimeOut()
	self.nTimerId = 0;
	if self.nLockState == 0 then
		self:UnLock();
	end
end

function tbBaseLock:IsStart()
	return self.nStartState;
end

function tbBaseLock:IsLock()
	return self.nLockState;
end

function tbBaseLock:GetTimeInfo()
	if not self.nTimerId or (self.nTimerId <= 0 and not self.nLastTime) then
		return;
	end

	local nTotalTime = self.nTime or 0;
	if self.nLastTime then
		return math.max((nTotalTime - self.nLastTime), 0) / Env.GAME_FPS, nTotalTime / Env.GAME_FPS;
	end

	local nLastTime = Timer:GetRestTime(self.nTimerId);
	if nLastTime < 0 then
		return;
	end

	return math.max(nTotalTime - nLastTime, 0) / Env.GAME_FPS, nTotalTime / Env.GAME_FPS;
end

function tbBaseLock:GetNextLock()
	return self.tbNextLock;
end

function tbBaseLock:Pause()
	assert(self.nMultiNum == 0);
	if not self.nTime or self.nTime <= 0 or not self.nTimerId or self.nTimerId <= 0 or self.nClose == 1 then
		return;
	end

	self.nLastTime = Timer:GetRestTime(self.nTimerId);
	Timer:Close(self.nTimerId);
	self.nTimerId = 0;
end

function tbBaseLock:Resume()
	if self.nLastTime and self.nLastTime > 0 and self.nClose ~= 1 then
		self.nTimerId = Timer:Register(self.nLastTime, self.TimeOut, self);
		self.nLastTime = nil;
	end
end

function tbBaseLock:Close()
	if self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
		self.nTimerId = 0;
	end
	self.nClose = 1;
end
