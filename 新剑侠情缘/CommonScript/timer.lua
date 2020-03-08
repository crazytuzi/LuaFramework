-- 文件名　：timer.lua
-- 创建者　：FanZai
-- 创建时间：2007-10-08 22:09:05
-- 文件说明：计时器系统


-- 范例见最下面

if (not Timer.tbTimeTable) then
	-- 注：	本系统中使用的uActiveTime变量在GC上表示毫秒，GS和Client上表示桢数。
	--		本系统的对外接口保持一致，使用桢数。
	-- 时刻表：[uActiveTime] = {nRegisterId1, nRegisterId2, ...}
	Timer.tbTimeTable	= {};
	-- 注册表：[nRegisterId] = {uActiveTime=.., nIdx=.., tbCallBack=..}
	Timer.tbRegister	= {};

	if (not Timer.nHaveUsedTimerId) then
		Timer.nHaveUsedTimerId = 0;
	end;
	Timer.tbAttach	= {};
end

-- 由程序根据注册情况，需要时调用
function Timer:OnActive(uCurrentTime)
	if MODULE_GAMECLIENT then
		local nCurrentTime = os.clock();
		self.nLastActiveTime = self.nLastActiveTime or 0;
		self.nLastClock = self.nLastClock or 0;
		if uCurrentTime == self.nLastActiveTime and nCurrentTime - self.nLastClock < 0.5 then
			return;
		end

		self.nLastActiveTime = uCurrentTime;
		self.nLastClock = os.clock();
	end

	local tbTime		= self.tbTimeTable[uCurrentTime];
	if (not tbTime) then
		return;
	end

	-- 建立一个table用于存放在本次调用中决定关闭的Timer
	self.tbToBeClose	= {};

	-- 这里不会有新的Timer注册在当前帧，可以不复制tbTime
	for nIdx, nRegisterId in pairs(tbTime) do
		if (not self.tbToBeClose[nRegisterId]) then	-- 没有打算关闭此Timer
			local tbEvent		= self.tbRegister[nRegisterId];

			local tbCallBack	= tbEvent.tbCallBack;
			local bOK, bRet		= Lib:CallBack(tbCallBack);	-- 调用回调

			if (not bOK) or (not bRet) or (bRet == 0) then									-- 返回nil false 0 或者 回调失败关闭Timer
				self.tbToBeClose[nRegisterId]	= 1;
			elseif (bRet) then												-- 返回true 继续循环
				local uNewTime	= RegisterTimerPoint(tbEvent.nWaitTime);
				tbEvent.nWaitTime	= tbEvent.nWaitTime;
				tbEvent.uActiveTime	= uNewTime;
				local tbNewTime		= self.tbTimeTable[uNewTime];
				if (not tbNewTime) then	-- 此时刻尚无注册
					self.tbTimeTable[uNewTime]	= {nRegisterId};
					tbEvent.nIdx				= 1;
				else	-- 此时刻已有注册
					tbEvent.nIdx			= #tbNewTime + 1;
					tbNewTime[tbEvent.nIdx]	= nRegisterId;
				end
			end
		end
	end

	-- 将累积下来的要关闭的Timer全都关闭
	for nRegisterId in pairs(self.tbToBeClose) do
		local tbEvent	= self.tbRegister[nRegisterId];
		self.tbRegister[nRegisterId]	= nil;
		if (tbEvent.uActiveTime ~= uCurrentTime) then
			self.tbTimeTable[tbEvent.uActiveTime][tbEvent.nIdx]	= nil;
		end
		if (tbEvent.OnDestroy) then	-- 需要通知销毁
			tbEvent:OnDestroy(nRegisterId);
		end
	end

	self.tbTimeTable[uCurrentTime]	= nil;
	self.tbToBeClose				= nil;
end


function Timer:UpdateTimerFrame(nChangeFrame)
	local tbTemp = {}
	for nFrame, tbTime in pairs(self.tbTimeTable) do
		tbTemp[nChangeFrame + nFrame] = tbTime;
		for nIdx, nRegisterId in pairs(tbTime) do
			if self.tbRegister[nRegisterId] then
				self.tbRegister[nRegisterId].uActiveTime = self.tbRegister[nRegisterId].uActiveTime + nChangeFrame;
			end
		end
	end
	
	self.tbTimeTable = tbTemp;
end

--注册新Timer，
--	参数：nWaitTime（从现在开始的桢数）, fnCallBack, varParam1, varParam2, ...
--	返回：nRegisterId
function Timer:Register(nWaitTime, ...)
	local arg = {...};
	local tbEvent	= {
		nWaitTime	= nWaitTime,
		tbCallBack	= arg,
		szRegInfo	= debug.traceback("Register Timer", 2),
	};
	return self:RegisterEx(tbEvent);
end

-- 注册新Timer，进阶版
function Timer:RegisterEx(tbEvent)
	assert(tbEvent.nWaitTime > 0);
	tbEvent.uActiveTime	= RegisterTimerPoint(tbEvent.nWaitTime)	-- 注册并得到新的触发时刻
	Timer.nHaveUsedTimerId = Timer.nHaveUsedTimerId + 1;
	local nRegisterId	= Timer.nHaveUsedTimerId;
	self.tbRegister[nRegisterId] = tbEvent;
	local tbNewTime	= self.tbTimeTable[tbEvent.uActiveTime];
	if (not tbNewTime) then	-- 此时刻尚无注册
		self.tbTimeTable[tbEvent.uActiveTime] = {nRegisterId};
		tbEvent.nIdx 			= 1;
	else	-- 此时刻已有注册
		tbEvent.nIdx			= #tbNewTime + 1;
		tbNewTime[tbEvent.nIdx]	= nRegisterId;
	end
	return nRegisterId;
end

--关闭Timer
function Timer:Close(nRegisterId)
	if (self.tbAttach[nRegisterId]) then
		print("Close Timer Error:", debug.traceback());
	end;

	local tbEvent	= self.tbRegister[nRegisterId];
	if not tbEvent then
		print("CloseTimerWarring", debug.traceback());
		return;
	end
	if (self.tbToBeClose) then	-- 正在调用Timer，不能直接关闭
		self.tbToBeClose[nRegisterId]	= 1;
	else
		self.tbTimeTable[tbEvent.uActiveTime][tbEvent.nIdx] = nil;
		self.tbRegister[nRegisterId] = nil;
		if (tbEvent.OnDestroy) then	-- 需要通知销毁
			tbEvent:OnDestroy(nRegisterId);
		end
	end
end

--察看指定的Timer剩余多少桢触发
function Timer:GetRestTime(nRegisterId)
	local tbEvent	= self.tbRegister[nRegisterId];
	if (not tbEvent) then
		return -1;
	else
		return tbEvent.uActiveTime - GetFrame();
	end
end

--察看指定的Timer启动计时时间
function Timer:GetWaitTime(nRegisterId)
	local tbEvent	= self.tbRegister[nRegisterId];
	if (not tbEvent) then
		return -1;
	else
		return tbEvent.nWaitTime;
	end
end

do return end
---------------- 以下是范例 ----------------

function SomeEvent:OnTimer()	-- 时间到，会调用此函数
	if (XXX) then
		-- 返回正数，表示要保持此Timer，等待123桢后再次调用
		return 123;
	elseif (YYY) then
		-- 返回0，表示要关闭此Timer
		return 0;
	else
		-- 返回nil，表示等待时间与上次相同
		return;
	end
end

function SomeEvent:Begin()
	-- 开启计时器，记录nRegisterId
	self.nRegisterId	= Timer:Register(1, self.OnTimer, self);
end

function SomeEvent:Stop()
	-- 查看剩余桢数
	print(Timer:GetRestTime(self.nRegisterId))
	-- 关闭计时器
	Timer:Close(self.nRegisterId);
end


-- 定时器 回调函数返回 true 则继续按照原来延迟继续循环，返回 nil或者 false则关闭定时器
Log("start timer test");
local nID = Timer:Register(15 * 3, function ()
	Log("11111111111")
	return true;
end)

Timer:Register(15 * 10, function ()
	Timer:Close(nID);
	Log("close timer");
end)
