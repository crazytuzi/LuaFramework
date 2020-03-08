
function TimeFrame:LoadSetting()
	local tbFile = LoadTabFile("Setting/timeframe_New.tab", "ssdddd", nil, {"MainFrame", "SubFrame", "DurationDays", "OpenDay", "OpenTime", "NewMaxLevel"});

	self.tbAllMainTimeFrame = {};
	self.tbAllTimeFrame = {};
	self.tbOpenNewMaxLevelTimeFrame = {};
	local szPreMainTimeFrame = nil;
	local szMainTimeFrame = nil;
	local nOpenDayToOpenServerTime = 1;
	local nMainFrameDurationDays = 0;
	local tbNextTimeFrameInfo = {};
	for _, tbRow in ipairs(tbFile) do
		local tbTimeFrame = {};
		tbTimeFrame.bIsMainFrame = not Lib:IsEmptyStr(tbRow.MainFrame);
		tbTimeFrame.szEvent = tbTimeFrame.bIsMainFrame and tbRow.MainFrame or tbRow.SubFrame;
		tbTimeFrame.nOpenDayTime = math.floor(tbRow.OpenTime / 100) * 3600 + (tbRow.OpenTime % 100) * 60;

		if tbRow.NewMaxLevel > 0 then
			tbTimeFrame.nMaxLevel = tbRow.NewMaxLevel;
			table.insert(self.tbOpenNewMaxLevelTimeFrame, tbTimeFrame);
		end

		if tbTimeFrame.bIsMainFrame then
			assert(Lib:IsEmptyStr(tbRow.SubFrame));

			szPreMainTimeFrame = szMainTimeFrame;
			szMainTimeFrame = tbTimeFrame.szEvent;
			if szPreMainTimeFrame then
				tbNextTimeFrameInfo[szPreMainTimeFrame] = szMainTimeFrame;
			end

			tbTimeFrame.nDurationDays = tbRow.DurationDays;
			nMainFrameDurationDays = tbRow.DurationDays;

			tbTimeFrame.nOpenDayToOpenServerTime = nOpenDayToOpenServerTime;

			--开了时间轴的当天就是此时间轴的第一天，所以减一
			nOpenDayToOpenServerTime = nOpenDayToOpenServerTime + tbTimeFrame.nDurationDays - 1;

			table.insert(self.tbAllMainTimeFrame, {tbTimeFrame.szEvent, tbTimeFrame.nOpenDayToOpenServerTime, tbTimeFrame.nOpenDayTime});

			-- 第一个住时间轴，必须为第一天0点
			if nOpenDayToOpenServerTime == tbTimeFrame.nDurationDays then
				tbTimeFrame.nOpenDayTime = 0;
				tbTimeFrame.bFirstTimeFrame = true;
			end
		else
			assert(not Lib:IsEmptyStr(tbRow.SubFrame));
			tbTimeFrame.nOpenDay = tbRow.OpenDay;

			tbTimeFrame.nOpenDayToOpenServerTime = nOpenDayToOpenServerTime - nMainFrameDurationDays + tbRow.OpenDay;
		end

		tbTimeFrame.szPreMainTimeFrame = szPreMainTimeFrame;
		tbTimeFrame.szMainTimeFrame = szMainTimeFrame;

		self.tbAllTimeFrame[tbTimeFrame.szEvent] = tbTimeFrame;
	end

	for _, tbInfo in pairs(self.tbAllTimeFrame) do
		tbInfo.szNextMainTimeFrame = tbNextTimeFrameInfo[tbInfo.szMainTimeFrame];
	end

	-- 最后一个主时间轴持续时间设大点
	local szLastMainTimeFrame = self.tbAllMainTimeFrame[#self.tbAllMainTimeFrame][1];
	self.tbAllTimeFrame[szLastMainTimeFrame].nDurationDays = 999999;
end

TimeFrame:LoadSetting();


-- 根据天数和时间
function TimeFrame:CalcTime(nDay, nTime, nOpenDayTime)
	if not nOpenDayTime then
		nOpenDayTime = self:GetServerCreateTime();
	end

	-- 此处获取了，带有服务器所在时区的，开服当天0点的时间戳
	local nOpenDayZeroTime = nOpenDayTime - ((nOpenDayTime + Lib:GetGMTSec()) % (3600 * 24));

	-- 开服当天实际是第0天，配置表里第一天代表开服当天，所以 减一
	nDay = nDay - 1;

	return nOpenDayZeroTime + nDay * 24 * 3600 + nTime;
end

function TimeFrame:CalcNewTimeFrameInfo()
	local nTimeNow = GetTime();
	local nOpenServerTime = self:GetServerCreateTime();

	local nCurMainFrameOpenTime = nOpenServerTime;
	local szCurMainTimeFrame = self.tbAllMainTimeFrame[1][1];
	if nTimeNow - nOpenServerTime <= 24 * 3600 then
		nCurMainFrameOpenTime = self:CalcTime(self.tbAllMainTimeFrame[1][2], self.tbAllMainTimeFrame[1][3], nOpenServerTime);
		return szCurMainTimeFrame, nCurMainFrameOpenTime;
	end

	local tbOldTimeFrameInfo = LoadTabFile("Setting/timeframe.tab", "sddd", "Event", {"Event", "OpenDay", "OpenTime", "NewMaxLevel"});

	for _, tbInfo in ipairs(self.tbAllMainTimeFrame) do
		local tbOldInfo = tbOldTimeFrameInfo[tbInfo[1]];
		if tbOldInfo then
			local nOldOpenTime = self:CalcTime(tbOldInfo.OpenDay, tbOldInfo.OpenTime);
			if nOldOpenTime > nTimeNow then
				break;
			end

			szCurMainTimeFrame = tbInfo[1];
			nCurMainFrameOpenTime = nOldOpenTime - ((nOldOpenTime + Lib:GetGMTSec()) % (3600 * 24)) + tbInfo[3];
		end
	end

	return szCurMainTimeFrame, nCurMainFrameOpenTime;
end

function TimeFrame:OnSyncTimeFrameInfo(tbTimeFrameInfo)
	if not MODULE_GAMECLIENT then
		return;
	end

	self.__tbTimeFrameInfo = tbTimeFrameInfo;
	self:Init();
end

function TimeFrame:GetCurMainTimeFrameInfo()
	local tbTimeFrameInfo = nil;
	if MODULE_GAMESERVER then
		tbTimeFrameInfo = ScriptData:GetValue("TimeFrame");
		-- 测试代码
		--tbTimeFrameInfo = {};
		if not tbTimeFrameInfo.szCurMainTimeFrame then
			tbTimeFrameInfo.szCurMainTimeFrame, tbTimeFrameInfo.nCurMainFrameOpenTime = self:CalcNewTimeFrameInfo();
			ScriptData:SaveValue("TimeFrame", tbTimeFrameInfo)
		end
	elseif MODULE_GAMECLIENT then
		tbTimeFrameInfo = self.__tbTimeFrameInfo;
	end

	return tbTimeFrameInfo.szCurMainTimeFrame, tbTimeFrameInfo.nCurMainFrameOpenTime;
end

function TimeFrame:InitServerCreateTime()
	local nServerCreateTime = ScriptData:GetValue("dwServerCreateTime");
	if type(nServerCreateTime) == "table" then
		nServerCreateTime = GetTime();
		--nServerCreateTime = nServerCreateTime - 260 * 24 * 3600
		ScriptData:SaveAtOnce("dwServerCreateTime", nServerCreateTime);
	end

	--nServerCreateTime = nServerCreateTime - 260 * 24 * 3600
	SetServerCreateTime(nServerCreateTime);
end

function TimeFrame:GetServerCreateTime()
	return GetServerCreateTime();
end

function TimeFrame:Init()
	if MODULE_GAMESERVER then
		self:InitServerCreateTime();
	end

	local szCurMainTimeFrame, nCurMainFrameOpenTime = self:GetCurMainTimeFrameInfo();
	Log("[TimeFrame]", szCurMainTimeFrame, Lib:GetTimeStr4(nCurMainFrameOpenTime));
	local tbCurMainTimeFrame = self.tbAllTimeFrame[szCurMainTimeFrame];
	local nVirtualOpenServerTime = nCurMainFrameOpenTime - (tbCurMainTimeFrame.nOpenDayToOpenServerTime - 1) * 24 * 3600 - tbCurMainTimeFrame.nOpenDayTime;

	for szTimeFrame, tbInfo in pairs(self.tbAllTimeFrame) do
		tbInfo.nTimeFrameOpenTime = self:CalcTime(tbInfo.nOpenDayToOpenServerTime, tbInfo.nOpenDayTime, nVirtualOpenServerTime);
		if szTimeFrame == szCurMainTimeFrame then
			if nCurMainFrameOpenTime ~= tbInfo.nTimeFrameOpenTime then
				Log(Lib:GetTimeStr4(nCurMainFrameOpenTime), Lib:GetTimeStr4(tbInfo.nTimeFrameOpenTime));
			end
			assert(nCurMainFrameOpenTime == tbInfo.nTimeFrameOpenTime);
		end

		if tbInfo.bFirstTimeFrame and tbInfo.nTimeFrameOpenTime > self:GetServerCreateTime() then
			tbInfo.nTimeFrameOpenTime = Lib:GetTodayZeroHour(self:GetServerCreateTime());
		end
	end

	self.bInit = true;
	self:UpdateMainTimeFrame();
	self:CommonCheck();

	-- 测试代码
	--self:OutputInfo();
end

function TimeFrame:DoCheckTimeFrame(szTimeFrame, nStartTime, szExtInfo)
	local tbTimeFrame = self.tbAllTimeFrame[szTimeFrame];
	if not tbTimeFrame or not tbTimeFrame.szNextMainTimeFrame then
		return;
	end

	local tbNextMainTimeFrame = self.tbAllTimeFrame[tbTimeFrame.szNextMainTimeFrame];
	if nStartTime >= tbNextMainTimeFrame.nTimeFrameOpenTime then
		Log("[TimeFrame] CommonCheck Fail !!", szExtInfo or "", szTimeFrame, Lib:GetTimeStr4(nStartTime), Lib:GetTimeStr4(tbNextMainTimeFrame.nTimeFrameOpenTime));
		Log(debug.traceback());
	end
end

function TimeFrame:CommonCheck()
	for szTimeFrame, tbInfo in pairs(self.tbAllTimeFrame) do
		self:DoCheckTimeFrame(szTimeFrame, tbInfo.nTimeFrameOpenTime);
	end

	Log("[TimeFrame] CommonCheck Finish !!");
end

function TimeFrame:UpdateMainTimeFrame()
	if not MODULE_GAMESERVER or not self.bInit then
		return;
	end

	local tbTimeFrameInfo = ScriptData:GetValue("TimeFrame");
	if not tbTimeFrameInfo.szCurMainTimeFrame then
		tbTimeFrameInfo.szCurMainTimeFrame, tbTimeFrameInfo.nCurMainFrameOpenTime = self:CalcNewTimeFrameInfo();
		ScriptData:SaveAtOnce("TimeFrame", tbTimeFrameInfo);
	end

	local nTimeNow = GetTime();
	local szNewMainTimeFrame = tbTimeFrameInfo.szCurMainTimeFrame;
	for _, tbInfo in ipairs(self.tbAllMainTimeFrame) do
		if self:GetTimeFrameState(tbInfo[1]) == 1 then
			szNewMainTimeFrame = tbInfo[1];
		else
			break;
		end
	end

	if szNewMainTimeFrame ~= tbTimeFrameInfo.szCurMainTimeFrame then
		tbTimeFrameInfo.szCurMainTimeFrame = szNewMainTimeFrame;
		tbTimeFrameInfo.nCurMainFrameOpenTime = self:CalcTimeFrameOpenTime(szNewMainTimeFrame);
		ScriptData:SaveAtOnce("TimeFrame", tbTimeFrameInfo);
		Log("[TimeFrame] UpdateMainTimeFrame", tbTimeFrameInfo.szCurMainTimeFrame, Lib:GetTimeStr4(tbTimeFrameInfo.nCurMainFrameOpenTime));
	end
end

function TimeFrame:CalcTimeFrameOpenTime(szTimeFrame)
	if not self.bInit then
		--Log(debug.traceback());
		return 0;
	end
	if MODULE_GAMECLIENT then
		local nForceOpenTime = Player.tbTimeFrameForceOpen and Player.tbTimeFrameForceOpen[szTimeFrame]
		if nForceOpenTime then
			local nOpenTime = self:GetServerCreateTime()
			nOpenTime = nOpenTime - (nOpenTime + Lib:GetGMTSec()) % (3600 * 24)
			return  nOpenTime + nForceOpenTime;
		end
	end

	return (self.tbAllTimeFrame[szTimeFrame] or {}).nTimeFrameOpenTime or 0;
end

function TimeFrame:GetTimeFrameState(szTimeFrame)
	if not self.bInit then
		--Log(debug.traceback());
		return 0;
	end
	-- if MODULE_GAMECLIENT then
	-- 	if Player.tbTimeFrameForceOpen and Player.tbTimeFrameForceOpen[szTimeFrame] then
	-- 		return 1;
	-- 	end
	-- end

	if self.tbTmpState and self.tbTmpState[szTimeFrame] then
		return self.tbTmpState[szTimeFrame];
	end

	local nOpenTime = self:CalcTimeFrameOpenTime(szTimeFrame);
	if not nOpenTime or nOpenTime <= 0 then
		return 0;
	end

	return nOpenTime > GetTime() and 0 or 1;
end

-- nType: 0 关闭， 1 开启， nil 恢复配置表配置状态
function TimeFrame:SetTimeFrameState(szTimeFrame, nType)
	if not self.tbAllTimeFrame[szTimeFrame] then
		return;
	end

	self.tbTmpState = self.tbTmpState or {};
	self.tbTmpState[szTimeFrame] = nType;
end

function TimeFrame:CalcRealOpenDay(szTimeFrame, nDay)
	if not self.bInit then
		--Log(debug.traceback());
		return 0, 0;
	end
	local nOpenTime = self:CalcTimeFrameOpenTime(szTimeFrame);
	if not nOpenTime then
		return 0;
	end

	nDay = nDay or 1;
	nDay = nDay == 0 and 1 or nDay;

	local nOpenServerTime = self:GetServerCreateTime();
	if nDay > 0 then
		nOpenTime = nOpenTime + (nDay - 1) * 24 * 3600;
	else
		nOpenTime = nOpenTime + nDay * 24 * 3600;
	end
	return math.max(Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay(nOpenServerTime) + 1, 1), nOpenTime;
end

function TimeFrame:OnClientLogout()
	if not MODULE_GAMECLIENT then
		return;
	end

	self.tbTmpState = {};
end

function TimeFrame:GetMaxLevel()
	if not self.bInit then
		--Log(debug.traceback());
		return 39;
	end
	local nMaxLevel = 39;
	for _, tbInfo in ipairs(self.tbOpenNewMaxLevelTimeFrame) do
		if self:GetTimeFrameState(tbInfo.szEvent) == 1 then
			nMaxLevel = tbInfo.nMaxLevel
		else
			break;
		end
	end
	return nMaxLevel;
end

function TimeFrame:OutputInfo()
	for szTimeFrame, tbInfo in pairs(self.tbAllTimeFrame) do
		local nShowTime = math.floor(tbInfo.nOpenDayTime / 3600) * 100 + math.floor((tbInfo.nOpenDayTime % 3600) / 60)
		Log(">>>", szTimeFrame, tbInfo.szMainTimeFrame, tbInfo.nOpenDayToOpenServerTime, nShowTime, tbInfo.nOpenDayTime, tbInfo.nTimeFrameOpenTime, Lib:GetTimeStr4(tbInfo.nTimeFrameOpenTime), Lib:GetTimeStr4(CalcTimeFrameOpenTime(szTimeFrame)));
	end
end